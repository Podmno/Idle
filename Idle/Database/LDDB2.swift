//
//  LDDB2.swift
//  Idle
//
//  Created by Ki MNO on 2024/6/23.
//

import Foundation
import CoreData
import Cocoa

public class LDDB2: NSObject {

    let persistentContainer = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    public func updateAppTable() {
        let context = persistentContainer?.viewContext
        print("NSPersistentContainer.defaultDirectoryURL(): \(NSPersistentContainer.defaultDirectoryURL())")
        
        let appFetch: NSFetchRequest<DBApp> = DBApp.fetchRequest()
        
        do {
            let repo = try context!.fetch(appFetch)
            print("cdb > app table member count: \(repo.count)")
        } catch {
            fatalError("Failed to fetch. \(error)")
        }
        
        let saveBool = LDKeychainManager.keyChainSaveData(data: "Test" as Any, withIdentifier: "studio.tri.Idle.keychainAccess.deviceKey")
        if saveBool {
            print("keychain Access > PASSED")
        } else {
            print("keychain Access > FAILURE")
        }
        // 获取数据
        let getString = LDKeychainManager.keychainReadData(identifier: "studio.tri.Idle.keychainAccess.deviceKey") as! String
        print(getString)


       
    }
    
    public func deleteAll() {
        let context = persistentContainer?.viewContext
        print("NSPersistentContainer.defaultDirectoryURL(): \(NSPersistentContainer.defaultDirectoryURL())")
        
        let appFetch: NSFetchRequest<DBApp> = DBApp.fetchRequest()
        
        do {
            let repo = try context!.fetch(appFetch)
            repo.forEach { data in
                context?.delete(data)
            }
            
            try context?.save()
            print("cdb > delete version all.")
        } catch {
            fatalError("Failed to fetch. \(error)")
        }
    }
}


/*
let app_table = DBApp(context: context!)
app_table.version = "1.0.0.0"
do {
    try context!.save()
} catch {
    print("save entity error \(error)")
}


*/
