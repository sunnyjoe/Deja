//
//  GetRecommendBrandsNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 21/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class RecommendBrandInfo {
    var newArrivals : Int = 0
    var backgroudImages = ""
    var brandInfo = BrandInfo()
}

class GetRecommendBrandsNetTask: DJHTTPNetTask {
    var recommendBrands = [RecommendBrandInfo]()
    
    override func uri() -> String!
    {
        return "apis_bm/product/get_new_arrival_of_brands/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskGet
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        return Dictionary<String , AnyObject>()
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let array = response["data"] as? NSArray
        {
            recommendBrands = [RecommendBrandInfo]()
            for i in array {
                if let dic = i as? NSDictionary {
                    if let tmp = dic["brand_info"] as? NSDictionary{
                        let brand = RecommendBrandInfo()
                        recommendBrands.append(brand)
                        
                        brand.brandInfo = BrandInfo.parseDicToBrandInfo(tmp)
                        if let number = dic["new_arrvial_count"] as? Int {
                            brand.newArrivals = number
                        }
                        if let image = dic["background_image"] as? String {
                            brand.backgroudImages = image
                        }
                    }
                }
            }//end array
        }
        
    }
    
    override func didFail(error: NSError!)
    {
    }
}
