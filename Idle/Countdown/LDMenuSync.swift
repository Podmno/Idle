//
//  LDMenuSync.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/14.
//

import Cocoa
import SwiftyJSON
import ForestSupport

let flagEnableForestViewer = true

public class LDMenuSync : NSObject {
    
    public var contentMenu: NSMenu!
    
    lazy var recordUtil = LDRecord()
    
    var storage = LFStorage()
    
    var menu_main_login: NSMenuItem?
    var menu_main_log_out: NSMenuItem?
    var menu_main_sync_now: NSMenuItem?
    var window_login: WDLinkForest?
    
    var window_forestviewer = WDForestViewer(windowNibName: "WDForestViewer")
    
    public override init() {
        super.init()
        
        contentMenu = NSMenu()
        
        if(storage.getLock()) {
            let menu_loading = NSMenuItem(title: "正在更新账户信息，请稍候。", action: nil, keyEquivalent: "")
            contentMenu.addItem(menu_loading)
            

            return
        }
        
        menu_main_login = NSMenuItem(title: "登录", action: #selector(onClickedLoginForestAccount), keyEquivalent: "")
        menu_main_login!.target = self
        //let menu_main_service_alert = NSMenuItem(title: "The reliability of this feature is not guaranteed.", action: nil, keyEquivalent: "")
        //menu_main_service_alert.target = self
        let menu_separator = NSMenuItem.separator()
        menu_main_log_out = NSMenuItem(title: "退出登录", action: #selector(onClickedLogOut), keyEquivalent: "")

        menu_main_log_out!.target = self
        var title_sync = "立即同步"
        if (!storage.getTempTreeRecordStartTime().isEmpty) {
            title_sync = "立即同步 | 有未同步记录"
            menu_main_log_out?.title = "同步未同步记录后才可以退出登录"
            menu_main_log_out?.action = nil
        }
        
        menu_main_sync_now = NSMenuItem(title: title_sync, action: #selector(onClickedSyncNow), keyEquivalent: "")
        menu_main_sync_now?.target = self

        let menu_treeviewer = NSMenuItem(title: "种植记录", action: #selector(onClickedForestViewer), keyEquivalent: "")
        menu_treeviewer.target = self
        contentMenu.addItem(menu_main_login!)
        
        if (flagEnableForestViewer) {
            contentMenu.addItem(menu_treeviewer)
        }
        
        
        //contentMenu.addItem(menu_main_service_alert)
        contentMenu.addItem(menu_separator)
        contentMenu.addItem(menu_main_sync_now!)
        contentMenu.addItem(menu_main_log_out!)
        
        
        
        addMenuTimeRecord()
        addMenuApplicationExit()
        
        initAccountSettings()
    }
    
    func addMenuTimeRecord() {

        let menu_info = NSMenuItem()
        let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10, weight: .bold)]
        let attr_string = NSAttributedString(string: "此 Mac 上的专注时间", attributes: attributes)
        menu_info.attributedTitle = attr_string
        
        
        let d_string = "今日专注：" + recordUtil.getFocusTimeDayStringDescribing()
        let w_string = "本周专注：" + recordUtil.getFocusTimeWeekStringDescribing()
        
        let menu_separator = NSMenuItem.separator()
        
        let menu_d = NSMenuItem(title: d_string, action: nil, keyEquivalent: "")
        let menu_w = NSMenuItem(title: w_string, action: nil, keyEquivalent: "")
        
        contentMenu.addItem(menu_separator)
        contentMenu.addItem(menu_info)
        contentMenu.addItem(menu_d)
        contentMenu.addItem(menu_w)
    }
    
    
    var menu_main_exit: NSMenuItem?
    func addMenuApplicationExit() {
        let menu_separator = NSMenuItem.separator()
        menu_main_exit = NSMenuItem(title: "退出 Forest", action: #selector(onClickedApplicationExit), keyEquivalent: "q")
        menu_main_exit?.keyEquivalentModifierMask = .command
        menu_main_exit?.target = self
        contentMenu.addItem(menu_separator)
        contentMenu.addItem(menu_main_exit!)
        
    }
    
    
    @objc func onClickedApplicationExit(_ : NSMenuItem) {
        exit(0)
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
            menu_main_sync_now?.isEnabled = false
            menu_main_sync_now?.target = nil
            return
        }
        print("Menu > Log in already")
        let account_name = account_info_json["name"].stringValue
        //let account_email = account_info_json["email"].stringValue
        
        let account_description = "账户：" + account_name
        menu_main_login!.title = account_description
        menu_main_login!.isEnabled = false
        menu_main_login!.target = nil
        menu_main_log_out!.isEnabled = true
        menu_main_log_out!.target = self
    }
    
    func uploadTreeFromTemp() {
        let treeUtil = LFManager()
        let startDate = storage.getTempTreeRecordStartTime()
        let endDate = storage.getTempTreeRecordEndTime()
        let duration = storage.getTempTreeRecordDuration()
        let tree_type = storage.getTempTreeRecordTreeType()
        let is_success = storage.getTempTreeRecordIsSuccess()
        let tag = storage.getTempTreeRecordTag()
        let note = storage.getTempTreeRecordNoteContent()
        
        
    
        let update_time = treeUtil.getUTCDate(date: Date())
        print("Tree Information: \n")
        print("Start time : \(startDate)")
        print("End time : \(endDate))")
        print("Update time : \(update_time)")
        
        print("Duration : \(duration)")
        
        print("Tree type : \(tree_type)")
        
        print("Is Success : \(is_success)")
        
        print("Note : \(note)")
        
        print("Tag : \(tag)")

        let queue = DispatchQueue(label: "studio.tri.idle.uploadTree")
        queue.async {
            let mgr = LFRequest()
            let tree_sturct = LFTree(startTime: startDate, endTime: endDate, duration: duration, tree_type: tree_type, is_success: is_success, tag: tag, note_content: note)
            
            let repo = mgr.updateTree(tree: tree_sturct)
            if (repo == 0) {
                // 成功同步了
                // LFRequest 会直接同步好其他的数据
                
                self.storage.storageTempTreeRecord(startTime: "", endTime: "", duration: 0, tree_type: 0, is_success: false, tag: 0, note_content: "")
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "同步完成。"
                    alert.runModal()
                }
            } else {
                
                if (repo == -2) {
                    self.storage.storageTempTreeRecord(startTime: "", endTime: "", duration: 0, tree_type: 0, is_success: false, tag: 0, note_content: "")
                    let alert = NSAlert()
                    alert.messageText = "推送数据被服务端拒绝。"
                    alert.runModal()
                    return
                }
                
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "同步失败。请稍后再试。"
                    alert.runModal()
                    return
                }
            }
            self.storage.setLock(lock: false)
        }
    }
    
    @objc func onClickedLoginForestAccount(_ : NSMenuItem) {
        
        
        if window_login == nil {
            
            if window_login?.isOpened == true {
                return
            }
            
            window_login = nil
            window_login = WDLinkForest(windowNibName: "WDLinkForest")
        }
        
        let record_util = LDRecord()
        record_util.resetTimeData()
        
        
        
        window_login!.showWindow(self);
        
        
    }
    
    @objc func onClickedSyncNow(_ : NSMenuItem) {
        
        print("perform sync now.")
        storage.setLock(lock: true)
        if (!storage.getTempTreeRecordStartTime().isEmpty) {
            // 有暂存资料的同步请求
            print("perform temp record upload.")
            uploadTreeFromTemp()
        } else {
            // FIXME: 网络连接功能：失败时显示提示
            
            // 没有暂存资料
            let queue = DispatchQueue(label: "studio.tri.idle.sync.queue")
            
            queue.async {
                let network = LFRequest()
                let data_account_info = network.getAccountInfo()
                
                if data_account_info.isEmpty {
                    
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "同步失败。请稍后再试。"
                        alert.runModal()
                    }
                    self.storage.setLock(lock: false)
                    
                    return
                }
                
                _ = network.getBoost()
                let data_tags = network.getTags()
                let data_unlocked_trees = network.getUnlockedTrees()
                
                self.storage.dataStorageTags(data: data_tags.rawString() ?? "")
                self.storage.dataStorageUnlock(data: data_unlocked_trees.rawString() ?? "")
                self.storage.dataStorageAccount(data: data_account_info.rawString() ?? "")
                self.storage.setLock(lock: false)
            }

        }
        
    }
    
    @objc func onClickedForestViewer(_ : NSMenuItem) {
        window_forestviewer.showWindow(nil)
    }
    
    @objc func onClickedLogOut(_ : NSMenuItem) {
        
        let alert = NSAlert()
        alert.messageText = "退出登录？"
        alert.informativeText = ""
        alert.addButton(withTitle: "否")
        alert.addButton(withTitle: "是")
        
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
                        alert.messageText = "登出完成。"
                        alert.informativeText = ""
                        alert.runModal()
                        self.storage.setLock(lock: false)
                        
                        let record_util = LDRecord()
                        record_util.resetTimeData()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userSignOut"), object: nil)
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.messageText = "登出失败。"
                        alert.informativeText = "请稍后再试。"
                        alert.runModal()
                        self.storage.setLock(lock: false)
                    }
                    
                }
                
            }
            
        }
    }
    
}
