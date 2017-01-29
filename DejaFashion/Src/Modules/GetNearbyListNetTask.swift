//
//  GetNearbyListNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 21/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class GetNearbyListNetTask: DJHTTPNetTask {
    var latitude : Double = 0
    var longitude : Double = 0
    
    var shops : [ShopInfo]?
    var malls : [MallInfo]?
    
    override func uri() -> String! {
        return "/apis_bm/nearby/mall_and_shop_list"
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = [NSObject : AnyObject]()
        
        dic["latitude"] = "\(latitude)"
        dic["longitude"] = "\(longitude)"
        
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let infos = response["shops_info"] as? NSArray{
            shops = ShopInfo.parseShopList(infos)
        }
        if let infos = response["shopping_malls_info"] as? NSArray{
            malls = MallInfo.parseMallList(infos)
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
}
