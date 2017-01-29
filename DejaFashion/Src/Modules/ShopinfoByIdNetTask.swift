//
//  ShopinfoByIdNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 5/7/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

class ShopinfoByIdNetTask: DJHTTPNetTask {
    
    var shop : ShopInfo?
    var shopId : String?
    
    override func uri() -> String! {
        return "/apis_bm/nearby/get_shopinfo_by_id"
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = [NSObject : AnyObject]()
        if let value = shopId
        {
            dic["id"] = value
        }
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let data = response["data"] as? NSDictionary{
            shop = ShopInfo.parseShop(data)
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
}
