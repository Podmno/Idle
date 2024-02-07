//
//  LFPlant.swift
//  Idle
//
//  Created by Ki MNO on 2024/1/31.
//

import Cocoa
import SwiftyJSON

/// 对应的树种对象
public class LFPlant: NSObject {
    
    /// 树种的上传 ID
    public var plantID: UInt = 0
    
    /// 树种的图片目录
    public var plantImageBaseFolderPath: String = ""
    
    
    
}

/// Forest 核心 Plant 资源管理
public class LFPlantManager: NSObject {
    
    // MARK: - 初始化
    
    /// 默认策略加载名为 PlantResource 的 Bundle
    public override init() {
        super.init()
        
        let load_path = Bundle.main.path(forResource: "PlantResource", ofType: "bundle")
        print("Plant Service > Load Default Bundle Path at \(String(describing: load_path))")
        
        let bundle = Bundle(path: load_path!)
        let plant_resource_dir = (bundle?.resourcePath ?? "") + "/plants"
        print("Plant Service > plant Folder supposed to locate at \(plant_resource_dir)")
        loadTreeList(plantDirPath: plant_resource_dir)
    }
    
    /// 载入 plantResourcePath
    public init(plantResourcePath: String) {
        super.init()
    }
    
    // MARK: - 外部 API
    
    /// 载入用户的可用树列表
    public func setupUserCurrentUnlockTree(unlockedTreeJSON: JSON) {
        
    }
    
    
    // MARK: - 内部工具
    
    /// 从 plant 文件夹加载导入树种文件
    private func loadTreeList(plantDirPath: String) {
        let manager = FileManager.default
        
    }

}
