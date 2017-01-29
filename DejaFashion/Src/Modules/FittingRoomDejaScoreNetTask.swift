//
//  FittingRoomDejaScoreNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 16/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

class FittingRoomDejaScoreNetTask: DJHTTPNetTask
{
    var clothedIds : [String]?
    var refineIds : [String]?
    
    var score : Int?
    var tips : String?
    var needRefresh = false
    
    override func uri() -> String!
    {
        return "apis_bm/fitting_room/get_score_and_tip/v4"
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        
        if self.clothedIds?.count > 0
        {
            dic["on_body_product"] = self.clothedIds?.joinWithSeparator(",")
        }
        
        if self.refineIds?.count > 0
        {
            dic["refine_ids"] = self.refineIds?.joinWithSeparator(",")
        }
        
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSDictionary
        {
            self.score = data["score"] as? Int
            self.tips = data["tip"] as? String
            if let tmp = data["need_refresh"] as? Int {
                if tmp == 1 {
                    needRefresh = true
                }else{
                    needRefresh = false
                }
            }
        }
    }
    
    override func didFail(error: NSError!)
    {
        
    }
}
