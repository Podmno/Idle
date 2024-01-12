//
//  VCMenuIcon.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/10.
//

import Cocoa

class VCMenuIcon: NSViewController {

    
    @IBOutlet weak var menuBarText: NSTextField!
    
    @IBOutlet weak var menuBarIcon: NSImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setMenuBarText(string: String) {
        menuBarText.stringValue = string
    }
    
}
