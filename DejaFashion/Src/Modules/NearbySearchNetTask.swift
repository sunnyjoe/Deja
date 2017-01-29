
//
//  NearbySearchNetTask.swift
//  DejaFashion
//
//  Created by jiao qing on 24/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class NearbySearchNetTask: GetNearbyListNetTask {
    var queryStr : String?
    
    override func uri() -> String! {
        return "/apis_bm/nearby/search"
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = super.query()
        
        if let tmp = queryStr {
            dic["query"] = tmp
        }
        return dic
    }
}
