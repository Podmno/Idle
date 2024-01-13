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
    
    public let domainSignin = "/sessions"
    public let domainUser = "/users"
    public let domainSignout = "/sessions/signout"
    public let domainTags = "/tags"
    public let domainUnlocked = "/tree_types/unlocked"
    public let domainAllTrees = "/plants"
    
    public let forestHeaderUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
    public var forestHeaderGeneral: HTTPHeaders!
    
    let storage = LFStorage()
    //public let forestURLParameters = ["seekrua": "extension_chrome-6.1.0"]
    
    public override init() {
        super.init()
        
        forestHeaderGeneral = ["User-Agent": self.forestHeaderUserAgent, "Content-Type": "application/json"]
        
    }
    
    public func switchToChinaReigon() {
        print("LFRequest Region -> China Mainland")
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
    
    public func getAccountInfo() {
        
        
    }
    
    public func signOut() -> Bool {
        
        let user_id = storage.getUserInfoID()
        
        if(user_id == "") {
            print("[WARNING] It seems that you have not log in yet!")
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
            print("Successfully delete cookie.")
            return true
            
        } else {
            print("Signout Failed.")
            return false
        }
        
        
        
    }
    
    
    
}
