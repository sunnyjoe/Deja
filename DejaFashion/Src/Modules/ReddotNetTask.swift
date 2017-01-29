//
//  ReddotNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 24/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//


class ReddotNetTask: DJHTTPNetTask {

    var outfitNew = 0
    var buddyStatusUpdate = 0
    var buddyMessageCount = 0
    
    override func uri() -> String! {
        return "apis_bm/feed/reddot/v4"
    }
    
    class func uri() -> String! {
        return "apis_bm/feed/reddot/v4"
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let data = response["data"] as? NSDictionary {
            if let new = data["frontpage_outfits"] as? NSNumber {
                self.outfitNew = new.integerValue
            }
            
            if let new = data["wardrobe_buddy"] as? NSNumber {
                self.buddyStatusUpdate = new.integerValue
            }
            
            if let new = data["wardrobe_buddy_message"] as? NSNumber {
                self.buddyMessageCount = new.integerValue
            }
        }
    }
    
}
