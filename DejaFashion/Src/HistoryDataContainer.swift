//
//  HistoryDataContainer.swift
//  DejaFashion
//
//  Created by Sun lin on 10/9/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

class HistoryDataContainer: NSObject {
    
    static let sharedInstance = HistoryDataContainer()
    
    
    private let browseHistoryTable = TableWith("browse_history", type: Clothes.self, primaryKey: "uniqueID", dbName: "clothes", columns: ["uniqueID", "thumbUrl", "categoryID", "curentPrice", "upPrice", "discountPercent", "name", "brandName", "timeStamp"])
    
    // temp cache in memory
    private var clothesMap = [String: Clothes]()
    // default by added timestamp
    private var orderMap = [String : UInt64]()
    
    private override init()
    {
        super.init()
        self.refreshFromDataBase()
    }
    
    func addClothesToHistory(clothes : Clothes) {
        let mills = NSDate.currentTimeSecond()
        
//        if debugMode {
//            clothes.timeStamp = NSNumber(unsignedInt: arc4random_uniform(20) * 100000)
//        }else{
            clothes.timeStamp = NSNumber(unsignedLongLong: mills)
       // }
        
        if let cid = clothes.uniqueID
        {
            if let _ = clothesMap[cid]
            {
                browseHistoryTable.delete(["uniqueID"], values: [cid])
            }
            clothesMap[cid] = clothes
            browseHistoryTable.save(clothes)
        }
    }
    
    func removeClothesFromHistory(clothIds : [String]) {
        clothIds.forEach { (clothId) -> () in
            clothesMap.removeValueForKey(clothId)
            browseHistoryTable.delete(["uniqueID"], values:[clothId])
        }
    }
    
    func queryAll() -> [Clothes] {
        var values = Array(clothesMap.values) as [Clothes]
        
        values.sortInPlace { element1, element2 in
            let value1 = element1.timeStamp
            let value2 = element2.timeStamp
            
            if value1 == nil || value2 == nil {
                return true
            }
            if value1!.longLongValue > value2!.longLongValue {
                return true
            }else{
                return false
            }
        }
                
        return values
    }
    
    
    func refreshFromDataBase() {
        let datas = browseHistoryTable.queryAll()
        for (_, data) in datas.enumerate() {
            if let id = data.uniqueID {
                clothesMap[id] = data
            }
        }
    }
    
}