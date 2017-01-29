//
//  SearchNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 15/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

class SearchNetTask: FilterableNetTask {

    var clothesList : [Clothes]?
    
    var isAnd = false
 
    var trySearchKeywords : [String]?
    
    override func uri() -> String! {
        return "apis_bm/product/search/v4"
    }
    
    class func uri() -> String! {
        return "apis_bm/product/search/v4"
    }
    
    init(keyword : String = "") {
        super.init()
        keyWords = keyword
    }

    override func query() -> [NSObject : AnyObject]! {
        var dic = buildFilterParams()
//        dic["is_and"] = isAnd ? "true" : "false"
        dic["is_and"] = "true"
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let data = response["data"] as? NSArray
        {
            self.clothesList = Clothes.parseClothesList(data)
        }
        
        if let end = response["end"] as? NSNumber {
            ended = end == 1
        }
        
        if let number = response["total_brand"] as? Int {
            fromBrandNumber = number
        }else{
            fromBrandNumber = nil
        }
        
        if let trySearchArray = response["try_search"] as? NSArray {
            trySearchKeywords = [String]()
            for trySearch in trySearchArray {
                if let array = trySearch as? NSArray {
                    var a = [String]()
                    for item in array {
                        if let s = item as? String {
                            a.append(s)
                        }
                    }
                    trySearchKeywords?.append(a.joinWithSeparator(" "))
                }
            }
        }
        if let total = response["total"] as? NSNumber {
            self.total = total.integerValue
        }
    }
    
    
    override func didFail(error: NSError!){
    }
}
