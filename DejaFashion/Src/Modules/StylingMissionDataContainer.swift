//
//  StylingMissionDataContainer.swift
//  DejaFashion
//
//  Created by DanyChen on 25/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit
import SDWebImage

class StylingMissionDataContainer: NSObject {
    
    static let sharedInstance = StylingMissionDataContainer()
    
    func getFaceImageByMissionId(missionId : String) -> UIImage? {
        let faceInfos = ConfigDataContainer.sharedInstance.getConfigMissionFaces()
        for faceInfo in faceInfos {
            if faceInfo.missionId == missionId {
                return SDImageCache.sharedImageCache().imageFromDiskCacheForKey(faceInfo.faceImageUrl)
            }
        }
        
        return nil
    }
    
    func downloadFaceImages() {
        let faceInfos = ConfigDataContainer.sharedInstance.getConfigMissionFaces()
        let group = dispatch_group_create()
        for faceInfo in faceInfos {
            let url = faceInfo.faceImageUrl
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
                    }
                }catch (let error) {
                    print(error)
                }
            })
        }
    }
    
}
