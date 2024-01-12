//
//  LFRequest.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/12.
//

import Cocoa

public class LFRequest : NSObject {
    
    public var forestAPIBaseURL = "https://c88fef96.forestapp.cc/api/v1"
    
    public let domainSignin = "/sessions"
    
    public let domainUser = "/users"
    
    public let domainSignout = "/sessions/signout"
    
    public let domainTags = "/tags"
    
    public let domainUnlocked = "/tree_types/unlocked"
    
    public let domainAllTrees = "/plants"
    
    public func switchToChinaReigon() {
        print("")
    }
    
    public func userLogin(username: String, password: String) {
        
        print("LFRequest Login with Username \(username), Password \(password).")
        
        
        
    }
    
    public func getAccountInfo() {
        
        
    }
    
    
    
}
