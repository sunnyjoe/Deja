//
//  FeedbackNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation


class FeedbackNetTask: DJHTTPNetTask
{
    var imageUrl : String?
    var text : String?
    
    override func uri() -> String!
    {
        return "apis/cloth/feedback/v3"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        if let image = self.imageUrl
        {
            dic["image"] = image;
        }
        if let content = self.text
        {
            dic["text"] = content;
        }
        return dic
    }
    
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        
    }
    
    
    override func didFail(error: NSError!)
    {
        
    }
}
