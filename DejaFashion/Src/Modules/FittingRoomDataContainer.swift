//
//  FittingRoomDataContainer.swift
//  DejaFashion
//
//  Created by jiao qing on 21/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit
import SDWebImage

let kDJAlbumPermissionIdentifier = "kDJAlbumPermissionIdentifier"
let DJNotifyDejaModelShapeChanged = "DJNotifyDejaModelShapeChanged"

let DejaModelMakeUpId = "DejaModelMakeUpId"
let DejaModelHairStyle = "DejaModelHairStyle"
let DejaModelSkinColor = "DejaModelSkinColor"
let DejaModelHairColor = "DejaModelHairColor"
let DejaBasicModelImage = "DejaBasicModelImage"

let kDefaultHairStyleID = "9"
let kDefaultMakeupID = "10"
let kDefaultHairColor = "6b5a47"
let kDefaultSkinColor = "e3bda9"


var kDefaultShoulder = "m"
var kDefaultCupSize = "l"
var kDefaultWaist = "s"
var kDefaultHip = "m"
var kDefaultArm = "s"
var kDefaultLeg = "s"
var kDefaultRatio = "s"


let kDJConfigHalfBodyShape = "kDJConfigHalfBodyShape"
let kDJConfigCupSize = "kDJConfigCupSize"
let kDJConfigArmShape = "kDJConfigArmShape"
let kDJConfigLegShape = "kDJConfigLegShape"

let FrontBodyImageCache = "FrontBodyImageCache"
let BreastImageCache = "BreastImageCache"
let LeftBodyImageCache = "LeftBodyImageCache"
let RightBodyImageCache = "RightBodyImageCache"
let LegBodyImageCache = "LegBodyImageCache"

let CachedDejaFaceImage = "CachedDejaFaceImage"
let CachedDejaHairBackImage = "CachedDejaHairBackImage"
let CachedDejaHairFrontImage = "CachedDejaHairFrontImage"

//"hairColor":[
//"907450",
//"8e6e37",
//"6c513b",
//"6b5a47",
//"603f2e",
//"3e2426",
//"382d2f",
//"252422"
//],
//"skinColor":[
//"f1d6cb",
//"e5c5ba",
//"e3bda9",
//"cda28e",
//"b88e73",
//"8f6353"

class ModelInfo: NSObject {
    var makeupId = ""
    var skinColor = ""
    var hairColor = ""
    var hairStyle = ""
    
    // TODO. refactor at v4.1.9, please delete after few versions
    var bodyShape = ""
    
    var shoulder = ""
    var cupSize = ""
    var waist = ""
    var hip = ""
    var arm = ""
    var leg = ""
    var ratio = ""
    
    
    func halfBodyShap() -> String
    {
        let value = "\(shoulder)\(waist)\(hip)\(arm)"
        if value.characters.count < 4
        {
            return "\(kDefaultShoulder)\(kDefaultWaist)\(kDefaultHip)\(kDefaultArm)"
        }
        return value
    }
    
    func fullBodyShape() -> String
    {
        let value = "\(shoulder)\(waist)\(hip)\(arm)\(leg)"
        if value.characters.count < 5
        {
            return ModelInfo.defaultBodyShape()
        }
        return value
    }
    
    
    func armShape() -> String
    {
        let value = "\(arm)\(shoulder)"
        if value.characters.count < 2
        {
            return "\(kDefaultArm)\(kDefaultShoulder)"
        }
        return value
    }
    
    func legShape() -> String
    {
        let value = "\(leg)\(hip)"
        if value.characters.count < 2
        {
            return "\(kDefaultLeg)\(kDefaultHip)"
        }
        return value
    }
    
//    func BraShape() -> String
//    {
//        let value = "\(shoulder)\(waist)\(hip)"
//        if value.characters.count < 3
//        {
//            return "\(kDefaultShoulder)\(kDefaultWaist)\(kDefaultHip)"
//        }
//        return value
//    }
    
    class func defaultBodyShape() -> String
    {
        return "\(kDefaultShoulder)\(kDefaultWaist)\(kDefaultHip)\(kDefaultArm)\(kDefaultLeg)"
    }
    
    class func defaultModeInfo() -> ModelInfo{
        let one = ModelInfo()
        one.makeupId = kDefaultMakeupID
        one.skinColor = kDefaultSkinColor
        one.hairColor = kDefaultHairColor
        one.hairStyle = kDefaultHairStyleID
        
        one.shoulder = kDefaultShoulder
        one.cupSize = kDefaultCupSize
        one.waist = kDefaultWaist
        one.hip = kDefaultHip
        one.arm = kDefaultArm
        one.leg = kDefaultLeg
        one.ratio = kDefaultRatio
        return one
    }
}

let kDefaultDejaModelFileName = "model"
let defaultFullBodyShape = "msmss"

let UserModelInfoTable = TableWith("MyModelInfo", type: ModelInfo.self, primaryKey: "bodyShape", dbName: "MyModelInfo")

class FittingRoomDataContainer: NSObject {
    static let sharedInstance = FittingRoomDataContainer()
    static let obj = NSObject()
    
    var bodyReshapeCoord : [String : [Int]]?
    lazy private var dejaFaceView = DJFaceView(frame : CGRectMake(0, 0, 150, 150 * 3))
    
    lazy var skinColorArray : [String] = {
        if let tmp = self.getDictionaryFromJsonName("DejaColor"){
            return tmp.objectForKey("skinColor") as! [String]
        }
        return [String]()
    }()
    
    lazy var hairColorArray : [String] = {
        if let tmp = self.getDictionaryFromJsonName("DejaColor"){
            return tmp.objectForKey("hairColor") as! [String]
        }
        return [String]()
    }()
    
}
//

//cloth related
extension FittingRoomDataContainer{
    func fetchClothResource(products : [Clothes], fullBodyShape : String, success : (() -> Void)?, failed : (() -> Void)?){
        var wImages = [WearableImage]()
        
        for pdt in products {
            if (pdt.leftWearableImage == nil && pdt.rightWearableImage == nil && pdt.frontWearableImage == nil && pdt.backWearableImage == nil && pdt.headWearableImage == nil) || pdt.layer == nil{
                if failed != nil{
                    failed!()
                }
                return
            }
            
            let newProductlayers : [String] = pdt.layer!.componentsSeparatedByString(",")
            if newProductlayers.count == 0{
                if failed != nil{
                    failed!()
                }
                return
            }
            
            if let tmp = pdt.leftWearableImage {
                wImages.append(tmp)
            }
            if let tmp = pdt.rightWearableImage {
                wImages.append(tmp)
            }
            if let tmp = pdt.frontWearableImage {
                wImages.append(tmp)
            }
            if let tmp = pdt.backWearableImage {
                wImages.append(tmp)
            }
            if let tmp = pdt.headWearableImage {
                wImages.append(tmp)
            }
        }
        
        var urls = [String]()
        for wi in wImages {
            if wi.imageUrl != nil {
                urls.append(wi.imageUrl!)
            }
            if wi.maskUrl != nil {
                urls.append(wi.maskUrl!)
            }
        }
        var everythingIsOK = true
        let group = dispatch_group_create()
        for url in urls{
            if (SDImageCache.sharedImageCache().imageFromDiskCacheForKey(url) != nil) {
                continue
            }
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let request =  NSURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 20)
                do {
                    let urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:nil) as NSData
                    
                    let image = UIImage(data: urlData)
                    if urlData.length > 0 && image != nil {
                        SDImageCache.sharedImageCache().storeImage(image, forKey: url, toDisk: true)
                    }else{
                        everythingIsOK = false
                    }
                }catch (let error) {
                    print(error)
                    everythingIsOK = false
                }
            })
        }
        for pdt in products {
            if pdt.reshape == nil || pdt.uniqueID == nil{
                continue
            }
            if pdt.reshape!.characters.count == 0{
                continue
            }
            
            let reshapeURL = "\(pdt.reshape!)\(pdt.mapTryonableClothId!)_\(fullBodyShape).zip"
            
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if !DownTool.download([reshapeURL], clothesId: pdt.uniqueID!, bodyShapeId: fullBodyShape) {
                    everythingIsOK = false
                }
            })
        }
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            dispatch_async(dispatch_get_main_queue(), {
                if everythingIsOK {
                    if success != nil{
                        success!()
                    }
                }else{
                    if failed != nil{
                        failed!()
                    }
                }
            })
        })
    }
    
    func preCacheImageFromUrls(strs : [String]){
        for url in strs{
            if (SDImageCache.sharedImageCache().imageFromDiskCacheForKey(url) != nil) {
                continue
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let request =  NSURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 20)
                do {
                    let urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:nil) as NSData
                    
                    let image = UIImage(data: urlData)
                    if urlData.length > 0 && image != nil {
                        SDImageCache.sharedImageCache().storeImage(image, forKey: url, toDisk: true)
                    }else{
                        
                    }
                }catch (let error) {
                    print(error)
                }
            })
        }
    }
    
    func checkConflictCloth(mustCloth : Clothes, newClothes : [Clothes]) -> Clothes?{
        for newCloth in newClothes{
            let newProductlayers : [String] = newCloth.layer!.componentsSeparatedByString(",")
            let preProductLayers = mustCloth.layer!.componentsSeparatedByString(",")
            for oneLayer in newProductlayers {
                if preProductLayers.indexOf(oneLayer) != nil{//conflict
                    return newCloth
                }
            }
        }
        return nil
    }
    
    func getFinalClothAfterPutNewCloth(previousClothes : [Clothes], products : [Clothes], fullBodyShape : String) -> [Clothes]{
        var clothesSummary = previousClothes
        
        for newProduct in products {
            let clothes = clothesSummary
            let newProductlayers : [String] = newProduct.layer!.componentsSeparatedByString(",")
            
            for pdt in clothes {
                let preProductLayers = pdt.layer!.componentsSeparatedByString(",")
                for oneLayer in newProductlayers {
                    if preProductLayers.indexOf(oneLayer) != nil{//conflict
                        for xCloth in clothesSummary {
                            if xCloth.uniqueID == pdt.uniqueID {
                                clothesSummary.removeAtIndex(clothesSummary.indexOf(xCloth)!)
                                break
                            }
                        }
                        break
                    }
                }
            }
            clothesSummary.append(newProduct)
        }
        clothesSummary.sortInPlace {(element1, element2) -> Bool in
            let thisTmp : [String] = element1.layer!.componentsSeparatedByString(",")
            let thisLayer = Int(thisTmp[0])
            
            let thatTmp : [String] = element2.layer!.componentsSeparatedByString(",")
            let thatLayer = Int(thatTmp[0])
            return thisLayer < thatLayer
        }
        
        for pdt in clothesSummary{
            if pdt.reshape == nil || pdt.uniqueID == nil{
                continue
            }
            var wis = [WearableImage]()
            var names = [String]()
            if let tmp = pdt.leftWearableImage{
                wis.append(tmp)
                names.append("left")
            }
            if let tmp = pdt.rightWearableImage{
                wis.append(tmp)
                names.append("right")
            }
            if let tmp = pdt.frontWearableImage{
                wis.append(tmp)
                names.append("front")
            }
            if let tmp = pdt.backWearableImage{
                wis.append(tmp)
                names.append("back")
            }
            
            for wi in wis{
                let name = names[wis.indexOf(wi)!]
                if wi.imageUrl != nil{
                    var partName = "\(name)_tar"
                    wi.imageReshapePosition = DownTool.queryByString(pdt.uniqueID!, tryonableClotheId: pdt.mapTryonableClothId!, bodyShapeId: fullBodyShape, partId: partName)
                    partName = "\(name)_src"
                    wi.imageReshapeTexture = DownTool.queryByString(pdt.uniqueID!, tryonableClotheId: pdt.mapTryonableClothId!, bodyShapeId: fullBodyShape, partId: partName)
                }
                if wi.maskUrl != nil{
                    var partName = "\(name)_mask_tar"
                    wi.maskReshapePosition = DownTool.queryByString(pdt.uniqueID!, tryonableClotheId: pdt.mapTryonableClothId!, bodyShapeId: fullBodyShape, partId: partName)
                    partName = "\(name)_mask_src"
                    wi.maskReshapeTexture = DownTool.queryByString(pdt.uniqueID!, tryonableClotheId: pdt.mapTryonableClothId!, bodyShapeId: fullBodyShape, partId: partName)
                }
            }
        }
        return clothesSummary
    }
}

//cloth related
extension FittingRoomDataContainer{
    func updateMyModelInfo(info : ModelInfo){
        UserModelInfoTable.deleteAll()
        UserModelInfoTable.saveAll([info])
    }
    
    func getDefaultModeInfo() -> ModelInfo{
        let one = ModelInfo()
        one.makeupId = kDefaultMakeupID
        one.skinColor = kDefaultSkinColor
        one.hairColor = kDefaultHairColor
        one.hairStyle = kDefaultHairStyleID
        
        one.shoulder = kDefaultShoulder
        one.cupSize = kDefaultCupSize
        one.waist = kDefaultWaist
        one.hip = kDefaultHip
        one.arm = kDefaultArm
        one.leg = kDefaultLeg
        return one
    }
    
    func getMyModelInfo() -> ModelInfo{
        let ret = UserModelInfoTable.queryAll()
        if ret.count == 0 || ret[0].shoulder == ""{
            let one = ModelInfo.defaultModeInfo()
            updateMyModelInfo(one)
            return one
        }
        return ret[0]
    }
    
    func getDefaultDejaFaceData() -> NSDictionary? {
        return getDictionaryFromJsonName(kDefaultDejaModelFileName)
    }
    
    func getWholeFace(skinColor : String, makeupId : String, hairColor : String) -> UIImage{
        if getCachedSkinColor() == skinColor && getCachedMakeupId() == makeupId && getCachedHairColor() == hairColor{
            if let cachedImage = getImageForKey(CachedDejaFaceImage){
                return cachedImage
            }
        }
        if getCachedSkinColor() != skinColor{
            setCachedSkinColor(skinColor)
        }
        if getCachedMakeupId() != makeupId{
            setCachedMakeupId(makeupId)
        }
        let wholeFace = dejaFaceView.getFaceWithColor(skinColor, makeupId: makeupId, hairColor: hairColor)
        storeImageForKey(CachedDejaFaceImage, theImage: wholeFace)
        return wholeFace
    }
    
    func getHairImages(hairColor : String, styleId : String) -> [UIImage]{
        if getCachedHairColor() == hairColor && getCachedHairStyleId() == styleId{
            if let cachedImage = getImageForKey(CachedDejaHairFrontImage){
                if let tmp = getImageForKey(CachedDejaHairBackImage){
                    return [cachedImage, tmp]
                }else{
                    return [cachedImage]
                }
            }
        }
        if getCachedHairColor() != hairColor{
            setCachedHairColor(hairColor)
        }
        if getCachedHairStyleId() != styleId{
            setCachedHairStyleId(styleId)
        }
        dejaFaceView.resetHairWithColor(hairColor, hairStyleId: styleId)
        storeImageForKey(CachedDejaHairFrontImage, theImage: dejaFaceView.frontHair)
        if let tmp = dejaFaceView.backHair{
            storeImageForKey(CachedDejaHairBackImage, theImage: tmp)
            return [dejaFaceView.frontHair, dejaFaceView.backHair]
        }else{
            NSUserDefaults.standardUserDefaults().removeObjectForKey(CachedDejaHairBackImage)
            NSUserDefaults.standardUserDefaults().synchronize()
            return [dejaFaceView.frontHair]
        }
    }
    
    func getBodyCoordinate(shape : String) -> CGRect{
        if bodyReshapeCoord == nil {
            bodyReshapeCoord = [String : [Int]]()
            if let path = NSBundle.mainBundle().pathForResource("BodyCoordinates", ofType: "txt"){
                do {
                    let stringTxt = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                    let allLines = stringTxt.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                    
                    for oneLine in allLines{
                        let singleStrs = oneLine.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " "))
                        if singleStrs.count < 5 {
                            break
                        }
                        let shapeName = singleStrs[0]
                        bodyReshapeCoord![shapeName] = [Int]()
                        for i in 1...singleStrs.count - 1{
                            if let vI = Int(singleStrs[i]){
                                (bodyReshapeCoord![shapeName])!.append(vI)
                            }
                        }
                    }
                }catch{}
            }
        }
        if let tmp = bodyReshapeCoord![shape]{
            if tmp.count == 4{
                return CGRectMake(CGFloat(tmp[0]), CGFloat(tmp[1]), CGFloat(tmp[2]), CGFloat(tmp[3]))
            }
        }
        return CGRectZero
    }
    
    func getBodyFrontImage(shape : String, skinColor : String) -> UIImage?{
        if getCachedHalfBodyShape() == shape && getCachedSkinColor() == skinColor{
            if let tmp = getImageForKey(FrontBodyImageCache){
                return tmp
            }
        }
        let bodyFrontImg = getRenderModelImage(shape, theImageName: "\(shape)_body.png", skinColor: skinColor)
        if bodyFrontImg == nil {
            return nil
        }
        storeStringForKey(kDJConfigHalfBodyShape, theStr: shape)
        storeImageForKey(FrontBodyImageCache, theImage: bodyFrontImg!)
        return bodyFrontImg
    }
    
    
    func getBodyBreastImage(cupSize : String, skinColor : String) -> UIImage?{
        if getCachedCupSize() == cupSize && getCachedSkinColor() == skinColor{
            if let tmp = getImageForKey(BreastImageCache){
                return tmp
            }
        }
        let breastImg = getRenderModelImage(cupSize, theImageName: "\(cupSize)_breast.png", skinColor: skinColor)
        if breastImg == nil {
            return nil
        }
        storeStringForKey(kDJConfigCupSize, theStr: cupSize)
        storeImageForKey(BreastImageCache, theImage: breastImg!)
        return breastImg
    }
    
    func getBodyArmImage(shape : String, skinColor : String) -> [UIImage]?{
        if getCachedArmShape() == shape && getCachedSkinColor() == skinColor{
            if let rArm = getImageForKey(RightBodyImageCache){
                if let lArm = getImageForKey(LeftBodyImageCache){
                    return [rArm, lArm]
                }
            }
        }
        
        let rightImg = getRenderModelImage("\(shape)r", theImageName: "\(shape)_right.png", skinColor: skinColor)
        let leftImg = getRenderModelImage("\(shape)l", theImageName: "\(shape)_left.png", skinColor: skinColor)
        if rightImg == nil || leftImg == nil{
            return nil
        }
        
        storeStringForKey(kDJConfigArmShape, theStr: shape)
        storeImageForKey(RightBodyImageCache, theImage: rightImg!)
        storeImageForKey(LeftBodyImageCache, theImage: leftImg!)
        return [rightImg!, leftImg!]
    }
    
    func getBodyLegImage(shape : String, skinColor : String) -> UIImage?{
        if getCachedLegShape() == shape && getCachedSkinColor() == skinColor{
            if let tmp = getImageForKey(LegBodyImageCache){
                return tmp
            }
        }
        
        let theImg = getRenderModelImage("\(shape)", theImageName: "\(shape)_leg.png", skinColor: skinColor)
        if theImg == nil {
            return nil
        }
        
        storeStringForKey(kDJConfigLegShape, theStr: shape)
        storeImageForKey(LegBodyImageCache, theImage: theImg!)
        return theImg!
    }
    
    func getRenderModelImage(shape : String, theImageName : String, skinColor : String) -> UIImage?{
        let gimage = UIImage(named: theImageName)
        if gimage == nil {
            return nil
        }
        
        let colorId = Int(getSkinColorIdFromColor(skinColor))! + 1
        let color1Image = UIImage(named: "SkinColor\(colorId)1.png")
        let color2Image = UIImage(named: "SkinColor\(colorId)2.png")
        if  color2Image?.CGImage == nil || color2Image == nil {
            return nil
        }
        
        let imageRect = getBodyCoordinate(shape)
        let renderRect = CGRectMake(0, 0, imageRect.width, imageRect.height)
        return getRenderedImage(gimage!, renderRect: renderRect, color1Image: color1Image, color2Image: color2Image!, colorId: colorId)
    }
    
    func isDefaultBodyShape(bodyshape : String, legShape : String) -> Bool{
        let c4 = legShape[0] as Character
        let fullShape = "\(bodyshape)\(c4)"
        
        if fullShape == ModelInfo.defaultBodyShape(){
            return true
        }
        return false
    }
    
//    private func getCachedFullBodyShape() -> String{
//        let halfBodyShape = getCachedHalfBodyShape()
//        let legShape = getCachedLegShape()
//        let c4 = legShape[0] as Character
//        return "\(halfBodyShape)\(c4)"
//    }
    
    private func getCachedArmShape() -> String{
        if let tmp = getStringForKey(kDJConfigArmShape){
            if tmp.characters.count < 2 {
                return "sm"
            }
            return tmp
        }
        return "sm"
    }
    
    private func getCachedLegShape() -> String{
        if let tmp = getStringForKey(kDJConfigLegShape){
            if tmp.characters.count < 2 {
                return "sm"
            }
            return tmp
        }
        return "sm"
    }
    
    private func getCachedHalfBodyShape() -> String{
        if let tmp = getStringForKey(kDJConfigHalfBodyShape){
            if tmp.characters.count < 4 {
                return (defaultFullBodyShape as NSString).substringToIndex(4)
            }
            return tmp
        }
        return (defaultFullBodyShape as NSString).substringToIndex(4)
    }
    
    
    private func getCachedCupSize() -> String{
        if let tmp = getStringForKey(kDJConfigCupSize){
            if tmp.characters.count < 1 {
                return kDefaultCupSize
            }
            return tmp
        }
        return kDefaultCupSize
    }
    
//    func extractHalfBodyShape(fullShape : String) -> String{
//        var value = fullShape
//        if value.characters.count < defaultFullBodyShape.characters.count{
//            value = defaultFullBodyShape
//        }
//        return (value as NSString).substringToIndex(4)
//    }
//    
//    func extractArmShape(fullShape : String) -> String{
//        var value = fullShape
//        if value.characters.count < defaultFullBodyShape.characters.count{
//            value = defaultFullBodyShape
//        }
//        let c0 = value[0] as Character
//        let c3 = value[3] as Character
//        return "\(c3)\(c0)"
//    }
//    
//    func extractLegShape(fullShape : String) -> String{
//        var value = fullShape
//        if value.characters.count < defaultFullBodyShape.characters.count{
//            value = defaultFullBodyShape
//        }
//        let c2 = value[2] as Character
//        let c4 = value[4] as Character
//        return "\(c4)\(c2)"
//    }
    
    private func getRenderedImage(img : UIImage, renderRect : CGRect, color1Image : UIImage?, color2Image : UIImage, colorId : Int) -> UIImage{
        UIGraphicsBeginImageContext(renderRect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(context!, 1, -1)
        CGContextTranslateCTM(context!, 0, -renderRect.size.height)
        CGContextDrawImage(context!, renderRect, img.CGImage!)
        CGContextClipToMask(context!, renderRect, img.CGImage!)
        if (colorId > 1){
            color1Image!.drawInRect(renderRect, blendMode: .Normal, alpha: 1)
        }
        if colorId == 1 {
            color2Image.drawInRect(renderRect, blendMode: .SoftLight, alpha: 0.6)
        }else{
            color2Image.drawInRect(renderRect, blendMode: .SoftLight, alpha: 1)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    
    private func setCachedMakeupId(makeupId : String){
        NSUserDefaults.standardUserDefaults().setObject(NSString(string: makeupId), forKey: DejaModelMakeUpId)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func setCachedHairStyleId(hairStyleId : String){
        NSUserDefaults.standardUserDefaults().setObject(NSString(string: hairStyleId), forKey: DejaModelHairStyle)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func setCachedSkinColor(skinColor : String){
        NSUserDefaults.standardUserDefaults().setObject(NSString(string: skinColor), forKey: DejaModelSkinColor)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        clearBodyImages()
    }
    
    private func clearBodyImages(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey(FrontBodyImageCache)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(BreastImageCache)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(RightBodyImageCache)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(LeftBodyImageCache)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(LegBodyImageCache)
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func setCachedHairColor(hairColor : String){
        NSUserDefaults.standardUserDefaults().setObject(NSString(string: hairColor), forKey: DejaModelHairColor)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func getCachedMakeupId() -> String{
        if let tmp = NSUserDefaults.standardUserDefaults().objectForKey(DejaModelMakeUpId){
            return "\(tmp)"
        }else{
            return kDefaultMakeupID
        }
    }
    
    private func getCachedHairStyleId() -> String{
        if let tmp = NSUserDefaults.standardUserDefaults().objectForKey(DejaModelHairStyle){
            return "\(tmp)"
        }else{
            return kDefaultHairStyleID
        }
    }
    
    private func getCachedSkinColor() -> String{
        if let tmp = NSUserDefaults.standardUserDefaults().objectForKey(DejaModelSkinColor){
            return "\(tmp)"
        }else{
            return kDefaultSkinColor
        }
    }
    
    private func getCachedHairColor() -> String{
        if let tmp = NSUserDefaults.standardUserDefaults().objectForKey(DejaModelHairColor){
            return tmp as! String
        }else{
            return kDefaultHairColor
        }
    }
    
    func getSkinColorIdFromColor(colorValue : String) -> String{
        var index = 0
        for color in self.skinColorArray {
            if color == colorValue{
                break
            }
            index += 1
        }
        return "\(index)"
    }
}

extension FittingRoomDataContainer {
    var firstTimeLikeStyle : Bool {
        get {
            return !DejaUserDefault.userDefault().boolForKey("not_first_time_like_style")
        }
        
        set {
            DejaUserDefault.userDefault().setBool(!newValue, forKey: "not_first_time_like_style")
        }
    }
    
    func firstTimeEnterFittingRoom() -> Bool{
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("firstTimeEnterFittingRoom"){
            return false
        }else{
            NSUserDefaults.standardUserDefaults().setObject("entered", forKey: "firstTimeEnterFittingRoom")
            NSUserDefaults.standardUserDefaults().synchronize()
            return true
        }
    }
    
    func isMissionTipShowedForLast1day() -> Bool{
        let currentMill = NSDate.currentTimeMillis()
        if let tmp = lastMissionTipShowTime(){
            if currentMill - tmp > 10 * 60 * 1000 {
                return false
            }else{
                return true
            }
        }
        return false
    }
    
    private func lastMissionTipShowTime() -> UInt64?{
        if let tmp = NSUserDefaults.standardUserDefaults().objectForKey("MissionLastTipShowTime"){
            if let td = tmp as? NSNumber{
                return td.unsignedLongLongValue
            }
        }
        return nil
    }
    
    func setMissionLastTipShowTime(){
        let currentMill = NSDate.currentTimeMillis()
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(unsignedLongLong: currentMill), forKey: "MissionLastTipShowTime")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func storeStringForKey(key : String, theStr : String){
        NSUserDefaults.standardUserDefaults().setObject(theStr, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getStringForKey(key : String) -> String?{
        if let tmp = NSUserDefaults.standardUserDefaults().objectForKey(key){
            if let td = tmp as? String{
                return td
            }
        }
        return nil
    }
    
    func storeImageForKey(key : String, theImage : UIImage){
        let imageData = UIImagePNGRepresentation(theImage)
        
        NSUserDefaults.standardUserDefaults().setObject(imageData, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getImageForKey(key : String) -> UIImage?{
        if let tmp = NSUserDefaults.standardUserDefaults().objectForKey(key){
            if let td = tmp as? NSData{
                return UIImage(data: td)
            }
        }
        return nil
    }
    
    func getDictionaryFromJsonName(name : String) -> NSDictionary?{
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "json")
        {
            do
            {
                let jsonString = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                if let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
                {
                    if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableLeaves) as? NSDictionary
                    {
                        return json
                    }
                }
            }
            catch let aError as NSError
            {
                aError.description
            }
        }
        return nil
    }
    
}

