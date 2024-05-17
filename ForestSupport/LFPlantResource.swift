//
//  LFPlantResource.swift
//  IdleExtra
//
//  Created by Ki MNO on 2024/3/8.
//

import Foundation

public struct LFPlantResourceInfo {
    var plantID: Int = 0
    
    var plantGradePicturePath: [Int: String] = [:]
    var plantGradePicturePathSpecial: [Int: String] = [:]
    
    var plantHasSpecialPicture: Bool = false
    

}

public class LFPlantResource : NSObject {
    
    let bundle = Bundle(for: LFPlantResource.self)
    
    var bundleResourceAvailable = false
    
    override init() {
        super.init()
        
        
    }
    
    
    public func getAllPlantsResource() -> [Int:LFPlantResourceInfo] {
        
        let load_path = Bundle.main.path(forResource: "PlantResource", ofType: "bundle")
        print("Plant Service > Load Default Bundle Path at \(String(describing: load_path))")
        
        let bundle = Bundle(path: load_path!)
        let plant_resource_dir = (bundle?.resourcePath ?? "") + "/plants"
        print("Plant Service > plant Folder supposed to locate at \(plant_resource_dir)")
        
        let plantsResourcePath = plant_resource_dir
        var plantsFolderArray: [Int:LFPlantResourceInfo] = [:]
        print("LFPlantResource > plantsResourcePath: \(plantsResourcePath)")
        let fileManager = FileManager.default
        do {
            
            let repo = try fileManager.contentsOfDirectory(atPath: plantsResourcePath)

            for item in repo {
                let result = generatePlantResourceStruct(folderPath: "\(plantsResourcePath)/\(item)", plantID: Int(item) ?? 0 )
                plantsFolderArray[Int(item) ?? 0] = result
                
            }

        } catch {
            print("file error.")
            
        }
        return plantsFolderArray
        
    }
    
    private func generatePlantResourceStruct(folderPath: String, plantID: Int) -> LFPlantResourceInfo {
        var reply = LFPlantResourceInfo()
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
            reply.plantID = plantID
            
            // 必须含有的内容：dead.png 和 4.png 否则返回空内容
            
            if (contents.contains("dead.png")) {
                reply.plantGradePicturePath[0] = "\(folderPath)/dead.png"
            } else {
                return LFPlantResourceInfo()
            }
            
            if (contents.contains("4.png")) {
                reply.plantGradePicturePath[4] = "\(folderPath)/4.png"
            } else {
                return LFPlantResourceInfo()
            }
            
            if (contents.contains("1.png")) {
                reply.plantGradePicturePath[1] = "\(folderPath)/1.png"
            } else {
                reply.plantGradePicturePath[1] = "\(folderPath)/4.png"
            }
            
            if (contents.contains("2.png")) {
                reply.plantGradePicturePath[2] = "\(folderPath)/2.png"
            } else {
                reply.plantGradePicturePath[2] = "\(folderPath)/4.png"
            }
            
            if (contents.contains("3.png")) {
                reply.plantGradePicturePath[3] = "\(folderPath)/3.png"
            } else {
                reply.plantGradePicturePath[3] = "\(folderPath)/4.png"
            }
            
            if (contents.contains("5.png")) {
                reply.plantGradePicturePath[5] = "\(folderPath)/5.png"
            } else {
                reply.plantGradePicturePath[5] = "\(folderPath)/4.png"
            }
            
            if (contents.contains("6.png")) {
                reply.plantGradePicturePath[6] = "\(folderPath)/6.png"
            } else {
                reply.plantGradePicturePath[6] = "\(folderPath)/4.png"
            }
            
            if (contents.contains("7.png")) {
                reply.plantGradePicturePath[7] = "\(folderPath)/7.png"
            } else {
                reply.plantGradePicturePath[7] = "\(folderPath)/4.png"
            }
            
            // 特别的 12 月限定皮肤
            if (contents.contains("Christmas")) {
                reply.plantHasSpecialPicture = true
                
                let sp_contents = try FileManager.default.contentsOfDirectory(atPath: "\(folderPath)/Christmas")
                
                for sp_item in sp_contents {
                    
                    if (sp_item.contains("4")) {
                        reply.plantGradePicturePathSpecial[4] = "\(folderPath)/Christmas/\(sp_item)"
                    }
                    
                    if (sp_item.contains("3")) {
                        // 特别定制：0 号树种的图片文件似乎对应有误，应该是 4 号图片名称命名为 3 了
                        reply.plantGradePicturePathSpecial[4] = "\(folderPath)/Christmas/\(sp_item)"
                    }
                    
                    if (sp_item.contains("5")) {
                        reply.plantGradePicturePathSpecial[5] = "\(folderPath)/Christmas/\(sp_item)"
                    }
                    
                    if (sp_item.contains("6")) {
                        reply.plantGradePicturePathSpecial[6] = "\(folderPath)/Christmas/\(sp_item)"
                    }
                    
                    if (sp_item.contains("7")) {
                        reply.plantGradePicturePathSpecial[7] = "\(folderPath)/Christmas/\(sp_item)"
                    }
                }
                
                reply.plantGradePicturePathSpecial[0] = reply.plantGradePicturePath[0]
                reply.plantGradePicturePathSpecial[1] = reply.plantGradePicturePath[1]
                reply.plantGradePicturePathSpecial[2] = reply.plantGradePicturePath[2]
                reply.plantGradePicturePathSpecial[3] = reply.plantGradePicturePath[3]
                
                if (!reply.plantGradePicturePathSpecial.keys.contains(4)) {
                    reply.plantGradePicturePathSpecial[4] = reply.plantGradePicturePath[4]
                }
                if (!reply.plantGradePicturePathSpecial.keys.contains(5)) {
                    reply.plantGradePicturePathSpecial[5] = reply.plantGradePicturePath[5]
                }
                if (!reply.plantGradePicturePathSpecial.keys.contains(6)) {
                    reply.plantGradePicturePathSpecial[6] = reply.plantGradePicturePath[6]
                }
                if (!reply.plantGradePicturePathSpecial.keys.contains(7)) {
                    reply.plantGradePicturePathSpecial[7] = reply.plantGradePicturePath[7]
                }
                
            }
            
        } catch {
            
        }
        return reply
    }
}
