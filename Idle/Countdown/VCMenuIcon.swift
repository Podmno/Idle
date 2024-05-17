//
//  VCMenuIcon.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/10.
//

import Cocoa
import SwiftUI

class VCMenuIcon: NSViewController {

    
    @IBOutlet weak var menuBarText: NSTextField!
    
    @IBOutlet weak var menuBarIcon: NSImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //let mgr = LFManager()
        //print("LOCAL:" + mgr.getLocalDate(from: "2024-01-14T14:51:37.120Z"))
        
        //let demo = LFRequest()
        //demo.updateTree(startTime: "2024-01-14T14:51:37.120Z", endTime: "2024-01-14T15:01:37.120Z", duration: 120, tree_type: 0, is_success: false, tag: 0, note: "")

        
    }
    
    func setMenuBarText(string: String) {

        menuBarText.stringValue = string
    }
    

    
}
