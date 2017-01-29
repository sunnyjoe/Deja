//
//  DejaUserDefault.swift
//  DejaFashion
//
//  Created by Sun lin on 16/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

class DejaUserDefault: NSObject
{
    private static let sharedInstance = NSUserDefaults(suiteName: "deja_3.0")!
    class func userDefault() -> NSUserDefaults
    {
        return sharedInstance
    }
}

extension NSUserDefaults {
    public func boolForKey(defaultName: String, defaultValue: Bool) -> Bool {
        if let obj = objectForKey(defaultName) as? NSNumber{
            return Bool(obj)
        }else {
            return defaultValue
        }
    }
    
    
    public func intForKey(defaultName: String, defaultValue: Int) -> Int {
        if let obj = objectForKey(defaultName) as? NSNumber{
            return Int(obj)
        }else {
            return defaultValue
        }
    }
    
    public func stringForKey(defaultName: String, defaultValue: String) -> String {
        if let obj = stringForKey(defaultName){
            return obj
        }else {
            return defaultValue
        }
    }

}