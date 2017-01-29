//
//  ShopDataContainer.swift
//  DejaFashion
//
//  Created by jiao qing on 21/6/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class OpenHour : NSObject
{
    var closeHour : String?
    var closeMinute : String?
    var openHour : String?
    var openMinute : String?
    
    func open() -> String
    {
        return "\(openHour!):\(openMinute!)"
    }
    
    func close() -> String
    {
        return "\(closeHour!):\(closeMinute!)"
    }
    
    func openToClose() -> String
    {
        return "\(open()) - \(close())"
    }
}

class ShopInfo: LocationInfo {
    var roomNo : String?
    var shopMallAddress : String?
    var contactNumber : String?
    var openHours : [OpenHour]?
    var postalCode : String?
    var brandInfo : BrandInfo?
    var todayOpenHour : OpenHour?
    var showMayLike = false
    
    func checkIfOpen() -> Bool
    {
        let date = NSDate()
        let unitFlags: NSCalendarUnit = [.Hour, .Weekday, .Minute]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        print("hour = \(components.hour)")
        print("minute = \(components.minute)")
        print("week = \(components.weekday)")
        var week = 0
        if components.weekday == 1
        {
            week = 6
        }else{
            week = components.weekday - 2
        }
        if let openhour = self.openHours?[week]
        {
            todayOpenHour = openhour
            let currentMinutes = components.hour * 60 + components.minute
            let openMinutes = Int(openhour.openHour!)! * 60 + Int(openhour.openMinute!)!
            let closeMinutes = Int(openhour.closeHour!)! * 60 + Int(openhour.closeMinute!)!
            if  currentMinutes >= openMinutes && currentMinutes <= closeMinutes{
                return true
            }
            else{
                return false
            }
            
        }
        return true
        
    }
    
    class func parseShop(dic : NSDictionary) -> ShopInfo?
    {
        
        let one = ShopInfo()
        parseBasic(dic, one: one)
        if let tmp = dic["shopping_mall_address"] as? String{
            one.shopMallAddress = tmp
        }
        if let tmp = dic["house_number"] as? String{
            one.roomNo = tmp
        }
        if let tmp = dic["opening_hours_detail"] as? [NSDictionary]{
            one.openHours = [OpenHour]()
            for dict in tmp
            {
                let oh =  OpenHour()
                let close = dict["close"] as? String
                let open = dict["open"] as? String
                
                oh.openHour = (open! as NSString).substringToIndex(2)
                oh.openMinute = (open! as NSString).substringFromIndex(2)
                oh.closeHour = (close! as NSString).substringToIndex(2)
                oh.closeMinute = (close! as NSString).substringFromIndex(2)
                one.openHours?.append(oh)
            }
        }
        if let tmp = dic["phone_no"] as? String{
            one.contactNumber = tmp
        }
        if let tmp = dic["postal_code"] as? String{
            one.postalCode = tmp
        }
        if let tmp = dic["brand_info"] as? NSDictionary{
            one.brandInfo = BrandInfo.parseDicToBrandInfo(tmp)
        }
        if let tmp = dic["you_may_like"] as? Bool{
            one.showMayLike = tmp
        }
        return one
    }
    
    class func parseShopList(infos : NSArray) -> [ShopInfo]?{
        var result = [ShopInfo]()
        for oneInfo in infos{
            if let dic = oneInfo as? NSDictionary{
                if let one = parseShop(dic)
                {
                    result.append(one)
                }
            }
        }
        
        //        {
        //            "address": "string",
        //            "brand_info": {
        //                "id": "string",
        //                "logo": "string",
        //                "name": "string",
        //                "status": 0,
        //                "weight": 0
        //            },
        //            "distance": "string",
        //            "house_number": "string",
        //            "id": "string",
        //            "latitude": "string",
        //            "longitude": "string",
        //            "name": "string",
        //            "opening_hours_detail": [
        //            "string"
        //            ],
        //            "phone_no": "string",
        //            "postal_code": "string",
        //            "shopping_mall_address": "string",
        //            "you_may_like": true
        //        }
        
        if result.count == 0{
            return nil
        }
        return result
    }
}

class MallInfo: LocationInfo {
    class func parseMallList(infos : NSArray) -> [MallInfo]?{
        var result = [MallInfo]()
        for oneInfo in infos{
            if let dic = oneInfo as? NSDictionary{
                let one = MallInfo()
                result.append(one)
                parseBasic(dic, one: one)
            }
        }
        
        if result.count == 0{
            return nil
        }
        return result
    }
}

class LocationInfo: NSObject {
    var name = ""
    var coordinate = CLLocationCoordinate2D()
    var id : String?
    var address : String?
    var distance : Float = 0
    
    class func parseBasic(dic : NSDictionary, one : LocationInfo){
        if let tmp = dic["address"] as? String{
            one.address = tmp
        }
        if let tmp = dic["latitude"] as? NSString{
            one.coordinate.latitude = tmp.doubleValue
        }
        if let tmp = dic["longitude"] as? NSString{
            one.coordinate.longitude = tmp.doubleValue
        }
        if let tmp = dic["name"] as? String{
            one.name = tmp
        }
        if let tmp = dic["id"] as? String{
            one.id = tmp
        }
        
        one.distance = LocationManager.sharedInstance().getDistance(one.coordinate)
    }
    
}

class ShopDataContainer: NSObject {
    static let sharedInstance = ShopDataContainer()

    func isFirstEnterNearby() -> Bool{
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("isFirstEnterNearby"){
            return false
        }
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(int: 1), forKey: "isFirstEnterNearby")
        NSUserDefaults.standardUserDefaults().synchronize()
        return true
    }
}
