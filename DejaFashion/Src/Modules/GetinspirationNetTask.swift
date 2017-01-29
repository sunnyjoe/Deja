

//
//  GetinspirationNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 24/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class GetinspirationNetTask: DJHTTPNetTask {
    var refineIds : [String]?
    var clothesList : [Clothes]?
    
    override func uri() -> String!
    {
        return "apis_bm/fitting_room/get_inspiration/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod {
        return DJHTTPNetTaskGet
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        
        if self.refineIds?.count > 0
        {
            dic["refine_ids"] = self.refineIds?.joinWithSeparator(",")
        }
        
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSArray
        {
            self.clothesList = Clothes.parseClothesList(data)
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
    
}
