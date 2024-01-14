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
    public var statusCountDownMinutes: Int = 15
    let wnd = WDTimerConfig(windowNibName: "WDTimerConfig")
    var wndLinkForest: WDLinkForest?
    let recordUtil = LDRecord()
    
    let menuControllerSync = LDMenuSync()
    
    
    @IBOutlet weak var clockMenu1: NSMenuItem!
    @IBOutlet weak var clockMenu2: NSMenuItem!
    @IBOutlet weak var clockMenu3: NSMenuItem!
    @IBOutlet weak var clockMenu4: NSMenuItem!
    @IBOutlet weak var clockMenu5: NSMenuItem!
    @IBOutlet var menuConfig: NSMenu!
    @IBOutlet var menuLink: NSMenu!
    @IBOutlet weak var btnConfig: NSButton!
    @IBOutlet weak var btnStart: NSButton!
    @IBOutlet weak var scCountDown: NSSegmentedControl!
    @IBOutlet weak var popTimeSelect: NSPopUpButton!
    @IBOutlet weak var lbToday: NSTextField!
    @IBOutlet weak var lbWeek: NSTextField!
    @IBOutlet weak var lbTotal: NSTextField!
    @IBOutlet weak var menuPrefDockStyleCircle: NSMenuItem!
    @IBOutlet weak var menuPrefDockStyleBar: NSMenuItem!
    @IBOutlet weak var specialIcon: NSImageView!
    @IBOutlet weak var outlineViewHeader: NSOutlineView!
    
    var vectoryEffect = ConfettiView()
    var clocksConfig: [Int] = [15, 30, 45, 60, 120]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveStopMessage), name: NSNotification.Name("countDownStop"), object: nil)
        
        popTimeSelect.selectItem(at: 0)
        
        uiSwitchBtnStart(status: false)
        
        btnStart.bezelColor = .controlAccentColor
        
        let last_focus_selection = recordUtil.getLastFocusTime()
        if (last_focus_selection <= 0) {
            
            scCountDown.setSelected(false, forSegment: 0)
            scCountDown.setSelected(true, forSegment: 1)
        } else {
            scCountDown.setSelected(true, forSegment: 0)
            scCountDown.setSelected(false, forSegment: 1)
            
        }
        
        if (self.scCountDown.indexOfSelectedItem == 0) {
            // Countdown
            self.popTimeSelect.isEnabled = true
        } else {
            self.popTimeSelect.isEnabled = false
        }
        
        setClockMenus()
        
        let last_run = self.recordUtil.getLastSelectClock()
        
        print("last_run: \(last_run)")
        if (last_run == 4) {
            self.popTimeSelect.selectItem(at: 5)
            return
        }
        self.popTimeSelect.selectItem(at: last_run)
        
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
        clocksConfig = recordUtil.getClocks()
        setClockMenus()
        
        let d = recordUtil.getDayMinutes()
        let w = recordUtil.getWeekMinutes()
        let t = recordUtil.getTotalMinutes()
        
        if (d >= 60) {
            let d_minutes = d % 60
            let d_hours = (d - d_minutes) / 60
            lbToday.stringValue = "\(d_hours)h\(d_minutes)m"
        } else {
            lbToday.stringValue = "\(d)m"
        }
        
        if (w >= 60) {
            let w_minutes = w % 60
            let w_hours = (w - w_minutes) / 60
            lbWeek.stringValue = "\(w_hours)h\(w_minutes)m"
        } else {
            lbWeek.stringValue = "\(w)m"
        }
        
        if (t >= 60) {
            let t_minutes = t % 60
            let t_hours = (t - t_minutes) / 60
            lbTotal.stringValue = "\(t_hours)h\(t_minutes)m"
        } else {
            lbTotal.stringValue = "\(t)m"
        }
        
        if (t >= 6000 && t < 60000) {
            let t_minutes = t % 60
            let t_hours = (t - t_minutes) / 60
            let attr = NSFont.systemFont(ofSize: 23.0)
            let para = NSMutableParagraphStyle()
            para.alignment = .center
            var attr_string = NSMutableAttributedString(string: "\(t_hours)h\(t_minutes)m")
            let range = NSMakeRange(0, attr_string.length)
            attr_string.addAttributes([.font: attr, .paragraphStyle: para], range: range)
            lbTotal.attributedStringValue = attr_string
            lbTotal.textColor = .labelColor
            specialIcon.image = NSImage(named: "flag.fill")
            specialIcon.isHidden = false
            specialIcon.contentTintColor = .labelColor
            
        }
        
        if (t >= 60000) {
            lbTotal.textColor = .controlAccentColor
            let t_minutes = t % 60
            let t_hours = (t - t_minutes) / 60
            let attr_string = NSMutableAttributedString(string: "\(t_hours)h\(t_minutes)m")
            let attr = NSFont.systemFont(ofSize: 23.0)
            let range = NSMakeRange(0, attr_string.length)
            let para = NSMutableParagraphStyle()
            para.alignment = .center
            attr_string.addAttributes([.font: attr, .paragraphStyle: para], range: range)
            lbTotal.attributedStringValue = attr_string
            specialIcon.image = NSImage(named: "flag.fill")
            specialIcon.isHidden = false
            specialIcon.contentTintColor = .controlAccentColor
            
        }
        
        if (t >= 5999940 ) {
            lbTotal.textColor = .controlAccentColor
            let attr_string = NSMutableAttributedString(string: "99999h")
            let attr = NSFont.systemFont(ofSize: 23.0)
            let para = NSMutableParagraphStyle()
            para.alignment = .center
            let range = NSMakeRange(0, attr_string.length)
            attr_string.addAttributes([.font: attr, .paragraphStyle: para], range: range)
            lbTotal.attributedStringValue = attr_string
            lbTotal.alignment = .center
            specialIcon.image = NSImage(named: "crown.fill")
            specialIcon.isHidden = false
        }

        
        print("Clocks config: \(clocksConfig)")
        //specialAnimationAdd()
    }
    
    func setClockMenus() {
        
        self.clockMenu1.title = "\(clocksConfig[0])min"
        self.clockMenu2.title = "\(clocksConfig[1])min"
        self.clockMenu3.title = "\(clocksConfig[2])min"
        self.clockMenu4.title = "\(clocksConfig[3])min"
        self.clockMenu5.title = "\(clocksConfig[4])min"
        

    }
    
    
    
    /// UI 切换：按钮为开始或停止状态
    /// - Parameter status: 当选项设定为  `true` 时，显示为 `暂停按钮`。否则显示为 `开始按钮`
    func uiSwitchBtnStart(status: Bool) {
        if status {
            btnStart.title = "   \(NSLocalizedString("Stop", comment: ""))"
            if #available(macOS 11.0, *) {
                btnStart.image = NSImage(named: "stop")
                //btnStart.image = NSImage(systemSymbolName: "stop", accessibilityDescription: "stop")
            } else {
                // Fallback on earlier versions
            }
        } else {
            btnStart.title = "   \(NSLocalizedString("Start", comment: ""))"
            if #available(macOS 11.0, *) {
                btnStart.image = NSImage(named: "play")
                // btnStart.image = NSImage(systemSymbolName: "play", accessibilityDescription: "play")
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    /// 由 UI 载入当前选择的时间选项
    func loadCurrentTimeSelection() {
        
        if (self.scCountDown.indexOfSelectedItem == 1) {
            
            self.statusCountDownMinutes = -1
            recordUtil.setLastFocusTime(time: -1)
            return
            
        }
        
        print(self.popTimeSelect.indexOfSelectedItem )
        switch self.popTimeSelect.indexOfSelectedItem {
        case 0:
            self.statusCountDownMinutes = clocksConfig[0]
            recordUtil.setLastFocusTime(time: clocksConfig[0])
            recordUtil.setLastSelectClock(clock: 0)
        case 1:
            self.statusCountDownMinutes = clocksConfig[1]
            recordUtil.setLastFocusTime(time: clocksConfig[1])
            recordUtil.setLastSelectClock(clock: 1)
        case 2:
            self.statusCountDownMinutes = clocksConfig[2]
            recordUtil.setLastFocusTime(time: clocksConfig[2])
            recordUtil.setLastSelectClock(clock: 2)
        case 3:
            self.statusCountDownMinutes = clocksConfig[3]
            recordUtil.setLastFocusTime(time: clocksConfig[3])
            recordUtil.setLastSelectClock(clock: 3)
        case 5:
            self.statusCountDownMinutes = clocksConfig[4]
            recordUtil.setLastFocusTime(time: clocksConfig[4])
            recordUtil.setLastSelectClock(clock: 4)
        default:
            self.statusCountDownMinutes = 15
            recordUtil.setLastFocusTime(time: 15)
            recordUtil.setLastSelectClock(clock: 0)
        }
    }
    
    func sendStartMessage() {
        let count_down_dict = ["mode": statusCountDownMode, "time": statusCountDownMinutes] as [String : Any]
        debugPrint(">> sendCountDownStartMessage: \(count_down_dict)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countDownStart"), object: count_down_dict)
    }
    
    func sendStopMessage() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "countDownStop"), object: nil)
    }
    
    func recordAdd(time: Int) {
        
        
        
    }
    
    
    /// 达成特别成就时的演出效果
    func specialAnimationAdd() {
        
        outlineViewHeader.backgroundColor = .controlAccentColor
        scCountDown.cell?.isBordered = true
        scCountDown.segmentStyle = .capsule
        btnStart.contentTintColor = .labelColor
        vectoryEffect = ConfettiView(frame: self.view.bounds)
        vectoryEffect.intensity = 1.5
        self.view.addSubview(vectoryEffect)

        vectoryEffect.startConfetti()
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(stopConfetti), userInfo: nil, repeats: false)

    }
    
    @objc func stopConfetti() {
        self.vectoryEffect.stopConfetti()
    }
    
    @objc func onReceiveStopMessage(sender: Notification) {
        print("VCCountDown > Receive Stop Message")
        uiSwitchBtnStart(status: false)
        self.statusCountDownStarted = false
        
    }
    
    
    @IBAction func btnClickedStart(_ sedner: Any) {

        loadCurrentTimeSelection()
        
        if !statusCountDownStarted {
            print("VCCountDown > Start Count Down")
            sendStartMessage()
            statusCountDownStarted = true
        } else {
            print("VCCountDown > Stop Count Down")
            sendStopMessage()
            statusCountDownStarted = false
        }
        
        uiSwitchBtnStart(status: statusCountDownStarted)
    }
    
    @IBAction func btnClickedLinkForest(_ sender: AnyObject) {
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 2))
        self.menuControllerSync.contentMenu.popUp(positioning: nil, at: p, in: sender.superview)
        //self.menuLink.popUp(positioning: nil, at: p, in: sender.superview)
    }
    
    @IBAction func clickedSwitchMode(_ sender: Any) {

        if (self.scCountDown.indexOfSelectedItem == 0) {
            // Countdown
            self.popTimeSelect.isEnabled = true
        } else {
            self.popTimeSelect.isEnabled = false
        }
    }
    
    @IBAction func clickedSwitchTime(_ sender: Any) {
        
    }
    
    @IBAction func btnClickedConfig(_ sender: AnyObject) {
        let p = NSPoint(x: sender.frame.origin.x, y: sender.frame.origin.y - (sender.frame.height / 2))
        self.menuConfig.popUp(positioning: nil, at: p, in: sender.superview)
    }
    
    
    @IBAction func menuClickedEditCountDown(_ sender: Any) {
        // FIXME: 某些情况下 WDTimerConfig 打开后样式奇怪且不在最前面
        
        
        wnd.showWindow(nil);
        wnd.becomeFirstResponder()
    
        //wnd.window?.makeKey()
    }
    
    @IBAction func menuClickedDockStyle(_ sender: Any) {
        if menuPrefDockStyleBar.state == .on {
            menuPrefDockStyleBar.state = .off
            menuPrefDockStyleCircle.state = .on
            
            
        } else {
            menuPrefDockStyleBar.state = .on
            menuPrefDockStyleCircle.state = .off
        }
    }
    
    @IBAction func menuClickedQuitApp(_ sender: Any) {
        NSApp.terminate(self)
    }
    
    @IBAction func menuClickedLogin(_ sender: Any) {
        //let wnd_login = VCLinkForest(nibName: "VCLinkForest", bundle: Bundle.main)
        if (wndLinkForest != nil) {
            wndLinkForest = nil
        }
        
        wndLinkForest = WDLinkForest(windowNibName: "WDLinkForest")
        wndLinkForest!.showWindow(self);
        wndLinkForest!.becomeFirstResponder()
        
    }
}
/*
 
 
 self.backgroundImageView.layer = CALayer()
 self.backgroundImageView.wantsLayer = true
 
 var rect = CGRect(x: 0.0, y: 0.0, width: 10, height: 10.0) //发射位置
 rect.origin.x = self.backgroundImageView.frame.width / 2
 let emitter = CAEmitterLayer()
 emitter.frame = rect
 

 self.backgroundImageView.layer!.addSublayer(emitter)
 //view.layer?.addSublayer(emitter)  //添加到layer层

 emitter.emitterShape = CAEmitterLayerEmitterShape.rectangle

 emitter.emitterPosition = CGPoint(x: rect.width/2, y: rect.height/2) //发射器在xy平面的中心位置。
 emitter.emitterSize = rect.size //发射器尺寸

 let emitterCell = CAEmitterCell()
 emitterCell.contents =  NSImage(named: "clock.fill")?.cgImage // 花瓣图片
 emitterCell.birthRate = 3 // 每秒产生花瓣的数量
 emitterCell.lifetime = 10 // 花瓣的存活时间
 emitterCell.yAcceleration = 30.0 // y轴上的加速度
 emitterCell.xAcceleration = 5.0 //x轴上的加速度
 emitterCell.velocity = 15.0 //初始速度
 emitterCell.emissionLongitude = CGFloat(-Double.pi) //向左
 emitterCell.velocityRange = 200.0 //速度范围
 emitterCell.emissionRange = CGFloat(Double.pi/2)  //周围发射角度
 emitterCell.spin = 1 //粒子旋转速度
 emitterCell.alphaRange = 0.3  //粒子透明度能改变的范围
 emitter.emitterCells = [emitterCell]
 
 //let backgroundImgView = NSImageView()
     //backgroundImgView.image = UIImage(named: "img5.jpeg")
     //backgroundImgView.frame = self.view.frame
     //self.view.addSubview(backgroundImgView)

 
 
 
 */
