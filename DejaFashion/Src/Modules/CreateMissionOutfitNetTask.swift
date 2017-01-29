//
//  CreateMissionOutfitNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 30/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class CreateMissionOutfitNetTask: DJHTTPNetTask {

    var clothedIds : [String]?
    var missionId : String?
    
    var missionOutfitId : String?
    
    override func uri() -> String!
    {
        return "/apis_bm/mission/outfit_init/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        
        if let cids = self.clothedIds
        {
            dic["product_ids"] = cids
        }
        
        if let mid = missionId {
            dic["mission_id"] = mid
        }
        
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let missionOutfitId = response["mission_outfit_id"] as? String
        {
            self.missionOutfitId = missionOutfitId
        }
    }
    
    
    override func didFail(error: NSError!)
    {
        
    }
}
