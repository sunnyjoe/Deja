
//
//  SocialDataContainer.swift
//  DejaFashion
//
//  Created by jiao qing on 22/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

let kDJSocialUpdateMark = "kDJSocialUpdateMark"

let addressBookTable = TableWith("AddressBook", type: ABContact.self, primaryKey: "phoneNumber", dbName: "AddressBook")
let dejaUserTable = TableWith("DejaContact", type: DejaContact.self, primaryKey: "uid", dbName: "DejaContact")

class SocialDataContainer: NSObject {
    static let sharedInstance = SocialDataContainer()
    
    func updateAddressBook(contacts : [ABContact]){
        addressBookTable.deleteAll()
        addressBookTable.saveAll(contacts)
    }
    
    func updateDejaContact(contacts : [DejaContact]){
        dejaUserTable.deleteAll()
        dejaUserTable.saveAll(contacts)
    }
    
    func getAllABContacts() -> [ABContact]{
        return  addressBookTable.queryAll()
    }
    
    func getAllDejaContacts() -> [DejaContact]{
        return  dejaUserTable.queryAll()
    }
    
    func getAllPhoneNumbers() -> [String]{
        let allAB = getAllABContacts()
        var result = [String]()
        for oneAB in allAB{
            result.append(oneAB.phoneNumber)
        }
        return result
    }
    
    func getMergedContacts() -> [Contact]{
        let allAB = getAllABContacts()
        let dejaContacts = getAllDejaContacts()
        
        var contacts = [Contact]()
        for oneAB in allAB{
            let oneCC = Contact()
            contacts.append(oneCC)
            var phoneName = ""
            if oneAB.firstName.characters.count > 0{
                phoneName = "\(oneAB.firstName)"
            }
            if oneAB.lastName.characters.count > 0{
                phoneName = "\(phoneName) \(oneAB.lastName)"
            }
            oneCC.phoneName = phoneName
            oneCC.phoneNumber = oneAB.phoneNumber
            if oneAB.imageData != nil{
                oneCC.phoneImage = UIImage(data: oneAB.imageData!)
            }
            
            for oneD in dejaContacts{
                if oneD.phoneNumber == oneAB.phoneNumber{
                    oneCC.uid = oneD.uid
                    oneCC.fbName = oneD.fbName
                    oneCC.fbImageUrl = oneD.fbImageUrl
                    
                    oneCC.dejaName = oneD.dejaName
                    oneCC.dejaImageUrl = oneD.dejaImageUrl
                    
                    if let rS = oneD.relationStatus{
                        oneCC.relationStatus = getRelationStatusFromNumber(rS)
                    }
                    break
                }
            }
        }
        
        for oneD in dejaContacts{
            if oneD.phoneNumber == nil && oneD.fbName != nil{
                let oneCC = Contact()
                contacts.append(oneCC)
                
                oneCC.uid = oneD.uid
                oneCC.dejaName = oneD.dejaName
                oneCC.dejaImageUrl = oneD.dejaImageUrl
                
                oneCC.fbImageUrl = oneD.fbImageUrl
                oneCC.fbName = oneD.fbName
                
                if let rS = oneD.relationStatus{
                    oneCC.relationStatus = getRelationStatusFromNumber(rS)
                }
            }
        }
        contacts.sortInPlace({ $0.uid > $1.uid })
        return contacts
    }
    
    func getRelationStatusFromNumber(ns : NSNumber) -> RelationStatus{
        if let status = RelationStatus(rawValue: ns.integerValue) {
            return status
        }
        return .notDetermined
    }
    
    func reStoreAddressBook(completion : () -> Void){
        dispatch_async(dispatch_get_main_queue(), {
            addressBookTable.deleteAll()
        })
        let getAB = DJGetAddressBook()
        getAB.getContacts({
            if let ret = getAB.contacts{
                let retA = ret as Array
                let contacts = retA as! [ABContact]
                
                dispatch_async(dispatch_get_main_queue(), {
                    addressBookTable.saveAll(contacts)
                    completion()
                })
            }
        })
    }
    
    func checkAddressBookChanges(change : () -> Void, same : () -> Void){
        let getAB = DJGetAddressBook()
        getAB.getContacts({
            if let ret = getAB.contacts{
                dispatch_async(dispatch_get_main_queue(), {
                    let retA = ret as Array
                    let contacts = retA as! [ABContact]
                    let storedC = self.getAllABContacts()
                    
                    self.updateAddressBook(contacts)
                    if contacts.count != storedC.count{
                        change()
                    }else{
                        var conStrs = [String]()
                        for oneC in contacts{
                            conStrs.append(oneC.phoneNumber)
                        }
                        var storeStrs = Set<String>()
                        for oneC in storedC{
                            storeStrs.insert(oneC.phoneNumber)
                        }
                        
                        var isSame = true
                        for oneStr in conStrs{
                            let index = storeStrs.indexOf(oneStr)
                            if index == nil{
                                isSame = false
                                break
                            }
                        }
                        if isSame{
                            same()
                        }else{
                            change()
                        }
                    }
                })
            }})
    }
    
    func parseDejaContact(data : NSArray) -> [DejaContact]{
        var ret = [DejaContact]()
        for oneData in data{
            if let dic = oneData as? NSDictionary
            {
                let oneCT = DejaContact()
                ret.append(oneCT)
                
                if let tmp = dic["uid"]{
                    oneCT.uid = tmp as! String
                }
                if let tmp = dic["name"]{
                    oneCT.dejaName = tmp as? String
                }
                if let tmp = dic["fb_name"]{
                    oneCT.fbName = tmp as? String
                }
                if let tmp = dic["fb_image"]{
                    oneCT.fbImageUrl = tmp as? String
                }
                if let tmp = dic["phone_number"]{
                    oneCT.phoneNumber = tmp as? String
                }
                if let tmp = dic["status"]{
                    let sI = tmp as! NSNumber
                    oneCT.relationStatus = sI
                }
            }
        }
        
        return ret
    }
    
    func parseSearchResult(data : NSArray) -> [Contact]{
        var ret = [Contact]()
        for oneData in data{
            if let dic = oneData as? NSDictionary
            {
                let oneCT = Contact()
                ret.append(oneCT)
                
                if let tmp = dic["uid"]{
                    oneCT.uid = tmp as? String
                }
                if let tmp = dic["name"]{
                    oneCT.dejaName = tmp as? String
                }
                if let tmp = dic["avatar"]{
                    oneCT.dejaImageUrl = tmp as? String
                }
                if let tmp = dic["status"]{
                    let sI = tmp as! NSNumber
                    oneCT.relationStatus = getRelationStatusFromNumber(sI)
                }
            }
        }
        
        return ret
    }
    
    func setContactUpdateMark(updateMark : UInt64){
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(unsignedLongLong: updateMark), forKey: kDJSocialUpdateMark)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getContactUpdateMark() -> UInt64{
        if let tmp = NSUserDefaults.standardUserDefaults().objectForKey(kDJSocialUpdateMark){
            if let theV = tmp as? NSNumber{
                return theV.unsignedLongLongValue
            }
        }
        return 0
    }
}



