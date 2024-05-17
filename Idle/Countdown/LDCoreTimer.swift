//
//  LDTimer.swift
//  IdlePlugin
//
//  Created by Ki MNO on 2023/12/25.
//

import Cocoa

class LDCoreTimer : NSObject {
    
    weak var target: AnyObject!
    var timer: DispatchSourceTimer!

    
    // resume + 1, suspend - 1
    private var sourceCount: Int = 0
    
    // 对象销毁时
    deinit {
        guard timer != nil else {
            return
        }
        timer.cancel()
        if sourceCount <= 0 {
            self.startTimer()
        }
        timer = nil
    }
    
    
    init(target: AnyObject, timerAction: Selector) {

        super.init()
        // 计时器初始化
        self.target = target
        let queue = DispatchQueue.global()
        timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer.schedule(deadline: DispatchTime.now(), repeating: .seconds(1), leeway: .milliseconds(10))
        timer.setEventHandler { [weak self] in
            guard let storangSelf = self else { return }
            DispatchQueue.main.async {
                storangSelf.perform(timerAction)
            }
        }
        

    }
    
    public func startTimer() {
        guard sourceCount <= 0 else {
            return
        }
        
        timer.resume()
        sourceCount += 1
    }
    
    public func stopTimer() {
        guard sourceCount > 0 else {
            return
        }
        timer.suspend()
        sourceCount -= 1
    }
    
    public func destroyTimer() {
        timer.cancel()
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}
