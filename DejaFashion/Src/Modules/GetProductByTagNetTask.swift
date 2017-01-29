//
//  GetProductByTagNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 18/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

enum ScanResultType : Int {
    case NotFind = 1
    case NotSupportBrand = 2
    case NotClear = 3
    case Others = 10
}

class GetProductByTagNetTask: DJHTTPNetTask {
    var imageData : NSData?
    
    var productInfo : [Clothes]?
    var retType : ScanResultType?
    var scannedBrand : BrandInfo?
    
    override func uri() -> String!
    {
        return "apis_bm/product/get_by_scan/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
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
            productInfo = Clothes.parseClothesList(data)
        }
        if let data = response["result_code"] as? Int
        {
            retType = ScanResultType(rawValue: data)
        }
//        DJStatisticsLogic.instance().reportTimeCost(kStatisticsID_scan_result_duration, withParameter: [:], timeInMills: Int32(NSDate.currentTimeMillis() - requestTimeInMills))
    }
    
    override func didFail(error: NSError!)
    {
    }
}
