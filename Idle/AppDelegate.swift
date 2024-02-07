//
//  AppDelegate.swift
//  Idle
//
//  Created by Ki MNO on 2023/12/28.
//

import Cocoa
import ForestSupport

let GLOBAL_APP_VERSION = "1.1 (21)"

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    let notificationUtil = LDNotification()
    
    let menuIcon = LDMenuIcon()
    let wndAbout = WDAbout(windowNibName: "WDAbout")
    
    let wndDemo = WDForestViewer(windowNibName: "WDForestViewer")

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let mgr_storage = LFStorage()
        mgr_storage.setLock(lock: false)
        
        // Insert code here to initialize your application
        menuIcon.initCreateIcon()
        
        let style = DockProgress.Style.pie(color: .controlAccentColor)
        DockProgress.style = style

        
        notificationUtil.userAuthNotificationPermission()
        
        //wndDemo.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    
    @IBAction func menuClickedAbout(_ sender: Any) {
        
        wndAbout.showWindow(self)
    }
    
    
}

