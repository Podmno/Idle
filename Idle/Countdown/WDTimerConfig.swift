//
//  WDTimerConfig.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/9.
//

import Cocoa

class WDTimerConfig: NSWindowController, NSTextFieldDelegate {
    
    @IBOutlet weak var imageIcon: NSImageView!
    
    @IBOutlet weak var tfCustomClock: NSTextField!
    
    @IBOutlet weak var clock1: NSPopUpButton!
    
    @IBOutlet weak var clock2: NSPopUpButton!
    
    
    @IBOutlet weak var clock3: NSPopUpButton!
    
    @IBOutlet weak var clock4: NSPopUpButton!
    
    let configHelper = LDRecord()
    
    let clocksDict = [15, 30, 45, 60, 75, 90, 105, 120, 150, 180]

    override func windowDidLoad() {
        super.windowDidLoad()
        //imageIcon.layer?.allowsEdgeAntialiasing = true
        tfCustomClock.delegate = self
   
        let last_input = configHelper.getClocks()
        let last_data = last_input[4]
        tfCustomClock.stringValue = String(last_data)
        
    }
    
    func controlTextDidChange(_ obj: Notification) {
        
        let reply = tfCustomClock.integerValue
        

        if (reply > 180) {
            tfCustomClock.stringValue = "180"
        }
        if (reply == 0) {
            tfCustomClock.stringValue = "15"
        }
    }
    
    func saveClocksProcess() {
        
        let c1 = clocksDict[clock1.indexOfSelectedItem]
        let c2 = clocksDict[clock2.indexOfSelectedItem]
        let c3 = clocksDict[clock3.indexOfSelectedItem]
        let c4 = clocksDict[clock4.indexOfSelectedItem]
        let c5 = tfCustomClock.integerValue
        
        let arr = [c1,c2,c3,c4,c5]
        print("Saved clocks: \(arr)")
        configHelper.setClocks(clocks: arr)
    }

    
    @IBAction func clickedCancel(_ sender: Any) {
        self.close()
    }
    
    @IBAction func clickedSave(_ sender: Any) {
        
        let reply = tfCustomClock.integerValue
        if (reply < 15 ) {
            
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Custom clock is less than 15 minutes", comment: "")
            alert.informativeText = NSLocalizedString("The focus record of this focus clock will not be saved.", comment: "")
            
            alert.runModal()
        }
        
        saveClocksProcess()
        self.close()
        
    }
    
}
