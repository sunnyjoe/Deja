
//
//  AddFriendConfrimNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 24/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class AddFriendConfrimNetTask: DJHTTPNetTask {
    var friendUid : String?
    
    override func uri() -> String!
    {
        return "apis_bm/friend/accept_request/v4"
    }
    
    class func uri() -> String!
    {
        return "apis_bm/friend/accept_request/v4"
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
        
    }
    
    override func didFail(error: NSError!)
    {
        
    }
}
