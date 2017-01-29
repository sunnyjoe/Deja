//
//  DynamicGetFiltersNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 26/8/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class DynamicGetFiltersNetTask: FilterableNetTask {
    var retSelectedBrandId : String?
    var retSelectedColorId : String?
    var retSelectedCuttingIds = [String]()
    var retSelectedSubCategoryId : String?
    var retSelectedMinPrice : Int?
    var retSelectedMaxPrice : Int?
    
    var retBrandIds = [String]()
    var retColorIds = [String]()
    var retSubCategoryIds = [String]()
    var retCuttingIds = [String : [String]]()
    var retMinPrice = 0
    var retMaxPrice = 0
    var retTotalItems = 0
    
    override func uri() -> String!
    {
        return "apis_bm/product/get_dynamic_filters/v5"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskGet
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        let dic = buildFilterParams()
        
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSDictionary
        {
            
            if let tmp = data["brand"] as? [String]{
                retBrandIds = tmp
            }
            if let tmp = data["color"] as? [String]{
                retColorIds = tmp
            }
            if let tmp = data["sub_category"] as? [String]{
                retSubCategoryIds = tmp
            }
            print(data["filter_conditions"])
            if let tmp = data["filter_conditions"] as? NSArray{
                retCuttingIds.removeAll()
                for one in tmp {
                    if let dic = one as? NSDictionary{
                        if let theId = dic["id"] as? String{
                            if let theIds = dic["available_filter"] as? [String]{
                                retCuttingIds[theId] = theIds
                            }
                            if let theIds = dic["available_filter_selected"] as? [String]{
                                if theIds.count > 0{
                                    retSelectedCuttingIds.append(theIds[0])
                                }
                            }
                        }
                    }
                }
            }
            
            
            if let tmp = data["price"] as? [Int]{
                if tmp.count >= 2{
                    retMinPrice = tmp[0] / 100
                    retMaxPrice = tmp[1] / 100
                }
            }
            
            if let tmp = data["brand_selected"] as? [String]{
                if tmp.count > 0{
                    retSelectedBrandId = tmp[0]
                }
            }
            if let tmp = data["sub_category_selected"] as? [String]{
                if tmp.count > 0{
                    retSelectedSubCategoryId = tmp[0]
                }
            }
            if let tmp = data["color_selected"] as? [String]{
                if tmp.count > 0{
                    retSelectedColorId = tmp[0]
                }
            }
            if let tmp = data["price_selected"] as? [Int]{
                if tmp.count >= 2{
                    retSelectedMinPrice = tmp[0] / 100
                    retSelectedMaxPrice = tmp[1] / 100
                }
            }
            
            if let tmp = data["total"] as? Int{
                retTotalItems = tmp
            }
        }
        
    }
    
    override func didFail(error: NSError!)
    {
    }
    
}
