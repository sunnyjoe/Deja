//
//  NearbyGetClothNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 5/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class NearbyShopInfo : NSObject {
    var shopInfo = [ShopInfo]()
    var shopNumber = 0
    var brandInfo : BrandInfo?
    var clothNumber = 0
    var sampleProducts = [Clothes]()
}

class NearbyGetClothNetTask: FilterableNetTask {
    var shopInfos = [NearbyShopInfo]()
    
    override func uri() -> String!
    {
        return "/apis_bm/product/get_by_filter_by_location/v5"
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
            for oneshopInfo in data{
                if let tmpDic = oneshopInfo as? NSDictionary{
                    let oneRetInfo = NearbyShopInfo()
                    shopInfos.append(oneRetInfo)
                    if let shopArray = tmpDic["shops"] as? NSArray{
                        oneRetInfo.shopNumber = shopArray.count
                        for oneShop in shopArray{
                            if let oneShopDic = oneShop as? NSDictionary{
                                oneRetInfo.shopInfo.append(ShopInfo.parseShop(oneShopDic)!)
                            }
                        }
                    }
                    if let dic = tmpDic["brand_info"] as? NSDictionary{
                        oneRetInfo.brandInfo = BrandInfo.parseDicToBrandInfo(dic)
                    }
                    if let tmp = tmpDic["cloth_number"] as? NSInteger{
                        oneRetInfo.clothNumber = tmp
                    }
                    if let clothArray = tmpDic["products"] as? NSArray
                    {
                        oneRetInfo.sampleProducts = Clothes.parseClothesList(clothArray)
                    }
                }
            }
        }
        if let end = response["end"] as? Bool
        {
            self.ended = end
        }
        if let total = response["total"] as? Int
        {
            self.total = total
        }
    }
    
    override func didFail(error: NSError!)
    {
    }
    
}
