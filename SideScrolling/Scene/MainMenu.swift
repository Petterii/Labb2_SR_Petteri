//
//  MainMenu.swift
//  SideScrolling
//
//  Created by lösen är 0000 on 2018-04-17.
//  Copyright © 2018 PT. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene {
    
    override func didMove(to view: SKView) {
        initialize()
        
    }
    
    func initialize() {
     
        createBG()
    }
    
    func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG")
            bg.name = "BG"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 100 )
            bg.zPosition = -5
            
            self.addChild(bg)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "startGame" {
                let gameplay = GameScene(fileNamed: "GameScene")
                gameplay!.scaleMode = .aspectFill
                view?.presentScene(gameplay!)
            }
        }
    }
    
}
