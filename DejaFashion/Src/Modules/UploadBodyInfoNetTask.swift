//
//  UploadBodyInfoNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 6/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class UploadBodyInfoNetTask: DJHTTPNetTask {

    override func method() -> DJHTTPNetTaskMethod {
        return DJHTTPNetTaskPost
    }
    
    override func uri() -> String! {
        return "apis_bm/account_setting/update_body_shape/v4"
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = Dictionary<String , AnyObject>()
        let s = FittingRoomDataContainer.sharedInstance.getMyModelInfo().fullBodyShape()
        if s.characters.count >= 5 {
            var config = "s_\(s[0] as String),w_\(s[1] as String),h_\(s[2] as String),"
            if s[3] == "s" {
                config += "a_sl,"
            }else {
                config += "a_st,"
            }
            if s[4] == "s" {
                config += "l_sl"
            }else {
                config += "l_st"
            }
            
            dic["body_shape"] = config
        }
        return dic
    }
}
