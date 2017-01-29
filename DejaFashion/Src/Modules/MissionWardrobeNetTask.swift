//
//  MissionWardrobeNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 31/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class MissionWardrobeNetTask: DJHTTPNetTask {
    var missionId : String?
    
    var clothesCateList : [String : [Clothes]]?
    var mustTryCloth : Clothes?
    var occasionId : String?
    
    override func uri() -> String!
    {
        return "apis_bm/fitting_room/get_mission_wardrobe/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod {
        return DJHTTPNetTaskGet
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        
        if missionId != nil
        {
            dic["mission_id"] = missionId!
        }
        
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["products"] as? NSDictionary
        {
            self.clothesCateList = Clothes.parseClothesToCategory(data)
        }
//        FIXME() //delete test musttrycloth
//        let keys = self.clothesCateList?.keys
//        for oneKey in keys!{
//            if let cc = clothesCateList![oneKey]{
//                if cc.count > 1{
//                    mustTryCloth = cc[0]
//                }
//            }
//        }
        if let data = response["must_have_cloth"] as? NSDictionary
        {
            self.mustTryCloth = Clothes.parseClothes(data)
        }
        if let data = response["occasion_id"] as? String
        {
            self.occasionId = data
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
    
}
