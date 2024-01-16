//
//  LDNotification.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/9.
//

import Cocoa
import UserNotifications

class LDNotification : NSObject, UNUserNotificationCenterDelegate {
    
    let forest_helper = LFManager()
    
    
    public func sendTimeUpNotification(timerM: Int) {
        

        let title = "你的树长大了！"
        let coins = forest_helper.countForCoins(focusTime: timerM)
        let body = "你得到了 \(coins) 枚金币。"

        sendGeneralNotification(title: title, message: body)
    }
    
    public func sendTimeNotRecordNotification() {
        return
        let title = "时长未被记录"
        let body = "小于 10 分钟的专注时长不会被记录。"

        sendGeneralNotification(title: title, message: body)
        
    }
    
    public func sendCountupTimeStopNotification(timerM: Int) {
        
        let title = "你的树长大了！"
        let coins = forest_helper.countForCoins(focusTime: timerM)
        let body = "你得到了 \(coins) 枚金币。"

        sendGeneralNotification(title: title, message: body)
    }
    
    public func sendAwardsNotification(grade: Int) {
        if (grade == 0) {
            
        }
    }
    
    public func sendGeneralNotification(title: String, message: String) {
        let identifier = "NOTICE_IDLE_" + UUID().uuidString
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("[LDN] Notification Set ID:  \(identifier)")
            }
        }
        
    }
    
    public func userAuthNotificationPermission() {
        
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("[LDN] Error: ", error)
                return
            }
            
            print("[LDN] Permission status OK")
            
            
        }
        
        
    }
    
    public func userAuthStatusCheck() -> Bool {
        
        var status = false
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .authorized:
                print("[LDN] User Auth: OK")
                status = true
                // do something
            case .notDetermined:
                //onNotDetermined?()
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) {
                        (accepted, error) in
                        if !accepted {
                            print("[LDN] User Auth: NOT ALLOWED")
                            status = false
                            // do something
                        } else {
                            print("[LDN User Auth: OK]")
                            status = true
                            // do something
                        }
                }
            case .denied:
                print("[LDN] User Auth: NOT ALLOWED")
                // do something
                status = false
            case .provisional:
                status = false
                return
            @unknown default:
                status = false
                return
            }
            
            
        }
        return status
        
        
    }
}
