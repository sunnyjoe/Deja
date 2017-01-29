//
//  WardrobeDataContainer.swift
//  DejaFashion
//
//  Created by DanyChen on 9/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

private var newAddedClothesIds = Set<String>()

var clothesIdWithNewStreetSnap : String?

extension Clothes {
    var isNewAdded : Bool {
        if isNew {
            return true
        }
        if let id = uniqueID {
            return newAddedClothesIds.contains(id)
        }else {
            return false
        }
    }
    
    var hasNewStreetSnaps : Bool {
        if let id = uniqueID {
            return id == clothesIdWithNewStreetSnap
        }else {
            return false
        }
    }
}


class WardrobeDataContainer: NSObject {
    
    static let sharedInstance = WardrobeDataContainer()
    
    private var categoryMap = [String : ClothCategory]()
    
    private let WardrobeClothesTable = TableWith("wardrobe_clothes", type: Clothes.self, primaryKey: "uniqueID", dbName: "clothes", columns: ["uniqueID", "thumbUrl", "categoryID", "thumbWidth", "thumbHeight", "name", "brandName"])
    
    // temp cache in memory
    private var clothesMap = [String : Clothes]()
    // default by added timestamp
    private var orderMap = [String : UInt64]()
    
    private override init() {
        super.init()
        
        let array = ConfigDataContainer.sharedInstance.getConfigCategory()
        for category in array {
            categoryMap[category.categoryId] = category
        }
        
        self.cachedDataInit()
    }
    
    func newAddedClothNumber() -> Int {
        return newAddedClothesIds.count
    }
    
    func cachedDataInit() {
        let datas = WardrobeSyncLogic.sharedInstance.queryAll()
        for (i, data) in datas.enumerate() {
            if let id = data.id {
                if let clothes = WardrobeClothesTable.querySingle(["uniqueID"], values: [id]) {
                    var ts : UInt64?
                    if let timeStamp = data.ts {
                        ts = UInt64(timeStamp)
                    }
                    if ts == nil {
                        ts = NSDate.currentTimeMillis() + UInt64(i)
                    }
                    clothesMap[id] = clothes
                    orderMap[id] = ts!
//                    print(ts!.description + " " + clothes.uniqueID!)
                }
            }
        }

    }
    
    
    var syncVersion : NSNumber!
    {
        get
        {
            if let ver = DejaUserDefault.userDefault().objectForKey("deja_v3_wardrobe_sync_version")
            {
                return ver as! NSNumber
            }
            return 0
        }
        set
        {
            DejaUserDefault.userDefault().setObject(newValue, forKey: "deja_v3_wardrobe_sync_version")
        }
    }
    
    
    var uploadWardrobeCountTimeStamp : NSNumber!
        {
        get
        {
            if let ver = DejaUserDefault.userDefault().objectForKey("deja_v3_wardrobe_update_count_ts")
            {
                return ver as! NSNumber
            }
            return 0
        }
        set
        {
            DejaUserDefault.userDefault().setObject(newValue, forKey: "deja_v3_wardrobe_update_count_ts")
        }
    }
    
    var wardrobeFirstTimeTutorialShown : Bool {
        get
        {
            return DejaUserDefault.userDefault().boolForKey("deja_v3_wardrobe_tutorial")
        }
        set
        {
            DejaUserDefault.userDefault().setBool(newValue, forKey: "deja_v3_wardrobe_tutorial")
        }
    }
    
    var contactUsRedDotShown : Bool {
        get
        {
            return DejaUserDefault.userDefault().boolForKey("deja_v3_wardrobe_contact_us_red_dot")
        }
        set
        {
            DejaUserDefault.userDefault().setBool(newValue, forKey: "deja_v3_wardrobe_contact_us_red_dot")
        }
    }
    
    var wardrobeTapClothesTutorialShown : Bool {
        get
        {
            return DejaUserDefault.userDefault().boolForKey("deja_v3_wardrobe_tap_clothes_tutorial")
        }
        set
        {
            DejaUserDefault.userDefault().setBool(newValue, forKey: "deja_v3_wardrobe_tap_clothes_tutorial")
        }
    }
    
    var wardrobeStyle : DrawerStyle {
        get
        {
            if let value = DejaUserDefault.userDefault().stringForKey("deja_v3_wardrobe_style") {
                if let style = DrawerStyle(rawValue: value) {
                    return style
                }
                return .Default
            }else {
                return .Default
            }
        }
        set
        {
            DejaUserDefault.userDefault().setObject(newValue.rawValue, forKey: "deja_v3_wardrobe_style")
        }
    }
    
    func addClothesToWardrobe(clothes : Clothes, fromServer : Bool = false, isNew : Bool = true) {
        let mills = NSDate.currentTimeMillis()
        if let cid = clothes.uniqueID
        {
            if let _ = clothesMap[cid] {
                
            }else {
                if isNew {
                    newAddedClothesIds.insert(cid)
                }
                clothesMap[cid] = clothes
                orderMap[cid] = mills
            }
            WardrobeClothesTable.save(clothes)
            WardrobeSyncLogic.sharedInstance.addToWardrobe([(mills, cid)], fromServer: fromServer)
        }
    }
    
    func changeClothesOrder(fromIndex : Int, toIndex : Int, list : [Clothes]) {
        if fromIndex == toIndex {
            return
        }
        
        // exchange the ts of two items
//        print("fromIndex = \(fromIndex) toIndex = \(toIndex)")
        let from = list[fromIndex]
        let to = list[toIndex]
//        print("from --- " + from.uniqueID!)
//        print("to --- " + to.uniqueID!)
        var itemsReordered = [(UInt64, String)]()
        let temp = orderMap[to.uniqueID!]!
//        print("temp --- " + temp.description)

        if fromIndex < toIndex {
            
            for i in (fromIndex + 1...toIndex).reverse()
//            for var i = toIndex; i > fromIndex; i -= 1
            {
                let item = list[i]
                let mills = orderMap[list[i - 1].uniqueID!]!
                
//                print("----------mills = \(mills)")
                
                orderMap[item.uniqueID!] = mills
                itemsReordered.append((mills, item.uniqueID!))
            }
            
            orderMap[from.uniqueID!] = temp
            itemsReordered.append((temp, from.uniqueID!))
        }else {
            
            for i in toIndex ..< fromIndex {
                let item = list[i]
                let mills = orderMap[list[i + 1].uniqueID!]!
                orderMap[item.uniqueID!] = mills
                itemsReordered.append((mills, item.uniqueID!))
            }
            
            orderMap[from.uniqueID!] = temp
            itemsReordered.append((temp, from.uniqueID!))
        }
        
        WardrobeSyncLogic.sharedInstance.updateTsOfItems(itemsReordered)
    }
    
    func addClothesListToWardrobe(clothesList : [Clothes], fromServer : Bool = false) {
        let currentMills = NSDate.currentTimeMillis()
        for (index, clothes) in clothesList.enumerate() {
            if let cid = clothes.uniqueID
            {
                if let _ = clothesMap[cid] {
                    
                }else {
                    newAddedClothesIds.insert(cid)
                    clothesMap[cid] = clothes
                    orderMap[cid] = currentMills + UInt64(index)
                }
            }
        }
        WardrobeSyncLogic.sharedInstance.addToWardrobe(clothesList.map{ (orderMap[$0.uniqueID!]!, $0.uniqueID!) }, fromServer: fromServer)
        WardrobeClothesTable.saveAll(clothesList)
    }
    
    func removeClothesFromWardrobe(clothIds : [String], fromServer : Bool = false) {
        clothIds.forEach { (clothId) -> () in
            clothesMap.removeValueForKey(clothId)
        }
        WardrobeSyncLogic.sharedInstance.removeFromWardrobe(clothIds, fromServer: fromServer)
    }
    
    func queryWardrobe() -> [String: [Clothes]] {
        var result = [String : [Clothes]]()
        let catgories = ConfigDataContainer.sharedInstance.getConfigCategory()
        for category in catgories {
            result[category.name] = [Clothes]()
        }
        let values = clothesMap.values.sort { orderMap[$0.uniqueID!]! > orderMap[$1.uniqueID!]! }
        for summary in values {
            if let cateId = summary.categoryID
            {
                if let categoryName = categoryMap[cateId]?.name {
                    if var array = result[categoryName] {
                        array.append(summary)
                        result[categoryName] = array
                    }else {
                        var newArray = [Clothes]()
                        newArray.append(summary)
                        result[categoryName] = newArray
                    }
                }
            }
        }
        
        result["All"] = queryAll()
        return result
    }
    
    func categoryClothes(list : [Clothes]) -> [String: [Clothes]] {
        var result = [String : [Clothes]]()
        let catgories = ConfigDataContainer.sharedInstance.getConfigCategory()
        for category in catgories {
            result[category.name] = [Clothes]()
        }
        for summary in list {
            if let cateId = summary.categoryID
            {
                if let categoryName = categoryMap[cateId]?.name {
                    if var array = result[categoryName] {
                        array.append(summary)
                        result[categoryName] = array
                    }else {
                        var newArray = [Clothes]()
                        newArray.append(summary)
                        result[categoryName] = newArray
                    }
                }
            }
        }
        
        result["All"] = list
        return result
    }
    
    func queryWardrobeByCategoryName(name : String) -> [Clothes] {
        return queryAll().filter { (clothes) -> Bool in
            if let cid = clothes.categoryID {
               return categoryMap[cid]?.name == name
            }
            return false
        }
    }
    
    func queryAll() -> [Clothes] {
        let values = clothesMap.values.sort { orderMap[$0.uniqueID!]! > orderMap[$1.uniqueID!]! }
        return values
    }
    
    func queryCategoryNameById(id : String) -> String? {
        return categoryMap[id]?.name
    }
    
    func queryCategoryIdByName(name : String) -> String? {
        let array = ConfigDataContainer.sharedInstance.getConfigCategory()
        return array.filter { $0.name == name }.first?.categoryId
    }
    
    func isInWardrobe(clothesId : String) -> Bool{
        if let _ = clothesMap[clothesId] {
            return true
        }else {
            return false
        }
    }
    
    func clear() {
        clothesMap.removeAll()
        syncVersion = 0
    }
    
    func clearNewAddedClothesIds() -> Bool{
        let needRefresh = newAddedClothesIds.count > 0
        newAddedClothesIds.removeAll()
        return needRefresh
    }
    
    func clearNewStreetSnapClothesIds() -> Bool{
        let needRefresh = clothesIdWithNewStreetSnap == nil
        clothesIdWithNewStreetSnap = nil
        return needRefresh
    }
}
