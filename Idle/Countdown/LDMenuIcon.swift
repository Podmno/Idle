//
//  LDMenuIcon.swift
//  IdlePlugin
//
//  Created by Ki MNO on 2023/12/25.
//

import Cocoa


class LDMenuIcon : NSObject {
    
    var timerM : Int = 0
    var timerS : Int = 0
    
    var timerMax : Int = 120
    
    var countUpMLog: Int = 0
    
    var setM: Int = 0
    
    let statusItem = NSStatusBar.system.statusItem(withLength: 65)
    
    let numberFormatterSecond = NumberFormatter()
    
    
    let vcCountDown = VCCountDown(nibName: "VCCountDown", bundle: Bundle.main)
    let vcMenuBarIcon = VCMenuIcon(nibName: "VCMenuIcon", bundle: Bundle.main)
    
    let popover = NSPopover()
    
    var coreTimer: LDCoreTimer!
    let notificationUtil = LDNotification()
    let recordUtil = LDRecord()
    
    override init() {
        super.init()
        
        numberFormatterSecond.minimumIntegerDigits = 2
        
        // 弹窗初始化
        popover.behavior = .transient
        //popover.contentSize = NSSize(width: 500, height: 300)
        popover.contentViewController = vcCountDown
        

        NotificationCenter.default.addObserver(self, selector: #selector(timerReceiveStart), name: NSNotification.Name("countDownStart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timerReceiveStop), name: NSNotification.Name("countDownStop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timerReceiveUserChange), name: NSNotification.Name("countDownUserChange"), object: nil)
        
    }
        
    func initCreateIcon() {

        if let button = statusItem.button {
            //statusItem.button?.window?.contentViewController = vcMenuBarIcon
            button.addSubview(vcMenuBarIcon.view)
            print("Already set button action")
            // 重要！！ 没有这一句没有反应的
            button.target = self
            button.action = #selector(toggleMenuIcon(_sender:))
            
            
            let last_focus_time = recordUtil.getLastFocusTime()
            print("Menu_Last_Time \(last_focus_time)")
            if (last_focus_time <= 0) {
                setMenuBarIconText(text: "0:00")
            } else {
                setMenuBarIconText(text: "\(last_focus_time):00")
            }
            
        }
    }
    
    func setMenuBarIconText(text: String) {
        

        vcMenuBarIcon.setMenuBarText(string: text)
        return
        
        //if let button = statusItem.button {
        //    button.title = text
            
        //}
    }
    
    func updateMenuBarIcon() {
        let post_obj = [0 : self.timerM, 1: self.timerS, 2: self.setM]

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "count"), object: post_obj)
        
        if(timerM == 0 && timerS == 0) {
            if(setM < 0) {
                setMenuBarIconText(text: "0:00")
            } else {
                setMenuBarIconText(text: "\(setM):00")
            }
            
            
            DispatchQueue.main.async {
                self.updateDockProgress()
            }
            return
        }
       
        let timer_string = "\(timerM):\(numberFormatterSecond.string(from: NSNumber(value: timerS)) ?? "0:00")"
        setMenuBarIconText(text: timer_string)
        DispatchQueue.main.async {
            self.updateDockProgress()
        }
    }
    
    @MainActor func updateDockProgress() {
        
        if(setM <= 0 ) {
            // 正计时处理逻辑
            // set DockProgress display type
            let progress: Double = Double(timerM + 1) / 120
            DockProgress.progress = progress
            
            //if (timerM == 0) {
            //    print("Countup: Reset Dock Progress")
            //    DockProgress.resetProgress()
            //}
            if (timerM == 0 && timerS == 0) {
                print("Countup: Reset Dock Progress")
                DockProgress.resetProgress()
            }
            
            return
        }

        if(timerM == 0 && timerS == 0) {
            DockProgress.resetProgress()
            
            // Send the timer stop message to VCCountDown
            
            
            
            return
        } else {
            //print("\(timerM) all \(setM)")
            let progress: Double = Double(timerM) / Double(setM+1)
            //print(progress)
            DockProgress.progress = progress
        }
    }
    
    func setCountDownTime(minutes: Int) {
        
        if (minutes < 0) {
            debugPrint("Count UP Mode On.")
            self.setM = -1
            self.timerM = 0
            self.timerS = 0
            //startTimer()
            
            DispatchQueue.main.async {
                let style = DockProgress.Style.badge(badgeValue: { Int(DockProgress.displayedProgress * 120 - 1) })
                DockProgress.style = style
            }
            
            return
        }
        
        self.timerM = minutes
        self.setM = self.timerM
        self.timerS = 1
        DispatchQueue.main.async {
            let style = DockProgress.Style.pie(color: .controlAccentColor)
            DockProgress.style = style
        }
        //startTimer()
    }
    
    
    func startTimer() {
        
        coreTimer = LDCoreTimer(target: self, timerAction: #selector(timerChangeAction))
        

        
        coreTimer.startTimer()
        
    }
    
    func stopTimer() {
        
        if coreTimer != nil {
            coreTimer.stopTimer()
            coreTimer.destroyTimer()
            coreTimer = nil
            
        }
        
        
        
        timerM = 0
        timerS = 0
        //countUpMLog = 0
        updateMenuBarIcon()
        
        if (setM < 0) {
            sendTimerStopNotification()
            userDefaultsAddTime()
        }
    }
    
    
    func sendTimerStopNotification() {
        
        // 向 macOS 通知中心发送通知
        if (setM <= 0) {
            // 正计时逻辑
            print("CountUpMLog \(countUpMLog)")
            
            if (countUpMLog >= 10) {
                notificationUtil.sendCountupTimeStopNotification(timerM: countUpMLog)
            } else {
                notificationUtil.sendTimeNotRecordNotification()
            }


            
            return
        }
        
        if (timerM > 0 || timerS > 5) {
            // 自己手动停止
            return
        }
        
        if (setM < 10) {
            notificationUtil.sendTimeNotRecordNotification()
            return
        }
        
        notificationUtil.sendTimeUpNotification(timerM: setM)
        
    }
    
    func userDefaultsAddTime() {
        
        // 向 UserDefaults 追加时间信息
        
        
        
        
        if (setM <= 0) {
            
            if (countUpMLog >= 15) {
                recordUtil.addTimeData(timerM: countUpMLog)
            }
            
            return
        }
        
        if (timerM > 0 || timerS > 3) {
            // 自己手动停止不计入
            return
        }
        
        if (setM < 15) {
            return
        }
        
        recordUtil.addTimeData(timerM: setM)
        
    }
    
    @objc func timerChangeAction() {
        if(setM <= 0) {
            // 倒计时的处理规则
            if(self.timerM >= timerMax) {
                self.timerM = timerMax
                self.timerS = 0
            } else {
                // 正计时
                if(timerS == 59) {
                    self.timerM += 1
                    self.timerS = 0
                } else {
                    self.timerS += 1
                    
                }
            }
            self.updateMenuBarIcon()
            //print("update countUpMLog \(countUpMLog)")
            self.countUpMLog = timerM
            

            
            return
        }
        
        
        if(timerM <= 0 && timerS <= 0) {
            self.coreTimer?.stopTimer()
            print("timer stoped.")
           
            sendTimerStopNotification()
            userDefaultsAddTime()
            
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countDownStop"), object: 0)
            return
        }
        
        if(timerS == 0) {
            self.timerS = 60
            self.timerM -= 1
        }
        
        self.timerS -= 1
        self.updateMenuBarIcon()
        
    }
    
    @objc func toggleMenuIcon(_sender: AnyObject) {

        if let button = self.statusItem.button {
            if self.popover.isShown {
                self.popover.performClose(self)
                
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge:NSRectEdge.minY)
            }
        }
    }
    
    /// 接收到传递的时钟启动消息
    @objc func timerReceiveStart(sender: Notification) {
        
        let info = sender.object as! Dictionary<String, Any>
        let mode = info["mode"] as! LDCountDownMode
        if (mode == .countup) {
            setCountDownTime(minutes: -1)
            debugPrint("LDMenuIcon > Started as Count Up")
            self.countUpMLog = 0
            startTimer()
            return
        }
        
        setCountDownTime(minutes: info["time"] as! Int)
        debugPrint("LDMenuIcon > Started ! Param : \(info["time"] as! Int)")
        self.countUpMLog = 0
        startTimer()
    }
    
    @objc func timerReceiveStop(sender: Notification) {
        stopTimer()
    }
    
    @objc func timerReceiveUserChange(sender: Notification) {
        let info = sender.object as! Dictionary<String, Any>
        let minutes = info["time"] as! Int
        let mode = info["mode"] as! LDCountDownMode
        debugPrint("LDMenuIcon > Receive UI Change \(minutes)")
        if (mode == .countup) {
            let text = "0:00"
            setMenuBarIconText(text: text)
        } else {
            let text = String(minutes) + ":00"
            setMenuBarIconText(text: text)
        }
        
        
        
        
    }
}
