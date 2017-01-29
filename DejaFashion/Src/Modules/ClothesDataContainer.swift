//
//  ClothesDataContainer.swift
//  DejaFashion
//
//  Created by DanyChen on 4/2/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

let maxSearchHistoryCount = 10

class BrandInfo: NSObject, NSCopying {
    var id = ""
    var name = ""
    var imageUrl = ""
    var isRecommend = false
    var weight = 0
    
    
    static func parseDicToBrandInfo(dic : NSDictionary) -> BrandInfo{
        let brand = BrandInfo()
        if let name = dic["name"] as? String {
            brand.name = name
        }
        if let id = dic["id"] as? String {
            brand.id = id
        }
        if let image = dic["logo"] as? String {
            brand.imageUrl = image
        }
        if let status = dic["status"] as? Int {
            brand.isRecommend = status == 1
        }
        if let weight = dic["weight"] as? Int {
            brand.weight = weight
        }
        return brand
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let one = BrandInfo()
        one.id = id
        one.name = name
        one.imageUrl = imageUrl
        one.isRecommend = isRecommend
        one.weight = weight
        
        return one
    }
    
}

class FindClothBanner : NSObject{
    var firstInfo : String?
    var secondInfo : String?
    var thridInfo : String?
    var bannerId : String?
    var brandId : String?
    var imageUrl : String?
    var jumpUrl : String?
    var promotionAlertTitle : String?
    var promotionAlertText : String?
    var promotionAlertButtonText : String?
    var promotionText : String?
    
    static func parseBanner(dict : NSDictionary) -> FindClothBanner{
        let banner = FindClothBanner()
        
        banner.firstInfo = dict["text_0"] as? String
        banner.secondInfo = dict["text_1"] as? String
        banner.thridInfo = dict["text_2"] as? String
        banner.bannerId = dict["id"] as? String
        banner.brandId = dict["brand_id"] as? String
        banner.imageUrl = dict["image_url"] as? String
        banner.jumpUrl = dict["jump_url"] as? String
        banner.promotionAlertTitle = dict["promotion_alert_title"] as? String
        banner.promotionAlertText = dict["promotion_alert_text"] as? String
        banner.promotionAlertButtonText = dict["promotion_alert_button_text"] as? String
        banner.promotionText = dict["promotion_text"] as? String
        
        
        return banner
    }
}

class SortRule : NSObject{
    var name : String?
    var value : Int?
    
    static func parseFromJson(dict : NSDictionary) -> SortRule{
        let rule = SortRule()
        
        rule.name = dict["name"] as? String
        rule.value = dict["value"] as? Int
        return rule
    }
}


class SearchHistory : NSObject {
    
    var keyword : String?
    var ts : NSNumber?
    
    override init() {
        
    }
    
    init(keyword : String, ts : NSNumber) {
        self.keyword = keyword
        self.ts = ts
    }
}

let searchHistoryTable = TableWith("search_history", type: SearchHistory.self, primaryKey: "keyword", dbName: "search")

class ClothesDataContainer: NSObject {
    
    static let sharedInstance = ClothesDataContainer()
    
    func checkNewArrivalVersion(brandId : String) -> String?
    {
        return NSUserDefaults.standardUserDefaults().objectForKey("checkNewArrivalVersion_\(brandId)") as? String
    }
    
    func setCheckNewArrivalVersion(brandId : String, version: String)
    {
        NSUserDefaults.standardUserDefaults().setObject(version, forKey: "checkNewArrivalVersion_\(brandId)")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    func insertSearchHistory(keyword : String) {
        searchHistoryTable.save(SearchHistory(keyword: keyword, ts: NSNumber(unsignedLongLong: NSDate.currentTimeMillis())))
    }
    
    func tagKey(key : String){
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func checkKeyTagged(key : String) -> Bool{
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(key){
            return  true
        }
        return false
    }
    
    func querySearchHistory() -> [SearchHistory] {
        let result = searchHistoryTable.queryAll("ts desc")
        return result.count <= maxSearchHistoryCount ? result : Array(result[0...maxSearchHistoryCount-1])
    }
    
    func deleteSearchHistory(keyword : String) {
        searchHistoryTable.delete(["keyword"], values: [keyword])
    }
    
    func clearAllHistory() {
        searchHistoryTable.deleteAll()
    }
    
    func extractFilterIds(filterArray : [Filter]) -> [String]{
        var result = [String]()
        for filter in filterArray {
            result.append(filter.id)
        }
        return result
    }
    
    func isFirstTimeUseScan() -> Bool{
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("isFirstTimeUseScan"){
            return false
        }
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(int: 1), forKey: "isFirstTimeUseScan")
        NSUserDefaults.standardUserDefaults().synchronize()
        return true
    }
    
    func scanHasEnteredClothDetail(setEntered : Bool = false) -> Bool{
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("scanHasEnteredClothDetail"){
            return true
        }
        if setEntered {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(int: 1), forKey: "scanHasEnteredClothDetail")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        return false
    }
    
    func extractBrandNames(brandList : [BrandInfo]) -> [String]{
        var names = [String]()
        for one in brandList{
            names.append(one.name)
        }
        return names
    }
    
    func findBrandByName(str : String) -> BrandInfo?{
        if let brandList = ConfigDataContainer.sharedInstance.getAllBrandList(){
            for one in brandList{
                if (one.name) == str{
                    return one
                }
            }
        }
        return nil
    }
}
