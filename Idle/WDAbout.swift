//
//  WDAbout.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/15.
//

import Cocoa

class WDAbout: NSWindowController {
    
    let wndVersion = WDExtensionVersion(windowNibName: "WDExtensionVersion")

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func btnClickedVersion(_ sender: Any) {
        /*
        #if DEBUG
        let alert = NSAlert()
        alert.messageText = ""
        alert.informativeText = GLOBAL_APP_VERSION
        alert.runModal()
        #endif
        print(GLOBAL_APP_VERSION)
         */
        
        wndVersion.showWindow(self)
    }
}
