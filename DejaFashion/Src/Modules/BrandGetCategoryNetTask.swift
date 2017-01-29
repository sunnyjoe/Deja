//
//  BrandGetCategoryNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 25/5/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class BrandGetCategoryNetTask: DJHTTPNetTask {
    var brandId : String?
    var categoryIds = [String]()
    
    var end = false
    var total = 0
    var newItemsCount = 15
    
    override func uri() -> String!
    {
//        return "/apis_bm/product/get_categories_of_brand/v4"
        return "/apis_bm/product/get_summary_info_of_brand/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskGet
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        if let tmp = brandId{
            dic["brand"] = tmp
            if let tmp = ClothesDataContainer.sharedInstance.checkNewArrivalVersion(tmp){
                dic["last_check_v"] = tmp
            }
        }
//        dic["last_check_v"] = "0"
        return dic
    }

    
//    override func didResponseJSON(response: [NSObject : AnyObject]!)
//    {
//        if let categoryIds = response["data"] as? [String]
//        {
//            self.categoryIds = categoryIds
//        }
//    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSDictionary
        {
            
            if let categoryIds = data["available_categories"] as? [String]
            {
                self.categoryIds = categoryIds
            }
            if let newArrivalCount = data["new_arrvial_count"] as? Int
            {
                self.newItemsCount = newArrivalCount
            }
            if let version = data["last_check_v"] as? String
            {
                if let tmp = brandId
                {
                    ClothesDataContainer.sharedInstance.setCheckNewArrivalVersion(tmp, version:version)
                }
            }
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
    
}
