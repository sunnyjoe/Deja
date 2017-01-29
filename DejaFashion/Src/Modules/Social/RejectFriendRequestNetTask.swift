//
//  RejectFriendRequestNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 29/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class RejectFriendRequestNetTask: DJHTTPNetTask {
    var buddyUid : String?
    
    override func uri() -> String! {
        return "apis_bm/friend/reject_request/v4"
    }
    
    class func uri() -> String! {
        return "apis_bm/friend/reject_request/v4"
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
