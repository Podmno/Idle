//
//  VCForest.swift
//  Idle
//
//  Created by Ki MNO on 2024/5/4.
//

import Cocoa

class VCForest: NSViewController {
    
    let fullGridWidth = 340.0
    let fullGridHeight = 340.0
    
    let cellWidth = 60.0
    let cellHeight = 30.0


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupForestGrid()
        
        addPlantCell()
    }
    
    func setupForestGrid() {

        // Line 1
        let centerX_real = fullGridWidth / 2 - cellWidth / 2
        let centerY_real = fullGridHeight / 2 - cellHeight / 2
        addForestCell(centerX: centerX_real, centerY: centerY_real, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real - cellWidth, centerY: centerY_real, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real - cellWidth * 2, centerY: centerY_real, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth, centerY: centerY_real, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth * 2, centerY: centerY_real, width: cellWidth, height: cellHeight, name: "ground-piece")
        
        // Line 2
        addForestCell(centerX: centerX_real - cellWidth / 2, centerY: centerY_real - cellHeight / 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real - cellWidth / 2 * 3 , centerY: centerY_real - cellHeight / 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth / 2, centerY: centerY_real - cellHeight / 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth / 2 * 3 , centerY: centerY_real - cellHeight / 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        
        addForestCell(centerX: centerX_real - cellWidth / 2, centerY: centerY_real + cellHeight / 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real - cellWidth / 2 * 3 , centerY: centerY_real + cellHeight / 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth / 2, centerY: centerY_real + cellHeight / 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth / 2 * 3 , centerY: centerY_real + cellHeight / 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        
        // Line 3
        addForestCell(centerX: centerX_real, centerY: centerY_real - cellHeight, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real - cellWidth, centerY: centerY_real - cellHeight, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth, centerY: centerY_real - cellHeight, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real, centerY: centerY_real + cellHeight, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real - cellWidth, centerY: centerY_real + cellHeight, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth, centerY: centerY_real + cellHeight, width: cellWidth, height: cellHeight, name: "ground-piece")
        
        // Line 4
        addForestCell(centerX: centerX_real - cellWidth / 2, centerY: centerY_real - cellHeight / 2 * 3, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth / 2, centerY: centerY_real - cellHeight / 2 * 3, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real - cellWidth / 2, centerY: centerY_real + cellHeight / 2 * 3, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real + cellWidth / 2, centerY: centerY_real + cellHeight / 2 * 3, width: cellWidth, height: cellHeight, name: "ground-piece")
        
        // Final Two Blocks
        addForestCell(centerX: centerX_real, centerY: centerY_real - cellHeight * 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        addForestCell(centerX: centerX_real, centerY: centerY_real + cellHeight * 2, width: cellWidth, height: cellHeight, name: "ground-piece")
        
        // Side Blocks
        addForestCell(centerX: centerX_real - cellWidth * 2, centerY: centerY_real - cellHeight, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-left")
        addForestCell(centerX: centerX_real - cellWidth * 1.5, centerY: centerY_real - cellHeight * 1.5, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-left")
        addForestCell(centerX: centerX_real - cellWidth * 1, centerY: centerY_real - cellHeight * 2.0, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-left")
        addForestCell(centerX: centerX_real - cellWidth * 0.5, centerY: centerY_real - cellHeight * 2.5, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-left")
        addForestCell(centerX: centerX_real, centerY: centerY_real - cellHeight * 3.0, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-left")
        addForestCell(centerX: centerX_real + cellWidth * 0.5, centerY: centerY_real - cellHeight * 3.0, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-right")
        addForestCell(centerX: centerX_real + cellWidth * 1.0, centerY: centerY_real - cellHeight * 2.5, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-right")
        addForestCell(centerX: centerX_real + cellWidth * 1.5, centerY: centerY_real - cellHeight * 2.0, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-right")
        addForestCell(centerX: centerX_real + cellWidth * 2.0, centerY: centerY_real - cellHeight * 1.5, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-right")
        addForestCell(centerX: centerX_real + cellWidth * 2.5, centerY: centerY_real - cellHeight * 1.0, width: cellWidth / 2, height: cellWidth * 1.5 / 2, name: "ground-right")
    }
    
    func addPlantCell() {
        let centerX_real = fullGridWidth / 2 - cellWidth / 2
        let centerY_real = fullGridHeight / 2 - cellHeight / 2
        // 5: 高度 FIX
        addForestCell(centerX: centerX_real, centerY: centerY_real - cellHeight * 1.5 - 5, width: cellWidth, height: cellWidth, name: "t4")
    }
    
    func addForestCell(centerX: Double, centerY: Double, width: Double, height: Double, name: String) {
        
        let image = NSImageView(image: NSImage(named: NSImage.Name(name))!)
        self.view.addSubview(image)
        image.frame = NSRect(x: CGFloat(centerX), y: CGFloat(centerY), width: CGFloat(width), height: CGFloat(height))
    }
    
    
}
