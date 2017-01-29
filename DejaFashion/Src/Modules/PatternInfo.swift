//
//  PatternInfo.swift
//  DejaFashion
//
//  Created by jiao qing on 15/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class PatternInfo: NSObject {
    var id : String = ""
    var imageUrl : String = ""
    
    static func parsePatternInfoDic(dic : NSDictionary) -> [String : [PatternInfo]]{
        var result = [String : [PatternInfo]]()
        for (key, value) in dic {
            let keyStr = key as! String
            if let data = value as? NSArray
            {
                result[keyStr] = [PatternInfo]()
                for oneP in data {
                    if let pI = oneP as? NSDictionary{
                        let patInfo = PatternInfo()
                        if let theId = pI["id"] as? String{
                            patInfo.id = theId
                        }
                        if let theUrl = pI["image"] as? String{
                            patInfo.imageUrl = theUrl
                        }
                        result[keyStr]?.append(patInfo)
                    }
                }
            }
        }
        return result
    }
}
