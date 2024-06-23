//
//  LFStorage.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/13.
//

import Cocoa
import SwiftyJSON
import Alamofire

public class LFStorage : NSObject {
    
    let defaults = UserDefaults.standard
    
    public override init() {
        super.init()
        
        print("IDLE_FOREST_IS_COUNTUP \(getLastUserTimerOptionCountup())")
        print("IDLE_FOREST_COUNT_TIME \(getLastUserTimeOptionTime())")
        
        if (getLastUserTimerOptionCountup() == false && getLastUserTimeOptionTime() == 0) {
            // 第一次打开
            setLastUserTimerOption(is_count_up: false, count_time: 10)
        }
    }
    
    public func setLastUserTimerOption(is_count_up: Bool, count_time: Int) {
        defaults.set(is_count_up, forKey: "IDLE_FOREST_IS_COUNTUP")
        defaults.set(count_time, forKey: "IDLE_FOREST_COUNT_TIME")
    }
    
    public func getLastUserTimerOptionCountup() -> Bool {
        return defaults.bool(forKey: "IDLE_FOREST_IS_COUNTUP")
    }
    
    public func getLastUserTimeOptionTime() -> Int {
        return defaults.integer(forKey: "IDLE_FOREST_COUNT_TIME")
    }
    
    public func setUserInfo(user_name: String, user_id: String, token: String) {
        
        
        defaults.set(user_name, forKey: "IDLE_FOREST_USERNAME")
        defaults.set(user_id, forKey: "IDLE_FOREST_ID")
        defaults.set(token, forKey: "IDLE_FOREST_TOKEN")
        
        updateLastUpdateTime()
        
    }
    
    public func getUserInfoUserName() -> String {
        return defaults.string(forKey: "IDLE_FOREST_USERNAME") ?? ""
    }
    
    public func getUserInfoID() -> String {
        return defaults.string(forKey: "IDLE_FOREST_ID") ?? ""
    }
    
    public func getUserToken() -> String {
        return defaults.string(forKey: "IDLE_FOREST_TOKEN") ?? ""
    }
    
    public func updateLastUpdateTime() {
        
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        defaults.set(Int(timeInterval), forKey: "IDLE_FOREST_LAST_UPDATE")
    }
    
    public func getLastUpdateTime() -> Date {
        
        let last_record_date = defaults.integer(forKey: "IDLE_FOREST_LAST_UPDATE")
        let last_time_date = Date(timeIntervalSince1970: TimeInterval(last_record_date))
        return last_time_date
    }
    
    public func setAccountChinaReigon(is_china_reigon: Bool) {
        
        defaults.set(is_china_reigon, forKey: "IDLE_FOREST_CHINA_ACCOUNT")
    }
    
    public func getAccountChinaReigon() -> Bool {
        self.updateLastUpdateTime()
        return defaults.bool(forKey: "IDLE_FOREST_CHINA_ACCOUNT")
    }
    
    public func dataStorageTags(data: String) {
        self.updateLastUpdateTime()
        defaults.set(data, forKey: "IDLE_FOREST_DATA_TAGS")
    }
    
    public func dataStorageAccount(data: String) {
        self.updateLastUpdateTime()
        defaults.set(data, forKey: "IDLE_FOREST_DATA_ACCOUNT")
    }
    
    public func dataStorageUnlock(data: String) {
        self.updateLastUpdateTime()
        defaults.set(data, forKey: "IDLE_FOREST_DATA_UNLOCK")
    }
    
    public func dataStorageAllTrees(data: String) {
        self.updateLastUpdateTime()
        defaults.set(data, forKey: "IDLE_FOREST_DATA_ALL")
    }
    
    public func dataGetTags() -> String {
        return defaults.string(forKey: "IDLE_FOREST_DATA_TAGS") ?? ""
    }
    
    public func dataGetAccount() -> String {
        return defaults.string(forKey: "IDLE_FOREST_DATA_ACCOUNT") ?? ""
    }
    
    public func dataGetUnlock() -> String {
        return defaults.string(forKey: "IDLE_FOREST_DATA_UNLOCK") ?? ""
    }
    
    public func dataGetAllTrees() -> String {
        return defaults.string(forKey: "IDLE_FOREST_DATA_ALL") ?? ""
    }
    
    public func setLock(lock: Bool) {
        defaults.set(lock, forKey: "IDLE_FOREST_LOCK")
    }
    
    public func getLock() -> Bool {
        return defaults.bool(forKey: "IDLE_FOREST_LOCK")
    }
    
    public func setEtag(etag: String) {
        defaults.set(etag, forKey: "IDLE_FOREST_ETAG")
        
    }
    
    public func getEtag() -> String {
        return defaults.string(forKey: "IDLE_FOREST_ETAG") ?? ""
    }
    
    public func storageTempTreeRecord(startTime: String, endTime: String, duration: Int, tree_type: Int, is_success: Bool, tag: Int, note_content: String) {
        
        defaults.set(startTime, forKey: "IDLE_FOREST_TMP_STARTTIME")
        defaults.set(endTime, forKey: "IDLE_FOREST_TMP_ENDTIME")
        defaults.set(duration, forKey: "IDLE_FOREST_TMP_DURATION")
        defaults.set(tree_type, forKey: "IDLE_FOREST_TMP_TREETYPE")
        defaults.set(is_success, forKey: "IDLE_FOREST_TMP_ISSUCCESS")
        defaults.set(tag, forKey: "IDLE_FOREST_TMP_TAG")
        defaults.set(note_content, forKey: "IDLE_FOREST_TMP_NOTE")
        
    }
    
    public func getTempTreeRecordStartTime() -> String {
        return defaults.string(forKey: "IDLE_FOREST_TMP_STARTTIME") ?? ""
    }
    
    public func getTempTreeRecordEndTime() -> String {
        return defaults.string(forKey: "IDLE_FOREST_TMP_ENDTIME") ?? ""
    }
    
    public func getTempTreeRecordDuration () -> Int {
        return defaults.integer(forKey: "IDLE_FOREST_TMP_DURATION")
    }
    
    public func getTempTreeRecordTreeType() -> Int {
        return defaults.integer(forKey: "IDLE_FOREST_TMP_TREETYPE")
    }
    
    public func getTempTreeRecordIsSuccess() -> Bool {
        return defaults.bool(forKey: "IDLE_FOREST_TMP_ISSUCCESS")
    }
    
    public func getTempTreeRecordTag() -> Int {
        return defaults.integer(forKey: "IDLE_FOREST_TMP_TAG")
    }
    
    public func getTempTreeRecordNoteContent() -> String {
        return defaults.string(forKey: "IDLE_FOREST_TMP_NOTE") ?? ""
    }
    
    public func addStorageTree(tree: LFTree) {
    
    }
    
    public func createStorageTreeFile() {
        
    }
    
    public func getStorageTreeCount() {
        
    }
    
    public func getStorageTreeInfo() {
        
    }
    
    public func toggleStorageTreeUpload() {
        
    }
    
}

/*
 Deprecated Version of JSON File Struct
 let filePath = NSHomeDirectory() + "/Documents/tree_upload.json"
 print("Create at: \(filePath)")
 var empty_json_obj = JSON()
 empty_json_obj["version"].int = 1
 print(empty_json_obj["version"])
 empty_json_obj["array"] = []
 let empty_file = empty_json_obj.rawString() ?? ""
 print("File: \(empty_file)")
 do {
     try empty_file.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
 } catch {
     print("Error Saving. Exit.")
     return
 }
 
print("Add Storage Tree \(tree.hash) to storage.")

let mgr = FileManager.default
let filePath = NSHomeDirectory() + "/Documents/tree_upload.json"
print("Temp Storage Tree File: \(filePath)")

createStorageTreeFile()

if !mgr.fileExists(atPath: filePath) {
    print("Temp File does note exist.")
    
}


// file Exists

do {
    createStorageTreeFile()
    let str_content = try String(contentsOfFile: filePath)
    var original_content_json = JSON(str_content)
    
    print("arrayValue:")
    var ar = original_content_json["array"].arrayValue
    //ar.append(tree.toJson().stringValue)
    original_content_json["array"] = JSON(ar)
    
    //original_content_json["array"] = JSON(data)

    
    print("Append JSON: \(original_content_json)")
    try original_content_json.rawString()?.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
} catch {
    print("Error Saving. Exit.")
}

*/
