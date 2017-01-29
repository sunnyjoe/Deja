//
//  Colors.swift
//  DejaFashion
//
//  Created by DanyChen on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

struct Colors {

    static let BackgroundColor = UIColor(fromHexString: "262729")
    static let DividerColor = UIColor(fromHexString: "eaeaea")
    static let DividerColorForBlack = UIColor(fromHexString: "2e2e2f")
    
    static let TutorialViewBackgroundColor = UIColor(fromHexString: "262729", alpha: 0.95)
    
    private static func toColors(hexStrings : [String]) -> [UIColor] {
        return hexStrings.map { (hexString : String) -> UIColor in
            return UIColor(fromHexString: hexString)
        }
    }
}


enum DrawerStyle : String {
    
    case Default = "Default"
    case Lily = "Lily"
    case Rose = "Rose"
    case Smokey = "Smokey"
    case Blue = "Blue"
    
    var backgroundColors : [UIColor] {
        get {
            switch self {
            case Lily:
                return [UIColor](count: 9, repeatedValue: UIColor.whiteColor())
            case Default:
                return Colors.toColors(["ebdeb2", "f3ecd2", "f9f4e4", "f8f4e7", "fbf9f2", "fefef9", "ffffff", "ffffff", "ffffff"])
            case Rose:
                return Colors.toColors(["d0aace", "dabcd4", "dbb6c6", "e3c4d0", "f0dee0", "f7edee", "ffffff", "ffffff", "ffffff"])
            case Smokey:
                return Colors.toColors(["50515a", "939295", "cdcccb", "ebeaea", "f5f3f3", "fefefe", "ffffff", "ffffff", "ffffff"])
            case Blue:
                return Colors.toColors(["343959", "76717f", "b7aeac", "e1d8d2", "f6efed", "faf7f6", "ffffff", "ffffff", "ffffff"])
            }
        }
    }
    
    var titleColors : [UIColor] {
        get {
            return [UIColor](count: 9, repeatedValue: DJCommonStyle.BackgroundColor)
        }
    }
    
    var borderColor : UIColor {
        get {
            return UIColor(fromHexString: "0a0205", alpha: 0.11)
        }
    }
}