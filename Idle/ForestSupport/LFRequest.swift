//
//  LFRequest.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/12.
//

import Cocoa
import Alamofire
import SwiftyJSON

public class LFRequest : NSObject {
    
    public var forestAPIBaseURL = "https://c88fef96.forestapp.cc/api/v1"
    public var forestAPIChinaURL = "https://forest-china.upwardsware.com/api/v1"
    public var forestAPIGlobalURL = "https://c88fef96.forestapp.cc/api/v1"
    
    public let domainSignin = "/sessions"
    public let domainUser = "/users"
    public let domainSignout = "/sessions/signout"
    public let domainTags = "/tags"
    public let domainUnlocked = "/tree_types/unlocked"
    public let domainAllTrees = "/plants"
    public let domainBoost = "/boost"
    
    public let forestHeaderUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
    public var forestHeaderGeneral: HTTPHeaders!
    
    let storage = LFStorage()
    //public let forestURLParameters = ["seekrua": "extension_chrome-6.1.0"]
    
    public override init() {
        super.init()
        
        if storage.getAccountChinaReigon() {
            self.forestAPIBaseURL = self.forestAPIChinaURL
            print("API > Already set China API Reigon.")
        }
        
    }
    
    public func getForestHeader() -> Dictionary<String, String> {
        var header: Dictionary<String, String> = Dictionary()
        header["Accept"] = "application/json, text/plain, */*"
        header["Accept-Encoding"] = "gzip, deflate, br"
        header["Accept-Language"] = "zh-CN,zh;q=0.9,en;q=0.8"

        let cookie = storage.getUserToken()
        if (!cookie.isEmpty) {
            header["Cookie"] = "remember_token=\(cookie)"
        }
        
        let tag = storage.getEtag()
        if (!tag.isEmpty) {
            header["If-None-Match"] = tag
        }
        
        header["Sec-Ch-Ua"] = "\"Not_A Brand\";v=\"8\", \"Chromium\";v=\"120\", \"Google Chrome\";v=\"120\""
        header["Sec-Ch-Ua-Mobile"] = "?0"
        header["Sec-Ch-Ua-Platform"] = "\"macOS\""
        header["Sec-Fetch-Dest"] = "empty"
        header["Sec-Fetch-Mode"] = "cors"
        header["Sec-Fetch-Site"] = "none"
        header["User-Agent"] = self.forestHeaderUserAgent
        header["Content-Type"] = "application/json"
        return header
    }
    
    public func switchToChinaReigon(is_china_reigon: Bool) {
        if is_china_reigon {
            print("LFRequest Region -> China Mainland")
            storage.setAccountChinaReigon(is_china_reigon: true)
            self.forestAPIBaseURL = self.forestAPIChinaURL
            print("API > Already set China API Reigon.")
        } else {
            print("LFRequest Region -> Global")
            storage.setAccountChinaReigon(is_china_reigon: false)
            self.forestAPIBaseURL = self.forestAPIGlobalURL
            print("API > Already set Global API Reigon.")
            
        }
        
        
        
        
        
    }
    
    public func userLogin(username: String, password: String) -> Int {
        
        print("LFRequest Login with Username \(username), Password \(password).")
        var reply_code = -1
        
        let semaphore = DispatchSemaphore.init(value: 0)
        let queue = DispatchQueue.init(label: "studio.tri.idle.forest.userlogin")
        
        let login_text_json: JSON = [ "session": ["email": username, "password": password] ]
        let post_url = forestAPIBaseURL + domainSignin + "?seekrua=extension_chrome-6.1.0"
        
        let header = HTTPHeaders(getForestHeader())
        
        queue.async {
            
            AF.request(post_url, method: .post, parameters: login_text_json, encoder: JSONParameterEncoder.default, headers: header).response { re in
                
                if re.error == nil {
                    
                    let json_result = JSON(re.data as Any)
                    debugPrint(re.response as Any)
                    
                    if (json_result.isEmpty != true) {
                        
                        let user_name = json_result["user_name"].stringValue
                        let user_id = json_result["user_id"].stringValue
                        let remember_token = json_result["remember_token"].stringValue
                        
                        self.storage.setUserInfo(user_name: user_name, user_id: user_id, token: remember_token)
                        
                        print("Network: Username \(user_name), UserID \(user_id), Token \(remember_token)")
                        
                        let tag_data = re.response?.headers
                        let tag = tag_data!["etag"] ?? ""
                        
                        print("Network: ETAG \(tag)")
                        self.storage.setEtag(etag: tag)
                        
                        
                        reply_code = 0
                        print("Login Response > OK")
                    } else {

                        reply_code = -2
                        if (re.response?.statusCode == 403) {
                            reply_code = -403
                        }
                        
                        if (re.response?.statusCode == 400) {
                            reply_code = -400
                        }
                        
                        print("Login Response > EMPTY ???")
                    }
                } else {
                    
                    reply_code = -1
                    print("Login Response > FAILED")
                }
                
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return reply_code
    }
    
    public func getAccountInfo() -> JSON {
        var data_json = JSON()
        let user_id = storage.getUserInfoID()
        if(user_id == "") {
            print("getAccountInfo [WARNING] It seems that you have not log in yet!")
            return data_json
        }
        
        let semaphore = DispatchSemaphore.init(value: 0)
        let queue = DispatchQueue(label: "studio.tri.idle.forest.userAccountGet")
        
        let target_url = forestAPIBaseURL + domainUser + "/" + user_id + "?seekrua=extension_chrome-6.1.0"
        let header = HTTPHeaders(getForestHeader())
        
        print("getAccountInfo > \(target_url)")
        
        queue.async {
            
            AF.request(target_url, method: .get ,headers: header).response { re in
                if re.error == nil {
                    debugPrint(re.data as Any)
                    let json_data = JSON(re.data as Any)
                    
                    if(!json_data.isEmpty) {
                        debugPrint(json_data)
                        data_json = json_data
                    } else {
                        print("[!] ACCOUNT DATA FAILURE")
                    }
                    
                    
                } else {
                    debugPrint(re.error as Any)
                }
                
                semaphore.signal()
            }
            
        }
        
        semaphore.wait()
        
        return data_json
    }
    
    /// 不知道有啥用
    public func getBoost() -> JSON {
        var reply = JSON()
        let user_id = storage.getUserInfoID()
        if(user_id == "") {
            print("getBoost [WARNING] It seems that you have not log in yet!")
            return reply
        }

        let semaphore = DispatchSemaphore.init(value: 0)
        let queue = DispatchQueue(label: "studio.tri.idle.forest.getBoost")
        let boost_domain = forestAPIBaseURL + domainUser + "/" + user_id + domainBoost + "?seekrua=extension_chrome-6.1.0"
        let header = HTTPHeaders(getForestHeader())
        queue.async {
            
            AF.request(boost_domain, method: .get, headers: header).response { re in
                if (re.error == nil) {
                    debugPrint(re.data as Any)
                    reply = JSON(re.data as Any)
                } else {
                    debugPrint(re.error as Any)
                }
                
                semaphore.signal()
            }
            
        }
        
        semaphore.wait()
        return reply
    }
    
    public func getTags() -> JSON {
        
        var result_json = JSON()
        
        
        let semaphore = DispatchSemaphore.init(value: 0)
        let queue = DispatchQueue(label: "studio.tri.idle.forest.getTags")
        let boost_domain = forestAPIBaseURL + "/" + domainTags + "?seekrua=extension_chrome-6.1.0"
        print("getTags > \(boost_domain)")
        let header = HTTPHeaders(getForestHeader())
        queue.async {
            
            AF.request(boost_domain, method: .get, headers: header).response { re in
                if (re.error == nil) {
                    result_json = JSON(re.data as Any)
                } else {
                    debugPrint(re.error as Any)
                }
                
                semaphore.signal()
            }
            
        }
        
        semaphore.wait()
        return result_json
    }
    
    public func getUnlockedTrees() -> JSON {
        
        var result_json = JSON()
        
        
        let semaphore = DispatchSemaphore.init(value: 0)
        let queue = DispatchQueue(label: "studio.tri.idle.forest.getUnlockTrees")
        let boost_domain = forestAPIBaseURL + "/" + domainUnlocked + "?seekrua=extension_chrome-6.1.0"
        print("getUnlockedTrees > \(boost_domain)")
        let header = HTTPHeaders(getForestHeader())
        queue.async {
            
            AF.request(boost_domain, method: .get, headers: header).response { re in
                if (re.error == nil) {
                    result_json = JSON(re.data as Any)
                } else {
                    debugPrint(re.error as Any)
                }
                
                semaphore.signal()
            }
            
        }
        
        semaphore.wait()
        return result_json
    }
    
    public func getAllTrees() -> JSON {
        var result_json = JSON()
        
        
        let semaphore = DispatchSemaphore.init(value: 0)
        let queue = DispatchQueue(label: "studio.tri.idle.forest.getAllTrees")
        let boost_domain = forestAPIBaseURL + "/" + domainAllTrees + "?seekrua=extension_chrome-6.1.0"
        print("getAllTrees > \(boost_domain)")
        let header = HTTPHeaders(getForestHeader())
        queue.async {
            
            AF.request(boost_domain, method: .get, headers: header).response { re in
                if (re.error == nil) {
                    result_json = JSON(re.data as Any)
                } else {
                    debugPrint(re.error as Any)
                }
                
                semaphore.signal()
            }
            
        }
        
        semaphore.wait()
        return result_json
    }
    
    /// POST：更新植树信息
    public func updateTree(startTime: String, endTime: String, duration: Int, tree_type: Int, is_success: Bool, tag: Int, note_content: String) -> Int {
        
        if duration < 10 {
            print("POST WARNING: less than 10 minutes. Skip upload.")
            return -1
        }
        
        
        print("data note \(note_content)")
        
        let manager = LFManager()
        var postJson = JSON()

        postJson["end_time"].string = endTime
        postJson["is_success"].bool = is_success
        postJson["note"].string = note_content
        postJson["start_time"].string = startTime
        postJson["tag"].int = tag
        postJson["tree_type_gid"].int = tree_type
        postJson["updated_at"].string = manager.getUTCDate(date: Date())
        
        let trees_count = manager.getTreeCount(focusTime: duration)
        let trees_phase = manager.getTreePhaseArray(treeCount: trees_count, isDead: !is_success)
        var trees_json_struct: [JSON] = []
        
        if (trees_count <= 0)  {
            print(">> ERROR CATCH: tree_count < 0")
            return -1
        }
        
        for i in 0...trees_count-1 {
            var j = JSON()
            j["is_dead"].bool = !is_success
            j["phase"].int = trees_phase[i]
            j["tree_type"].int = tree_type
            trees_json_struct.append(j)
            
        }
        
        postJson["trees"].object = trees_json_struct
        
        print("postJson >>>> \(postJson)")
        
        var return_code = -1
        
        var resultJson = JSON()
        resultJson["plant"] = postJson
        
        //return 0
        
        self.storage.setLock(lock: true)
        let semaphore = DispatchSemaphore.init(value: 0)
        let queue = DispatchQueue(label: "studio.tri.idle.forest.postTree")
        let url_post = forestAPIBaseURL + "/" + domainAllTrees + "?seekrua=extension_chrome-6.1.0"
        print("<!> postTree > \(url_post)")
        let header = HTTPHeaders(getForestHeader())
        queue.async {
            
            AF.request(url_post, method: .post, parameters: resultJson, encoder: JSONParameterEncoder.default, headers: header).response { re in
                
                debugPrint("====== TREE =======")
                // response 处理
                debugPrint("data > ")
                debugPrint(re.data as Any)
                debugPrint("response > ")
                debugPrint(re.response as Any)
                debugPrint("error > ")
                debugPrint(re.error as Any)
                debugPrint("===================")
                
                if (re.error != nil) {
                    return_code = -1
                }
                
                if (re.response?.statusCode == 200) {
                    
                    // OK
                    return_code = 0
                } else {
                    return_code = -2
                }
                
                semaphore.signal()
            }
            
        }
        
        semaphore.wait()
        
        
        
        if (return_code == -1) {
            
            print("Sync failed. Storage temp.")
            
            // 同步失败，进行暂存
            storage.storageTempTreeRecord(startTime: startTime, endTime: endTime, duration: duration, tree_type: tree_type, is_success: is_success, tag: tag, note_content: note_content)
            self.storage.setLock(lock: false)
            return -1
        }
        
        if (return_code == -2) {
            
            self.storage.setLock(lock: false)
            return -2
        }
        
        // 与 Chrome 扩展执行一致动作
        let data_account_info = getAccountInfo()
        _ = getBoost()
        let data_tags = getTags()
        let data_unlocked_trees = getUnlockedTrees()
        
        self.storage.dataStorageTags(data: data_tags.rawString() ?? "")
        self.storage.dataStorageUnlock(data: data_unlocked_trees.rawString() ?? "")
        self.storage.dataStorageAccount(data: data_account_info.rawString() ?? "")
        self.storage.setLock(lock: false)
        return 0
        
        
    }
    
    public func userSignOut() -> Bool {
        
        let user_id = storage.getUserInfoID()
        
        if(user_id == "") {
            print("signOut [WARNING] It seems that you have not log in yet!")
            return false
        }
        
        let semaphore = DispatchSemaphore.init(value: 0)
        let queue = DispatchQueue.init(label: "studio.tri.idle.forest.usersignout")
        
        let remote_address = forestAPIBaseURL + domainSignout + "?seekrua=extension_chrome-6.1.0"
        
        var remote_result = false
        let header = HTTPHeaders(getForestHeader())
        queue.async {
            AF.request(remote_address, method: .delete, headers: header).response { re in
                if re.error == nil {
                    debugPrint(re.data as Any)
                    remote_result = true
                    semaphore.signal()
                } else {
                    debugPrint("Failed to delete cookie.")
                    remote_result = false
                    semaphore.signal()
                }
            }
                 
        }
        
        semaphore.wait()
        
        if (remote_result) {
            storage.setUserInfo(user_name: "", user_id: "", token: "")
            storage.dataStorageTags(data: "")
            storage.dataStorageAccount(data: "")
            storage.dataStorageUnlock(data: "")
            storage.dataStorageAllTrees(data: "")
            storage.setEtag(etag: "")
            storage.storageTempTreeRecord(startTime: "", endTime: "", duration: 0, tree_type: 0, is_success: false, tag: 0, note_content: "")
            print("Successfully delete cookie.")
            return true
            
        } else {
            print("Signout Failed.")
            return false
        }
    }

}
