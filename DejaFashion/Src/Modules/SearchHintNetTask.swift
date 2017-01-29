//
//  SearchHintNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 15/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//


class SearchHintNetTask: DJHTTPNetTask {
    
    var keyword : String
    
    override func uri() -> String! {
        return "apis_bm/product/search_hint/v4"
    }
    
    class func uri() -> String! {
        return "apis_bm/product/search_hint/v4"
    }
    
    init(keyword : String) {
        self.keyword = keyword
        super.init()
    }
    
    var keywords : [String]?
    
    override func query() -> [NSObject : AnyObject]! {
        return ["query" : keyword]
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        keywords = response["data"] as? [String]
    }
    
    
    override func didFail(error: NSError!)
    {
    }

}
