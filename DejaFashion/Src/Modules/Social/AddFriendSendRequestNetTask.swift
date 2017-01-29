//
//  AddFriendSendRequestNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 24/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class AddFriendSendRequestNetTask: DJHTTPNetTask {
    var friendUid : String?
    var name : String?

    override func uri() -> String!
    {
        return "/apis_bm/friend/send_friend_request/v4"
    }
    
    class func uri() -> String!
    {
        return "/apis_bm/friend/send_friend_request/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        if friendUid != nil
        {
            dic["buddy_uid"] = friendUid!
        }
        
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            let n = self.name == nil ? "she" : self.name!
            appDelegate.registerForAPN(DJStringUtil.localize("Invitation was sent!", comment:""),withDesc:DJStringUtil.localize("Would you like to be alerted when \(n) join?", comment:""))
        }
    }
    
    override func didFail(error: NSError!)
    {
        
    }
}
