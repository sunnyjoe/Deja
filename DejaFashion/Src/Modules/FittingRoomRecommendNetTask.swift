//
//  FittingRoomRecommendNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 16/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

class FittingRoomRecommendNetTask: DJHTTPNetTask
{
    var refineIds : [String]?
    var onBodyClothIds : [String]?
    
    var clothesCateList : [String : [Clothes]]?
    
    override func uri() -> String!
    {
        return "apis_bm/fitting_room/get_recommend/v4"
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        
        if self.refineIds?.count > 0
        {
            dic["refine_ids"] = self.refineIds?.joinWithSeparator(",")
        }
        if self.onBodyClothIds?.count > 0
        {
            dic["on_body_product"] = self.onBodyClothIds?.joinWithSeparator(",")
        }
        
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSDictionary
        {
            self.clothesCateList = Clothes.parseClothesToCategory(data)
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
}
