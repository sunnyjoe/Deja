//
//  AddByPatternNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 3/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class AddByPatternNetTask: DJHTTPNetTask {
    var imageData : NSData?
    
    var clothesList = [Clothes]()
    var mark = ""
    var categoryIds = [String]()
    
    var end = false
    var total = 0
    
    override func uri() -> String!
    {
        return "apis_bm/product/get_by_pattern_init/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func files() -> [NSObject : AnyObject]! {
        if imageData != nil
        {
            var dic = Dictionary<String , AnyObject>()
            dic["file"] = imageData
            return dic
        }
        return nil
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let dic = response["first_page"] as? NSDictionary
        {
            if let data = dic["data"] as? NSArray {
                clothesList = Clothes.parseClothesList(data)
            }
        }
        if let mark = response["mark"] as? String
        {
            self.mark = mark
        }
        if let categoryIds = response["sorted_categories"] as? [String]
        {
            self.categoryIds = categoryIds
        }
    }
    
    override func didFail(error: NSError!)
    {
        
    }
}
