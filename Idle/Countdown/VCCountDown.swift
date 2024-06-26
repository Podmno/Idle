//
//  VCCountDown.swift
//  Idle
//
//  Created by Ki MNO on 2023/12/28.
//

import Cocoa
import ForestSupport
import SwiftyJSON

/// FLAG: 开启切换树种功能
let FLAG_ENABLE_TRUE_TYPE_SWITCH = true

public enum LDCountDownMode {
    case countdown
    case countup
}


class VCCountDown: NSViewController {
    
    /// Plant Resource Service
    let plantService = LFPlantManager()

    /// 当前的倒计时模式
    public var statusCountDownMode = LDCountDownMode.countdown
    
    /// 是否已经开启了倒计时
    public var statusCountDownStarted = false
    
    /// 是否展示提醒标语
    public var statusShowQuote = false
    
    /// 当前设定的倒计时时间（分钟）
    public var statusCountDownMinutes: Int = 10
    
    /// 当前的树等级
    public var statusCurrentTreeGrade: Int = 4
    
    /// 判断是否成功（上传时使用）
    public var statusIsSuccess: Bool = false
    
    /// 正计时时间记录
    public var focusRecordCountUpTime: Int = 0
    
    /// 从计时器同步过来的时间分钟数
    var sync_timerM: Int = 0
    
    /// 从计时器同步过来的时间秒数
    var sync_timerS: Int = 0
    
    /// 倒计时专用：同步过来的时钟分钟数
    var sync_setM: Int = 0
    
    var wndLinkForest: WDLinkForest?
    lazy var recordUtil = LDRecord()
    let treeUtil = LFUtility()
    
    let plantResources = LFPlantResource()
    var plantResourcesData: [Int:LFPlantResourceInfo] = [:]
    var plantResourcesAvailableList: [Int] = []
    
    /// 秒数规格化
    var numberFormatterSecond : NumberFormatter {
        let n = NumberFormatter()
        n.minimumIntegerDigits = 2
        return n
    }
    
    /// 可供选择的倒计时
    let focusTimeArray = [10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120]
    
    /// 当前选择的倒计时 Index
    var focusTimeCurrent = 0
    
    /// 专注标语
    let focusQuote = ["现在就开始工作吧！","不要再逛网页了！","不要一直看我，人家会害羞","加油，时间快到了！","一分一秒，皆是您专注的时光","赶快去做事","别放弃啊！","就在眼前，撑下去！","种一棵树，心无旁骛","加油，时间快到了！","专注！专注！","加油，您做得到的！","赶快做事，认真生活"]
    
    /// 用于检测鼠标是否指向时间大标题
    let delegateLargeTitleView = ViewLargeTimeLabel()
    
    /// 树种选择检测
    let delegateLargePlantView = ViewLargePlantIcon()
    
    /// 同步 Menu Controller
    var menuControllerSync: LDMenuSync? = LDMenuSync()
    
    /// Tag Editor
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
   
    @IBOutlet weak var menuPrefDockStyleCircle: NSMenuItem!
    @IBOutlet weak var menuPrefDockStyleBar: NSMenuItem!
    @IBOutlet weak var lbMainInfo: NSTextField!
    @IBOutlet weak var lbLargeTimeTitle: NSTextField!
    
    @IBOutlet weak var popCountType: NSPopUpButton!
    
    @IBOutlet weak var btnTimeLeftArrow: NSButton!
    @IBOutlet weak var btnTimeRightArrow: NSButton!
    
    @IBOutlet weak var btnPlantLeftArrow: NSButton!
    @IBOutlet weak var btnPlantRightArrow: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotificationObserver()
        setupViewTrackingArea()
        uiSetRecordFocusTime()
        
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
        
        loadAvailableTreeID()
    }
    
    
    func loadAvailableTreeID() {
        
        let all_res = plantResources.getAllPlantsResource()
        let storage_util = LFStorage()
        let account_info = storage_util.dataGetUnlock()
        let account_json = JSON(parseJSON: account_info)
        
        if (account_json.isEmpty) {
            plantResourcesData[0] = all_res[0]
            
            return
        }
        
        for (_,data_content) in account_json {
            
            let tree_id = data_content["gid"].intValue
            
            if (!all_res.keys.contains(tree_id)) {
                // 如果资源包 bundle 没有更新，那么跳过这个新的树种
                continue
            }
            
            plantResourcesAvailableList.append(tree_id)
            plantResourcesData[tree_id] = all_res[tree_id]
            
        }
        plantResourcesAvailableList.sort()
    }
    
    @objc func userSignInToggle() {
        print("VC > !! toggle userSignIn")
        forestRecordTreeType = 0
        plantResourcesData.removeAll()
        plantResourcesAvailableList.removeAll()
        
        loadAvailableTreeID()
        
        uiUpdateTreePicture()
    }
    
    @objc func userSignOutToggle() {
        print("VC > !! toggle userSignOut")
        forestRecordTreeType = 0
        plantResourcesData.removeAll()
        plantResourcesAvailableList.removeAll()
        
        loadAvailableTreeID()
        
        uiUpdateTreePicture()
    }
    
    // MARK: - 用户界面配置
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveStopMessage), name: NSNotification.Name("countDownStop"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveLargeLabelEnterMessage), name: NSNotification.Name("largeTitleEnter"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveLargeLabelExitMessage), name: NSNotification.Name("largeTitleExit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userSignOutToggle), name: NSNotification.Name("userSignOut"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userSignOutToggle), name: NSNotification.Name("userSignIn"), object: nil)
        
        if (FLAG_ENABLE_TRUE_TYPE_SWITCH) {
            NotificationCenter.default.addObserver(self, selector: #selector(onReceiveLargePlantEnterMessage), name: NSNotification.Name("largePlantEnter"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onReceiveLargePlantExitMessage), name: NSNotification.Name("largePlantExit"), object: nil)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveCount), name: NSNotification.Name("count"), object: nil)
    }
    
    private func setupViewTrackingArea() {
        lbLargeTimeTitle.addTrackingRect(lbLargeTimeTitle.bounds, owner: delegateLargeTitleView, userData: nil, assumeInside: false)
        
        if(FLAG_ENABLE_TRUE_TYPE_SWITCH) {
            var button_bounds = btnBallImage.bounds
            // 扩大监测区域
            button_bounds.size.width = button_bounds.width + 100
            button_bounds.center.x = button_bounds.center.x - 50
            btnBallImage.addTrackingRect(button_bounds, owner: delegateLargePlantView, userData: nil, assumeInside: false)
        }
        (self.btnTreePicture.cell! as! NSButtonCell).highlightsBy = NSCell.StyleMask(rawValue: 0)
        (self.btnBallImage.cell! as! NSButtonCell).highlightsBy = NSCell.StyleMask(rawValue: 0)
        
        
    }
    
    // MARK: Overrides
    
    override func viewDidAppear() {
        super.viewDidAppear()
        //specialAnimationAdd()
        if !self.focusStatus {
            uiUpdateCurrentTimeSelection()
        }

        
        uiGenerateRandomQuote()
        
        if #available(macOS 14.0, *) {
            NSApp.activate()
            
            print("macOS 14: Current App Active Status: \(NSApp.isActive)")
        } else {
            // Fallback on earlier versions
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    // MARK: UI 与状态切换
    
    /// 更新时间选择
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
        
        /* 未登录用户组织专注：解除限制
        if (storage.getUserToken().isEmpty) {
            let alert = NSAlert()
            alert.messageText = "请登录。"

            alert.addButton(withTitle: "好")
            alert.runModal()
            return
        }*/
        
        if (storage.getLock()) {
            let alert = NSAlert()
            alert.messageText = "正在进行数据同步，请稍等片刻。"

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
        
        uiStatusSetCurrentFocusTrue()
        
        storage.storageTempTreeRecord(startTime: "", endTime: "", duration: 0, tree_type: 0, is_success: false, tag: 0, note_content: "")
        
        self.btnPlantLeftArrow.isHidden = true
        self.btnPlantRightArrow.isHidden = true
        
        mainStartFocus()
    }
    
    /// 设定 UI 为结束专注
    func uiStatusSetCurrentFocusFalse() {
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
    
    /// 设定 UI 为正在专注
    func uiStatusSetCurrentFocusTrue() {
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
    }
    
    
    /// 随机激励标语
    func uiGenerateRandomQuote() {
        
        if self.statusShowQuote != true {
            return
        }
        
        let index = arc4random() % UInt32(focusQuote.count)
        self.lbMainInfo.stringValue = focusQuote[Int(index)]
        
    }
    
    /// 更新树种图片
    func uiUpdateTreePicture() {
        if statusCountDownMode == .countup {
            let tree_path = plantResourcesData[forestRecordTreeType]?.plantGradePicturePath[4]
            if (tree_path == nil) {
                // 异常情况：使用资源包里携带的默认 tree 图片
                let tree_pic_name = forestTreePictureAttr + "4"
                self.btnTreePicture.image = NSImage(named: tree_pic_name)
                return
            }
            self.btnTreePicture.image = NSImage(contentsOfFile: tree_path!)
            return
        }

        let tree_status = treeUtil.getTreePhaseGrade(currentMinuts: statusCountDownMinutes)
        
        let tree_path = plantResourcesData[forestRecordTreeType]?.plantGradePicturePath[tree_status]
        if (tree_path == nil) {
            // 异常情况：使用资源包里携带的默认 tree 图片
            let tree_pic_name = forestTreePictureAttr + String(tree_status)
            self.btnTreePicture.image = NSImage(named: tree_pic_name)
            return
        }

        self.btnTreePicture.image = NSImage(contentsOfFile: tree_path!)
        
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
    
    
    // MARK: 主要倒计时函数
    

    func sendUserTimerChangeMessage() {
        let count_down_dict = ["mode": statusCountDownMode, "time": statusCountDownMinutes] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countDownUserChange"), object: count_down_dict)
        uiUpdateTreePicture()
        
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

    /// 读取今日专注时间，设置 UI 为 今日共专注 ？？ 分钟
    func uiSetRecordFocusTime() {
        
        let record_util = LDRecord()
        let d_focus_time = record_util.getDayMinutes()
        if d_focus_time == 0 {
            self.lbMainInfo.stringValue = "点击树木图片开始种植"
            
        } else {
            self.lbMainInfo.stringValue = "你今天已经专心了\n" + record_util.getFocusTimeDayStringDescribing()
        }
        
        
    }

    @objc func onReceiveStopMessage(sender: Notification) {
        
        // 接收到计时器结束消息
        
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
        
        let tree_path = plantResourcesData[forestRecordTreeType]?.plantGradePicturePath[t_pic]
        
        self.btnPlantLeftArrow.isHidden = true
        self.btnPlantRightArrow.isHidden = true
        
        if (tree_path == nil) {
            // 异常情况：使用资源包里携带的默认 tree 图片
            let tree_pic_name = forestTreePictureAttr + String(t_pic)
            self.btnTreePicture.image = NSImage(named: tree_pic_name)
            
        } else {
            self.btnTreePicture.image = NSImage(contentsOfFile: tree_path!)
        }
        //let pic_name = forestTreePictureAttr + String(t_pic)
        //self.btnTreePicture.image = NSImage(named: pic_name)
        btnXMark.image = NSImage(named: "return")
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
    
    // MARK: - 用户光标浮动检测
    
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
    
    /// 鼠标移动进入树种图标
    @objc func onReceiveLargePlantEnterMessage(sender: Notification) {
        // countup 不影响
        
        if (self.plantResourcesData.count == 1) {
            self.btnPlantLeftArrow.isHidden = true
            self.btnPlantRightArrow.isHidden = true
            return
        }
        
        if (self.focusStatus == true) {
            return
        }
        
        NSAnimationContext.runAnimationGroup({ [self] context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.btnPlantLeftArrow.isHidden = false
            self.btnPlantRightArrow.isHidden = false
            btnPlantLeftArrow.animator().alphaValue = 1
            btnPlantRightArrow.animator().alphaValue = 1
        })

    }
    
    /// 鼠标移动退出树种图标
    @objc func onReceiveLargePlantExitMessage(sender: Notification) {
        
        if (self.plantResourcesData.count == 1) {
            self.btnPlantLeftArrow.isHidden = true
            self.btnPlantRightArrow.isHidden = true
            return
        }
        
        NSAnimationContext.runAnimationGroup({ [self] context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            btnPlantLeftArrow.animator().alphaValue = 0
            btnPlantRightArrow.animator().alphaValue = 0
            
        }, completionHandler: { [self] in
            self.btnPlantLeftArrow.isHidden = true
            self.btnPlantRightArrow.isHidden = true
        })
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
  
        wndTagEditor?.window?.level = .modalPanel
        //NSApp.activate(ignoringOtherApps: true)
        wndTagEditor?.showWindow(nil)
        //wndTagEditor?.showWindow(self)
        
    }
    
    @IBAction func btnClickedTimeL(_ sender: Any) {
        
        if (self.statusCountDownMode == .countup) {
            return
        }
        
        if self.focusTimeCurrent == 0 {
            self.focusTimeCurrent = focusTimeArray.count - 1
        } else {
            self.focusTimeCurrent -= 1
        }
        
        self.statusCountDownMinutes = focusTimeArray[focusTimeCurrent]
        
        uiUpdateCurrentTimeSelection()

    }
    
    @IBAction func btnClickedTimeR(_ sender: Any) {
        if (self.statusCountDownMode == .countup) {
            return
        } 
        
        if (self.focusTimeCurrent == focusTimeArray.count - 1) {
            self.focusTimeCurrent = 0
        } else {
            self.focusTimeCurrent += 1
        }
        
        self.statusCountDownMinutes = focusTimeArray[focusTimeCurrent]
        
        uiUpdateCurrentTimeSelection()
    }
    
    var currentSelectTreeTypeIndex = 0
    @IBAction func btnSwitchPlantL(_ sender: Any) {
        print(plantResourcesAvailableList)
        
        if (currentSelectTreeTypeIndex == 0) {
            currentSelectTreeTypeIndex = plantResourcesAvailableList.count - 1
        } else {
            currentSelectTreeTypeIndex -= 1
        }
        
        forestRecordTreeType = plantResourcesAvailableList[currentSelectTreeTypeIndex]
        
        uiUpdateTreePicture()
    }
    
    @IBAction func btnSwitchPlantR(_ sender: Any) {
        print(plantResourcesAvailableList)
        if (currentSelectTreeTypeIndex == plantResourcesAvailableList.count - 1) {
            currentSelectTreeTypeIndex = 0
        } else {
            currentSelectTreeTypeIndex += 1
        }
        
        forestRecordTreeType = plantResourcesAvailableList[currentSelectTreeTypeIndex]
        
        uiUpdateTreePicture()
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
                
                
                self.btnPlantLeftArrow.isHidden = true
                self.btnPlantRightArrow.isHidden = true
            }

        } else {
            let storage = LFStorage()
            
            if (storage.getUserToken().isEmpty) {
                // 用户未登录，不进行上传操作
                print("User not logged in, skip upload.")
                
            } else {
                // 用户已经登陆
                // 回到主界面与上传准备
                var start_time = treeUtil.getUTCDate(date: forestRecordStartTime!)
                let end_time = treeUtil.getUTCDate(date: forestRecordEndTime!)
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
                    let forest_manager = LFUtility()
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
                
               
                // Upload Tree
                let queue = DispatchQueue(label: "studio.tri.idle.uploadTree")
                queue.async { [self]  in
                    let mgr = LFRequest()
                    let result_tree = LFTree(startTime: start_time, endTime: end_time, duration: duration, tree_type: self.forestRecordTreeType, is_success: self.statusIsSuccess, tag: self.forestRecordTag, note_content: self.forestRecordInfo)
                    // TODO: Update Tree > Toggle Update
                    _ = mgr.updateTree(tree: result_tree)
                    
                    print("> LFStorage.addStorageTree")
                    storage.addStorageTree(tree: result_tree)
                    
                }
                
                if (statusIsSuccess) {
                    // 只有成功的记录才会被计入
                    let record = LDRecord()
                    record.addTimeData(timerM: duration)
                }
                
            }
            
            //self.btnPlantLeftArrow.isHidden = false
            //self.btnPlantRightArrow.isHidden = false
            
            
            uiStatusSetCurrentFocusFalse()
            uiSetRecordFocusTime()
        }
    }
    
    
    func uploadTree() {
        
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


class ViewLargePlantIcon: NSObject {
    @objc(mouseEntered:) func mouseEntered(with event: NSEvent) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "largePlantEnter"), object: nil)
    }

    @objc(mouseExited:) func mouseExited(with event: NSEvent) {

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "largePlantExit"), object: nil)
    }
    
    
}
