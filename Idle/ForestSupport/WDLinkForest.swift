//
//  WDLinkForest.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/12.
//

import Cocoa

class WDLinkForest: NSWindowController {
    
    
    @IBOutlet weak var popUpServerReigon: NSPopUpButton!
    @IBOutlet weak var tfUserName: NSTextField!
    @IBOutlet weak var tfPassword: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var piLoading: NSProgressIndicator!
    @IBOutlet weak var lbLoadingInfo: NSTextField!
    
    @IBOutlet weak var btnCancel: NSButton!
    
    let manager = LFRequest()
    let storage = LFStorage()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.becomeKey()
    }
    
    
    
    
    func animationSelfShake() {
        
        NSSound.beep()
        
        let window = self.window

            let numberOfShakes = 3
            let durationOfShake = 0.4
            let vigourOfShake : CGFloat = 0.03
            let frame : CGRect = (window?.frame)!
            let shakeAnimation :CAKeyframeAnimation  = CAKeyframeAnimation()

            let shakePath = CGMutablePath()
            shakePath.move( to: CGPoint(x:NSMinX(frame), y:NSMinY(frame)))

            for _ in 0...numberOfShakes-1 {
                shakePath.addLine(to: CGPoint(x:NSMinX(frame) - frame.size.width * vigourOfShake, y:NSMinY(frame)))
                shakePath.addLine(to: CGPoint(x:NSMinX(frame) + frame.size.width * vigourOfShake, y:NSMinY(frame)))
            }

            shakePath.closeSubpath()
            shakeAnimation.path = shakePath
            shakeAnimation.duration = durationOfShake

        
            let animations = ["frameOrigin" : shakeAnimation]

            window?.animations = animations
            window?.animator().setFrameOrigin(NSPoint(x: frame.minX, y: frame.minY))
        
    }
    
    func uiSwitchLoading(isLoadingNow: Bool) {
        if isLoadingNow {
            btnOK.isEnabled = false
            btnCancel.isEnabled = false
            piLoading.startAnimation(self)
            piLoading.isHidden = false
            lbLoadingInfo.stringValue = "Logging in. Please wait a moment."
            tfUserName.isEnabled = false
            tfPassword.isEnabled = false
            popUpServerReigon.isEnabled = false
        } else {
            btnOK.isEnabled = true
            btnCancel.isEnabled = true
            piLoading.stopAnimation(self)
            piLoading.isHidden = true
            //lbLoadingInfo.isHidden = true
            tfUserName.isEnabled = true
            tfPassword.isEnabled = true
            popUpServerReigon.isEnabled = true
            
        }
    }
    
    
    @IBAction func btnClickedOK(_ sender: Any) {

        if (tfUserName.stringValue.isEmpty || tfPassword.stringValue.isEmpty) {
            animationSelfShake()
            return
        }
        
        uiSwitchLoading(isLoadingNow: true)

        // Login Process
        
        // Reigon Process
        
        let is_china_reigon = popUpServerReigon.indexOfSelectedItem
        
        if (is_china_reigon == 1) {
            self.manager.switchToChinaReigon(is_china_reigon: true)
        } else {
            self.manager.switchToChinaReigon(is_china_reigon: false)
        }
        
        let username = tfUserName.stringValue
        let password = tfPassword.stringValue
        
        let queue = DispatchQueue(label: "studio.tri.idle.loginprocess")
        queue.async {
            let repo = self.manager.userLogin(username: username, password: password)
            if (repo < 0) {
                
 
                if (repo == -403) {
                    DispatchQueue.main.async {
                        self.lbLoadingInfo.stringValue = "Incorrect Username or Password. (0314)"
                        self.uiSwitchLoading(isLoadingNow: false)
                        self.animationSelfShake()
                    }
                    return
                }
                
                if (repo == -1) {
                    DispatchQueue.main.async {
                        self.lbLoadingInfo.stringValue = "Can not connect to the server. (0302)"
                        self.uiSwitchLoading(isLoadingNow: false)
                        self.animationSelfShake()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.lbLoadingInfo.stringValue = "Login Failed. Please try again later."
                    self.uiSwitchLoading(isLoadingNow: false)
                    self.animationSelfShake()
                }
                
                return
            }
            
            // OK with 200 OK
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "Fetching User Data..."
            }
            
            // Download Account Info
            let data_account_info = self.manager.getAccountInfo()
           
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "Get Meta Information..."
            }
            
            let data_boost = self.manager.getBoost()
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "Get Tags Data..."
            }
            
            let data_tags = self.manager.getTags()
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "Get Unlocked Trees..."
            }
            
            let data_unlocked_trees = self.manager.getUnlockedTrees()
            
            if (data_account_info.isEmpty || data_boost.isEmpty || data_tags.isEmpty || data_unlocked_trees.isEmpty) {
                
                DispatchQueue.main.async {
                    self.lbLoadingInfo.stringValue = "Connection reset by peer. Please try again later. (0304)"
                    self.uiSwitchLoading(isLoadingNow: false)
                    self.animationSelfShake()
                    return
                }
                
            }
            
            
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "Saving..."
            }
            
            self.storage.dataStorageTags(data: data_tags.rawValue as! Data)
            self.storage.dataStorageUnlock(data: data_unlocked_trees.rawValue as! Data)
            self.storage.dataStorageAccount(data: data_account_info.rawValue as! Data)

            DispatchQueue.main.async {
                self.close()
            }
            
        }
        
    }
    
    @IBAction func btnClickedCancel(_ sender: Any) {
        self.close()
    }
    
    
}
