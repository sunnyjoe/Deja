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

class Table<T : NSObject> {
    
    var name : String
    private var dbName : String
    private var primaryKey : String?
    private var database : Database?
    private var normalColumns : [String]?
    private var columns : [String]?
    
    //primaryKey should be one of the property name, columns should be the sublist of all properties
    private init(name : String, primaryKey : String?,  dbName : String, columns : [String]? = nil) {
        self.name = name
        self.dbName = dbName
        self.primaryKey = primaryKey
        self.columns = columns
        if self.columns == nil {
            self.columns = getPropertyList()
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
    
    func save(obj : T) -> Bool {
        if !setupDatabase() { return false }
        return database!.insert(name, columns: columns!, values: convertObjToValue(obj))
    }
    
    func convertObjToValue(obj : T) -> [AnyObject?] {
        return columns!.map { obj.valueForKey($0) }
    }
    
    func saveAll(objs : [T]) -> Bool {
        if !setupDatabase() { return false }
        
        return database!.bulkInsert(name, columns: columns!, valuesList: objs.map({ (obj : T) -> [AnyObject?] in
            return convertObjToValue(obj)
        }))
    }
    
    func query(columnNames : [String], values : [AnyObject?], orderBy : String = "") -> [T] {
        if !setupDatabase() { return [] }
        var array = [T]()
        if let rs = database!.query(name, columns: columnNames, values: values, orderBy: orderBy) {
            while rs.next() {
                if let t = parseResultSetToObj(rs) {
                    array.append(t)
                }
            }
        }
        return array
    }
    
    func querySingle(columnNames : [String], values : [AnyObject?]) -> T? {
        if !setupDatabase() { return nil }
        if let rs = database!.query(name, columns: columnNames, values: values) {
            while rs.next() {
                return parseResultSetToObj(rs)
            }
        }
        return nil
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
    
    func queryAll(orderby : String = "") -> [T] {
        if !setupDatabase() { return [] }
        var array = [T]()
        if let rs = database!.query(name, columns: nil, values: nil, orderBy: orderby) {
            while rs.next() {
                if let t = parseResultSetToObj(rs) {
                    array.append(t)
                }
            }
        }
        return array
    }
    
    func delete(columnNames : [String], values : [AnyObject?]) -> Bool {
        if !setupDatabase() { return false }
        return database!.delete(name, columns: columnNames, values: values)
    }
    
    func deleteAll() -> Bool {
        if !setupDatabase() { return false }
        return database!.delete(name, columns: nil, values: nil)
    }
    
    func executeUpdates(sqls : [String]) -> Bool {
        if !setupDatabase() { return false }
        return database!.executeUpdates(sqls)
    }
}

//class CommonTable : Table<NSDictionary> {
//    
//    init(name: String, primaryKey: String, dbName: String) {
//        super.init(name: name, primaryKey: primaryKey, dbName: dbName)
//    }
//    
//    override func getAllColumns() -> [String] {
//        return [primaryKey!, BaseColumns.rawData]
//    }
//    
//    override func getNormalColumns() -> [String] {
//        return [BaseColumns.rawData]
//    }
//    
//    override func convertObjToValue(obj: NSDictionary) -> [AnyObject?] {
//        do {
//            let data : AnyObject = try NSJSONSerialization.dataWithJSONObject(obj, options: .PrettyPrinted)
//            return [data]
//        }catch {
//            return [NSNull()]
//        }
//    }
//    
//    override func parseResultSetToObj(resultSet: FMResultSet) -> NSDictionary? {
//        do {
//            return try NSJSONSerialization.JSONObjectWithData(resultSet.dataForColumn(BaseColumns.rawData), options: .AllowFragments) as? NSDictionary
//        } catch {
//            return nil
//        }
//    }
//    
//    func queryById(id : String) -> NSDictionary? {
//        return querySingle([primaryKey!], values: [id])
//    }
//}

func TableWith<T : NSObject>(tableName : String?, type : T.Type, primaryKey : String?, dbName : String = "Default") -> Table<T> {
    return Table<T>(name: (tableName == nil ? NSStringFromClass(T):tableName!), primaryKey : primaryKey, dbName : dbName)
}

func TableWith<T : NSObject>(tableName : String?, type : T.Type, primaryKey : String?, dbName : String = "Default", columns : [String]? = nil) -> Table<T> {
    return Table<T>(name: (tableName == nil ? NSStringFromClass(T):tableName!), primaryKey : primaryKey, dbName : dbName, columns : columns)
}

//func tableWithName(name : String, primaryKey : String, dbName : String = "Default") -> CommonTable {
//    return CommonTable(name: name, primaryKey : primaryKey, dbName: dbName)
//}

class Database : NSObject {
    
    var fmDatabase : FMDatabase
    
    init(name : String) {
        let fileManager = NSFileManager.defaultManager()
        let documents = try! fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent(name + ".db")!
        fmDatabase = FMDatabase(path: fileURL.path)
        if !fmDatabase.open() {
            print("Unable to open database")
            fmDatabase.close()
            if let path = fileURL.path {
                do {
                    try fileManager.removeItemAtPath(path)
                    print("delete database file success")
                }catch {
                    print("Unable to delete database")
                }
            }
        }
    }

    func setupTable(name : String, primaryKey : String?, columns : [String]) -> Bool {
        if fmDatabase.open() && columns.count > 0 {
            if let existingColumns = getExistingColumnsOfTable(name) {
                return updateTableStructure(name ,columns: columns, originColumnNames: existingColumns)
            }else {
                return createTable(name, primaryKey: primaryKey, columns: columns)
            }
        }else {
            return false
        }
    }
    
    func getExistingColumnsOfTable(tableName : String) -> Set<String>? {
        let rs = fmDatabase.executeQuery("PRAGMA table_info(\(tableName))", withArgumentsInArray: nil)
        var result = Set<String>()
        while rs.next() {
            if let columnName = rs.stringForColumn("name") {
                result.insert(columnName)
            }
        }
        return result.count > 0 ? result : nil
    }
    
    func updateTableStructure(tableName : String, columns : [String], originColumnNames : Set<String>) -> Bool{
        var columnsNeedToAdd = [String]()
        var result = true
        for column in columns {
            if !originColumnNames.contains(column) {
                columnsNeedToAdd.append(column)
            }
        }
        if columnsNeedToAdd.count == 0 {
            return true
        }
        
        for column in columnsNeedToAdd {
            let sql = "alter table " + tableName + " add column " + column + " TEXT"
            result = fmDatabase.executeUpdate(sql, withArgumentsInArray: nil)
        }
        
        return result
    }
    
    
    func createTable(tableName : String, primaryKey : String?, columns : [String]) -> Bool {
        var sql = "create table " + tableName + "("
        if let primaryColumn = primaryKey {
            sql += primaryColumn + " TEXT primary key"
        }else {
            sql += "id INTEGER primary key autoincrement"
        }
        for column in columns {
            sql += ", " + column + " TEXT"
        }
        sql += ")"
        return fmDatabase.executeUpdate(sql, withArgumentsInArray: nil)
    }
    
    func insert(tableName : String, columns : [String], values : [AnyObject?]) -> Bool {
        return insertWithPreparedSql(prepareSqlForInsertColumns(tableName, columns: columns), valueCount: columns.count, values: values)
    }
    
    private func insertWithPreparedSql(sql : String, valueCount : Int,  values : [AnyObject?]) -> Bool {
        if valueCount == 0 || valueCount != values.count {
            return false
        }
        return fmDatabase.executeUpdate(sql, withArgumentsInArray: convertNullObjects(valueCount, values: values))
    }
    
    private func convertNullObjects(count : Int, values : [AnyObject?]) -> [AnyObject] {
        var objects = [AnyObject]()
        for i in 0..<count {
            if values[i] == nil {
                objects.append(NSNull())
            }else {
                objects.append(values[i]!)
            }
        }
        return objects
    }
    
    func prepareSqlForInsertColumns(tableName : String, columns : [String]) -> String {
        var combineColumnString = ""
        var questioMarks = ""
        for i in 0..<columns.count {
            if i == 0 {
                combineColumnString += columns[0]
                questioMarks += "?"
            }else {
                combineColumnString += "," + columns[i]
                questioMarks += ",?"
            }
        }
        return "insert or replace into " + tableName + "(" + combineColumnString + ") values(" + questioMarks + ")";
    }
    
    func bulkInsert(tableName : String, columns : [String], valuesList : [[AnyObject?]]) -> Bool {
        fmDatabase.beginTransaction()
        var success = true
        let sql = prepareSqlForInsertColumns(tableName, columns: columns)
        for values in valuesList {
            if !insertWithPreparedSql(sql, valueCount: columns.count, values: values) {
                success = false
                break
            }
        }
        if !success {
            fmDatabase.rollback()
        }else {
            fmDatabase.commit()
        }
        return success
    }
    
    func executeUpdates(sqls : [String]) -> Bool{
        fmDatabase.beginTransaction()
        var success = true
        for sql in sqls {
            if !fmDatabase.executeUpdate(sql, withArgumentsInArray: nil) {
                success = false
                break
            }
        }
        if !success {
            fmDatabase.rollback()
        }else {
            fmDatabase.commit()
        }
        return success
    }
    
    func query(tableName : String, columns : [String]?, values : [AnyObject?]?, orderBy : String = "") -> FMResultSet? {
        var orderBySuffix = ""
        if orderBy.characters.count > 0 {
            orderBySuffix = "order by " + orderBy
        }
        if columns == nil || columns?.count == 0 {
            return fmDatabase.executeQuery("select * from " + tableName + " " + orderBySuffix, withArgumentsInArray: nil)
        }else if columns?.count == values?.count {
            var condition = " where "
            var i = 0
            for column in columns! {
                if i == 0 {
                    condition += column + "=?"
                }else {
                    condition += "and " + column + "=? "
                }
                i += 1
            }
            return fmDatabase.executeQuery("select * from " + tableName + condition + " " + orderBySuffix, withArgumentsInArray: convertNullObjects(columns!.count, values: values!))
        }
        return nil
    }
    
    func delete(tableName : String, columns : [String]?, values : [AnyObject?]?) -> Bool {
        if columns == nil || columns?.count == 0 {
            return fmDatabase.executeUpdate("delete from " + tableName, withArgumentsInArray: nil)
        }else if columns?.count == values?.count {
            var condition = " where "
            var i = 0
            for column in columns! {
                if i == 0 {
                    condition += column + "=?"
                }else {
                    condition += "and " + column + "=? "
                }
                i += 1
            }
            let query = "delete from " + tableName + condition
            let argus = convertNullObjects(columns!.count, values: values!)
            return fmDatabase.executeUpdate(query, withArgumentsInArray: argus)
        }
        return false
    }
}
