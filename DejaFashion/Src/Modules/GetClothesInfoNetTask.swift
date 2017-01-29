//
//  GetClothesInfoNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 24/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

class GetClothesInfoNetTask: DJHTTPNetTask {
    var clothedIds : [String]?
    
    var clothesList : [Clothes]?
    
    override func uri() -> String!
    {
        return "apis_bm/product/get_tryon_infos/v4"
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        
        if let cids = self.clothedIds
        {
            dic["product_ids"] = cids.joinWithSeparator(",")
        }
        
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSArray
        {
            
            var temporary = [NSDictionary]()
            
            for node in data
            {
                temporary.append(node as! NSDictionary)
                
            }
            self.clothesList = Clothes.parseClothesList(temporary)
        }
        
    }
    
    
    override func didFail(error: NSError!)
    {
        
    }
}
