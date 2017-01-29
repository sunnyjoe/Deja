//
//  String+Extension.swift
//  DejaFashion
//
//  Created by DanyChen on 4/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import Foundation

func returnEmptyStringIfNil(origin : String?) -> String {
    if let s = origin {
        return s
    }
    return ""
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
//    subscript (r: Range<Int>) -> String {
//        let range = startIndex.advancedBy(r.startIndex)..<startIndex.advancedBy(r.endIndex)
//        return substringWithRange(range)
//    }
    
    static func randomStringWithLength (len : Int) -> String {
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var result = ""
        
//        for (var i=0; i < len; i += 1){
        for _ in 0..<len{
            let length = UInt32(letters.characters.count)
            let rand = arc4random_uniform(length)
            result.append(letters[Int(rand)])
        }
        
        return result
    }
}