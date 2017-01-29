//
//  WardrobeSyncLogic.swift
//  DejaFashion
//
//  Created by Sun lin on 17/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import Foundation

private let syncStatusWaiting = 0
private let syncStatusDone    = 1

let dataStatusRemoved = 2
let dataStatusAdded   = 1


class SyncItem : NSObject {
    var id : String?
    var ts : String?
    var syncStatus : NSNumber?
    var dataStatus : NSNumber?
    
    override init() {
    }
    
    init(id : String, ts : UInt64, syncStatus : Int, dataStatus : Int) {
        self.id = id
        self.ts = ts.description
        self.syncStatus = NSNumber(integer: syncStatus)
        self.dataStatus = NSNumber(integer: dataStatus)
    }
}

private let WardrobeTable = TableWith("wardrobe", type: SyncItem.self, primaryKey: "id", dbName: "wardrobe")

class WardrobeSyncLogic: NSObject, MONetTaskDelegate
{
    static let sharedInstance = WardrobeSyncLogic()
    
    var isSyncing = false
    var tempItemsInMemory = [String : SyncItem]()
    
    private override init() {
        super.init()
        MONetTaskQueue.instance().addTaskDelegate(self, uri: LoginNetTask.uri())
        MONetTaskQueue.instance().addTaskDelegate(self, uri: RegisterNetTask.uri())
        MONetTaskQueue.instance().addTaskDelegate(self, uri: WardrobeSyncNetTask.uri())
        MONetTaskQueue.instance().addTaskDelegate(self, uri: LogoutNetTask.uri())
    }
    
    func addToWardrobe(ids : [(mills : UInt64,  cid : String)], fromServer : Bool = false) {
        updateWardrobe(ids, fromServer: fromServer, dataStatus: dataStatusAdded)
    }
    
    func removeFromWardrobe(ids : [String], fromServer : Bool = false) {
        updateWardrobe(ids.map { (0, $0) }, fromServer: fromServer, dataStatus: dataStatusRemoved)
    }
    
    func updateTsOfItems(tsOfItems : [(UInt64, String)]) {
        var sqls = [String]()
        for ts in tsOfItems {
            let sql = "UPDATE \(WardrobeTable.name) SET ts=\(ts.0) WHERE id=\(ts.1)"
            sqls.append(sql)
            print(sql)
        }
        WardrobeTable.executeUpdates(sqls)
    }
    
    func queryAll() -> [SyncItem] {
        let datas = WardrobeTable.query(["dataStatus"], values: [NSNumber(integer: dataStatusAdded)], orderBy: "ts")
        return datas
    }
    
    private func updateWardrobe(ids : [(mills : UInt64,  cid : String)], fromServer : Bool = false, dataStatus : Int) {
        if fromServer {
            var syncItems = [SyncItem]()
            ids.forEach({ (id) -> () in
                let item = SyncItem(id: id.cid, ts: id.mills, syncStatus: syncStatusDone, dataStatus: dataStatus)
                syncItems.append(item)
            })
            WardrobeTable.saveAll(syncItems)
            return
        }
        if isSyncing {
            ids.forEach({ (id) -> () in
                let item = SyncItem(id: id.cid, ts: id.mills, syncStatus: syncStatusWaiting, dataStatus: dataStatus)
                tempItemsInMemory[id.cid] = item
            })
        }else {
            var syncItems = [SyncItem]()
            ids.forEach({ (id) -> () in
                let item = SyncItem(id: id.cid, ts: id.mills, syncStatus: syncStatusWaiting, dataStatus: dataStatus)
                syncItems.append(item)
            })
            WardrobeTable.saveAll(syncItems)
            self.loopSync()
        }
    }
    
    func triggerSync()
    {
        if AccountDataContainer.sharedInstance.userID == nil
        {
            return
        }
        if !self.isSyncing
        {
            self.isSyncing = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500), dispatch_get_global_queue(0, 0), { () -> Void in
                self.loopSync(true)
            })
        }

    }
    
    private func loopSync(force: Bool = false)
    {
        let unSyncClothes = WardrobeTable.query(["syncStatus"], values: [NSNumber(integer: syncStatusWaiting)])
        if unSyncClothes.count > 0 || WardrobeDataContainer.sharedInstance.syncVersion == 0 || force
        {
            self.isSyncing = true
            dispatch_async(dispatch_get_main_queue(), {
                
                self.sendSyncNetTask(unSyncClothes)
            })
        }else {
            self.isSyncing = false
        }
    }
    
    
    private func sendSyncNetTask(waiting4Sync : [SyncItem])
    {
        var actions = [WardrobeAction]()
        for clothes in waiting4Sync
        {
            let act = WardrobeAction()
            act.clothesID = clothes.id
            if let status = clothes.dataStatus?.integerValue
            {
                act.flag = status
            }
//            switch clothes.dataStatus!
//            {
//            case dataStatusAdded:
//                act.flag = dataStatusAdded
//                break
//            case dataStatusRemoved:
//                act.flag = dataStatusRemoved
//                break
//            default:
//                act.flag = 1
//                break
//            }
            actions.append(act)
        }
        let task = WardrobeSyncNetTask()
        task.version = WardrobeDataContainer.sharedInstance.syncVersion!
        task.wardrobeActions = actions
        MONetTaskQueue.instance().addTaskDelegate(self, uri: task.uri())
        MONetTaskQueue.instance().addTask(task)
    }
    
    func netTaskDidEnd(task: MONetTask!)
    {
        switch task.uri()
        {
        case LoginNetTask.uri():
//            WardrobeTable.deleteAll()
            WardrobeDataContainer.sharedInstance.clear()
            self.triggerSync()
            break
        case WardrobeSyncNetTask.uri():
            self.isSyncing = false
            
            dispatch_async(dispatch_get_global_queue(0, 0), {
                
                if self.tempItemsInMemory.count > 0 {
                    WardrobeTable.saveAll(Array(self.tempItemsInMemory.values))
                    self.tempItemsInMemory.removeAll()
                    self.loopSync()
                }
            })
            break
        case LogoutNetTask.uri():
            WardrobeTable.deleteAll()
            WardrobeDataContainer.sharedInstance.clear()
            break
        case RegisterNetTask.uri():
            let unSyncClothes = WardrobeTable.query(["syncStatus"], values: [NSNumber(integer: syncStatusWaiting)])
            if unSyncClothes.count > 0 && !isSyncing {
                isSyncing = true
                sendSyncNetTask(unSyncClothes)
            }else {
                isSyncing = false
            }

            break
        default:
            ""
        }
    }
    
    func netTaskDidFail(task: MONetTask!)
    {
        switch task.uri()
        {
        case LoginNetTask.uri():
            break
        case WardrobeSyncNetTask.uri():
            self.isSyncing = false
        default:
            ""
        }
    }
    
    func clearUserData() {
        WardrobeTable.deleteAll()
        WardrobeDataContainer.sharedInstance.clear()
    }
    
//    -(void)loopSyncAll
//    {
//    if([DJUserDataContainer instance].uid.length)
//    {
//    [self loopSyncFavorite:NO];
//    [self loopSyncCreation:NO];
//    [self loopSyncCreationFavorite:NO];
//    [self loopSyncFollowingUser:NO];
//    [self loopSyncRecent];
//    }
//    }
}