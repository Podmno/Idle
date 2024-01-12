//
//  LDRecord.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/9.
//

import Cocoa

class LDRecord : NSObject {
    
    let defaults = UserDefaults.standard
    
    override init() {
        super.init()
        
        
        // User Default Init
        
        let init_status = defaults.bool(forKey: "IDLE_INIT_STATUS")
        print("Record > IDLE_INIT_STATUS: \(init_status)")
        
        // IDLE_INIT_STATUS 为 false：初次使用，进行初始化
        
        if (!init_status) {
            // init user defaults
            
            defaults.set(true, forKey: "IDLE_INIT_STATUS")
            
            defaults.set(0, forKey: "IDLE_TOTAL_MINUTES")
            defaults.set(0, forKey: "IDLE_DAY_MINUTES")
            defaults.set(0, forKey: "IDLE_WEEK_MINUTES")
            defaults.set(15, forKey: "IDLE_LAST_FOCUS_TIME")
            
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            defaults.set(Int(timeInterval), forKey: "IDLE_LAST_OPEN")
            let clocks = [15, 30, 45, 60, 120]
            defaults.set(clocks, forKey: "IDLE_CLOCKS")
            defaults.set(0, forKey: "IDLE_LAST_SELECT_CLOCK")
        } else {
            
            
            // 并不是第一次打开了
            
            let last_record_date = defaults.integer(forKey: "IDLE_LAST_OPEN")
            let last_time_interval = TimeInterval(last_record_date)
            let last_time_date = Date(timeIntervalSince1970: last_time_interval)
            
            if (Calendar.current.isDateInThisWeek(last_time_date)) {
                print("Record > is this week, skip clear week data")
                
            } else {
                print("Record > not this week. clear week data")
                defaults.set(0, forKey: "IDLE_WEEK_MINUTES")
            }
            
            if (Calendar.current.isDateInToday(last_time_date)) {
                print("Record > is this day, skip clear day data")
            } else {
                print("Record > not this day. clear day data")
                defaults.set(0, forKey: "IDLE_DAY_MINUTES")
            }
            
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            defaults.set(Int(timeInterval), forKey: "IDLE_LAST_OPEN")
        }
        

        
    }
    
    func restoreDefaults() {
        defaults.set(false, forKey: "IDLE_INIT_STATUS")
    }
    
    func addTimeData(timerM: Int) {
       
        var timesave_total = defaults.integer(forKey: "IDLE_TOTAL_MINUTES")
        var timesave_week = defaults.integer(forKey: "IDLE_WEEK_MINUTES")
        var timesave_day = defaults.integer(forKey: "IDLE_DAY_MINUTES")
        
        timesave_day += timerM
        timesave_week += timerM
        timesave_total += timerM
        
        
        if (timesave_total > 5999940 ) {
            // 最大存储: 99999 Hours
            defaults.set(5999940, forKey: "IDLE_TOTAL_MINUTES")
            
        } else {
            defaults.set(timesave_total, forKey: "IDLE_TOTAL_MINUTES")
        }
        
        defaults.set(timesave_week, forKey: "IDLE_WEEK_MINUTES")
        defaults.set(timesave_day, forKey: "IDLE_DAY_MINUTES")
    }
    
    func getTotalMinutes() -> Int {
        return defaults.integer(forKey: "IDLE_TOTAL_MINUTES")
    }
    
    func getWeekMinutes() -> Int {
        return defaults.integer(forKey: "IDLE_WEEK_MINUTES")
    }
    
    func getDayMinutes() -> Int {
        return defaults.integer(forKey: "IDLE_DAY_MINUTES")
    }
    
    func setLastFocusTime(time: Int) {
        defaults.set(time, forKey: "IDLE_LAST_FOCUS_TIME")
        
    }
    
    func getLastFocusTime() -> Int {
        return defaults.integer(forKey: "IDLE_LAST_FOCUS_TIME")
    }
    
    func setClocks(clocks: [Int]) {
        defaults.set(clocks, forKey: "IDLE_CLOCKS")
    }
    
    func getClocks() -> [Int] {
        return (defaults.array(forKey: "IDLE_CLOCKS") ?? [15,30,45,60,120]) as! [Int]
    }
    
    func setLastSelectClock(clock: Int) {
        defaults.set(clock, forKey: "IDLE_LAST_SELECT_CLOCK")
    }
    
    func getLastSelectClock() -> Int {
        return defaults.integer(forKey: "IDLE_LAST_SELECT_CLOCK")
    }
    
    
    
}

extension Calendar {
  private var currentDate: Date { return Date() }

  func isDateInThisWeek(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
  }

  func isDateInThisMonth(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .month)
  }

  func isDateInNextWeek(_ date: Date) -> Bool {
    guard let nextWeek = self.date(byAdding: DateComponents(weekOfYear: 1), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear)
  }

  func isDateInNextMonth(_ date: Date) -> Bool {
    guard let nextMonth = self.date(byAdding: DateComponents(month: 1), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: nextMonth, toGranularity: .month)
  }

  func isDateInFollowingMonth(_ date: Date) -> Bool {
    guard let followingMonth = self.date(byAdding: DateComponents(month: 2), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: followingMonth, toGranularity: .month)
  }
}
