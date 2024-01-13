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
    
}
