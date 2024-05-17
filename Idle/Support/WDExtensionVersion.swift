//
//  WDExtensionVersion.swift
//  Idle
//
//  Created by Ki MNO on 2024/5/3.
//

import Cocoa

class WDExtensionVersion: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()

    }
    
    func recordExtensionVersion() {
        
    }
    
    func windowWillClose(_ notification: Notification) {
        
        print("will close.")
    }
    
}
