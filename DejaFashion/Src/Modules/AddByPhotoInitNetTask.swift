//
//  AddByPhotoInitNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 3/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class AddByPhotoInitNetTask: DJHTTPNetTask {
    var templateId : String?
    var imageData : NSData?
 
    var clothesList = [Clothes]()
    var mark : String?
    var total : Int?
    
    override func uri() -> String!
    {
        return "apis_bm/product/get_by_photo_init/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        if templateId != nil
        {
            dic["template_id"] = templateId!
        }
        
        return dic
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
        
        if let data = response["data"] as? NSArray
        {
            clothesList = Clothes.parseClothesList(data)
        }
        if let data = response["mark"] as? String
        {
            mark = data
        }
        if let number = response["total"] as? Int{
            total = number
        }else{
            total = nil
        }
    }
    
    override func didFail(error: NSError!)
    {
        
    }
}
