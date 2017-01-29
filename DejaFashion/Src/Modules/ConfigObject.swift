//
//  ConfigObject.swift
//  DejaFashion
//
//  Created by jiao qing on 18/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

class ConfigObject : NSObject {
    var configId : String?
    var version : NSNumber?
    var data : NSData?
}

class Filter : NSObject, NSCopying {
    var id : String = ""
    var name : String = ""
    var condtionId : String?
    var icon : String?
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let one = Filter()
        one.id = id
        one.name = name
        one.condtionId = condtionId
        one.icon = icon
 
        return one
    }
}

class FilterCondition : NSObject {
    var id : String = ""
    var name : String = ""
    var values = [Filter]()
}

class ColorFilter : Filter {
    var colorValue : UIColor = UIColor.clearColor()
    var weight = 0
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let one = ColorFilter()
        one.id = id
        one.name = name
        one.condtionId = condtionId
        one.icon = icon
        one.weight = weight
        one.colorValue = colorValue
 
        return one
    }
}

class ShareText: NSObject
{
    var title = ""
    var text = ""
    
    static func parseFromJson(dict : NSDictionary) -> ShareText{
        let text = ShareText()
        if let tmp = dict["title"] as? String{
            text.title = tmp
        }
        if let tmp = dict["text"] as? String{
            text.text = tmp
        }
        return text
    }
}

class ShareTextConfig : NSObject
{
    var sources = [String: ShareSource]()
    func sourceForId(sourceID: String) -> ShareSource?
    {
        return sources[sourceID]
    }
    static func parseFromJson(dict : NSDictionary) -> ShareTextConfig{
        let config = ShareTextConfig()
        
        for key in dict.allKeys
        {
            if let k = key as? String
            {
                if let tmp = dict[k] as? NSDictionary
                {
                    config.sources[k] = ShareSource.parseFromJson(tmp)
                }
            }
        }
        
        return config

    }
}

class ShareSource : NSObject
{
    var wechat = ShareText()
    var whatsapp = ShareText()
    var message = ShareText()
    var facebook = ShareText()
    var moments = ShareText()
    
    static func parseFromJson(dict : NSDictionary) -> ShareSource{
        
        let source = ShareSource()
        if let tmp = dict["wechat"] as? NSDictionary
        {
            source.wechat = ShareText.parseFromJson(tmp)
        }
        if let tmp = dict["whatsapp"] as? NSDictionary
        {
            source.whatsapp = ShareText.parseFromJson(tmp)
        }
        
        if let tmp = dict["message"] as? NSDictionary
        {
            source.message = ShareText.parseFromJson(tmp)
        }
        if let tmp = dict["facebook"] as? NSDictionary
        {
            source.facebook = ShareText.parseFromJson(tmp)
        }
        if let tmp = dict["moments"] as? NSDictionary
        {
            source.moments = ShareText.parseFromJson(tmp)
        }
        return source
    }
    
}

enum PurposeType : String{
    case NoLimit
    case Deal
    case NewArrival
    case Nearby
    case Occasion
    case BodyIssues
}

class SearchPurpose: NSObject{
    var id : String = ""
    var name : String = ""
    var type = PurposeType.NoLimit
    var subPurposes = [SearchPurpose]()
   
    static func parseFromJson(dict : NSDictionary) -> SearchPurpose{
        let purpose = SearchPurpose()
        if let name = dict["name"] as? String
        {
            purpose.name = name
        }
        if let id = dict["id"] as? String
        {
            purpose.id = id
            
            if id == "0"{
                purpose.type = PurposeType.NoLimit
            }else if id == "1"{
                purpose.type = PurposeType.Deal
            }else if id == "2"{
                purpose.type = PurposeType.NewArrival
            }else if id == "3"{
                purpose.type = PurposeType.Nearby
            }else if id == "4"{
                purpose.type = PurposeType.Occasion
            }else if id == "5"{
                purpose.type = PurposeType.BodyIssues
            }
        }
        
        if let subps = dict["sub_purpose"] as? NSArray
        {
            for p in subps {
                if let dic = p as? NSDictionary {
                    let subp = SearchPurpose.parseFromJson(dic)
                    purpose.subPurposes.append(subp)
                    subp.type = purpose.type
                }
            }
        }
        return purpose
    }
    
}

class ClothCategory : NSObject  {
    var categoryId : String = ""
    var name : String = ""
    var iconURL : String?
    var subCategories = [ClothSubCategory]()
}

class ClothSubCategory : NSObject, NSCopying {
    var categoryId : String = ""
    var name : String = ""
    var iconURL : String?
    var filterConditions = [String]() // ids
    var superCategoryid : String?
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let one = ClothSubCategory()
        one.categoryId = categoryId
        one.name = name
        one.iconURL = iconURL
        one.filterConditions = filterConditions
        one.superCategoryid = superCategoryid
        
        return one
    }
}


