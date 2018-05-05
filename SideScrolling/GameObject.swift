//
//  GameObject.swift
//  SideScrolling
//
//  Created by lösen är 0000 on 2018-04-24.
//  Copyright © 2018 PT. All rights reserved.
//

import SpriteKit

class GameObject {
    var sprite: SKSpriteNode
    var alive: Bool
    var playerLastPosY : CGFloat?
    var moveCenter : Bool
    
    init() {
        self.sprite = SKSpriteNode()
        self.alive = true
        self.moveCenter = true
    }
    
    init(sprite: SKSpriteNode) {
        self.sprite = sprite
        self.alive = true
        self.moveCenter = true
    }

    func movePlayer(frameWidth: CGFloat, _ dt: Float) {
        if moveCenter == true && self.sprite.position.x-40 < (-frameWidth/4) {
            self.sprite.position.x += (20 * CGFloat(dt))
        } else if moveCenter == true && self.sprite.position.x+40 > -(frameWidth/4) {
            self.sprite.position.x -= (40 * CGFloat(dt))
        }
    }
}
