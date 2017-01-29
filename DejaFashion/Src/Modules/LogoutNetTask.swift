//
//  LogoutNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation
import SwiftyJSON


class LogoutNetTask: DJHTTPNetTask
{
    
    class func uri() -> String!
    {
        return "apis_bm/account/logout/v4"
    }
    
    
    override func uri() -> String!
    {
        return "apis_bm/account/logout/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        let dic = Dictionary<String , AnyObject>()
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        let json = JSON(response)
        if let uid = json["uid"].string
        {
            AccountDataContainer.sharedInstance.userID = uid
        }
        AccountDataContainer.sharedInstance.currentAccountType = .Anonymous
        AccountDataContainer.sharedInstance.signature = nil
        AccountDataContainer.sharedInstance.userName = nil
        AccountDataContainer.sharedInstance.avatar = nil
        AccountDataContainer.sharedInstance.cartId = nil
        DJUserFeedbackLogic.instance().unRegisterUser()
    }
    
    
    override func didFail(error: NSError!)
    {
        
    }
}
