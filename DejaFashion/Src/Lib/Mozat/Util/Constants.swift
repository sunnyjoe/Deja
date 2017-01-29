//
//  Constant.swift
//  DejaFashion
//
//  Created by jiao qing on 6/1/16.
//  Copyright © 2016 Mozat. All rights reserved.
//
import UIKit

let ScreenWidth = UIScreen.mainScreen().bounds.width
let ScreenHeight = UIScreen.mainScreen().bounds.height

let StatusBarHeight = 20.0 as CGFloat
let NavigationBarHeight = 44.0 as CGFloat

let kDJModelViewHeight3x : CGFloat = 1400
let kDJModelViewWidth3x : CGFloat = 860

let bottomAreaHeight : CGFloat = 60

let defaultBlackAvatarImageName = "DefaultBlackAvatar"
let kDJCameraPermissionIdentifier = "kDJCameraPermissionIdentifier"

let kIphoneSizeScale = ScreenWidth / 375

#if APPSTORE
var debugMode = false
#else
var debugMode = true
#endif

class DJConstants : NSObject{
    static var isDebug : Bool {
        return debugMode
    }
}

struct ImageQuality {
    static let HIGH = 375 * Int(UIScreen.mainScreen().scale)
    static let MIDDLE = 200 * Int(UIScreen.mainScreen().scale)
    static let LOW = 100 * Int(UIScreen.mainScreen().scale)
}

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}

public func _Log(format: String) {
    if debugMode {
        NSLog(format)
    }
}


extension Double {
    
    var operatingSystemIsSameOrHigher: Bool {
        let major = Int(self)
        let minor = Int(round((self - Double(major)) * 10))
        let version = NSOperatingSystemVersion(majorVersion: major, minorVersion: minor, patchVersion: 0)
        return NSProcessInfo().isOperatingSystemAtLeastVersion(version)
    }
    
    var operatingSystemIsLower: Bool {
        return !operatingSystemIsSameOrHigher
    }
}

@available(iOS, deprecated=1.0, message="I'm not deprecated, please ***FIXME**")
func FIXME()
{
    // instead of TODO warning
}

public enum Model : String {
    case simulator = "simulator/sandbox",
    iPod1          = "iPod 1",
    iPod2          = "iPod 2",
    iPod3          = "iPod 3",
    iPod4          = "iPod 4",
    iPod5          = "iPod 5",
    iPad2          = "iPad 2",
    iPad3          = "iPad 3",
    iPad4          = "iPad 4",
    iPhone4        = "iPhone 4",
    iPhone4S       = "iPhone 4S",
    iPhone5        = "iPhone 5",
    iPhone5S       = "iPhone 5S",
    iPhone5C       = "iPhone 5C",
    iPadMini1      = "iPad Mini 1",
    iPadMini2      = "iPad Mini 2",
    iPadMini3      = "iPad Mini 3",
    iPadAir1       = "iPad Air 1",
    iPadAir2       = "iPad Air 2",
    iPhone6        = "iPhone 6",
    iPhone6plus    = "iPhone 6 Plus",
    iPhone6S       = "iPhone 6S",
    iPhone6Splus   = "iPhone 6S Plus",
    unrecognized   = "?unrecognized?"
}

public extension UIDevice {
    
    public class func isIPhone5() -> Bool {
        return UIDevice.type == .iPhone5 || UIDevice.type == .iPhone5C || UIDevice.type == .iPhone5S
    }
    
    public class func isIPhone4() -> Bool {
        return UIDevice.type == .iPhone4 || UIDevice.type == .iPhone4S
    }
    
    public class func isIPod() -> Bool {
        return UIDevice.type.rawValue.hasPrefix("iPod")
    }
    
    public class func isIPad() -> Bool {
        return UIDevice.type.rawValue.hasPrefix("iPad")
    }
        
    public static var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafeMutablePointer(&systemInfo.machine) {
            ptr in String.fromCString(UnsafePointer<CChar>(ptr))
        }
        var modelMap : [ String : Model ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad2,5"   : .iPadMini1,
            "iPad2,6"   : .iPadMini1,
            "iPad2,7"   : .iPadMini1,
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPad4,1"   : .iPadAir1,
            "iPad4,2"   : .iPadAir2,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPhone7,1" : .iPhone6plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6Splus
        ]
        
        if let model = modelMap[String.fromCString(modelCode!)!] {
            return model
        }
        return Model.unrecognized
    }
}

public class AppConfig : NSObject {
    class var currentVersion : String? {
        get {
            if let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] {
                if let version = nsObject as? String {
                    return version
                }
            }
            return ""
        }
    }
    
}

