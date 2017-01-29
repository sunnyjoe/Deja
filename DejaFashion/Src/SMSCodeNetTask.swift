//
//  SMSCodeNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 3/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class SMSCodeNetTask: DJHTTPNetTask {
    var photoNumber : String?
    
    var sessionId : String?
    override func uri() -> String! {
        return "apis_bm/account/send_sms_otp/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = [NSObject : AnyObject]()
        if photoNumber != nil {
            dic["phone_number"] = photoNumber!
        }
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let data = response as? [String : AnyObject]
        {
            if let sd = data["session_id"] {
                sessionId = sd as? String
            }
        }
    }
    
    override func didFail(error: NSError!) {
    }
}
