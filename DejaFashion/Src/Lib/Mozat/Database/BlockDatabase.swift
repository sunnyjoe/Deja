//
//  DatabaseUtil.swift
//  DejaFashion
//
//  Created by DanyChen on 21/12/15.
//  Copyright © 2015 Mozat. All rights reserved.
//

import UIKit

private var databaseMap = [String : Database]()

private struct BaseColumns {
    static let id = "id"
    static let rawData = "raw_data"
}

class BlockTable<T : NSObject> {
    var name : String
    private var dbName : String
    private var primaryKey : String?
    private var database : Database?
    private var normalColumns : [String]?
    private var columns : [String]?
    private var queue : FMDatabaseQueue?
    
    //primaryKey should be one of the property name, columns should be the sublist of all properties
    private init(name : String, primaryKey : String?,  dbName : String, columns : [String]? = nil) {
        self.name = name
        self.dbName = dbName
        self.primaryKey = primaryKey
        self.columns = columns
        if self.columns == nil {
            self.columns = getPropertyList()
        }
        
        setupDatabase()
        if database != nil {
            queue = FMDatabaseQueue(path: database!.fmDatabase.databasePath())
        }
    }
    
    private func getPropertyList() -> [String] {
        let t = T()
        return Mirror(reflecting: t).children.filter { $0.label != nil }.map { $0.label! }
    }
    
    private func setupDatabase() -> Bool {
        if database == nil {
            if let db = databaseMap[dbName] {
                let setupSuccess = db.setupTable(name, primaryKey: primaryKey, columns: getNormalColumns())
                if setupSuccess {
                    database = db
                }else {
                    return false
                }
            }else {
                let database = Database(name: dbName)
                let setupSuccess = database.setupTable(name, primaryKey: primaryKey, columns: getNormalColumns())
                if setupSuccess {
                    self.database = database
                    databaseMap[dbName] = database
                }else {
                    return false
                }
            }
        }
        return true
    }
    
    func getNormalColumns() -> [String] {
        if normalColumns == nil {
            normalColumns = self.columns!.filter( { $0 != primaryKey} )
        }
        return normalColumns!
    }
    
    func parseResultSetToObj(resultSet : FMResultSet) -> T? {
        let obj = T()
        for key in columns! {
            let value = resultSet.objectForColumnName(key)
            if !(value is NSNull) {
                obj.setValue(value, forKey: key)
            }
        }
        return obj
    }
    
    func convertObjToValue(obj : T) -> [AnyObject?] {
        return columns!.map { obj.valueForKey($0) }
    }
    
    
    func save(obj : T) {
        if database == nil { return }
        queue?.inDatabase({(db : FMDatabase?) -> Void in
            self.database!.insert(self.name, columns: self.columns!, values: self.convertObjToValue(obj))
        })
    }
    
    func saveAll(objs : [T]){
        if database == nil { return }
        queue?.inDatabase({(db : FMDatabase?) -> Void in
            self.database!.bulkInsert(self.name, columns: self.columns!, valuesList: objs.map({ (obj : T) -> [AnyObject?] in
                self.convertObjToValue(obj)
            }))
        })
    }
    
    func query(columnNames : [String], values : [AnyObject?], orderBy : String = "", handler : ([T]) -> Void) {
        if database == nil { handler([]) }
        queue?.inDatabase({(db : FMDatabase?) -> Void in
            var array = [T]()
            if let rs = self.database!.query(self.name, columns: columnNames, values: values, orderBy: orderBy) {
                while rs.next() {
                    if let t = self.parseResultSetToObj(rs) {
                        array.append(t)
                    }
                }
            }
            handler(array)
        })
    }
    
    func querySingle(columnNames : [String], values : [AnyObject?], handler : (T?) -> Void){
        if database == nil { handler(nil)}
        queue?.inDatabase({(db : FMDatabase?) -> Void in
            if let rs = self.database!.query(self.name, columns: columnNames, values: values) {
                while rs.next() {
                    handler(self.parseResultSetToObj(rs))
                    break
                }
            }
        })
    }
    
    func queryAll(orderby : String = "", handler : ([T]) -> Void){
        if database == nil {
            handler([])
        }
        queue?.inDatabase({(db : FMDatabase?) -> Void in
            var array = [T]()
            if let rs = self.database!.query(self.name, columns: nil, values: nil, orderBy: orderby) {
                while rs.next() {
                    if let t = self.parseResultSetToObj(rs) {
                        array.append(t)
                    }
                }
            }
            handler(array)
        })
    }
    
    func delete(columnNames : [String], values : [AnyObject?]) {
        if database == nil { return  }
        queue?.inDatabase({(db : FMDatabase?) -> Void in
            self.database!.delete(self.name, columns: columnNames, values: values)
        })
    }
    
    func deleteAll() {
        if database == nil { return  }
        queue?.inDatabase({(db : FMDatabase?) -> Void in
            self.database!.delete(self.name, columns: nil, values: nil)
        })
    }
    
    func executeUpdates(sqls : [String]) {
        if database == nil { return  }
        queue?.inDatabase({(db : FMDatabase?) -> Void in
            self.database!.executeUpdates(sqls)
        })
    }
}


