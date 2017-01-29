//
//  Random.swift
//  DejaFashion
//
//  Created by DanyChen on 15/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

extension Int {
    /**
     Get random int value in a range
     
     - parameter min: minium value
     - parameter max: maxium value
     
     - returns: include parameter-min and parameter-max
     */
    static func random(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
}