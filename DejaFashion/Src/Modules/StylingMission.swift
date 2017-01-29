//
//  StylingMission.swift
//  DejaFashion
//
//  Created by DanyChen on 28/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

import UIKit

class Occasion : NSObject {
    var id : String?
    var image : String?
    var name : String?
}

class StylingMission: NSObject {
    var id : String?
    var desc : String?
    var outfitCount = 0
    var occasion : Occasion?
}

extension StylingMission {
    static func parseMissionInfo(missionInfo : NSDictionary) -> StylingMission {
        let mission = StylingMission()
        mission.id = missionInfo["id"] as? String
        mission.desc = missionInfo["description"] as? String
        if let count = missionInfo["outfit_count"] as? Int {
            mission.outfitCount = count
        }
        mission.id = missionInfo["id"] as? String
        if let occasionInfo = missionInfo["occasion"] as? NSDictionary {
            let occasion = Occasion()
            occasion.id = occasionInfo["id"] as? String
            occasion.image = occasionInfo["image"] as? String
            occasion.name = occasionInfo["name"] as? String
            mission.occasion = occasion
        }
        return mission
    }
}
