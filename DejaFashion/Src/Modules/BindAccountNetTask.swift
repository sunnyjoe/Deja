//
//  BindAccountNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 2/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
import SwiftyJSON

class BindAccountNetTask: DJHTTPNetTask {
    var facebookInfo : FacebookInfo?
        
    override func uri() -> String!
    {
        return "apis_bm/account/bind/v4"
    }
    
    class func uri() -> String!
    {
        return "apis_bm/account/bind/v4"
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
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let _ = self.facebookInfo{
        }
        
        let json = JSON(response)

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
        
    }
    
    
    override func didFail(error: NSError!)
    {
        
    }
    
}
