//
//  VCCountDown.swift
//  Idle
//
//  Created by Ki MNO on 2023/12/28.
//

import Cocoa

public enum LDCountDownMode {
    case countdown
    case countup
}

class VCCountDown: NSViewController {

    public var statusCountDownMode = LDCountDownMode.countdown
    public var statusCountDownStarted = false
    public var statusCountDownSucceed = false
    
    public var statusShowQuote = false
    
    public var statusCountDownMinutes: Int = 10
    
    public var statusCurrentTreeGrade: Int = 4
    
    public var statusIsSuccess: Bool = false
    
    
    public var focusRecordCountUpTime: Int = 0
    
    var sync_timerM: Int = 0
    var sync_timerS: Int = 0
    var sync_setM: Int = 0
    
    var wndLinkForest: WDLinkForest?
    let recordUtil = LDRecord()
    let treeUtil = LFManager()
    
    let numberFormatterSecond = NumberFormatter()
    
    let focusTimeArray = [10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120]
    var focusTimeCurrent = 0
    
    let focusQuote = ["现在就开始工作吧！","不要再逛网页了！","不要一直看我，人家会害羞","加油，时间快到了！","一分一秒，皆是您专注的时光","赶快去做事","别放弃啊！","就在眼前，撑下去！","种一棵树，心无旁骛","加油，时间快到了！","专注！专注！","加油，您做得到的！","赶快做事，认真生活"]
    
    let delegateLargeTitleView = ViewLargeTimeLabel()
    
    var menuControllerSync: LDMenuSync? = LDMenuSync()
    
    var wndTagEditor: WDTreeEdit? = WDTreeEdit(windowNibName: "WDTreeEdit")
    
    /// 当前是否处于专注状态
    var focusStatus: Bool = false
    
    /// Forest 记录：开始的时间
    var forestRecordStartTime: Date?
    
    /// Forest 记录：结束时间
    var forestRecordEndTime: Date?
    
    /// Forest 记录：树种类型
    var forestRecordTreeType: Int = 0
    
    /// Forest 记录：Tag 标记
    var forestRecordTag: Int = 0
    
    /// Forest 记录：备注内容
    var forestRecordInfo: String = ""
    
    /// Forest 记录：资源文件中树的前缀
    var forestTreePictureAttr: String = "t"

    @IBOutlet var menuConfig: NSMenu!

    @IBOutlet weak var btnXMark: NSButton!
    
    @IBOutlet weak var btnGear: NSButton!
    
    @IBOutlet weak var btnBallImage: NSButton!
    @IBOutlet weak var btnEdit: NSButton!
    @IBOutlet weak var scCountDown: NSSegmentedControl!

    @IBOutlet weak var btnTreePicture: NSButton!
    @IBOutlet weak var lbMainInfo: NSTextField!
    @IBOutlet weak var menuPrefDockStyleCircle: NSMenuItem!
    @IBOutlet weak var menuPrefDockStyleBar: NSMenuItem!
    
    @IBOutlet weak var lbLargeTimeTitle: NSTextField!
    
    @IBOutlet weak var popCountType: NSPopUpButton!
    
    @IBOutlet weak var btnTimeLeftArrow: NSButton!
    
    @IBOutlet weak var btnTimeRightArrow: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        numberFormatterSecond.minimumIntegerDigits = 2
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveStopMessage), name: NSNotification.Name("countDownStop"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveLargeLabelEnterMessage), name: NSNotification.Name("largeTitleEnter"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveLargeLabelExitMessage), name: NSNotification.Name("largeTitleExit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveCount), name: NSNotification.Name("count"), object: nil)
        lbLargeTimeTitle.addTrackingRect(lbLargeTimeTitle.bounds, owner: delegateLargeTitleView, userData: nil, assumeInside: false)
        
        (self.btnTreePicture.cell! as! NSButtonCell).highlightsBy = NSCell.StyleMask(rawValue: 0)
        (self.btnBallImage.cell! as! NSButtonCell).highlightsBy = NSCell.StyleMask(rawValue: 0)
        
        let last_time = recordUtil.getLastFocusTime()
        if (last_time == -1) {
            statusCountDownMode = .countup
            statusCountDownMinutes = -1
            
            popCountType.selectItem(at: 1)
        } else {
            statusCountDownMode = .countdown
            statusCountDownMinutes = last_time
            popCountType.selectItem(at: 0)
            focusTimeCurrent = recordUtil.getLastSelectClock()
        }

    }
    
    // MARK: Overrides
    
    override func viewDidAppear() {
        super.viewDidAppear()

        //specialAnimationAdd()
        if !self.focusStatus {
            uiUpdateCurrentTimeSelection()
        }
        
        uiGenerateRandomQuote()
    }
    
    // MARK: Functions
    
    func uiUpdateCurrentTimeSelection() {
        
        if (statusCountDownMode == .countup) {
            lbLargeTimeTitle.stringValue = "0:00"
            sendUserTimerChangeMessage()
            statusCountDownMinutes = -1
            recordUtil.setLastFocusTime(time: -1)
            
        } else {
            self.lbLargeTimeTitle.stringValue = String(statusCountDownMinutes) + ":00"
            sendUserTimerChangeMessage()
            recordUtil.setLastFocusTime(time: statusCountDownMinutes)
            recordUtil.setLastSelectClock(clock: focusTimeCurrent)
        }
        
        
    }
    

    
    /// UI 准备开始专注
    func uiReadyStart() {
        if (self.focusStatus == true) {
            return
        }
        
        let storage = LFStorage()
        let data_starttime = storage.getTempTreeRecordStartTime()
        
        if (storage.getUserToken().isEmpty) {
            let alert = NSAlert()
            alert.messageText = "请登录。"

            alert.addButton(withTitle: "好")
            alert.runModal()
            return
        }
        
        
        if (!data_starttime.isEmpty) {
            
            let alert = NSAlert()
            alert.messageText = "因为上次同步失败，还有暂存的记录未被同步。在完成数据同步后才可以进行新的专注。"
            alert.informativeText = "点击左上角的齿轮图标，再点击 “立即同步” 来上传未同步的记录。"
            
            alert.addButton(withTitle: "好")
            alert.runModal()
            return
            
        }
        
        self.focusStatus = true
        self.btnGear.isHidden = true
        self.btnEdit.isHidden = false
        self.btnXMark.isHidden = false
        self.btnXMark.image = NSImage(named: "remove")
        self.popCountType.isHidden = true
        self.btnTimeLeftArrow.isHidden = true
        self.btnTimeRightArrow.isHidden = true
        self.forestRecordInfo = ""
        uiGenerateRandomQuote()
        
        storage.storageTempTreeRecord(startTime: "", endTime: "", duration: 0, tree_type: 0, is_success: false, tag: 0, note_content: "")
        
        mainStartFocus()
    }
    
    /// UI 结束专注
    func uiRestoreToDefault() {
        self.focusStatus = false
        self.btnGear.isHidden = false
        self.btnEdit.isHidden = true
        self.btnXMark.isHidden = true
        self.btnXMark.image = NSImage(named: "remove")
        self.popCountType.isHidden = false
        self.lbMainInfo.stringValue = "点击树木图片开始种植"
        
        
        self.focusRecordCountUpTime = 0
        uiUpdateCurrentTimeSelection()
    }
    
    func uiGenerateRandomQuote() {
        
        if self.statusShowQuote != true {
            return
        }
        
        let index = arc4random() % 13
        self.lbMainInfo.stringValue = focusQuote[Int(index)]
        
    }
    

    func uiUpdateTreeStatus() {
        

        
        if statusCountDownMode == .countup {
            let f = forestTreePictureAttr + "4"
            self.btnTreePicture.image = NSImage(named: f)
            return
        }

        let tree_status = treeUtil.getTreePhaseGrade(currentMinuts: statusCountDownMinutes)
        
        let tree_pic_name = forestTreePictureAttr + String(tree_status)

        self.btnTreePicture.image = NSImage(named: tree_pic_name)
        
    }
    
    func mainStartFocus() {
        
        let count_down_dict = ["mode": statusCountDownMode, "time": statusCountDownMinutes] as [String : Any]
        debugPrint(">> sendCountDownStartMessage: \(count_down_dict)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countDownStart"), object: count_down_dict)
        
        print("FRecord >")
        self.forestRecordStartTime = Date()
        
        self.statusShowQuote = true
        uiGenerateRandomQuote()
    }
    
    
    // MARK: Notification Send & Receive
    

    func sendUserTimerChangeMessage() {
        let count_down_dict = ["mode": statusCountDownMode, "time": statusCountDownMinutes] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countDownUserChange"), object: count_down_dict)
        uiUpdateTreeStatus()
        
    }
    
    func sendStartMessage() {
        let count_down_dict = ["mode": statusCountDownMode, "time": statusCountDownMinutes] as [String : Any]
        debugPrint(">> sendCountDownStartMessage: \(count_down_dict)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countDownStart"), object: count_down_dict)
    }
    
    func sendStopMessage() {
        // 手动停止了计时
        self.statusShowQuote = false
        self.statusCountDownStarted = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countDownStop"), object: 1)
        
        if (statusCountDownMode == .countup) {
            self.statusShowQuote = false
            self.statusCountDownStarted = false
            
            self.lbMainInfo.stringValue = "成功啦！"
            self.lbLargeTimeTitle.stringValue = ""
            statusIsSuccess = true
            self.forestRecordEndTime = Date()
            btnXMark.image = NSImage(named: "return")
            
            return
        }
        
        lbLargeTimeTitle.stringValue = ""
        lbMainInfo.stringValue = "失败了，下一次再努力！"
        btnTreePicture.image = NSImage(named: forestTreePictureAttr + "0")
        statusIsSuccess = false
        btnXMark.image = NSImage(named: "return")
        self.forestRecordEndTime = Date()
    }
    
    func recordFocus() {
        
        // 核心：记录此次的专注记录
        
        
    }


    @objc func onReceiveStopMessage(sender: Notification) {
        print("VCCountDown > Receive Stop Message")
        
        let repo_status = sender.object as! Int
        
        if (repo_status == 1) {
            return
        }
        self.statusShowQuote = false
        self.statusCountDownStarted = false
        
        self.lbMainInfo.stringValue = "成功啦！"
        self.lbLargeTimeTitle.stringValue = ""
        statusIsSuccess = true
        // 设定图片
        self.forestRecordEndTime = Date()
        let final_m = sync_setM
        let t_pic = treeUtil.getTreePhaseGrade(currentMinuts: final_m)
        let pic_name = forestTreePictureAttr + String(t_pic)
        self.btnTreePicture.image = NSImage(named: pic_name)
        btnXMark.image = NSImage(named: "return")
    }
    
    @objc func onReceiveLargeLabelEnterMessage(sender: Notification) {
        
        if (self.statusCountDownMode == .countup) {
            return
        }
        
        if (self.focusStatus == true) {
            return
        }
        
        NSAnimationContext.runAnimationGroup({ [self] context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.btnTimeLeftArrow.isHidden = false
            self.btnTimeRightArrow.isHidden = false
            btnTimeLeftArrow.animator().alphaValue = 1
            btnTimeRightArrow.animator().alphaValue = 1
        })
        
    }
    
    @objc func onReceiveLargeLabelExitMessage(sender: Notification) {
        
        if (self.statusCountDownMode == .countup) {
            return
        }
        
        if (self.focusStatus == true) {
            return
        }
        
        NSAnimationContext.runAnimationGroup({ [self] context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            btnTimeLeftArrow.animator().alphaValue = 0
            btnTimeRightArrow.animator().alphaValue = 0
            
        }, completionHandler: { [self] in
            self.btnTimeLeftArrow.isHidden = true
            self.btnTimeRightArrow.isHidden = true
        })
    }
    
    @objc func onReceiveCount(sender: Notification) {
        let info = sender.object as! Dictionary<Int, Int>
        let timerM = info[0] ?? 0
        let timerS = info[1] ?? 0
        let setM = info[2] ?? 0
        
        sync_timerM = timerM
        sync_timerS = timerS
        sync_setM = setM
        
        if (focusRecordCountUpTime < sync_timerM) {
            focusRecordCountUpTime = sync_timerM
        }
        
        if(timerM == 0 && timerS == 0) {
            if(setM < 0) {
                lbLargeTimeTitle.stringValue = "0:00"
            } else {
                lbLargeTimeTitle.stringValue = "\(setM):00"
            }
            return
        }
       
        let timer_string = "\(timerM):\(numberFormatterSecond.string(from: NSNumber(value: timerS)) ?? "0:00")"
        lbLargeTimeTitle.stringValue = timer_string

        if focusStatus == true {
            // 树的成长状态处理
            let current_grade = treeUtil.getTreeGradePicture(currentM: sync_timerM, setM: sync_setM)
            let tree_pic_name = forestTreePictureAttr + String(current_grade)
            self.btnTreePicture.image = NSImage(named: tree_pic_name)
            //print(tree_pic_name)
        }
        

    }

    // MARK: IBAction
    
    @IBAction func btnClickedLinkForest(_ sender: AnyObject) {
        if (menuControllerSync != nil) {
            menuControllerSync = nil
            menuControllerSync = LDMenuSync()
        }
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 2))
        menuControllerSync!.contentMenu.popUp(positioning: nil, at: p, in: sender.superview)
        //self.menuLink.popUp(positioning: nil, at: p, in: sender.superview)
    }
    

    
    @IBAction func btnClickedConfig(_ sender: AnyObject) {
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 2))
        self.menuConfig.popUp(positioning: nil, at: p, in: sender.superview)
    }
    
    @IBAction func btnClickedEdit(_ sender: AnyObject) {
        
        if wndTagEditor != nil {
            if wndTagEditor?.isOpened == true {
                return
            }
            
            wndTagEditor = nil; wndTagEditor = WDTreeEdit(windowNibName: "WDTreeEdit")
        }
        
        wndTagEditor?.lastInfoContent = forestRecordInfo
        wndTagEditor?.lastSelectTagID = forestRecordTag
        
        wndTagEditor?.handleSendBackTreeEdit =  { (tag: Int, content: String) -> Void in
            
            self.forestRecordTag = tag
            self.forestRecordInfo = content
            print("update tag \(tag)")
            
        }
        
        wndTagEditor?.showWindow(self)
        
    }
    
    @IBAction func btnClickedTimeL(_ sender: Any) {
        if self.focusTimeCurrent == 0 {
            self.focusTimeCurrent = focusTimeArray.count - 1
        } else {
            self.focusTimeCurrent -= 1
        }
        
        self.statusCountDownMinutes = focusTimeArray[focusTimeCurrent]
        
        uiUpdateCurrentTimeSelection()

    }
    
    @IBAction func btnClickedTimeR(_ sender: Any) {
        if (self.focusTimeCurrent == focusTimeArray.count - 1) {
            self.focusTimeCurrent = 0
        } else {
            self.focusTimeCurrent += 1
        }
        
        self.statusCountDownMinutes = focusTimeArray[focusTimeCurrent]
        
        uiUpdateCurrentTimeSelection()
    }
    
    
    @IBAction func btnClickedXMark(_ sender: Any) {
        
        
        if (btnXMark.image?.name() == "remove") {
            
            if statusCountDownMode == .countup {
                
                sendStopMessage()
                
                if focusRecordCountUpTime < 10 {
                    let alert = NSAlert()
                    alert.messageText = "此次专注时间小于 10 分钟，不会被记录。"
                    alert.runModal()
                }
                
                return
            }
            
            let alert = NSAlert()
            alert.messageText = "您确定要放弃吗？"
            alert.informativeText = "您充满活力、绿意盎然的树将会枯萎"
            
            alert.addButton(withTitle: "取消")
            alert.addButton(withTitle: "放弃")
            
            let repo = alert.runModal()
            
            if (repo == .alertSecondButtonReturn) {
                sendStopMessage()
            }

        } else {
            
            // 回到主界面与上传准备
            var start_time = treeUtil.getUTCDate(date: forestRecordStartTime!)
            var end_time = treeUtil.getUTCDate(date: forestRecordEndTime!)
            let update_time = treeUtil.getUTCDate(date: Date())
            
            // 如果是正计时：进行时间修正
            
            var duration = 0
            if (statusCountDownMode == .countup) {
                // 正计时
                duration = focusRecordCountUpTime
            } else {
                duration = sync_setM
            }
            
            if statusCountDownMode == .countup {
                
                // 正计时的时间修正，转换为 5 的倍数
                let forest_manager = LFManager()
                let fix_focustime = forest_manager.countUpFocusTimeAdjust(focusTime: duration)
                let fixed_start_time = Date(timeInterval: -60 * Double(fix_focustime), since: forestRecordEndTime!)
                duration = fix_focustime
                start_time = treeUtil.getUTCDate(date: fixed_start_time)
            }
            
            
            print("Tree Information: \n")
            print("Start time : \(start_time)")
            print("End time : \(end_time))")
            print("Update time : \(update_time)")

            
            print("Duration : \(duration)")
            
            print("Tree type : \(forestRecordTreeType)")
            
            print("Is Success : \(statusIsSuccess)")
            
            print("Note : \(forestRecordInfo)")
            
            print("Tag : \(forestRecordTag)")
            
            let queue = DispatchQueue(label: "studio.tri.idle.uploadTree")
            queue.async { [self]  in
                let mgr = LFRequest()
                mgr.updateTree(startTime: start_time, endTime: end_time, duration: duration, tree_type: self.forestRecordTreeType, is_success: self.statusIsSuccess, tag: self.forestRecordTag, note_content: self.forestRecordInfo)
                
            }
            
            
            uiRestoreToDefault()
        }
    }
    
    
    @IBAction func btnClickedTree(_ sender: Any) {
        

        
        
        uiReadyStart()
    }
    
    
    @IBAction func btnClickedBall(_ sender: Any) {
        uiReadyStart()
    }
    
    @IBAction func popClickedChange(_ sender: Any) {

        if popCountType.indexOfSelectedItem == 0 {
            statusCountDownMode = .countdown
            statusCountDownMinutes = focusTimeArray[0]
            focusTimeCurrent = 0
        } else {
            statusCountDownMode = .countup
            
        }
        
        uiUpdateCurrentTimeSelection()
    }
}


class ViewLargeTimeLabel : NSObject {
    @objc(mouseEntered:) func mouseEntered(with event: NSEvent) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "largeTitleEnter"), object: nil)
      }

      @objc(mouseExited:) func mouseExited(with event: NSEvent) {

          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "largeTitleExit"), object: nil)
      }
    
    
    
}
