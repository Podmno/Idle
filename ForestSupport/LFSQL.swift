//
//  LFSQL.swift
//  Idle
//
//  Created by Ki MNO on 2024/6/22.
//

import Foundation
import SQLite

public class LFSQL : NSObject {
    
    
    let dbPath = NSHomeDirectory() + "/Documents/sq3.db"
    
    let app_table = Table("app")
    let db_version = Expression<String>("db_version")
    let db_update_date = Expression<String>("db_update_date")
    let db_create_date = Expression<String>("db_create_date")
    let db_app_name = Expression<String>("db_app_name")
    
    public func initializeV1() {
        print("sq3 > initialize db v1, path at \(dbPath)")
        
        do {
            let db = try Connection(dbPath)
            
            let app_table_exist = try db.scalar(app_table.exists)
            print("sq3 > app_table_exist: \(app_table_exist)")
            
            if (!app_table_exist) {
                try db.run(app_table.create { t in
                    t.column(db_version, primaryKey: true)
                    t.column(db_update_date)
                    t.column(db_create_date)
                    t.column(db_app_name)
                    
                })
                
                let insert = app_table.insert(db_version <- "v1", db_update_date <- "null", db_create_date <- "null", db_app_name <- "AltIdle")
                _ = try db.run(insert)
                
                print("sq3 > app_table created.")
            }
            
            let app_info = try db.prepare(app_table)
            for it in app_info {
                print("sq3 > app_info: dbversion: \(it[db_version]), updated at: \(it[db_update_date]), created at: \(it[db_update_date]), app_name: \(it[db_app_name])")
                break
            }
            
        } catch {
            print(error)
        }
        
        
    }
    
    public func timeRecord() {
        
    }
}
