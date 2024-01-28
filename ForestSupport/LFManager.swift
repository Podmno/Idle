//
//  LFManager.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/12.
//

import Cocoa

public class LFManager : NSObject {
    
    public var treeTypePictureName = [0 : "t"]
    
    public func countForCoins(focusTime: Int) -> Int {
        
        let mult = focusTime / 5
        let adjust_time = 5 * mult
        
        if adjust_time <= 0 {
            return 0
        }
        
        if ( (adjust_time >= 10) && (adjust_time <= 20)  ) {
            
        }
        
        var alt = (adjust_time - 30) / 30
        if alt < 1 {
            alt = 0
        }
        
        let coins = 4 + adjust_time/5 + alt * 5
        return coins
    }
    
    public func getTreePhaseGrade(currentMinuts: Int) -> Int {
        
        if (currentMinuts < 0 ) {
            return 0
        }
        
        if (currentMinuts < 5) {
            return 1
        }
        
        if (currentMinuts < 8) {
            return 2
        }
        
        if (currentMinuts < 10) {
            return 3
        }
        
        if (currentMinuts < 60) {
            return 4
        }
        
        if (currentMinuts < 90) {
            return 5
        }
        
        if (currentMinuts < 120) {
            return 6
        }
        return 7
        
    }
    
    public func getTreeCount(focusTime: Int) -> Int {
        if (focusTime < 10) {
            return 0
        }
        
        if (focusTime < 60) {
            return 1
        }
        if (focusTime < 90) {
            return 2
        }
        if (focusTime < 120) {
            return 3
        }
        return 4
        
    }
    
    public func getTreePhaseArray(treeCount: Int,isDead: Bool) -> [Int] {
        if (treeCount == 0) {
            return []
        }
        
        if (treeCount == 1) {
            if (isDead) {
                return [8]
            } else {
                return [4]
            }
            
        }
        
        if (treeCount == 2) {
            if (isDead) {
                return [8,8]
            } else {
                return [4,5]
            }
            
        }
        
        if (treeCount == 3) {
            if (isDead) {
                return [8,8,8]
            } else {
                return [4,5,6]
            }
            
        }
        
        if (treeCount == 4) {
            if (isDead) {
                return [8,8,8,8]
            } else {
                return [4,5,6,7]
            }
            
        }
        
        return []
    }
    
    public func getTreeGradePicture(currentM: Int, setM: Int) -> Int {
        
        if setM == -1 {
            // 正计时图片策略
            return getTreePhaseGrade(currentMinuts: currentM)
        }
        
        let remainM = setM - currentM
        
        if setM < 60 {
            // 最终图片为 4
            let gap = setM / 3
            if remainM < gap {
                return 1
            }
            if remainM < 2*gap {
                return 2
            }
            if remainM < 3*gap {
                return 3
            }

            return 3
        }
        
        if setM < 90 {
            // 最终图片为 5
            let gap = setM / 4
            if remainM < gap {
                return 1
            }
            if remainM < 2*gap {
                return 2
            }
            if remainM < 3*gap {
                return 3
            }
            if remainM < 4*gap {
                return 4
            }

            return 4
            
        }
        
        if setM < 120 {
            // 最终图片为 6
            let gap = setM / 5
            if remainM < gap {
                return 1
            }
            if remainM < 2*gap {
                return 2
            }
            if remainM < 3*gap {
                return 3
            }
            if remainM < 4*gap {
                return 4
            }
            if remainM < 5*gap {
                return 5
            }

            return 5
            
        }
        
        if setM == 120 {
            // 最终图片为 7
            let gap = setM / 6
            if remainM < gap {
                return 1
            }
            if remainM < 2*gap {
                return 2
            }
            if remainM < 3*gap {
                return 3
            }
            if remainM < 4*gap {
                return 4
            }
            if remainM < 5*gap {
                return 5
            }
            if remainM < 6*gap {
                return 6
            }

            return 6
            
        }
        
        return 0
    }
    
    public func convertLocalDate(from UTCDate: String) -> String {
            
        let dateFormatter = DateFormatter.init()

        // UTC 时间格式
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let utcTimeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = utcTimeZone

        guard let dateFormatted = dateFormatter.date(from: UTCDate) else {
            return ""
        }

        // 输出格式
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy:MM:dd'T'HH:mm:ss.SSS'Z'"
        let dateString = dateFormatter.string(from: dateFormatted)

        return dateString
    }
    
    public func getUTCDate(date: Date) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let utcTimeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = utcTimeZone
        return dateFormatter.string(from: date)
        
    }

    /// 调整正计时专注时间至整数
    public func countUpFocusTimeAdjust(focusTime: Int) -> Int {
        if (focusTime < 10) {
            return 0
        }
        
        let mult = focusTime / 5
        let adjust_time = 5 * mult
        return adjust_time
    }
    
    
}
