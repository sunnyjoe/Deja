//
//  AccountDataContainer.swift
//  DejaFashion
//
//  Created by Sun lin on 16/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

let DEFAULTS_KEY_USER_ID    = "deja_v3_user_id"
let DEFAULTS_KEY_SIGNATURE  = "deja_v3_signature"
let DEFAULTS_KEY_USER_NAME  = "deja_v3_user_name"
let DEFAULTS_KEY_AVATAR     = "deja_v3_avatar"
let DEFAULTS_KEY_EMAIL     = "deja_v3_email"
let DEFAULTS_KEY_GENDER     = "deja_v3_gender"
let DEFAULTS_KEY_CART_ID     = "deja_v3_cart_id"
let DEFAULTS_KEY_BIND_INFOS    = "deja_v3_bind_infos"
let DEFAULTS_KEY_LOGIN_TYPE     = "deja_v3_login_type"

let DEFAULTS_KEY_PUSH_TOKEN = "deja_v3_push_token"

class BindInfo : NSObject, NSCoding{
    var partyId = 0
    var identifier : String?
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        partyId = aDecoder.decodeObjectForKey("partyId") as! Int
        identifier = aDecoder.decodeObjectForKey("identifier") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(partyId, forKey: "partyId")
        aCoder.encodeObject(identifier, forKey: "identifier")
    }
}

enum AccountType : Int{
    case Facebook = 1
    case SMS = 5
    
    case Anonymous = 0
}

class AccountDataContainer : NSObject
{
    static let sharedInstance = AccountDataContainer()
    
    private override init() {
        super.init()
    }
    
    private func setObject(value: AnyObject?, forKey defaultName: String)
    {
        if value == nil
        {
            DejaUserDefault.userDefault().removeObjectForKey(defaultName)
        }
        else
        {
            DejaUserDefault.userDefault().setObject(value, forKey: defaultName)
        }
        DejaUserDefault.userDefault().synchronize()
    }
    
    func stringForKey(key : String) -> String? {
        return DejaUserDefault.userDefault().objectForKey(key) as? String
    }
    
    func setString(value : String?, forKey key : String) {
        self.setObject(value, forKey: key)
    }
    
    var userID : String?
        {
        get
        {
            return stringForKey(DEFAULTS_KEY_USER_ID)
        }
        set
        {
            setString(newValue, forKey: DEFAULTS_KEY_USER_ID)
        }
    }
    
    var signature : String?
        {
        get
        {
            return stringForKey(DEFAULTS_KEY_SIGNATURE)
        }
        set
        {
            setString(newValue, forKey: DEFAULTS_KEY_SIGNATURE)
        }
    }
    
    var userName : String?
        {
        get
        {
            return stringForKey(DEFAULTS_KEY_USER_NAME)
        }
        set
        {
            setString(newValue, forKey: DEFAULTS_KEY_USER_NAME)
        }
    }
    
    var avatar : String?
        {
        get
        {
            return stringForKey(DEFAULTS_KEY_AVATAR)
            
        }
        set
        {
            setString(newValue, forKey: DEFAULTS_KEY_AVATAR)
        }
    }
    
    var email : String?
        {
        get
        {
            return DejaUserDefault.userDefault().objectForKey(DEFAULTS_KEY_EMAIL) as? String
        }
        set
        {
            self.setObject(newValue, forKey: DEFAULTS_KEY_EMAIL)
        }
    }
    
    var gender : String?
        {
        get
        {
            return DejaUserDefault.userDefault().objectForKey(DEFAULTS_KEY_GENDER) as? String
        }
        set
        {
            self.setObject(newValue, forKey: DEFAULTS_KEY_GENDER)
        }
    }
    
    var cartId : String? {
        get
        {
            return stringForKey(DEFAULTS_KEY_CART_ID)
        }
        set
        {
            setString(newValue, forKey: DEFAULTS_KEY_CART_ID)
        }
    }
    
    var pushToken : String? {
        get
        {
            return stringForKey(DEFAULTS_KEY_PUSH_TOKEN)
        }
        set
        {
            setString(newValue, forKey: DEFAULTS_KEY_PUSH_TOKEN)
        }
    }
    /*
    func savePeople(people:[Person]) {
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(people as NSArray)
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(archivedObject, forKey: UserDefaultsPeopleKey)
    defaults.synchronize()
    }
    
    func retrievePeople() -> [Person]? {
    if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsPeopleKey) as? NSData {
    return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [Person]
    }
    return nil
    }
    
    
    */
    
    var bindInfos : [BindInfo]? {
        get
        {
            
            if let unarchivedObject = DejaUserDefault.userDefault().objectForKey(DEFAULTS_KEY_BIND_INFOS) as? NSData {
                return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [BindInfo]
            }
            return nil
        }
        set
        {
            if let infos = newValue {
                let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(infos as NSArray)
                setObject(archivedObject, forKey: DEFAULTS_KEY_BIND_INFOS)
            }else {
                setObject(nil, forKey: DEFAULTS_KEY_BIND_INFOS)
            }
        }
    }
    
    var bindedFacebookInfo : BindInfo? {
        get {
            if let infos = bindInfos {
                for info in infos {
                    if info.partyId == AccountType.Facebook.rawValue {
                        return info
                    }
                }
            }
            return nil
        }
    }
    
    var currentAccountType : AccountType {
        get
        {
            if let string = stringForKey(DEFAULTS_KEY_LOGIN_TYPE) {
                if let number = Int(string) {
                    if let type = AccountType(rawValue: number) {
                        return type
                    }
                }
            }
            return .Anonymous
        }
        set
        {
            setString(newValue.rawValue.description, forKey: DEFAULTS_KEY_LOGIN_TYPE)
        }
    }
    
    func isAnonymous() -> Bool {
        return currentAccountType == .Anonymous
    }
    
//    func valueInKeyChain(key : String) -> String? {
//        return SSKeychain.passwordForService(NSBundle.mainBundle().bundleIdentifier, account: key)
//    }
//    
//    func setValueInKeyChain(value: String?, forKey key : String) {
//        if let v = value {
//            SSKeychain.setPassword(v, forService: NSBundle.mainBundle().bundleIdentifier, account: key)
//        }
//    }
}