//
//  ChangeProfileNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 1/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

class ChangeProfileNetTask: DJHTTPNetTask {
    var imageURL : String?
    var newName : String?
    
    override func uri() -> String! {
        return "apis_bm/account/change_profile/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = [NSObject : AnyObject]()
        if imageURL != nil {
            dic["avatar"] = imageURL
        }
        if newName != nil {
            dic["name"] = newName
        }
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let url = response["avatar"] as? String {
            AccountDataContainer.sharedInstance.avatar = url
        }
        
        if let name = newName {
            AccountDataContainer.sharedInstance.userName = name
        }
    }
    
    override func didFail(error: NSError!) {
        _Log("ChangeProfileNetTask error.code = \(error.code)" )
    }
}
