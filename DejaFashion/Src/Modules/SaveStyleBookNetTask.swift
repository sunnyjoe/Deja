//
//  SaveStyleBookNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 22/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

class SaveStyleBookNetTask: DJHTTPNetTask {
    var clothedIds : [String]?
    
    var tmplate : String?
 
    override func uri() -> String!
    {
        return "apis_bm/outfit/add_to_outfitbook/v4"
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
        
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSDictionary
        {
            self.tmplate = data["tip"] as? String
        }
    }
    
    
    override func didFail(error: NSError!)
    {
        
    }

}
