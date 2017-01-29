//
//  StyleDataContainer.swift
//  DejaFashion
//
//  Created by DanyChen on 23/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

let selectedFilterTable = TableWith("selected_filter", type: Filter.self, primaryKey: "id", dbName: "Style")

class StyleDataContainer: NSObject {
    
    static let sharedInstance = StyleDataContainer()

    var styleFilterTutorialShown : Bool {
        get
        {
//            return DejaUserDefault.userDefault().boolForKey("deja_v3_style_filter_tutorial")
            return true
        }
        set
        {
            DejaUserDefault.userDefault().setBool(newValue, forKey: "deja_v3_style_filter_tutorial")
        }
    }
    
    var selectedStyleFilter : [Filter]? {
        get
        {
            return selectedFilterTable.queryAll()
        }
        set
        {
            selectedFilterTable.deleteAll()
            if let filters = newValue {
                
                selectedFilterTable.saveAll(filters)
            }
        }
    }
    
}
