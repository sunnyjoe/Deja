//
//  UserGuideMissionNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 26/4/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class UserGuideMissionNetTask: DJHTTPNetTask {

    var mission : StylingMission?
    var userInfo : DejaFriend?
    
    override func uri() -> String {
        return "apis_bm/mission/get_user_guide_mission/v4"
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let missionJson = response["missionInfo"] as? NSDictionary{
            mission = StylingMission.parseMissionInfo(missionJson)
        }
        
        if let info = response["userInfo"] as? NSDictionary {
            let user = DejaFriend()
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
            
            if let id = Int((mission?.id)!) {
                user.missionId = id
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
            userInfo = user

        }
    }
    
}
