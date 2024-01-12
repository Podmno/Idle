//
//  LDNotification.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/9.
//

import Cocoa
import UserNotifications

class LDNotification : NSObject, UNUserNotificationCenterDelegate {
    
    
    public func sendTimeUpNotification(timerM: Int) {
        

        let title = NSLocalizedString("Timer Stopped", comment: "")
        let body = String.localizedStringWithFormat(NSLocalizedString("%lld minutes countdown is over.", comment: ""), timerM)

        sendGeneralNotification(title: title, message: body)
    }
    
    public func sendTimeNotRecordNotification() {
        let title = NSLocalizedString("The duration is not recorded", comment: "")
        let body = NSLocalizedString("Focus duration is less than 15 minutes and will not be recorded.", comment: "")

        sendGeneralNotification(title: title, message: body)
        
    }
    
    public func sendCountupTimeStopNotification(timerM: Int) {
        
        let title = NSLocalizedString("Timer Stopped", comment: "")
        let body = String.localizedStringWithFormat(NSLocalizedString("%lld minutes are included in the total focus time.", comment: ""), timerM)

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
                print("消息通知已设定: \(identifier)")
            }
        }
        
    }
    
    public func userAuthNotificationPermission() {
        
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
                return
            }
            
            print("授权成功")
            
            
        }
        
        
    }
    
    public func userAuthStatusCheck() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .authorized:
                print("已授权，用户允许通知")
                // do something
            case .notDetermined:
                //onNotDetermined?()
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) {
                        (accepted, error) in
                        if !accepted {
                            print("用户不允许消息通知。")
                            // do something
                        } else {
                            print("已授权，用户允许通知")
                            // do something
                        }
                }
            case .denied:
                print("用户不允许消息通知。")
                // do something

            case .provisional:
                return
            @unknown default:
                return
            }
        }
        
        
        
    }
}
