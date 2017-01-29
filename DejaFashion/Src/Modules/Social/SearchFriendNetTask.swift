//
//  SearchFriendNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 28/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

let searchFriendPageSize : Int32 = 20

class SearchFriendNetTask: DJHTTPNetTask {
    var queryStr : String?
    var page : Int32 = 0
 
    var searchContact = [Contact]()
    var end = false
    override func uri() -> String!
    {
        return "apis_bm/friend/get_user_search/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskGet
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        if queryStr != nil
        {
            dic["query"] = queryStr!
        }
        dic["page"] = NSNumber(int: page)
        dic["page_size"] = NSNumber(int: searchFriendPageSize)
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let cArray = response["data"] as? NSArray
        {
            searchContact = SocialDataContainer.sharedInstance.parseSearchResult(cArray)
        }
        if let data = response["end"] as? Bool
        {
           end = data
        }
        
    }
    
    override func didFail(error: NSError!)
    {
        
    }

}
