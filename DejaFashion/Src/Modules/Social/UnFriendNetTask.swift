//
//  UnFriendNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 28/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class UnFriendNetTask: DJHTTPNetTask {

    var buddyUid : String?
    
    override func uri() -> String! {
        return "apis_bm/friend/unfriend/v4"
    }
    
    class func uri() -> String! {
        return "apis_bm/friend/unfriend/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = [NSObject : AnyObject]()
        if let id = buddyUid {
            dic["buddy_uid"] = id
        }
        return dic
    }
}
