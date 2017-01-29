//
//  RegisterNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation
import SwiftyJSON


class RegisterNetTask: DJHTTPNetTask {
    
    override func uri() -> String! {
        return "apis_bm/account/register/v4"
    }
    
    class func uri() -> String! {
        return "apis_bm/account/register/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        
        if let token = AccountDataContainer.sharedInstance.pushToken {
            dic["device_token"] = token
        }else {
            dic["device_token"] = ""
        }
        
        // add the token
        return dic
    }

    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        
        let json = JSON(response)
        
        if AccountDataContainer.sharedInstance.userID?.characters.count > 0 {
            return
        }
        
        if let uid = json["uid"].string
        {
            AccountDataContainer.sharedInstance.userID = uid
        }
        
        if let sig = json["data"]["sig"].string
        {
            AccountDataContainer.sharedInstance.signature = sig
        }
        
        if let name = json["data"]["name"].string
        {
            AccountDataContainer.sharedInstance.userName = name
        }
        
        if let avatar = json["data"]["avatar"].string
        {
            AccountDataContainer.sharedInstance.avatar = avatar
        }
        
        if let cartId = json["data"]["cart_id"].string
        {
            AccountDataContainer.sharedInstance.cartId = cartId
        }
        
        AccountDataContainer.sharedInstance.currentAccountType = .Anonymous
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            if sharedWebView?.superview == nil {
                appDelegate.resetWebView()
            }
        }
    }
    
    override func didFail(error: NSError!)
    {
        
    }
}
