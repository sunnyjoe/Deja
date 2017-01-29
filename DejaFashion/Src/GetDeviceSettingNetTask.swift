//
//  GetDeviceSettingNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 7/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation
import SwiftyJSON

class GetDeviceSettingNetTask: DJHTTPNetTask
{
    
    class func uri() -> String!
    {
        return "/apis_bm/account_setting/get_push_noti_property/v4"
    }
    
    
    override func uri() -> String!
    {
        return "/apis_bm/account_setting/get_push_noti_property/v4"
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        dic["types"] = "deal_alert"
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        let json = JSON(response)
        let dealAlert = json["data"]["deal_alert"].intValue
        DJConfigDataContainer.instance().pushControlDealAlertOn = (dealAlert == 1)
    }
    
    
    override func didFail(error: NSError!)
    {
        
    }
}
