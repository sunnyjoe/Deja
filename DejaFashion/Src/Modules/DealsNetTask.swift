//
//  DealsNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 30/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class DealsNetTask: FilterableNetTask {
    var clothesList : [Clothes]?
    
    override func uri() -> String! {
        return "apis_bm/product/get_by_filter_deal/v4"
    }
    
    override func query() -> [NSObject : AnyObject]! {
        return buildFilterParams()
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        
        if let data = response["data"] as? NSArray
        {
            self.clothesList = Clothes.parseClothesList(data)
        }
        
        if let end = response["end"] as? NSNumber {
            ended = end == 1
        }
        
        if let total = response["total"] as? NSNumber {
            self.total = total.integerValue
        }
    }
    
    
    override func didFail(error: NSError!)
    {
        //        self.handleFakeClothes()
    }
}
