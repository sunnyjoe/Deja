//
//  AddFriendGetStatusNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 22/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class AddFriendGetStatusNetTask: DJHTTPNetTask {
    var phoneNumbers : [String]?
    
    var dejaContacts : [DejaContact]?
    
    var fbExpired = false
    override func uri() -> String!
    {
        return "apis_bm/friend/update_contact_book/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        if phoneNumbers != nil
        {
            dic["contacts"] = phoneNumbers!
        }
        let updateMark = SocialDataContainer.sharedInstance.getContactUpdateMark()
        dic["last_update"] = NSNumber(unsignedLongLong: updateMark)
        
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let dejaCArray = response["data"] as? NSArray
        {
            dejaContacts = SocialDataContainer.sharedInstance.parseDejaContact(dejaCArray)
            SocialDataContainer.sharedInstance.updateDejaContact(dejaContacts!)
        }
        if let mark = response["last_update"] as? NSNumber
        {
            SocialDataContainer.sharedInstance.setContactUpdateMark(mark.unsignedLongLongValue)
        }
        fbExpired = false
        if let ep = response["expired_third_parties"] as? NSArray
        {
            for etp in ep{
                if let theId = etp as? Int{
                    if theId == 1{
                        fbExpired = true
                    }
                }
            }
        }
    }
    
    override func didFail(error: NSError!)
    {
        
    }
    
}
