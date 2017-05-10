//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Mohit Kumar on 09/05/17.
//  Copyright © 2017 Mohit Kumar. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var gameOver = false
    var score = 0
    var timer = Timer()
    
    enum colliderType: UInt32 {
        case bird = 1
        case objects = 2
        case gap = 4
    }
    
    override func sceneDidLoad() {
        
        
     
    }
    
    func makePipes(){
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width , dy:0), duration: TimeInterval(self.frame.width/100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes,removePipes])
        
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height/4
        
        // setup the up to downward pipe
        let pipe1Texture = SKTexture(imageNamed: "pipe1")
        let pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipe1Texture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.run(moveAndRemovePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe1.physicsBody!.isDynamic = false
        
        pipe1.physicsBody!.contactTestBitMask = colliderType.objects.rawValue
        pipe1.physicsBody!.categoryBitMask = colliderType.objects.rawValue
        pipe1.physicsBody!.collisionBitMask = colliderType.objects.rawValue
        
        pipe1.zPosition = -1
        self.addChild(pipe1)
        
        //setup the down to upward pipe
        let pipe2Texture = SKTexture(imageNamed: "pipe2")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.run(moveAndRemovePipes)
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipe2.physicsBody!.isDynamic = false
        
        pipe2.physicsBody!.contactTestBitMask = colliderType.objects.rawValue
        pipe2.physicsBody!.categoryBitMask = colliderType.objects.rawValue
        pipe2.physicsBody!.collisionBitMask = colliderType.objects.rawValue
        
        pipe2.zPosition = -1
        
        self.addChild(pipe2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY+pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1Texture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(moveAndRemovePipes)
        
        gap.physicsBody!.contactTestBitMask = colliderType.bird.rawValue
        gap.physicsBody!.categoryBitMask = colliderType.gap.rawValue
        gap.physicsBody!.collisionBitMask = colliderType.gap.rawValue
        
        self.addChild(gap)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false{
            if contact.bodyA.categoryBitMask == colliderType.gap.rawValue || contact.bodyB.categoryBitMask == colliderType.gap.rawValue{
                print("Add 1 to score")
                score += 1
                scoreLabel.text = String(score)
            }else{
                self.speed = 0
                gameOver = true
                timer.invalidate()
                gameOverLabel.fontName = "Halvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to Play Again"
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                self.addChild(gameOverLabel)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        setupGame()
        
    }
    
    func setupGame(){
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        
        //Create Background
        
        let bgTexture = SKTexture(imageNamed: "bg")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width , dy: 0), duration: 8)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx : bgTexture.size().width, dy: 0), duration: 0)
        let moveBgForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation,shiftBGAnimation]))
        
        var i : CGFloat = 0
        
        while i < 3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x:  bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(moveBgForever)
            bg.zPosition = -2
            
            self.addChild(bg)
            i += 1
        }
        
        
        
        //Create bird and animate it
        let birdTexture = SKTexture(imageNamed: "flappy1")
        let birdTexture2 = SKTexture(imageNamed: "flappy2")
        let animation = SKAction.animate(with: [birdTexture,birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody!.isDynamic = false
        
        bird.physicsBody!.contactTestBitMask = colliderType.objects.rawValue
        bird.physicsBody!.categoryBitMask = colliderType.bird.rawValue
        bird.physicsBody!.collisionBitMask = colliderType.bird.rawValue
        
        bird.run(makeBirdFlap)
        
        self.addChild(bird)
        
        //Create pipes
        
        //
        
        //Create gound to the bottom
        
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = colliderType.objects.rawValue
        ground.physicsBody!.categoryBitMask = colliderType.objects.rawValue
        ground.physicsBody!.collisionBitMask = colliderType.objects.rawValue
        
        self.addChild(ground)
        
        
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2 - 70)
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false{
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        }else{
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setupGame()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
