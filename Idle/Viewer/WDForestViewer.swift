//
//  WDForestViewer.swift
//  Idle
//
//  Created by Ki MNO on 2024/2/7.
//

import Cocoa
import ForestSupport

class WDForestViewer: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func checkUserLoginStatus() {
        let record = LFStorage()
        let account_json = record.dataGetAccount()
        

    }
    
}
