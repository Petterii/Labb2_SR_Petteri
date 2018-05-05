//
//  GameScene.swift
//  SideScrolling
//
//  Created by lösen är 0000 on 2018-04-15.
//  Copyright © 2018 PT. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

struct ColliderType {
    static let Obstacle: UInt32 = 0x1 << 1
    static let Player: UInt32 =  0x1 << 2
    static let Ground: UInt32 =  0x1 << 0
    static let Enemy: UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var game: SKAction?
    var lastTime: Float?
    
    var highScores: Int?
    
    
    // Partical variables
    var trailE: SKEmitterNode? = SKEmitterNode()
    var smoke: SKEmitterNode? = SKEmitterNode()
    var hit: SKEmitterNode? = SKEmitterNode()
    
    // need to over what I dont need!!!!! TODO!!!
    var lives: Int = 3
    var isDeadScreen = false
    var gameSpeed : CGFloat = 2
    var yourScore: Int = 0
    var distScore: CGFloat = 0
    var groundLastPos: CGFloat = 0
    
    // GameObjects
    var player : GameObject = GameObject()
    var obsticles : [GameObject] = [GameObject]()
    var ground : SKSpriteNode!
    
    var canJump = false
    var doubleJump = false
    
    // SoundStuff
    let jumpSound = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    let landSound = SKAction.playSoundFileNamed("landing.wav", waitForCompletion: false)
    let birdhitSound = SKAction.playSoundFileNamed("birdhit.wav", waitForCompletion: false)
    let explotionSound = SKAction.playSoundFileNamed("explode.wav", waitForCompletion: false)
    let spikeSound = SKAction.playSoundFileNamed("spikes.wav", waitForCompletion: false)
    
    var audioPlayer = AVAudioPlayer()
    
    
    override func didMove(to view: SKView) {
        initialize()
        
    }
    
    func initialize() {
        physicsWorld.contactDelegate = self
        
        let backgroundSound = SKAudioNode(fileNamed: "background.mp3")
        backgroundSound.run(SKAction.changeVolume(by: -0.9, duration: 0))
        addChild(backgroundSound)
        
        createPlayer()
        createBG()
        createGround()
        CreateReplayButton()
        currentScore()
        getHighScore()
        createObsticles()
        createBird()
        increaseScore()
        createLives()
   
    }

    
    func createLives() {
        for i in 1...3 {
            let life = SKSpriteNode(imageNamed: "heart")
            life.name = "life\(i)"
            life.setScale(0.5)
            life.anchorPoint = CGPoint(x: 0.5 , y: 0.5)
            
            life.position = CGPoint(x: -50 + (CGFloat(i) * life.size.width), y: (frame.size.height/2) - (life.size.width/2))
            
            life.zPosition = 5
            self.addChild(life)
            
        }
    }
    
    func getHighScore() {
        highScores =  UserDefaults.standard.integer(forKey: "HighScore")
        
    }
    
    func saveHighScore() {
        UserDefaults.standard.set(highScores, forKey:"HighScore")
    }
    
    func increaseScore() {
        
        let score = SKAction.run {
            self.yourScore += 1
            self.updateScore()
        }
        let cooldown = SKAction.wait(forDuration: 3)
        game = SKAction.repeatForever(SKAction.sequence([score, cooldown]))
        run(game!, withKey: "CurrentScore")
    }
    
    
    func CreateReplayButton() {
        let replay = SKSpriteNode(imageNamed: "replay")
        replay.name = "replay"
        replay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        replay.setScale(0.5)
        replay.position = CGPoint(x: (self.frame.size.width / 2) - (replay.size.width / 2), y: (self.frame.size.height / 2) - (replay.size.width / 2))
        
        replay.zPosition = 5
        
        self.addChild(replay)
    }
    func createBird() {
        let obsticle = SKAction.run {
            let obsticle = SKSpriteNode(imageNamed: "bird")
            obsticle.setScale(0.1)
            obsticle.name = "Bird"
            
            let size = CGSize(width: (obsticle.size.width/2), height: (obsticle.size.height/2))
            obsticle.position = CGPoint(x: (self.frame.size.width / 2) + 20  , y: 0)
        
            obsticle.physicsBody = SKPhysicsBody(rectangleOf: size)
            obsticle.physicsBody?.affectedByGravity = false
            obsticle.physicsBody?.isDynamic = false
            obsticle.physicsBody?.categoryBitMask = ColliderType.Enemy
            
            obsticle.xScale = -0.1 // verticle mirror
            obsticle.zPosition = 3
          
            self.addChild(obsticle)
            
            let obj = GameObject(sprite: obsticle)
            self.obsticles.append(obj)
            
        }
        let cooldown = SKAction.wait(forDuration: 4, withRange: 2)
        game = SKAction.repeatForever(SKAction.sequence([obsticle, cooldown]))
        run(game!, withKey: "birdSpawn")
    }
    
    func createObsticles() {
        let obsticle = SKAction.run {
            let obsticle : SKSpriteNode
            let randNr = arc4random_uniform(2)
            let obsticleType : String
            let obsName : String
            
            if self.yourScore > 5 {
                switch randNr{
                case 1 : obsticleType = "characters_000\(arc4random_uniform(6)+1)"
                        obsName = "Obsticle"
                default: obsticleType = "spikes"
                        obsName = "Spikes"
                }
            } else {
                obsticleType = "characters_000\(arc4random_uniform(6)+1)"
                obsName = "Obsticle"
            }
            
            
            obsticle = SKSpriteNode(imageNamed: obsticleType)
            obsticle.setScale(0.3)
            obsticle.name = obsName
            obsticle.position = CGPoint(x: (self.frame.size.width / 2) + 20  , y: self.ground.position.y + (self.ground.size.height/2) + (obsticle.size.height/2) - 10)
            
            obsticle.physicsBody = SKPhysicsBody(rectangleOf: obsticle.size)
            obsticle.physicsBody?.affectedByGravity = true
            obsticle.physicsBody?.isDynamic = false
            obsticle.physicsBody?.categoryBitMask = ColliderType.Obstacle
         
            obsticle.zPosition = 3
            self.addChild(obsticle)
            let obj = GameObject(sprite: obsticle)
            self.obsticles.append(obj)
        }
        let cooldown = SKAction.wait(forDuration: 3, withRange: 1)
        run(SKAction.repeatForever(SKAction.sequence([obsticle, cooldown])), withKey: "obsticleSpawn")
    }
    
    func createObject(imageName: String, spriteLabel: String, position: CGPoint) -> SKSpriteNode {
        let object = SKSpriteNode(imageNamed: "\(imageName)")
        object.name = spriteLabel
        object.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        object.position = position
        object.zPosition = 10
        return object
    }
    
    func PlayerJump(Obj: SKSpriteNode) {
        Obj.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        Obj.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 30))
    }
    
    func playerHurtJump(Obj: SKSpriteNode) {
        Obj.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        Obj.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 10))
    }
    
    func collision(image: SKSpriteNode) -> SKSpriteNode {
        
        
        return image
    }
    
    func createPlayer() {
        let image = createObject(imageName: "player", spriteLabel: "Player", position: CGPoint(x: 0, y: 0 ))
        image.setScale(0.5)
        image.physicsBody = SKPhysicsBody(rectangleOf: image.size)
        image.physicsBody?.affectedByGravity = true
        image.physicsBody?.allowsRotation = false
        image.physicsBody?.categoryBitMask = ColliderType.Player
        image.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Obstacle
        image.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.Obstacle | ColliderType.Enemy
        
        player = GameObject(sprite: image)
        self.addChild(player.sprite)
        
        trailE = SKEmitterNode(fileNamed: "MyParticle")!
        trailE?.position = player.sprite.position
        trailE?.zPosition = -1
        
        self.player.sprite.addChild(trailE!)
    }
    
    func createSmoke() {
        smoke = SKEmitterNode(fileNamed: "smoke")!
        smoke?.name = "smoke"
        smoke?.zPosition = 2
        smoke?.position.x = player.sprite.position.x
        smoke?.position.y = ground.position.y + (ground.size.height/2)
        
        addChild(smoke!)
    }
    
    
    func createGround() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "ground")
            bg.name = "Ground"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: -(self.frame.size.height / 2) - 45)
            bg.zPosition = 3
            
            bg.physicsBody = SKPhysicsBody(rectangleOf: bg.size)
            bg.physicsBody?.affectedByGravity = false
            bg.physicsBody?.categoryBitMask = ColliderType.Ground
            bg.physicsBody?.isDynamic = false
            
            ground = bg
            
            self.addChild(bg)
        }
    }
    
    func createBG() {
        for i in 0...2 {
            
            let bg = SKSpriteNode(imageNamed: "BG")
            bg.name = "BG"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 100 )
            bg.zPosition = 0
            
            self.addChild(bg)
        }
    }
    
    func moveBackgroundsAndGrounds(_ dt: Float) {
        // moveing of background
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in
            let bgNode = node as! SKSpriteNode
            node.position.x -= 20 * CGFloat(dt)
            if bgNode.position.x < -(bgNode.size.width) {
                bgNode.position.x += bgNode.size.width * 3
            }
        }))
        
        // moveing of ground 
        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
            let bgNode = node as! SKSpriteNode
            node.position.x -= 50 * CGFloat(dt)
            if bgNode.position.x < -(bgNode.size.width) {
                bgNode.position.x += bgNode.size.width * 3
            }
        }))
    }
    
    func moveObsticles(_ dt: Float) {
        enumerateChildNodes(withName: "Obsticle", using: ({
            (node, error) in
            node.position.x -= (100 * CGFloat(dt))
        }))
        
        enumerateChildNodes(withName: "Spikes", using: ({
            (node, error) in
            node.position.x -= (100 * CGFloat(dt))
        }))
        
        
        enumerateChildNodes(withName: "Bird", using: ({
            (node, error) in
            node.position.x -= (190 * CGFloat(dt))
        }))
        
        for obj in obsticles {
            if obj.sprite.position.x < -(self.frame.size.width / 2) {
                obj.sprite.removeFromParent()
                obj.alive = false
                self.obsticles = self.obsticles.filter({ s in s.alive })
            }
        }
        
        enumerateChildNodes(withName: "smoke", using: ({
            (node, error) in
            node.position.x -= (100 * CGFloat(dt))
            }
        ))
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Player"{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obsticle" {
            player.moveCenter = true
        }
        
     
        
    }
    
    
    
    func removeLife() {
        
        enumerateChildNodes(withName: "life\(lives)", using: {
            (node , error) in
            let life = node as! SKSpriteNode
            life.removeFromParent()
            
        })
        lives -= 1
    }
    
    func createPlayerExplotion() {
        
        hit = SKEmitterNode(fileNamed: "birdhit")!
        hit?.name = "birdhit"
        hit?.zPosition = 2
        hit?.position = player.sprite.position
        
        addChild(hit!)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Player"{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Spikes" {
            player.moveCenter = true
            if lives == 0  {
                run(explotionSound)
                
                let action = SKAction.run {
                    self.createPlayerExplotion()
                    self.isDeadScreen = true
                    self.player.sprite.removeFromParent()
                }
                let wait = SKAction.wait(forDuration: 3)
                let deadAction = SKAction.run {
                    self.deadScreen()
                }
                
                run(SKAction.sequence([action,wait,deadAction]))
                
            } else if !canJump {
                run(spikeSound)
                playerHurtJump(Obj: player.sprite)
                removeLife()
            }
           
        }
        
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Bird" {
            // lose a life
            if lives == 0  {
                run(explotionSound)
                
                let action = SKAction.run {
                    self.createPlayerExplotion()
                    self.isDeadScreen = true
                    self.player.sprite.removeFromParent()
                }
                let wait = SKAction.wait(forDuration: 3)
                let deadAction = SKAction.run {
                    self.deadScreen()
                }
                
                run(SKAction.sequence([action,wait,deadAction]))
                
            } else {
                run(birdhitSound)
                removeLife()
            }
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obsticle" {
            
            player.moveCenter = false
            if canJump == false {
                canJump = true
                doubleJump = false
                gameSpeed = gameSpeed * 0.9
            }
            
        }
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Ground" {
            if canJump == false {
                run(landSound)
                smoke?.removeFromParent()
                createSmoke()
            }
            if canJump == false {
            canJump = true
            doubleJump = false
            gameSpeed = gameSpeed * 0.9
            }
            
        }
        
    }
    
    func updateScore() {
        enumerateChildNodes(withName: "CurrentScore", using: ({
            (node, error) in
            let obsNode = node as! SKLabelNode
            obsNode.removeFromParent()
        }))
        self.currentScore()
    }
    
    func isDead() -> Bool {
        if player.sprite.position.x < -(self.frame.size.width / 2) {
            return true
        }
        return false
    }
    
    func adjustTrail() {
        if let lastPos = player.playerLastPosY {
            if lastPos < player.sprite.position.y-10 {
                trailE?.yAcceleration = -1800
            } else { trailE?.yAcceleration = 0 }
        } else {
            trailE?.yAcceleration = 0
        }
        player.playerLastPosY = player.sprite.position.y
    }
    
    
    func moveyourScore() {
        enumerateChildNodes(withName: "CurrentScore") { (node, error) in
            let obj = node as! SKLabelNode
            obj.text = "\(self.yourScore)"
            obj.fontName =  "AvenirNext-Bold"
            let move = SKAction.moveBy(x: 100, y: -100, duration: 1)
            obj.run(move)
        }
    }
    
    func moveReplayButton() {
        enumerateChildNodes(withName: "replay") { (node, error) in
            let obj = node as! SKSpriteNode
            let pos = CGPoint(x: 0, y: 0)
            let scale = SKAction.scale(by: 4, duration: 1)
            let move = SKAction.move(to: pos, duration: 1)
            let seq = SKAction.sequence([move,scale])
            obj.run(seq)
        }
    }
    
    /// DEAD SCREEN
    func deadScreen() {
        moveyourScore()
        moveReplayButton()
        
        canJump = false
        isDeadScreen = true
        removeAllActions()
        oneHighScore()
    }
    
    func updateHighScore() {
        if yourScore > highScores! {
                highScores = yourScore
            saveHighScore()
            }
    }
    
    
    func oneHighScore() {
        updateHighScore()
        
        // HighScore
        createTextLabel(text: "HighScore", scale: 1.3,
                        pos: CGPoint(x: (frame.size.width / 4) + 20, y: 110),
                        font: "AvenirNext-Bold")
        
        let text = "\(highScores ?? 0)"
        createTextLabel(text: text, scale: 4,
                        pos: CGPoint(x: (frame.size.width / 4) + 20, y: 0),
                        font: "AvenirNext-Bold")
       
        
        // YOUR SCORE
        createTextLabel(text: "Your Score", scale: 1.3,
                        pos: CGPoint(x: -(frame.size.width / 4) - 20, y: 110),
                        font: "AvenirNext-Bold")

    }
    
    func createTextLabel(text: String, scale: CGFloat, pos: CGPoint, font: String) {
        let oneScore = SKLabelNode()
        oneScore.text = "\(text)"
        oneScore.fontColor = SKColor.red
        oneScore.setScale(scale)
        oneScore.fontName = font
        oneScore.position = pos
        oneScore.zPosition = 5
        self.addChild(oneScore)
    }
    
    
    func currentScore() {
        let Score = SKLabelNode()
        Score.name = "CurrentScore"
        Score.text = "\(yourScore) M"
        Score.fontColor = SKColor.red
        
        Score.setScale(2)
        Score.position = CGPoint(x: -(self.frame.size.width / 2) + (Score.frame.width / 2), y: (self.frame.size.height / 2) - (Score.frame.height))
        
        Score.zPosition = 5
        
        self.addChild(Score)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if atPoint(location).name == "replay" {
                
                let gameplay = GameScene(fileNamed: "GameScene")
                gameplay!.scaleMode = .aspectFill
                view?.presentScene(gameplay!)
            } else {
                if canJump {
                    run(jumpSound)
                    PlayerJump(Obj: player.sprite)
                    gameSpeed = gameSpeed * 1.1
                    canJump = false
                    doubleJump = true
                }else if doubleJump {
                    run(jumpSound)
                    PlayerJump(Obj: player.sprite)
                    doubleJump = false
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isDead() && !isDeadScreen {
            deadScreen()
            
        } else if !isDeadScreen{
            if let t = lastTime {
                let dt = (Float(currentTime) - t) * Float(gameSpeed)
                moveBackgroundsAndGrounds(dt)
                moveObsticles(dt)
                player.movePlayer(frameWidth: frame.size.width, dt)
                adjustTrail()
            }
        }
        lastTime = Float(currentTime)
    }
    
}
