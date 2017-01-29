//
//  DejaUser.swift
//  DejaFashion
//
//  Created by DanyChen on 22/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

enum RelationStatus : Int{
    case isFriend = 1
    case sendedRequest = 2
    case requestAccept = 3
    case notFriend = 4
    
    case mySelf = 5
    case notDetermined = 0
}

/**
 DEFAULT = 0
 NEW_MISSION = 1
 NEW_ITEM = 2
 FRIEND_REQUEST = 3
 */
enum FriendStatus : Int{
    case normal = 0
    case newMission = 1
    case newItem = 2
    case friendRequest = 3
}

class DejaFriend : NSObject {
    var uid = ""
    var name = "She"
    var avatar : String?
    var status : FriendStatus = .normal
    var isNew = false
    var isCelebrity = false
    var statusDesc : String?
    var clothesCount = 0
    var missionId = 0
    var missionDesc = ""
    var missionOutfitId = 0
    var fromFacebook = false
}

// Contact from Address Book
class ABContact: NSObject {
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var imageData : NSData?
}

class DejaContact: NSObject {
    var uid = ""
    
    var dejaName : String?
    var dejaImageUrl : String?
    
    var fbName : String?
    var fbImageUrl : String?
    
    var phoneNumber : String?
    var relationStatus : NSNumber?
}

class Contact: NSObject {
    var uid : String?
    
    var dejaName : String?
    var dejaImageUrl : String?
    
    var fbImageUrl : String?
    var fbName : String?
    
    var phoneNumber : String?
    var phoneImage : UIImage?
    var phoneName : String?
    
    var relationStatus : RelationStatus?
}
