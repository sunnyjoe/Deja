//
//  ConfigDataContainer.swift
//  DejaFashion
//
//  Created by Sun lin on 18/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreTelephony

let DJConfigFindClothBannerChanged = "DJConfigFindClothBannerChanged"
enum ConfigId : String {
    case category_filter
    case style_refine_condition
    case web_url
    case patch_info
    case update_info
    case cloth_color
    case statistics
    case celebrity_face
    case feedback_email
    case product_brand
    case demo_products
    case find_cloth_banner
    case offline_events
    case text
    case interval
    case sort_by_rules
    case purpose
    
    func getValueParser() -> ((configObject :ConfigObject) -> ConfigValue){
        switch self {
        case category_filter:
            return ConfigValue.parseClothesFilter
        case style_refine_condition:
            return ConfigValue.parseStyleFilter
        case web_url:
            return ConfigValue.parseWebUrl
        case patch_info:
            return ConfigValue.doNothing
        case update_info:
            return ConfigValue.doNothing
        case cloth_color:
            return ConfigValue.parseColorFilters
        case statistics:
            return ConfigValue.parseStatisticsConfigs
        case celebrity_face:
            return ConfigValue.parseMissionFaces
        case feedback_email:
            return ConfigValue.parseFeedbackEmail
        case product_brand:
            return ConfigValue.parseBrands
        case text:
            return ConfigValue.parseText
        case demo_products:
            return ConfigValue.parseDemoClothes
        case find_cloth_banner:
            return ConfigValue.parseFindClothBanner
        case interval:
            return ConfigValue.parseInterval
        case sort_by_rules:
            return ConfigValue.parseSortByRules
        case purpose:
            return ConfigValue.parsePurpose
        case offline_events:
            return ConfigValue.parseOfflineEvents
        }
    }
    
    static func allValue() -> [ConfigId]{
        return [.category_filter,
                .style_refine_condition,
                .web_url,
                .patch_info,
                .update_info,
                .cloth_color,
                .statistics,
                .celebrity_face,
                .feedback_email,
                .product_brand,
                .text,
                .demo_products,
                .find_cloth_banner,
                .interval,
                .sort_by_rules,
                .purpose,
                .offline_events
        ]
    }
}

private let ConfigTable = TableWith("config", type: ConfigObject.self, primaryKey: "configId", dbName: "config")

class ConfigValue : NSObject {
    
    private var data : NSData?
    
    private var configCategory = [ClothCategory]()
    private var configFilterConditions = [FilterCondition]()
    private var configStyleCategory = [FilterCondition]()
    
    private var clothDetailUrl = ""
    private var styleBookUrl = ""
    private var inspirationUrl = ""
    private var inviteFriendsUrl = ""
    private var mashUpUrl = ""
    private var inspirationDetailUrl = ""
    private var outfitsUrl = ""
    private var termsUrl = ""
    private var productDetailUrl = ""
    private var messageListUrl = ""
    private var editMissionOutfitUrl = ""
    private var renewMissionOutfitUrl = ""
    private var missionListUrl = ""
    private var sharedMissionUrl = ""
    private var homePageGuideUrl = ""
    private var shopLocationUrl = ""
    
    private var searchKeywordHintText = ""
    private var newFindPlaceHolder = ""
    
    
    private var shareTextConfig = ShareTextConfig()
    private var configColorFilters = [ColorFilter]()
    
//    private var userGuideTrickNumberMap = [Int : (Int, Int)]()
    
    private var missionFaceInfos = [(missionId : String, faceImageUrl : String)]()
    
    private var statisticsConfigs = [[String : String]]()
    
    private var feedbackEmail = ""
    
    private var brandList = [BrandInfo]()
    private var sortByRules = [SortRule]()
    private var searchPurposes = [SearchPurpose]()
    
    private var homePageTips = [String]()
    
    private var demoClothes = [Clothes]()
    private var findClothBanners = [FindClothBanner]()
    private var offlineEvents = [FindClothBanner]()
    private var scrollBannerInterval = 8
    
    static func doNothing(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        value.data = configObject.data
        return value
    }
    
    
//    static func parseTrickNumbers(configObject : ConfigObject) -> ConfigValue {
//        let value = ConfigValue()
//        if let data = configObject.data {
//            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary] {
//                for (i,json) in array.enumerate() {
//                    if let left = json["left"] as? Int {
//                        var l = left
//                        if l <= 0 {
//                            l = 0
//                        }
//                        var right = 0
//                        if let r = json["right"] as? Int {
//                            right = r
//                        }
//                        value.userGuideTrickNumberMap[i + 1] = (l, right)
//                    }
//                }
//            }
//        }
//        return value
//    }
    
    static func parseMissionFaces(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        if let data = configObject.data {
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary] {
                for json in array {
                    if let missionId = json["mission_id"] as? String {
                        if let image = json["image"] as? String {
                            value.missionFaceInfos.append((missionId: missionId, faceImageUrl: image))
                        }
                    }
                }
            }
        }
        return value
    }
    
    static func parseClothesFilter(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        var json : NSDictionary?
        if let data = configObject.data {
            json = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary
        }
        if json == nil {
            return value
        }
        
        if let data = json!["categories"] as? [NSDictionary]
        {
            for category in data {
                let oneCate = ClothCategory()
                value.configCategory.append(oneCate)
                
                if let tmp = category["category_id"] as? String{
                    oneCate.categoryId = tmp
                }
                if let tmp = category["category_name"] as? String{
                    oneCate.name = tmp
                }
                
                if let subCates = category["sub_categories"] as? [NSDictionary]{
                    for item in subCates {
                        let subCate = ClothSubCategory()
                        oneCate.subCategories.append(subCate)
                        
                        if let tmp = item["sub_category_id"] as? String{
                            subCate.categoryId = tmp
                        }
                        if let tmp = item["sub_category_name"] as? String{
                            subCate.name = tmp
                        }
                        if let tmp = item["sub_category_image"] as? String{
                            subCate.iconURL = tmp
                        }
                        if let tmp = item["filter_conditions"] as? [String]{
                            subCate.filterConditions = tmp
                        }
                        subCate.superCategoryid = oneCate.categoryId
                    }
                }
            }
        }
        
        if let data = json!["filter_conditions"] as? [NSDictionary]
        {
            for condition in data {
                let oneCondition = FilterCondition()
                value.configFilterConditions.append(oneCondition)
                
                if let tmp = condition["condition_id"] as? String{
                    oneCondition.id = tmp
                }
                if let tmp = condition["condition_name"] as? String{
                    oneCondition.name = tmp
                }
                
                if let filterValues = condition["filter_values"] as? [NSDictionary]{
                    for item in filterValues {
                        let fv = Filter()
                        oneCondition.values.append(fv)
                        
                        fv.condtionId = oneCondition.id
                        if let tmp = item["filter_value_id"] as? String{
                            fv.id = tmp
                        }
                        if let tmp = item["filter_value_name"] as? String{
                            fv.name = tmp
                        }
                        if let tmp = item["icon"] as? String{
                            fv.icon = tmp
                        }
                    }
                }
            }
        }
        return value
    }
    
    static func parseStyleFilter(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        if let data = configObject.data {
            let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray
            if array?.count > 0{
                for item in array! {
                    if let json = item as? NSDictionary {
                        let oneObj = FilterCondition()
                        value.configStyleCategory.append(oneObj)
                        if let tmp = json["condition_id"] as? String{
                            oneObj.id = tmp
                        }
                        if let tmp = json["condition_name"] as? String{
                            oneObj.name = tmp
                        }
                        
                        if let filterValues = json["filter_values"] as? [NSDictionary]{
                            for item in filterValues {
                                let fv = Filter()
                                fv.condtionId = oneObj.id
                                if let tmp = item["filter_value_id"] as? String{
                                    fv.id = tmp
                                }
                                if let tmp = item["filter_value_name"] as? String{
                                    fv.name = tmp
                                }
                                if let tmp = item["icon"] as? String{
                                    fv.icon = tmp
                                }
                                oneObj.values.append(fv)
                            }
                        }
                    }
                }
            }
        }
        return value
    }
    
    static func parseWebUrl(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        if let data = configObject.data {
            if let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary {
                if var tmp = urls["cloth_detail"] as? String{
                    if let range = tmp.rangeOfString("{cloth_id}")
                    {
                        tmp.replaceRange(range, with: "%@")
                    }
                    value.clothDetailUrl = replaceDomain(tmp)
                }
                if let tmp = urls["style_book"] as? String{
                    value.styleBookUrl = replaceDomain(tmp)
                }
                if let tmp = urls["inspiration"] as? String{
                    value.inspirationUrl = replaceDomain(tmp)
                }
                if let tmp = urls["invite_friends"] as? String{
                    value.inviteFriendsUrl = replaceDomain(tmp)
                }
                
                if let tmp = urls["mash_up"] as? String{
                    value.mashUpUrl = replaceDomain(tmp)
                }
                
                if var tmp = urls["inspiration_detail"] as? String{
                    if let range = tmp.rangeOfString("{inspiration_id}")
                    {
                        tmp.replaceRange(range, with: "%@")
                    }
                    value.inspirationDetailUrl = replaceDomain(tmp)
                }
                
                if let tmp = urls["outfits"] as? String{
                    value.outfitsUrl = replaceDomain(tmp)
                }
                if let tmp = urls["terms"] as? String {
                    value.termsUrl = replaceDomain(tmp)
                }
                //                if let tmp = urls["shopping_cart"] as? String {
                //                    value.shoppingCartUrl = replaceDomain(tmp)
                //                }
                //                if let tmp = urls["order_history"] as? String {
                //                    value.orderHistoryUrl = replaceDomain(tmp)
                //                }
                if var tmp = urls["product_detail"] as? String{
                    if let range = tmp.rangeOfString("{product_id}")
                    {
                        tmp.replaceRange(range, with: "%@")
                    }
                    value.productDetailUrl = replaceDomain(tmp)
                }
                if let tmp = urls["message_list"] as? String {
                    value.messageListUrl = replaceDomain(tmp)
                }
                if let tmp = urls["mission_list"] as? String {
                    value.missionListUrl = replaceDomain(tmp)
                }
                if var tmp = urls["edit_mission_outfit"] as? String{
                    if let range = tmp.rangeOfString("{mission_outfit_id}")
                    {
                        tmp.replaceRange(range, with: "%@")
                    }
                    value.editMissionOutfitUrl = replaceDomain(tmp)
                }
                if var tmp = urls["renew_mission_outfit"] as? String{
                    if let range = tmp.rangeOfString("{mission_id}")
                    {
                        tmp.replaceRange(range, with: "%@")
                    }
                    if let r = tmp.rangeOfString("{outfit_id}")
                    {
                        tmp.replaceRange(r, with: "%@")
                    }
                    value.renewMissionOutfitUrl = replaceDomain(tmp)
                }
                if var tmp = urls["shared_mission_url"] as? String{
                    if let range = tmp.rangeOfString("{uid}")
                    {
                        tmp.replaceRange(range, with: "%@")
                    }
                    value.sharedMissionUrl = replaceDomain(tmp)
                }
                if let tmp = urls["homepage_guide"] as? String {
                    value.homePageGuideUrl = replaceDomain(tmp)
                }
                if var tmp = urls["shop_location"] as? String
                {
                    
                    if let range = tmp.rangeOfString("{product_id}")
                    {
                        tmp.replaceRange(range, with: "%@")
                    }
                    
                    if let range = tmp.rangeOfString("{ol_shop}")
                    {
                        tmp.replaceRange(range, with: "%d")
                    }
                    
                    value.shopLocationUrl = replaceDomain(tmp)
                }
            }
        }
        return value
    }
    
    static func parseColorFilters(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        var array : NSArray?
        if let data = configObject.data {
            array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray
        }
        if array == nil {
            return value
        }
        
        var result = [ColorFilter]()
        
        for j in array! {
            let json = j as? NSDictionary
            let f = ColorFilter()
            if let id = json?["id"] as? Int {
                f.id = id.description
            }
            if let name = json?["name"] as? String {
                f.name = name
            }
            if let weight = json?["weight"] as? Int {
                f.weight = weight
            }
            if let color_value = json?["color_value"] as? String {
                f.colorValue = UIColor(fromHexString: color_value)
            }
            result.append(f)
        }
        value.configColorFilters.appendContentsOf(result.sort { $0.weight > $1.weight } )
        return value
    }
    
    private static func replaceDomain(url : String) -> String {
        return url.stringByReplacingOccurrencesOfString("{domain}", withString: DJWebPageBaseURL).stringByReplacingOccurrencesOfString("{rc}", withString: DJWebPageRC)
    }
    
    static func parseStatisticsConfigs(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        if let data = configObject.data {
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String : String]] {
                value.statisticsConfigs = array
            }
        }
        return value
    }
    
    static func parseFeedbackEmail(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        if let data = configObject.data {
            if let email = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? String {
                value.feedbackEmail = email
            }
            
        }
        return value
    }
    
    static func parseBrands(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        if let data = configObject.data {
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray {
                for i in array {
                    if let dic = i as? NSDictionary {
                        let brand = BrandInfo.parseDicToBrandInfo(dic)
                        value.brandList.append(brand)
                    }
                }
            }
        }
        return value
    }
    
    static func parseText(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        if let data = configObject.data {
            if let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary {
                if let tmp = urls["search_keyword_hint"] as? String{
                    value.searchKeywordHintText = tmp
                }
                if let tmp = urls["new_find_place_holder"] as? String{
                    value.newFindPlaceHolder = tmp
                }
                
                if let tmp = urls["share"] as? NSDictionary
                {
                    value.shareTextConfig = ShareTextConfig.parseFromJson(tmp)
                }
                
            }
        }
        return value
    }
    
    static func parseDemoClothes(configObject : ConfigObject) -> ConfigValue {
        let value = ConfigValue()
        if let data = configObject.data {
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary] {
                for item in array {
                    value.demoClothes.append(Clothes.parseClothes(item))
                }
            }
        }
        return value
    }
    
    static func parseFindClothBanner(configObject : ConfigObject) -> ConfigValue{
        let value = ConfigValue()
        if let data = configObject.data {
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary] {
                for item in array {
                    value.findClothBanners.append(FindClothBanner.parseBanner(item))
                }
            }
        }
        return value
    }
    
    static func parseInterval(configObject : ConfigObject) -> ConfigValue
    {
        let value = ConfigValue()
        if let data = configObject.data {
            if let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary {
                if let tmp = urls["scroll_banner"] as? Int{
                    value.scrollBannerInterval = tmp
                }
            }
        }
        return value
    }
    
    
    static func parseSortByRules(configObject : ConfigObject) -> ConfigValue
    {
        let value = ConfigValue()
        if let data = configObject.data {
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray {
                for i in array {
                    if let dic = i as? NSDictionary {
                        let rule = SortRule.parseFromJson(dic)
                        value.sortByRules.append(rule)
                    }
                }
            }
            
        }
        return value
    }
    
    static func parsePurpose(configObject : ConfigObject) -> ConfigValue
    {
        let value = ConfigValue()
        if let data = configObject.data {
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray {
                for i in array {
                    if let dic = i as? NSDictionary {
                        let p = SearchPurpose.parseFromJson(dic)
                        value.searchPurposes.append(p)
                    }
                }
            }
            
        }
        return value
    }
    
    static func parseOfflineEvents(configObject : ConfigObject) -> ConfigValue{
        let value = ConfigValue()
        if let data = configObject.data {
            if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary] {
                for item in array {
                    value.offlineEvents.append(FindClothBanner.parseBanner(item))
                }
            }
        }
        return value
    }
    
    
    
}

class ConfigDataContainer: NSObject
{
    static let sharedInstance = ConfigDataContainer()
    
    var countryCodeDic : NSDictionary?
    
    var configMap = [ConfigId : ConfigObject]()
    var configValueMap = [ConfigId : ConfigValue]()
    
    private override init() {
        super.init()
        let mills = NSDate.currentTimeMillis()
        let configs = ConfigTable.queryAll()
        if configs.count > 0 {
            for config in configs {
                if let configId = ConfigId(rawValue: config.configId!) {
                    configMap[configId] = config
                }
            }
        }else {
            loadLocalConfigs()
        }
        _Log("ConfigDataContainer init() cost \(NSDate.currentTimeMillis() - mills) mills")
    }
    
    private func loadLocalConfigs() {
        let path = NSBundle.mainBundle().pathForResource("Config", ofType: "json")
        do
        {
            let jsonString = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            
            if  jsonData == nil {
                return
            }
            
            let json = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
            
            parseConfigJson(json)
            
        }
        catch let aError as NSError
        {
            aError.description
        }
    }
    
    func parseConfigJson(dic : NSDictionary) {
        let configs = dic["data"] as? NSDictionary
        let versions = dic["versions"] as? NSDictionary
        var configObjects = [ConfigObject]()
        if let keys = configs?.allKeys {
            for key in keys {
                let k = key.description
                if let configContent = configs![k] {
                    let configObject = ConfigObject()
                    configObject.data = NSKeyedArchiver.archivedDataWithRootObject(configContent)
                    let version = versions![k] as? Int
                    configObject.version = (version == nil ? 0 : version!)
                    configObject.configId = k
                    configObjects.append(configObject)
                    if let configId = ConfigId(rawValue: k) {
                        configMap[configId] = configObject
                        configValueMap[configId] = nil
                        if configId == ConfigId.find_cloth_banner {
                            NSNotificationCenter.defaultCenter().postNotificationName(DJConfigFindClothBannerChanged, object: nil)
                        }
                    }
                }
            }
            if configObjects.count > 0 {
                //                print(NSDate.currentTimeMillis())
                ConfigTable.saveAll(configObjects)
                //                print(NSDate.currentTimeMillis().description + " result = \(result)")
            }
        }
    }
    
    func getSearchKeywordHint() -> String? {
        return configValueForKey(.text).searchKeywordHintText
    }
    
    func getNewFindPlaceHolder() -> String?
    {
        return configValueForKey(.text).newFindPlaceHolder
    }
    
    func getScrollBannerInterval() -> Int
    {
        return configValueForKey(.interval).scrollBannerInterval
    }
    
    func getFeedbackEmail() -> String? {
        return configValueForKey(.feedback_email).feedbackEmail
    }
    
    func configValueForKey(configId : ConfigId) -> ConfigValue {
        if let value = configValueMap[configId] {
            return value
        }
        if let object = configMap[configId] {
            let value = configId.getValueParser()(configObject: object)
            configValueMap[configId] = value
            return value
        }
        return ConfigValue()
    }
    
    func getFindClothBanners() -> [FindClothBanner]{
        return configValueForKey(.find_cloth_banner).findClothBanners
    }
    
    func getOfflineEvents() -> [FindClothBanner]{
        return configValueForKey(.offline_events).offlineEvents
    }
    
    func getSortByRules() -> [SortRule]{
        return configValueForKey(.sort_by_rules).sortByRules
    }
    
    func getSearchPurposes() -> [SearchPurpose]{
        return configValueForKey(.purpose).searchPurposes
    }
    
    func getDefaultSearchPurpose() -> SearchPurpose? {
        let whole = getSearchPurposes()
        for one in whole {
            if one.id == "0"{
                return one
            }
        }
        return nil
    }
    
    func getConfigMissionFaces() -> [(missionId : String, faceImageUrl : String)] {
        return configValueForKey(.celebrity_face).missionFaceInfos
    }
    
    func getConfigCategory() -> [ClothCategory]{
        return configValueForKey(.category_filter).configCategory
    }
    
    func getConfigFilters() -> [FilterCondition]{
        return configValueForKey(.category_filter).configFilterConditions
        
    }
    
    func getShareTextConfig() -> ShareTextConfig{
        return configValueForKey(.text).shareTextConfig
    }
    
    func getConfigCategoryById(categoryId : String) -> ClothCategory?{
        for cate in getConfigCategory() {
            if cate.categoryId == categoryId {
                return cate
            }
        }
        if (categoryId == "0") {
            let c = ClothCategory()
            c.categoryId = "0"
            c.name = "All"
            return c
        }
        return nil
    }
    
    func getConfigSubCategoryById(subcategoryId : String) -> ClothSubCategory?{
        for cate in getConfigCategory() {
            for one in cate.subCategories {
                if one.categoryId == subcategoryId {
                    return one
                }
            }
        }
        return nil
    }
    
    func getFiltersByIds(ids : [String]) -> [Filter] {
        var ret = [Filter]()
        
        for item in getConfigFilters() {
            for one in item.values {
                if ids.contains(one.id) {
                    ret.append(one)
                }
            }
        }
 
        return ret
    }
    
//    func getHomePageTips() -> [String] {
//        return configValueForKey(.tab1_tips).homePageTips
//    }
//    
//    func getRamdonHomePageTip() -> String? {
//        let tips = getHomePageTips()
//        if tips.count > 0 {
//            return tips[Int.random(0, max: tips.count - 1)]
//        }
//        return nil
//    }
    
    func getFilterIdsFromFilter(filter : [Filter]?) -> [String]?{
        if filter == nil{
            return nil
        }
        
        if filter!.count == 0{
            return nil
        }
        
        var str = [String]()
        for one in filter!{
            str.append(one.id)
        }
        return str
    }
    
    func getCatogryByTemplateId(templateId : String) -> ClothCategory?{
        var categoryId = "17"
        
        if templateId == "01" || templateId == "02" || templateId == "03" {
            categoryId = "17"
        }else if templateId == "04" || templateId == "05" || templateId == "06"{
            categoryId = "19"
        }else if templateId == "07" || templateId == "08"{
            categoryId = "20"
        }else if templateId == "09" || templateId == "10" || templateId == "11" || templateId == "12"{
            categoryId = "18"
        }else if templateId == "13" || templateId == "14" || templateId == "15"{
            categoryId = "21"
        }else if templateId == "16"{
            categoryId = "585"
        }
        
        for cate in getConfigCategory() {
            if cate.categoryId == categoryId {
                return cate
            }
        }
        return nil
    }
    
    func getFilterConditionById(conditionId : String) -> FilterCondition?{
        for item in getConfigFilters() {
            if item.id == conditionId {
                return item
            }
        }
        if getConfigStyleCategory().count > 0 {
            let categories = getConfigStyleCategory()
            for stc in categories {
                if stc.id == conditionId {
                    return stc
                }
            }
        }
        return nil
    }
    
    func getOccasionFilterNameById(id : String?) -> String? {
        let conditions = getConfigStyleCategory()
        for c in conditions {
            for f in c.values {
                if f.id == id {
                    return f.name
                }
            }
        }
        return nil
    }
    
    func getConfigStyleCategory() -> [FilterCondition] {
        return configValueForKey(.style_refine_condition).configStyleCategory
    }
    
    func getConfigColorFilters() -> [ColorFilter] {
        return configValueForKey(.cloth_color).configColorFilters
    }
    
    func getColorFilterById(id : String) -> ColorFilter?{
        let all = getConfigColorFilters()
        for one in all {
            if one.id == id {
                return one
            }
        }
        return nil;
    }
    
    func getClothDetailUrl(clothID : String) -> String{
        return String(format: configValueForKey(.web_url).clothDetailUrl, clothID)
    }
    
    func getCountryCodeDic() -> NSDictionary{
        if countryCodeDic == nil{
            countryCodeDic = NSDictionary()
            if let plistPath = NSBundle.mainBundle().pathForResource("Countries", ofType: "plist") {
                if let orgData = NSDictionary(contentsOfFile: plistPath) {
                    countryCodeDic = orgData
                }
            }
        }
        return countryCodeDic!
    }
    
    func getStyleBookUrl() -> String{
        return configValueForKey(.web_url).styleBookUrl
    }
    
    func getInspirationUrl() -> String{
        return configValueForKey(.web_url).inspirationUrl
    }
    func getInviteFriendsUrl() -> String{
        return configValueForKey(.web_url).inviteFriendsUrl
    }
    func getMashupUrl() -> String{
        return configValueForKey(.web_url).mashUpUrl
    }
    
    func getInspirationDetailUrl(iid : String) -> String{
        return String(format: configValueForKey(.web_url).inspirationDetailUrl, iid)
    }
    
    func getOutfitsUrl() -> String{
        return configValueForKey(.web_url).outfitsUrl
    }
    
    func getTermsUrl() -> String {
        return configValueForKey(.web_url).termsUrl
    }
    
    func getProductDetailUrl(pid : String) -> String {
        return String(format: configValueForKey(.web_url).productDetailUrl, pid)
    }
    
    func getMessageListUrl() -> String {
        return configValueForKey(.web_url).messageListUrl
    }
    
    func getMissionListUrl() -> String {
        return configValueForKey(.web_url).missionListUrl
    }
    
    func getEditMissionOutfitUrl(missionOutfitId : String) -> String {
        return String(format: configValueForKey(.web_url).editMissionOutfitUrl, missionOutfitId)
    }
    
    func getSharedMissionUrl(uid : String) -> String {
        return String(format: configValueForKey(.web_url).sharedMissionUrl, uid)
    }
    
    func getHomePageGuideUrl() -> String {
        return configValueForKey(.web_url).homePageGuideUrl
    }
    /**
     
     - parameter clothID:             clothID
     - parameter isGoToBrandHomePage: 1, go to brand home page | 0, open product detail page directly
     
     - returns:
     */
    func getShopLocationUrl(clothID : String, isGoToBrandHomePage: Int) -> String
    {
        return String(format: configValueForKey(.web_url).shopLocationUrl, clothID, isGoToBrandHomePage)
    }
    
    func getUpdateMissionOutfitUrl(missionId : String, outfitId : String) -> String {
        return String(format: configValueForKey(.web_url).renewMissionOutfitUrl, missionId, outfitId)
    }
    
    private func getCategoryById(id : String) -> ClothCategory? {
        return getConfigCategory().filter({$0.categoryId == id}).first
    }
    
    func getStatisticsSelectors() -> [[String : String]] {
        return configValueForKey(.statistics).statisticsConfigs
    }
    
    func getCurrentCountryCallingCode() -> String?{
        let network_Info =  CTTelephonyNetworkInfo()
        let carrier = network_Info.subscriberCellularProvider
        if carrier == nil {
            return nil
        }
        let countryCode = carrier!.isoCountryCode
        if countryCode == nil {
            return nil
        }
        
        let ccd = getCountryCodeDic()
        let orgKeys = ccd.allKeys as! [String]
        
        for oneKey in orgKeys {
            if oneKey.uppercaseString == countryCode?.uppercaseString {
                let dic = ccd[oneKey] as! NSDictionary
                return String(dic["CountryCallingCode"]!)
            }
        }
        7
        return nil
    }
    
    func getDemoClothesList() -> [Clothes] {
        return configValueForKey(.demo_products).demoClothes
    }
    
    func getLengthOfPhoneNumByCountryCode(code : String) -> (Int, Int) {
        let ccd = getCountryCodeDic()
        let orgKeys = ccd.allKeys as? [String]
        if orgKeys == nil{
            return (0,20)
        }
        for oneKey in orgKeys! {
            let dic = ccd[oneKey] as? NSDictionary
            if dic == nil{
                continue
            }
            let cc = dic!["CountryCallingCode"]
            if cc == nil {
                continue
            }
            if String(cc!) == code {
                let vv = dic!["PhoneNumberLength"] as? String
                if vv == nil{
                    return (0,20)
                }
                let lenar = vv!.componentsSeparatedByString(",")
                if lenar.count == 1{
                    let oneT = lenar[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if oneT.characters.count > 0{
                        if let tmp = Int(oneT){
                            return (tmp, tmp)
                        }
                    }
                }else if lenar.count > 1{
                    var numberV = [Int]()
                    for stL in lenar{
                        let oneT = stL.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        if oneT.characters.count > 0{
                            if let tmp = Int(oneT){
                                numberV.append(tmp)
                            }
                        }
                    }
                    if numberV.count == 0{
                        return (0,20)
                    }else if numberV.count == 1{
                        return (numberV[0], numberV[0])
                    }
                    var smallest = 100
                    var biggest = 0
                    for rn in numberV{
                        if rn < smallest{
                            smallest = rn
                        }
                        if rn > biggest{
                            biggest = rn
                        }
                    }
                    return (smallest, biggest)
                }
                break
            }
        }
        
        return (0,20)
    }
    
    var pushPopupTipHasShown : Bool {
        get
        {
            return DejaUserDefault.userDefault().boolForKey("deja_v3_push_popup_tip")
        }
        set
        {
            DejaUserDefault.userDefault().setBool(newValue, forKey: "deja_v3_push_popup_tip")
        }
    }
    
    var lastAppLaunchVersion : String? {
        get
        {
            return DejaUserDefault.userDefault().stringForKey("deja_v4_last_app_lauch_version")
        }
        set
        {
            DejaUserDefault.userDefault().setObject(newValue, forKey: "deja_v4_last_app_lauch_version")
        }
    }
    
    var firstTimeIntoHomePage : Bool {
        get
        {
            return DejaUserDefault.userDefault().boolForKey("deja_v4_first_time_into_home", defaultValue: true)
        }
        set
        {
            DejaUserDefault.userDefault().setBool(newValue, forKey: "deja_v4_first_time_into_home")
        }
    }
    

    var displayInviteBannerTimeStamp : Int {
        get
        {
            return DejaUserDefault.userDefault().intForKey("deja_v4_display_invite_banner_ts", defaultValue: 0)
        }
        set
        {
            DejaUserDefault.userDefault().setInteger(newValue, forKey: "deja_v4_display_invite_banner_ts")
        }
    }
    
    
    var firstTimeInstallAppVersion : String? {
        get
        {
            return DejaUserDefault.userDefault().stringForKey("deja_v4_install_app_version")
        }
        set
        {
            DejaUserDefault.userDefault().setObject(newValue, forKey: "deja_v4_install_app_version")
        }
    }
    
    var firstTimeLaunch : Bool {
        get
        {
            return DejaUserDefault.userDefault().boolForKey("deja_v4_first_time_launch", defaultValue: true)
        }
        set
        {
            DejaUserDefault.userDefault().setBool(newValue, forKey: "deja_v4_first_time_launch")
        }
    }
    
    var scanButtonClicked : Bool {
        get
        {
            return DejaUserDefault.userDefault().boolForKey("deja_v4_scan_button_clicked")
        }
        set
        {
            DejaUserDefault.userDefault().setBool(newValue, forKey: "deja_v4_scan_button_clicked")
        }
    }
}

extension ConfigDataContainer{
    
    func getRecommendBrandList() -> [BrandInfo]?{
        return configValueForKey(.product_brand).brandList.filter({$0.isRecommend == true})
    }
    
    func getBrandInfoById(brandId : String) -> BrandInfo?{
        let list = getAllBrandList()
        if list == nil{
            return nil
        }
        for v in list!{
            if v.id == brandId{
                return v
            }
        }
        return nil
    }
    
    func getAllBrandList() -> [BrandInfo]?{
        return configValueForKey(.product_brand).brandList.sort({ (left, right) -> Bool in
            left.weight > right.weight
        })
    }
}













