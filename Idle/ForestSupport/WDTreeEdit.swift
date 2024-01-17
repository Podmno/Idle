//
//  WDTreeEdit.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/14.
//

import Cocoa
import SwiftyJSON
class WDTreeEdit: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var popTagEdit: NSPopUpButton!
    let storage = LFStorage()
    
    var tagIDArray: [Int] = []
    var tagTitleArray: [String] = []
    
    var lastSelectTagID = 0
    var lastInfoContent = ""
    
    var isOpened = false
    
    var handleSendBackTreeEdit: (Int, String) -> Void = {_,_ in
        print("nothing happend.")
    }
    
    @IBOutlet weak var tfContent: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        tfContent.formatter = CustomTextFieldFormatter(maxLength: 150, isUppercased: false)
        setupAllTags()
        isOpened = true
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    
    
    func windowWillClose(_ notification: Notification) {
        print("window will close!")
        isOpened = false
    }
    
    
    
    func setupAllTags() {
        
        self.tfContent.stringValue = lastInfoContent
        
        let tags_json_string = storage.dataGetTags()
        
        if (tags_json_string.isEmpty) {
            return
        }
        
        let tags_json = JSON(parseJSON: tags_json_string)
        
        print(tags_json)
        
        tagIDArray.append(0)
        tagTitleArray.append("未设置")
        let tags_json_arr = tags_json["tags"]
        
        for (_,tag_data_json) in tags_json_arr {
            
            if (tag_data_json["deleted"].boolValue == true) {
                continue
            }
            
            let tag_id = tag_data_json["tag_id"].intValue
            let tag_title = tag_data_json["title"].stringValue
            if tag_id == 0 {
                continue
            }
            
            tagIDArray.append(tag_id)
            tagTitleArray.append(tag_title)
            
        }
        
        print(tagIDArray)
        print(tagTitleArray)
        
        for i in 0...tagIDArray.count-1 {
            let menu = NSMenuItem(title: tagTitleArray[i], action: nil, keyEquivalent: "")
            popTagEdit.menu?.addItem(menu)
        }
        
        for i in 0...popTagEdit.numberOfItems {
            
            if lastSelectTagID == tagIDArray[i] {
                popTagEdit.selectItem(at: i)
                break
            }
            
        }
        
    }
    
    @IBAction func btnClickedFinish(_ sender: Any) {
        let tag_id_index = popTagEdit.indexOfSelectedItem
        let tag_id = tagIDArray[tag_id_index]
        let content = tfContent.stringValue
        handleSendBackTreeEdit(tag_id, content)
        self.close()
    }
    
    
}


class CustomTextFieldFormatter: Formatter {
    var maxLength: UInt
    var isUppercased: Bool
    
    init(maxLength: UInt, isUppercased: Bool) {
        self.maxLength = maxLength
        self.isUppercased = isUppercased
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func string(for obj: Any?) -> String? {
        return obj as? String
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = string as AnyObject
        return true
    }
    
    override func isPartialStringValid(_ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, proposedSelectedRange proposedSelRangePtr: NSRangePointer?, originalString origString: String, originalSelectedRange origSelRange: NSRange, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialStringPtr.pointee.length > maxLength {
            return false
        }
        
        
        if isUppercased && partialStringPtr.pointee != partialStringPtr.pointee.uppercased as NSString {
            partialStringPtr.pointee = partialStringPtr.pointee.uppercased as NSString
            return false
        }
        
        return true
    }
    
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        return nil
    }
}
