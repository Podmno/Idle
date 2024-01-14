//
//  LFStorage.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/13.
//

import Cocoa

public class LFStorage : NSObject {
    
    let defaults = UserDefaults.standard
    
    public override init() {
        super.init()
    }
    
    
    public func setUserInfo(user_name: String, user_id: String, token: String) {
        
        
        defaults.set(user_name, forKey: "IDLE_FOREST_USERNAME")
        defaults.set(user_id, forKey: "IDLE_FOREST_ID")
        defaults.set(token, forKey: "IDLE_FOREST_TOKEN")
        
        updateLastUpdateTime()
        
    }
    
    public func getUserInfoUserName() -> String {
        return defaults.string(forKey: "IDLE_FOREST_USERNAME") ?? ""
    }
    
    public func getUserInfoID() -> String {
        return defaults.string(forKey: "IDLE_FOREST_ID") ?? ""
    }
    
    public func getUserToken() -> String {
        return defaults.string(forKey: "IDLE_FOREST_TOKEN") ?? ""
    }
    
    public func updateLastUpdateTime() {
        
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        defaults.set(Int(timeInterval), forKey: "IDLE_FOREST_LAST_UPDATE")
    }
    
    public func getLastUpdateTime() -> Date {
        
        let last_record_date = defaults.integer(forKey: "IDLE_FOREST_LAST_UPDATE")
        let last_time_date = Date(timeIntervalSince1970: TimeInterval(last_record_date))
        return last_time_date
    }
    
    public func setAccountChinaReigon(is_china_reigon: Bool) {
        
        defaults.set(is_china_reigon, forKey: "IDLE_FOREST_CHINA_ACCOUNT")
    }
    
    public func getAccountChinaReigon() -> Bool {
        self.updateLastUpdateTime()
        return defaults.bool(forKey: "IDLE_FOREST_CHINA_ACCOUNT")
    }
    
    public func dataStorageTags(data: String) {
        self.updateLastUpdateTime()
        defaults.set(data, forKey: "IDLE_FOREST_DATA_TAGS")
    }
    
    public func dataStorageAccount(data: String) {
        self.updateLastUpdateTime()
        defaults.set(data, forKey: "IDLE_FOREST_DATA_ACCOUNT")
    }
    
    public func dataStorageUnlock(data: String) {
        self.updateLastUpdateTime()
        defaults.set(data, forKey: "IDLE_FOREST_DATA_UNLOCK")
    }
    
    public func dataStorageAllTrees(data: String) {
        self.updateLastUpdateTime()
        defaults.set(data, forKey: "IDLE_FOREST_DATA_ALL")
    }
    
    public func dataGetTags() -> String {
        return defaults.string(forKey: "IDLE_FOREST_DATA_TAGS") ?? ""
    }
    
    public func dataGetAccount() -> String {
        return defaults.string(forKey: "IDLE_FOREST_DATA_ACCOUNT") ?? ""
    }
    
    public func dataGetUnlock() -> String {
        return defaults.string(forKey: "IDLE_FOREST_DATA_UNLOCK") ?? ""
    }
    
    public func dataGetAllTrees() -> String {
        return defaults.string(forKey: "IDLE_FOREST_DATA_ALL") ?? ""
    }
    
    public func setLock(lock: Bool) {
        defaults.set(lock, forKey: "IDLE_FOREST_LOCK")
    }
    
    public func getLock() -> Bool {
        return defaults.bool(forKey: "IDLE_FOREST_LOCK")
    }
    

    
}
