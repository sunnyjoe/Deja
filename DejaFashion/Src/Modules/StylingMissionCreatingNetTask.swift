//
//  StylingMissionCreatingNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 29/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class StylingMissionCreatingNetTask: DJHTTPNetTask {

    var desc = ""
    var clothesId : String?
    var occasionId : String?
    
    override func uri() -> String! {
        return "apis_bm/mission/mission_submit/v4"
    }
    
    class func uri() -> String! {
        return "apis_bm/mission/mission_submit/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = [NSObject : AnyObject]()
        dic["description"] = desc
        if let id = clothesId {
            dic["must_have_cloth_id"] = id
        }
        if let id = occasionId {
            dic["occasion_id"] = id
        }
        return dic
    }
    

}
