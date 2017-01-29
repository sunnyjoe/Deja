
//
//  AddByPhotoMoreOrFilterNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 10/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class AddByPhotoMoreOrFilterNetTask: FilterableNetTask {
    var clothesList = [Clothes]()
     
    func nextPage() -> AddByPhotoMoreOrFilterNetTask
    {
        pageIndex += 1
        return self
    }
    
    override func uri() -> String!
    {
        return "apis_bm/product/get_by_photo_cont/v4"
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
        
        if let data = response["data"] as? NSArray
        {
            clothesList = Clothes.parseClothesList(data)
        }else {
            clothesList = []
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
    
    override func didFail(error: NSError!)
    {
        
    }
}
