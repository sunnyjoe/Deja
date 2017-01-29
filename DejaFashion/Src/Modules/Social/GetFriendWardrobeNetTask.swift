//
//  GetFriendWardrobeNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 28/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class GetFriendWardrobeNetTask: DJHTTPNetTask {
    
    var clothesList = [Clothes]()
    
    var mission : StylingMission?
    
    var buddyUid : String?
    
    var missionOutfitId : Int = 0
    
    var friendInfo : DejaFriend?
    
    override func uri() -> String!
    {
        return "apis_bm/friend/get_buddy_wardrobe_info/v4"
    }
    
    class func uri() -> String!
    {
        return "apis_bm/friend/get_buddy_wardrobe_info/v4"
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = Dictionary<String , AnyObject>()
        if let id = buddyUid {
            dic["buddy_uid"] = id
        }
        dic["page_size"] = 200
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let data = response["data"] as? [NSDictionary] {
            var list = [Clothes]()
            for info in data {
                var new = false
                if let isNew = info["new"] as? Bool {
                    new = isNew
                }
                if let clothesInfo = info["product_info"] as? NSDictionary {
                    let clothes = Clothes.parseClothes(clothesInfo)
                    clothes.isNew = new
                    list.append(clothes)
                }
                
                
            }
            clothesList = list
        }
        if let missionInfo = response["mission"] as? NSDictionary {
           self.mission = StylingMission.parseMissionInfo(missionInfo)
        }
        if let outfitId = response["mission_outfit_id"] as? Int {
            self.missionOutfitId = outfitId
        }
        if let userInfo = response["user_info"] as? NSDictionary {
            friendInfo = DejaFriend()
            if let uid = userInfo["uid"] as? String {
                friendInfo?.uid = uid
            }
            if let name = userInfo["name"] as? String {
                friendInfo?.name = name
            }
            if let avatar = userInfo["avatar"] as? String {
                friendInfo?.avatar = avatar
            }
        }
    }

}
