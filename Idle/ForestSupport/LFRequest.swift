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
        
        forestHeaderGeneral = ["User-Agent": self.forestHeaderUserAgent, "Content-Type": "application/json"]
        
        if storage.getAccountChinaReigon() {
            self.forestAPIBaseURL = self.forestAPIChinaURL
            print("API > Already set China API Reigon.")
        }
        
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
        
        queue.async {
            AF.request(post_url, method: .post, parameters: login_text_json, encoder: JSONParameterEncoder.default, headers: self.forestHeaderGeneral).response { re in
                
                if re.error == nil {
                    
                    let json_result = JSON(re.data as Any)
                    debugPrint(re.response as Any)
                    
                    if (json_result.isEmpty != true) {
                        
                        let user_name = json_result["user_name"].stringValue
                        let user_id = json_result["user_id"].stringValue
                        let remember_token = json_result["remember_token"].stringValue
                        
                        self.storage.setUserInfo(user_name: user_name, user_id: user_id, token: remember_token)
                        
                        print("Network: Username \(user_name), UserID \(user_id), Token \(remember_token)")
                        
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
        print("getAccountInfo > \(target_url)")
        
        queue.async {
            
            AF.request(target_url, method: .get ,headers: self.forestHeaderGeneral).response { re in
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
        let boost_domain = forestAPIBaseURL + domainUser + "/" + user_id + "/" + domainBoost + "?seekrua=extension_chrome-6.1.0"
        
        queue.async {
            
            AF.request(boost_domain, method: .get, headers: self.forestHeaderGeneral).response { re in
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
        queue.async {
            
            AF.request(boost_domain, method: .get, headers: self.forestHeaderGeneral).response { re in
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
        queue.async {
            
            AF.request(boost_domain, method: .get, headers: self.forestHeaderGeneral).response { re in
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
        queue.async {
            
            AF.request(boost_domain, method: .get, headers: self.forestHeaderGeneral).response { re in
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
    
    public func updateTree() {
        
        
        
        
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
        
        queue.async {
            AF.request(remote_address, method: .delete, headers: self.forestHeaderGeneral).response { re in
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
            storage.dataStorageTags(data: Data())
            storage.dataStorageAccount(data: Data())
            storage.dataStorageUnlock(data: Data())
            storage.dataStorageAllTrees(data: Data())
            print("Successfully delete cookie.")
            return true
            
        } else {
            print("Signout Failed.")
            return false
        }
    }

}
