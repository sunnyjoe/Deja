//
//  FriendListNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 28/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

class FriendListNetTask: DJHTTPNetTask {
    
    var page = 0
    var pageSize = 20
    
    var friends = [DejaFriend]()
    
    var messageCount = 0
    
    var end = false
    var total = 0
    
    override func uri() -> String!
    {
        return "apis_bm/friend/get_buddy_info/v4"
    }
    
    class func uri() -> String!
    {
        return "apis_bm/friend/get_buddy_info/v4"
    }
    
    override func query() -> [NSObject : AnyObject]!
    {
        var dic = Dictionary<String , AnyObject>()
        dic["page"] = page
        dic["page_size"] = pageSize
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!)
    {
        if let data = response["data"] as? [NSDictionary]
        {
            var friends = [DejaFriend]()
            for dic in data {
                let user = DejaFriend()
                if let msgType = dic["msg_type"] as? NSNumber {
                    if let status = FriendStatus(rawValue: msgType.integerValue) {
                        user.status = status
                    }
                    if let msg = dic["msg"] as? String {
                        user.statusDesc = msg
                    }
                }
                
                if let wardrobe_count = dic["wardrobe_count"] as? String {
                    user.clothesCount = Int(wardrobe_count)!
                }
                
                if let type = dic["type"] as? Int {
                    user.isNew = type != 0
                }
                
                if let info = dic["user_info"] as? NSDictionary {
                    if let name = info["name"] as? String {
                        user.name = name
                    }
                    if let avatar = info["avatar"] as? String {
                        user.avatar = avatar
                    }
                    if let uid = info["uid"] as? String{
                        user.uid = uid
                    }
                    if let type = info["type"] as? Int {
                        user.isCelebrity = type != 0
                    }
                    
                    if let bindParties = info["bind_parties"] as? [NSDictionary] {
                        for bindParty in bindParties {
                            if let id = bindParty["thirdPartyId"] as? Int {
                                if id == 1 {
                                    user.fromFacebook = true
                                    break
                                }
                            }
                        }
                    }
                }
                //{ "mission_id": 123, "mission_outfit_id" : 456}
                if let extraInfo = dic["extra"] as? NSDictionary {
                    if let missionId = extraInfo["mission_id"] as? Int {
                        user.missionId = missionId
                    }
                    if let missionOutfitId = extraInfo["mission_outfit_id"] as? Int {
                        user.missionOutfitId = missionOutfitId
                    }
                }
                
                friends.append(user)
            }
            self.friends = friends
        }
        
        if let data = response["end"] as? Bool
        {
            self.end = data
        }
        if let data = response["total"] as? Int
        {
            self.total = data
        }
        if let data = response["message_count"] as? Int
        {
            self.messageCount = data
        }

    }
    
    override func didFail(error: NSError!)
    {
        
    }
    
}
