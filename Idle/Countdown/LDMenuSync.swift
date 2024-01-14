//
//  LDMenuSync.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/14.
//

import Cocoa
import SwiftyJSON

public class LDMenuSync : NSObject {
    
    public var contentMenu: NSMenu!
    
    var storage = LFStorage()
    
    var menu_main_login: NSMenuItem?
    var menu_main_log_out: NSMenuItem?
    
    var window_login: WDLinkForest?
    
    public override init() {
        super.init()
        
        contentMenu = NSMenu()
        
        
        if(storage.getLock()) {
            let menu_loading = NSMenuItem(title: "Updating. Please proceed later.", action: nil, keyEquivalent: "")
            contentMenu.addItem(menu_loading)
            

            return
        }
        
        menu_main_login = NSMenuItem(title: "Log in Forest Account", action: #selector(onClickedLoginForestAccount), keyEquivalent: "")
        menu_main_login!.target = self
        let menu_main_service_alert = NSMenuItem(title: "The reliability of this feature is not guaranteed.", action: nil, keyEquivalent: "")
        menu_main_service_alert.target = self
        let menu_separator = NSMenuItem.separator()
        
        let menu_main_sync_now = NSMenuItem(title: "Sync now", action: #selector(onClickedSyncNow), keyEquivalent: "")
        menu_main_sync_now.target = self
        menu_main_log_out = NSMenuItem(title: "Log out", action: #selector(onClickedLogOut), keyEquivalent: "")
        menu_main_log_out!.target = self
        
        contentMenu.addItem(menu_main_login!)
        contentMenu.addItem(menu_main_service_alert)
        contentMenu.addItem(menu_separator)
        contentMenu.addItem(menu_main_sync_now)
        contentMenu.addItem(menu_main_log_out!)
        
        initAccountSettings()
    }
    
    func initAccountSettings() {
        
        let account_info_data = storage.dataGetAccount()
        let account_info_json = JSON(parseJSON: account_info_data)
        
        print(account_info_json)
        if account_info_data.isEmpty {
            // 还没有登录
            print("Menu > Not log in")
            menu_main_login!.isEnabled = true
            menu_main_log_out!.isEnabled = false
            menu_main_login!.target = self
            menu_main_log_out!.target = nil
            return
        }
        print("Menu > Log in already")
        let account_name = account_info_json["name"].stringValue
        let account_email = account_info_json["email"].stringValue
        
        let account_description = account_name + " / " + account_email
        menu_main_login!.title = account_description
        menu_main_login!.isEnabled = false
        menu_main_login!.target = nil
        menu_main_log_out!.isEnabled = true
        menu_main_log_out!.target = self
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
        
        let alert = NSAlert()
        alert.messageText = "Logging out?"
        alert.informativeText = "The synchronization status will be released."
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        
        alert.alertStyle = .critical
        
        
        let repo = alert.runModal()
        
        if (repo == .alertFirstButtonReturn) {
            print("Cancel")
        } else {
            print("OK")
            
            let queue = DispatchQueue(label: "studio.tri.idle.logout")
            queue.async {
                
                // Log Out Menu Bar block 禁止用户进行同步操作 封堵防止出现冲突
                self.storage.setLock(lock: true)
                
                let network = LFRequest()
                let repo = network.userSignOut()
                
                if (repo == true) {
                    
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.messageText = "Logout Successful"
                        alert.informativeText = "The record has been cleared. You can log back in at any time."
                        alert.runModal()
                        self.storage.setLock(lock: false)
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.messageText = "Logout Failed"
                        alert.informativeText = "Please try again later."
                        alert.runModal()
                        self.storage.setLock(lock: false)
                    }
                    
                }
                
            }
            
        }
    }
    
}
