//
//  LoginNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation
import SwiftyJSON

class FacebookInfo : NSObject
{
    var token : String?
}

class GooglePlusInfo : NSObject
{
    var token : String?
}

class TwitterInfo : NSObject
{
    var token : String?
}

class SMSInfo : NSObject
{
    var sessionId : String?
    var otpCode : String?
}


class LoginNetTask: DJHTTPNetTask
{
    var facebookInfo : FacebookInfo?
    var googlePlusInfo : GooglePlusInfo?
    var twitterInfo : TwitterInfo?
    var smsInfo : SMSInfo?
    
    override func uri() -> String!
    {
        return LoginNetTask.uri()
    }
    
    class func uri() -> String!
    {
        return "apis_bm/account/login/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        if let fbinfo = self.facebookInfo
        {
            dic["third_party_id"] = 1;//facebook
            var info = [String:String]()
            info["access_token"] = fbinfo.token
            dic["third_party_info"] = info
        }
        else if let gplusinfo = self.googlePlusInfo
        {
            dic["third_party_id"] = 2;//google plus
            var info = [String:String]()
            info["access_token"] = gplusinfo.token
            dic["third_party_info"] = info
        }
        else if let twitterInfo = self.twitterInfo
        {
            dic["third_party_id"] = 3;//google plus
            var info = [String:String]()
            info["access_token"] = twitterInfo.token
            dic["third_party_info"] = info
        }else if smsInfo != nil
        {
            dic["third_party_id"] = 5
            var info = [String:String]()
            info["session_id"] = smsInfo?.sessionId
             info["otp_code"] = smsInfo?.otpCode
            dic["third_party_info"] = info
        }
        
        if let token = AccountDataContainer.sharedInstance.pushToken {
            dic["device_token"] = token
        }else {
            dic["device_token"] = ""
        }
        
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if facebookInfo != nil {
           AccountDataContainer.sharedInstance.currentAccountType = .Facebook
        }
        
        if smsInfo != nil {
            AccountDataContainer.sharedInstance.currentAccountType = .SMS
        }
        
        DJLoginLogic.clearUserData()
        let json = JSON(response)
        if let uid = json["data"]["uid"].string
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
        }else {
            AccountDataContainer.sharedInstance.userName = ""
        }
        if let avatar = json["data"]["avatar"].string
        {
            AccountDataContainer.sharedInstance.avatar = avatar
        }else {
            AccountDataContainer.sharedInstance.avatar = ""
        }
        if let cartId = json["data"]["cart_id"].string
        {
            AccountDataContainer.sharedInstance.cartId = cartId
        }else {
            AccountDataContainer.sharedInstance.cartId = ""
        }
        if let email = json["data"]["email"].string
        {
            AccountDataContainer.sharedInstance.email = email
        }
        if let gender = json["data"]["gender"].string
        {
            AccountDataContainer.sharedInstance.gender = gender
        }
        if let bindParties = json["data"]["bind_parties"].arrayObject {
            var infos = [BindInfo]()
            for i in bindParties {
                if let id = i["thirdPartyId"]?.integerValue {
                    let info = BindInfo()
                    let dictionary = i as? NSDictionary
                    info.identifier = dictionary?["identifier"] as? String
                    info.partyId = id
                    infos.append(info)
                }
            }
            AccountDataContainer.sharedInstance.bindInfos = infos
        }else {
            AccountDataContainer.sharedInstance.bindInfos = nil
        }
        
        DJUserFeedbackLogic.instance().registerUser()
    }
    
    
    override func didFail(error: NSError!)
    {
        
    }
}
