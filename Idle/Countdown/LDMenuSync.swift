//
//  LDMenuSync.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/14.
//

import Cocoa

public class LDMenuSync : NSObject {
    
    public var contentMenu: NSMenu!
    
    var menu_main_login: NSMenuItem!
    
    var window_login: WDLinkForest?
    
    public override init() {
        super.init()
        
        contentMenu = NSMenu()
        
        menu_main_login = NSMenuItem(title: "Log in Forest Account", action: #selector(onClickedLoginForestAccount), keyEquivalent: "")
        menu_main_login.target = self
        let menu_main_service_alert = NSMenuItem(title: "The reliability of this feature is not guaranteed.", action: nil, keyEquivalent: "")
        menu_main_service_alert.target = self
        let menu_separator = NSMenuItem.separator()
        
        let menu_main_sync_now = NSMenuItem(title: "Sync now", action: #selector(onClickedSyncNow), keyEquivalent: "")
        menu_main_sync_now.target = self
        let menu_main_log_out = NSMenuItem(title: "Log out", action: #selector(onClickedLogOut), keyEquivalent: "")
        menu_main_log_out.target = self
        
        contentMenu.addItem(menu_main_login)
        contentMenu.addItem(menu_main_service_alert)
        contentMenu.addItem(menu_separator)
        contentMenu.addItem(menu_main_sync_now)
        contentMenu.addItem(menu_main_log_out)
        
    }
    
    
    @objc func onClickedLoginForestAccount(_ : NSMenuItem) {
        
        
        if window_login == nil {
            window_login = nil
            window_login = WDLinkForest(windowNibName: "WDLinkForest")
        }
        
        window_login!.showWindow(self);
        
        
    }
    
    @objc func onClickedSyncNow(_ : NSMenuItem) {
        
    }
    
    @objc func onClickedLogOut(_ : NSMenuItem) {
        
        
    }
    
}
