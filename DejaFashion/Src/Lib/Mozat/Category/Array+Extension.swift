//
//  Array+Extension.swift
//  DejaFashion
//
//  Created by jiao qing on 15/1/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

extension Array where Element: Equatable{
    
    func compareEqualityWithoutOrder(right : [Element]) -> Bool {
        if self.count != right.count {
            return false
        }
        for lItem in self{
            var contain = false
            for rItem in right {
                if lItem == rItem {
                    contain = true
                    break
                }
            }
            if !contain {
                return false
            }
        }
        
        return true
    }
}