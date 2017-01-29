//
//  AddByPatternMoreNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 9/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

let ByPatternURL = "apis_bm/product/get_by_pattern_cont/v4"

class AddByPatternMoreNetTask: FilterableNetTask {

    var clothesList = [Clothes]()
    
    var mainCategory = 0
    
    override func uri() -> String!
    {
        return ByPatternURL
    }
    
    class func uri() -> String!
    {
        return ByPatternURL
    }
    
    override func query() -> [NSObject : AnyObject]! {
        let dic = buildFilterParams()
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        
        if let data = response["data"] as? NSArray
        {
            clothesList = Clothes.parseClothesList(data)
        }
        if let data = response["end"] as? Bool
        {
            ended = data
        }
        if let data = response["total"] as? Int
        {
            total = data
        }
    }
}
