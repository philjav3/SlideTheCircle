//
//  GameScene.swift
//  SlideTheCircle
//
//  Created by Phil Javinsky III on 2/26/16.
//  Copyright (c) 2016 Phil Javinsky III. All rights reserved.
//

import SpriteKit
import GameKit

let nodeMask: UInt32 = 0x1 << 0 // 1
let wallMask: UInt32 = 0x1 << 1 // 2
let floorMask:  UInt32 = 0x1 << 2 // 4
let scoreMask: UInt32 = 0x1 << 3 // 8

class GameScene: SKScene, SKPhysicsContactDelegate {
    var touchLocation: CGPoint = CGPointZero
    var ball, dummy, blur, playAgain, mainMenu: SKSpriteNode!
    var gameOverLabel, scoreLabel, scoreLabel2, bestLabel: SKLabelNode!
    var instructions, scoreText, bestText: SKLabelNode!
    var walls: SKNode!
    var started: Bool = false
    var score: Int = 0, height: Int = 540
    var sparkColor: UIColor = UIColor(red: 22/255, green: 112/255, blue: 234/255, alpha: 1)
    
    override func didMoveToView(view: SKView) {
        adBanner.hidden = true
        
        ball = self.childNodeWithName("node") as! SKSpriteNode
        ball.texture = SKTexture(imageNamed: ballColor)
        ball.removeFromParent()
        dummy = self.childNodeWithName("dummy") as! SKSpriteNode
        dummy.texture = SKTexture(imageNamed: ballColor)
        instructions = self.childNodeWithName("instructions") as! SKLabelNode
        scoreLabel = self.childNodeWithName("score") as! SKLabelNode
        
        // Game over screen
        blur = self.childNodeWithName("blur") as! SKSpriteNode
        gameOverLabel = blur.childNodeWithName("gameOverLabel") as! SKLabelNode
        playAgain = blur.childNodeWithName("playAgain") as! SKSpriteNode
        mainMenu = blur.childNodeWithName("mainMenu") as! SKSpriteNode
        bestText = blur.childNodeWithName("bestLabel") as! SKLabelNode
        bestText.position = CGPoint(x: -100, y: 575)
        bestLabel = blur.childNodeWithName("best") as! SKLabelNode
        bestLabel.position = CGPoint(x: -100, y: 450)
        scoreText = blur.childNodeWithName("scoreLabel") as! SKLabelNode
        scoreText.position = CGPoint(x: 2020, y: 575)
        scoreLabel2 = blur.childNodeWithName("score2") as! SKLabelNode
        scoreLabel2.position = CGPoint(x: 2020, y: 450)
        
        self.physicsWorld.contactDelegate = self
        self.view?.multipleTouchEnabled = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
        ball.physicsBody?.collisionBitMask = wallMask
        ball.physicsBody?.contactTestBitMask = wallMask | scoreMask
        
        // Start walls
        if !started {
            started = true
            dummy.removeFromParent()
            self.addChild(ball)
            let fade = SKAction.fadeAlphaBy(-1, duration: 0.5)
            let remove = SKAction.removeFromParent()
            let sequence1 = SKAction.sequence([fade,remove])
            instructions.runAction(sequence1)
            
            let spawn = SKAction.runBlock(spawnWalls)
            let wait = SKAction.waitForDuration(wallFreq)
            let sequence2 = SKAction.sequence([spawn, wait])
            self.runAction(SKAction.repeatActionForever(sequence2))
        }
        
        if playAgain.containsPoint(touchLocation) {
            let newGame: GameScene = GameScene(fileNamed: "GameScene")!
            newGame.scaleMode = .AspectFit
            self.view?.presentScene(newGame, transition: SKTransition.fadeWithDuration(2))
        }
        else if mainMenu.containsPoint(touchLocation) {
            let main: MainScene = MainScene(fileNamed: "MainScene")!
            main.scaleMode = .AspectFit
            self.view?.presentScene(main, transition: SKTransition.fadeWithDuration(2))
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func update(currentTime: CFTimeInterval) {
        ball.position.y = touchLocation.y
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let node1 = (contact.bodyA.categoryBitMask == nodeMask) ? contact.bodyA : contact.bodyB
        let other = (node1 == contact.bodyA) ? contact.bodyB : contact.bodyA
        
        if other.categoryBitMask == wallMask {
            gameOver()
        }
        else if other.categoryBitMask ==  scoreMask {
            updateScore()
        }
    }
    
    func spawnWalls() {
        walls = SKScene(fileNamed: "Walls")!.childNodeWithName("walls")!
        walls.removeFromParent()
        self.addChild(walls)
        
        let direction = Int(arc4random_uniform(2))
        if direction == 0 { // down
            if height > 180 {
                height = height - 120
            }
        }
        else if direction == 1 { // up
            if height < 900 {
                height = height + 120
            }
        }
        walls.position = CGPoint(x: 1940, y: height)
        
        let action1 = SKAction.moveToX(-20, duration: wallSpeed)
        let action2 = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([action1, action2])
        walls.runAction(moveAndRemove)
    }
    
    func updateScore() {
        score++
        scoreLabel.text = String(score)
    }
    
    func gameOver() {
        let spark: SKEmitterNode = SKEmitterNode(fileNamed: "Spark")!
        if ballColor == "circleR" {
            sparkColor = UIColor(red: 219/255, green: 0, blue: 0, alpha: 1)
        }
        else if ballColor == "circleO" {
            sparkColor = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
        }
        else if ballColor == "circleY" {
            sparkColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
        }
        else if ballColor == "circleG" {
            sparkColor = UIColor(red: 0, green: 219/255, blue: 82/255, alpha: 1)
        }
        else if ballColor == "circleB" {
            sparkColor = UIColor(red: 22/255, green: 112/255, blue: 234/255, alpha: 1)
        }
        else if ballColor == "circleP" {
            sparkColor = UIColor(red: 210/255, green: 87/255, blue: 1, alpha: 1)
        }
        spark.particleColorSequence = nil
        spark.particleColor = sparkColor
        spark.position = ball.position
        self.addChild(spark)
        ball.removeFromParent()
        
        if score > best {
            best = score
            if difficulty == Difficulty.Easy {
                defaults.setInteger(best, forKey: "bestEasyScore")
            }
            else if difficulty == Difficulty.Medium {
                defaults.setInteger(best, forKey: "bestMediumScore")
            }
            else if difficulty == Difficulty.Hard {
                defaults.setInteger(best, forKey: "bestHardScore")
            }
            if player.authenticated {
                saveHighScore(best)
            }
        }
        
        // show game over screen
        scoreLabel.removeFromParent()
        blur.position = CGPoint(x: 0, y: 0)
        bestLabel.text = String(best)
        scoreLabel2.text = String(self.score)
        
        bestText.runAction(SKAction.moveToX(770, duration: 1))
        bestLabel.runAction(SKAction.moveToX(770, duration: 1))
        
        scoreText.runAction(SKAction.moveToX(1150, duration: 1))
        scoreLabel2.runAction(SKAction.moveToX(1150, duration: 1))
        
        adBanner.hidden = false
    }
    
    // send high score to leaderboard
    func saveHighScore(highScore: Int) {
        // check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: identifier)
            scoreReporter.value = Int64(highScore)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error: NSError?) -> Void in
                if error != nil {
                    print("error")
                }
            })
        }
    }
}
