//
//  UnBindAccountNetTask.swift
//  DejaFashion
//
//  Created by DanyChen on 8/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//

class UnBindAccountNetTask: DJHTTPNetTask {

    var accountType : AccountType?
    
    override func uri() -> String {
        return "apis_bm/account/unbind/v4"
    }
    
    class func uri() -> String {
        return "apis_bm/account/unbind/v4"
    }
    
    override func method() -> DJHTTPNetTaskMethod {
        return DJHTTPNetTaskPost
    }
    
    override func query() -> [NSObject : AnyObject]! {
        var dic = [NSObject : AnyObject]()
        if let type = accountType {
            dic["third_party_id"] = NSNumber(integer: type.rawValue)
        }
        return dic
    }
    
    override func didResponseJSON(response: [NSObject : AnyObject]!) {
        if let infos = AccountDataContainer.sharedInstance.bindInfos {
            var newInfos = [BindInfo]()
            for info in infos {
                if info.partyId != accountType?.rawValue {
                    newInfos.append(info)
                }
            }
            AccountDataContainer.sharedInstance.bindInfos = newInfos
        }
        
    }
    
}
