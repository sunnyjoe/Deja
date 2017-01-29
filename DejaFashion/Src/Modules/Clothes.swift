//
//  Clothes.swift
//  DejaFashion
//
//  Created by Sun lin on 15/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

//public enum ClothesInWardrobeStatus : Int {
//
//    case Removed = 1
//    case Added = 2
//    case None = 0
//}

//delet redundant heigt width
class Clothes: NSObject
{
    var uniqueID : String?
    var categoryID : String?
    var subCategoryID : String?
    var name : String?
    var brandName : String?
    var brandId : String?
    var shopUrl : String?
    
    var curentPrice : NSNumber?
    var upPrice : NSNumber?
    var currency = "S$"
    var discountPercent : NSNumber?
    
    var thumbUrl : String?
    var thumbColor : String?
    var thumbWidth : NSNumber?
    var thumbHeight : NSNumber?
    var timeStamp : NSNumber?
    
    var layer : String?
    var status : Int?
    var isInWardrobe : Bool?
    var reshape : String?
    var mapTryonableClothId : String?
    var isNew = false
    
    var tryable = false
    var leftWearableImage : WearableImage?
    var rightWearableImage : WearableImage?
    var frontWearableImage : WearableImage?
    var backWearableImage : WearableImage?
    var headWearableImage : WearableImage?
}

extension Clothes
{
    class func parseClothesToCategory(keyDic : NSDictionary) -> [String : [Clothes]]{
        var clothesCateList = [String : [Clothes]]()
        
        if let keys = keyDic.allKeys as? [String] {
            for key in keys {
                if let cateArray = keyDic.objectForKey(key) as? NSArray {
                    clothesCateList[key] = parseClothesList(cateArray)
                }
            }
        }
        return clothesCateList
    }
    
    class func parseClothesList(array: NSArray) -> [Clothes]
    {
        var clothesList = [Clothes]()
        for obj in array
        {
            if let dict = obj as? NSDictionary
            {
                clothesList.append(Clothes.parseClothes(dict))
            }
        }
        return clothesList
    }
    
    class func getStringPriceWithUnit(cloth : Clothes) -> String? {
        var price : String?
        if cloth.curentPrice != nil{
            let priceF : Float = Float(cloth.curentPrice!) / 100
            price = "\(cloth.currency) \(priceF)"
        }
        return price
    }
    
    class func parseClothes(dict: NSDictionary) -> Clothes
    {
        let clothes = Clothes();
        clothes.uniqueID = dict["id"] as? String
        clothes.name = dict["name"] as? String
        clothes.brandId = dict["brand_id"] as? String
        if let brName = dict["brand_name"] as? String{
            if brName == "" {
                clothes.brandName = "N.A."
            }else {
                clothes.brandName = brName
            }
        }else{
            if let tmp = dict["brand_id"] as? String{
                if let bInfo = ConfigDataContainer.sharedInstance.getBrandInfoById(tmp){
                    clothes.brandName = bInfo.name
                }
            }else {
                clothes.brandName = "N.A."
            }
        }
        clothes.categoryID = dict["category"] as? String
        clothes.subCategoryID = dict["sub_category"] as? String
        if let currency =  dict["currency"] as? String {
            clothes.currency = currency
        }
        clothes.discountPercent = dict["discount_percent"] as? Int
        if let tmp = dict["price"] as? Int {
            if tmp >= 0{
                clothes.curentPrice = tmp
            }
        }
        clothes.upPrice = dict["original_price"] as? Int
        
        clothes.thumbColor = dict["color_value"] as? String
        if let str = dict["image"] as? String{
            clothes.thumbUrl = str
        }
        clothes.thumbWidth = dict["image_width"] as? NSNumber
        clothes.thumbHeight = dict["image_height"] as? NSNumber
        
        clothes.shopUrl = dict["shop_url"] as? String
        
        if let type = dict["tryon_status"] as? Int{
            if type == 0{
                clothes.tryable = true
            }else{
                clothes.tryable = false
            }
        }
        
        clothes.layer = dict["layer"] as? String
        if let type = dict["type"] as? Int
        {
            clothes.isInWardrobe = type == 2;// 1 : recommendation , 2: wardrobe
        }
        if let status = dict["status"] as? Int
        {
            clothes.status = status
        }
        if let wearableImage = dict["wearable_images"] as? NSDictionary
        {
            if let reshapeFile = wearableImage["reshape"] as? String{
                clothes.reshape = reshapeFile
                
                
                let tempReshapeUrl = NSURL(string: clothes.reshape!)
                clothes.mapTryonableClothId = tempReshapeUrl?.lastPathComponent
            }
            if let left = wearableImage["left"] as? NSDictionary
            {
                clothes.leftWearableImage = WearableImage.parseWearableImage(left)
            }
            if let right = wearableImage["right"] as? NSDictionary
            {
                clothes.rightWearableImage = WearableImage.parseWearableImage(right)
            }
            if let back = wearableImage["back"] as? NSDictionary
            {
                clothes.backWearableImage = WearableImage.parseWearableImage(back)
            }
            if let head = wearableImage["head"] as? NSDictionary
            {
                clothes.headWearableImage = WearableImage.parseWearableImage(head)
            }
            if let front = wearableImage["front"] as? NSDictionary
            {
                clothes.frontWearableImage = WearableImage.parseWearableImage(front)
            }
        }
        return clothes
    }
    
}

class WearableImage : NSObject
{
    var rect = CGRectZero
    var imageUrl : String?
    var maskUrl : String?
    
    var imageReshapePosition : String?
    var imageReshapeTexture : String?
    var maskReshapePosition : String?
    var maskReshapeTexture : String?
    
    class func parseWearableImage(dict: NSDictionary) ->WearableImage
    {
        
        let wearableImage = WearableImage()
        if let url = dict["url"] as? String
        {
            wearableImage.imageUrl = url
        }
        if let mask = dict["mask"] as? String
        {
            wearableImage.maskUrl = mask
        }
        if let x = dict["x"] as? CGFloat
        {
            wearableImage.rect.origin.x = x
        }
        if let y = dict["y"] as? CGFloat
        {
            wearableImage.rect.origin.y = y
        }
        if let w = dict["w"] as? CGFloat
        {
            wearableImage.rect.size.width = w
        }
        if let h = dict["h"] as? CGFloat
        {
            wearableImage.rect.size.height = h
        }
        
        
        return wearableImage
    }
}