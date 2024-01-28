//
//  WDLinkForest.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/12.
//

import Cocoa

public class WDLinkForest: NSWindowController, NSWindowDelegate{
    
    
    @IBOutlet weak var popUpServerReigon: NSPopUpButton!
    @IBOutlet weak var tfUserName: NSTextField!
    @IBOutlet weak var tfPassword: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var piLoading: NSProgressIndicator!
    @IBOutlet weak var lbLoadingInfo: NSTextField!
    
    @IBOutlet weak var btnCancel: NSButton!
    
    public var windowAlreadyExtended = false
    
    public var isOpened = false
    
    let manager = LFRequest()
    let storage = LFStorage()
    
    public override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.becomeKey()
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        isOpened = true
    }
    
    public func windowWillClose(_ notification: Notification) {
        isOpened = false
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
            lbLoadingInfo.stringValue = "正在登录..."
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
        
        print("OKKKK")
        

        if (tfUserName.stringValue.isEmpty || tfPassword.stringValue.isEmpty) {
            animationSelfShake()
            return
        }
        
        //zlet view = self.window!.contentView!

        
        //let frame_after = NSRect(x: self.window!.frame.minX, y: self.window!.frame.minY, width: self.window?.frame.width ?? 300, height: (self.window?.frame.height ?? 178) + 30)
        //self.window?.setFrame(frame_after, display: true, animate: true)
        
        
        if (!windowAlreadyExtended) {
            let frame = window!.frame
            let new_frame = NSRect(x: frame.origin.x, y: frame.origin.y - 30, width: frame.width, height: frame.height + 40)
            self.window?.setFrame(new_frame, display: true, animate: true)
            windowAlreadyExtended = true
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
                        self.lbLoadingInfo.stringValue = "用户名或密码错误。"
                        self.uiSwitchLoading(isLoadingNow: false)
                        self.animationSelfShake()
                    }
                    return
                }
                
                if (repo == -1) {
                    DispatchQueue.main.async {
                        self.lbLoadingInfo.stringValue = "无法连接至服务器。"
                        self.uiSwitchLoading(isLoadingNow: false)
                        self.animationSelfShake()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.lbLoadingInfo.stringValue = "登录失败，请稍后再试。"
                    self.uiSwitchLoading(isLoadingNow: false)
                    self.animationSelfShake()
                }
                
                return
            }
            
            // OK with 200 OK
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "获取用户资料..."
            }
            
            // Download Account Info
            let data_account_info = self.manager.getAccountInfo()
           
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "获取用户资料..."
            }
            
            let data_boost = self.manager.getBoost()
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "获取用户资料..."
            }
            
            let data_tags = self.manager.getTags()
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "获取用户资料..."
            }
            
            let data_unlocked_trees = self.manager.getUnlockedTrees()
            
            if (data_account_info.isEmpty || data_boost.isEmpty || data_tags.isEmpty || data_unlocked_trees.isEmpty) {
                
                DispatchQueue.main.async {
                    self.lbLoadingInfo.stringValue = "信息获取过程中出现问题，请稍后再试。"
                    self.uiSwitchLoading(isLoadingNow: false)
                    self.animationSelfShake()
                    return
                }
                
            }
            
            
            
            DispatchQueue.main.async {
                self.lbLoadingInfo.stringValue = "正在完成..."
            }
            
            
            self.storage.dataStorageTags(data: data_tags.rawString() ?? "")
            self.storage.dataStorageUnlock(data: data_unlocked_trees.rawString() ?? "")
            self.storage.dataStorageAccount(data: data_account_info.rawString() ?? "")

            DispatchQueue.main.async {
                self.close()
            }
            
        }
        
    }
    
    @IBAction func btnClickedCancel(_ sender: Any) {
        self.close()
    }
    
    
}
