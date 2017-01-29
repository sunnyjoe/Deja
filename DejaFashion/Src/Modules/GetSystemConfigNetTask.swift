//
//  GetSystemConfigNetTask.swift
//  DejaFashion
//
//  Created by Sun lin on 16/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation
import SwiftyJSON

class GetSystemConfigNetTask: DJHTTPNetTask
{
    
    var patchUrl : String?

    override func uri() -> String!
    {
        return "apis_bm/config/sync/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod
    {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        var versions = Dictionary<String , AnyObject>()
        
        let configObjects = ConfigDataContainer.sharedInstance.configMap.values
        
        for configId in ConfigId.allValue() {
            versions[configId.rawValue] = 0
        }
        
        for obj in configObjects {
            versions[obj.configId!] = obj.version!
        }
        
        versions["update_info"] = 0
        
        dic["versions"] = versions
        
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    { 
        ConfigDataContainer.sharedInstance.parseConfigJson(response)
        let json = JSON(response)
        let updateInfo = json["data"]["update_info"]
        if updateInfo != nil
        {
            if updateInfo["force"] != 0
            {
                //alert every time
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    DJAlertView(title: DJStringUtil.localize("New Version Available", comment:""), message: updateInfo["desc"].stringValue, cancelButtonTitle: DJStringUtil.localize("Exit", comment:""), otherButtonTitles: [DJStringUtil.localize("Update", comment:"")], onDismiss: { (buttonIndex) -> Void in
                        if buttonIndex == 0
                        {
//                            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_update_force_ok)
                            let url = NSURL(string: updateInfo["url"].stringValue)
                            UIApplication.sharedApplication().openURL(url!)
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                                exit(0);
                            })
                        }
                        }, onCancel: { () -> Void in
//                            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_update_force_cancel)
                            exit(0)
                    }).show()
                })
            }
            else
            {
                //only alert once
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    DJAlertView(title: DJStringUtil.localize("New Version Available", comment:""), message: updateInfo["desc"].stringValue, cancelButtonTitle: DJStringUtil.localize("Cancel", comment:""), otherButtonTitles: [DJStringUtil.localize("Update", comment:"")], onDismiss: { (buttonIndex) -> Void in
                        if buttonIndex == 0
                        {
//                            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_update_suggest_ok)
                            let url = NSURL(string: updateInfo["url"].stringValue)
                            UIApplication.sharedApplication().openURL(url!)
                        }
                        }, onCancel: { () -> Void in
//                            DJStatisticsLogic.instance().addTraceLog(kStatisticsID_update_suggest_cancel)
                            
                    }).show()
                })
                
            }
        }
        
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        if version != nil
        {
            let currentVersionPatchUrl = json["data"]["patch_info"][version!]["url"]
            if currentVersionPatchUrl != nil
            {
                DJJSPatchHandler.instance().downLoadJSPatch(currentVersionPatchUrl.stringValue, version: version!)
                self.patchUrl = currentVersionPatchUrl.stringValue
            }
            if let patchVersions = json["data"]["patch_info"].dictionary?.keys {
                var maxPatchVersion = version
                for patchVersion in patchVersions {
                    if patchVersion > maxPatchVersion {
                        maxPatchVersion = patchVersion
                    }
                }
                if maxPatchVersion != version {
                    let patchUrl = json["data"]["patch_info"][maxPatchVersion!]["url"]
                    if patchUrl != nil {
                        DJJSPatchHandler.instance().downLoadJSPatch(patchUrl.stringValue, version: maxPatchVersion)
                    }
                }
            }
        }
        
        let faceInfos = ConfigDataContainer.sharedInstance.getConfigMissionFaces()
        if faceInfos.count > 0 {
            StylingMissionDataContainer.sharedInstance.downloadFaceImages()
        }
        
        if json["data"]["statistics"] != nil {
            DJHookMethodTool.hookStatistics()
        }
    }
    
    
    override func didFail(error: NSError!)
    {
    }

}
