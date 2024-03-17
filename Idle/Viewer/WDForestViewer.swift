//
//  WDForestViewer.swift
//  Idle
//
//  Created by Ki MNO on 2024/2/7.
//

import Cocoa
import ForestSupport
import SwiftyJSON

class WDForestViewer: NSWindowController {

    
    @IBOutlet weak var btnSyncNow: NSButton!
    @IBOutlet weak var mainTable: NSTableView!
    @IBOutlet weak var imgAvatar: NSImageView!
    @IBOutlet weak var lbUserName: NSTextField!
    @IBOutlet weak var btnPercent: NSButton!
    @IBOutlet weak var btnTrees: NSButton!
    @IBOutlet weak var btnCoins: NSButton!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var piLoading: NSProgressIndicator!
    @IBOutlet weak var lbInfo: NSTextField!
    
    let tableProvider = WDForestViewerTableViewProvider()
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        mainTable.delegate = tableProvider
        mainTable.dataSource = tableProvider
        
        piLoading.startAnimation(self)
        
        setupUser()
    }
    
    func setupUser() {
        let storage = LFStorage()
        let user_content = storage.dataGetAccount()
        
        if (user_content.isEmpty) {
            piLoading.isHidden = true
            lbInfo.isHidden = true
            
            datePicker.isEnabled = false
            btnSyncNow.isEnabled = false
            
            let alert = NSAlert()
            alert.messageText = "此功能需要登陆 Forest 账号。"
            alert.runModal()
            
            
        } else{
            
            // 载入用户资料
            
            
        }
    }
    
    func downloadAndSaveUserData() {
        print("FV > Check if user data exists.")
        
        
        
        
        
    }
    
    
    
    @IBAction func dateChanged(_ sender: Any) {
        print("Date Changed!")
    }
    
    @IBAction func btnClickedSyncWindow(_ sender: Any) {

    }
    
    
    @IBAction func btnClickedSyncNow(_ sender: Any) {
        
    }
}

class WDForestViewerTableViewProvider: NSObject ,NSTableViewDelegate, NSTableViewDataSource {
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let vc = VCForestCell(nibName: "VCForestCell", bundle: Bundle.main)
        return vc.view
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
        return 200
    }
}


