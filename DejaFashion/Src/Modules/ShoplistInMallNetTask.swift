//
//  ShoplistInMallNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 28/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

class ShoplistInMallNetTask: DJHTTPNetTask {
    
    var shops : [ShopInfo]?
    var mall : MallInfo?
    
    override func uri() -> String! {
        return "/apis_bm/nearby/shoplist_in_mall"
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = [NSObject : AnyObject]()
        dic["shopping_mall_id"] = self.mall?.id
        
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let infos = response["data"] as? NSArray{
            shops = ShopInfo.parseShopList(infos)
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
}