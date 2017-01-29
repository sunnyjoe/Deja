//
//  Extensions.swift
//  DejaFashion
//
//  Created by DanyChen on 5/1/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

extension NSURL {
    
    var allQueryItems: [NSURLQueryItem]? {
        get {
            let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)!
            let allQueryItems = components.queryItems
            return allQueryItems as [NSURLQueryItem]?
        }
    }
    
    func queryItemForKey(key: String) -> NSURLQueryItem? {
        if let queryItems = allQueryItems {
            let items = queryItems.filter { $0.name == key }
            return items.first
        }else {
            return nil
        }
    }
    
}
