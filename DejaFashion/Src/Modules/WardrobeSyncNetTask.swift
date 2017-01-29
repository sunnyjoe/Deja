//
//  WardrobeSync.swift
//  DejaFashion
//
//  Created by Sun lin on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

class WardrobeAction : NSObject
{
    var clothesID : String?
    var flag : Int?
}

public let syncSuccessNotification = "syncSuccessNotification"

class WardrobeSyncNetTask: DJHTTPNetTask
{
    var wardrobeActions = [WardrobeAction]()
    var syncResult : [Clothes]?
    var version : NSNumber = 0
    
    override func uri() -> String!
    {
        return WardrobeSyncNetTask.uri()
    }
    
    class func uri() -> String!
    {
        return "apis_bm/wardrobe/sync/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        
        var events = [NSDictionary]()
        
        let actions = self.wardrobeActions
        
        for action in actions
        {
            var event = Dictionary<String , AnyObject>()
            if let clothesID = action.clothesID
            {
                event["product_id"] = clothesID
            }
            if let flag = action.flag
            {
                event["flag"] = flag
            }
            events.append(event)
        }
        
        if events.count > 0
        {
            dic["events"] = events
        }
        dic["v"] = self.version
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? NSArray
        {
            self.syncResult = Clothes.parseClothesList(data)
            for clothes in self.syncResult!
            {
                if clothes.status == dataStatusAdded
                {
                    WardrobeDataContainer.sharedInstance.addClothesToWardrobe(clothes, fromServer: true, isNew: self.wardrobeActions.count == 0 && version != 0)
                }
                else if clothes.status == dataStatusRemoved
                {
                    WardrobeDataContainer.sharedInstance.removeClothesFromWardrobe([clothes.uniqueID!], fromServer: true)
                }
            }
            if wardrobeActions.count != data.count {
                // with some new data
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: syncSuccessNotification, object: NSNumber(integer: 1)))
            }else {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: syncSuccessNotification, object: NSNumber(integer: 0)))
            }

        }
        if let ver = response["v"] as? NSNumber
        {
            WardrobeDataContainer.sharedInstance.syncVersion = ver
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
}