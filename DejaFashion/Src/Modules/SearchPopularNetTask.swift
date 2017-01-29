//
//  SearchPopularNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 15/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//


class SearchPopularNetTask: DJHTTPNetTask {

    var keywords : [String]?
    
    override func uri() -> String! {
        return "apis_bm/product/search_popular/v4"
    }
    
    class func uri() -> String! {
        return "apis_bm/product/search_popular/v4"
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        keywords = response["data"] as? [String]
    }
    
    
    override func didFail(error: NSError!)
    {
    }
}
