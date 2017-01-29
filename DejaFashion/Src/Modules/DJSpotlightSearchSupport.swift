//
//  DJSpotlightSearchSupport.swift
//  DejaFashion
//
//  Created by DanyChen on 3/11/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

class DJSpotlightSearchSupport: NSObject {
    
    @objc class func addIndexes() {
        if #available(iOS 9.0, *) {
            

            var searchItems = [CSSearchableItem]()
//            for word in keyWords {
                let attrSet = CSSearchableItemAttributeSet(
                    itemContentType: kUTTypeText as String
                )
                attrSet.contentDescription = "Your personal styling app, fashion consultant, style advisor, shopping with best price guarantee"
                attrSet.title = "Deja"
                attrSet.keywords =
                    ["Tinder",
                        "Carousell",
                        "淘宝",
                        "Lazada",
                        "Zalora",
                        "Qoo10",
                        "Groupon",
                        "65daigou",
                        "ASOS",
                        "Shopee",
                        "天猫",
                        "Wish",
                        "Reebonz",
                        "Redmart",
                        "京东",
                        "Tangs",
                        "Uniqlo",
                        "Deal.sg",
                        "H&M",
                        "Flipkart",
                        "Forever 21",
                        "Zara",
                        "Cute",
                        "蘑菇街",
                        "Shopbop",
                        "Polyvore",
                        "Contton on",
                        "Rakuten"]
                
                let searchItem = CSSearchableItem(
                    uniqueIdentifier: "fitting_room",
                    domainIdentifier: "com.dejafashion.appstore",
                    attributeSet: attrSet
                )
                searchItems.insert(searchItem, atIndex:0)
//            }
            
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchItems) { error in
                    print("Success!")
            }
            
        }
    }
}

