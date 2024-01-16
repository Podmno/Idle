//
//  LDMenuTimer.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/14.
//

import Cocoa

public class LDMenuTimer : NSObject {
    
    public var contentMenu: NSMenu!
    
    var menu_timer_editor: NSMenuItem!
    
    var wndTimerConfig: WDTimerConfig? = WDTimerConfig(windowNibName: "WDTimerConfig")
    
    public override init() {
        super.init()
        
        contentMenu = NSMenu()
        
        menu_timer_editor = NSMenuItem(title: "Edit Timer Configuration...", action: #selector(clickedTimerEditor), keyEquivalent: "")
        menu_timer_editor.target = self
        contentMenu.addItem(menu_timer_editor)
    }
    
    @objc func clickedTimerEditor(_ : NSMenuItem) {
        
        if wndTimerConfig != nil {
            wndTimerConfig = nil
            wndTimerConfig = WDTimerConfig(windowNibName: "WDTimerConfig")
        }
        
        wndTimerConfig!.showWindow(self)
        
    }
    
}
