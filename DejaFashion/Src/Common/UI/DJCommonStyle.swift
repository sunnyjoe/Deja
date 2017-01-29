//
//  DJCommonStyle.swift
//  DejaFashion
//
//  Created by DanyChen on 29/9/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

@objc class DJCommonStyle: NSObject {
    
    static let ColorRedStr = "f81f34"
    static let Color2F = UIColor(fromHexString: "2f2f2f")
    static let Color41 = UIColor(fromHexString: "414141")
    static let Color81 = UIColor(fromHexString: "818181")
    static let ColorB5 = UIColor(fromHexString: "b5b7b6")
    static let ColorCE = UIColor(fromHexString: "cecece")
    static let ColorEA = UIColor(fromHexString: "eaeaea")
    static let ColorRed = UIColor(fromHexString: ColorRedStr)
    
    static let ContentTextColor = UIColor(fromHexString: "414141")
    static let DescTextColor = UIColor(fromHexString: "cecece")
    static let DividerColor = UIColor(fromHexString: "eaeaea")
    static let BackgroundColor = UIColor(fromHexString: "262729")
    
    static let ColorBlue = UIColor(fromHexString: "71b0ea")
    
    class func colorRedWithAlpha(alpha: CGFloat) -> UIColor {
        return UIColor(fromHexString: ColorRedStr, alpha: alpha)
    }
    
    class func backgroundColorWithAlpha(alpha: CGFloat) -> UIColor {
        return UIColor(fromHexString: "262729", alpha: alpha)
    }
    
    class func dividerWithFrame(rect : CGRect) -> UIView {
        let view = UIView(frame: rect)
        view.backgroundColor = DJCommonStyle.DividerColor
        return view
    }
    
    class func rightBlackArrowImage() -> UIImage {
        return UIImage(named: "BlackArrowRight")!
    }
    
    class func rightWhiteArrowImage() -> UIImage {
        return UIImage(named: "ArrowRight")!
    }
    
    class func leftWhiteArrowImage() -> UIImage {
        return UIImage(named: "WhiteBackIconNormal")!
    }
}
