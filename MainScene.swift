//
//  MainScene.swift
//  SlideTheCircle
//
//  Created by Phil Javinsky III on 2/26/16.
//  Copyright © 2016 Phil Javinsky III. All rights reserved.
//

import SpriteKit
import GameKit

var wallSpeed: Double = 3
var wallFreq: Double = 0.5
var arrowPos: CGPoint = CGPoint(x: 100, y: 550)
var bestEasy: Int = 0, bestMedium: Int = 0, bestHard: Int = 0
enum Difficulty {
    case Easy, Medium, Hard
}
var difficulty = Difficulty.Easy
var best: Int = 0
var identifier: String = "easy"

class MainScene: SKScene, GKGameCenterControllerDelegate {
    var touchLocation: CGPoint = CGPointZero
    var startLabel, easyLabel, mediumLabel, hardLabel: SKLabelNode!
    var easy, medium, hard, arrow, gameCenter: SKSpriteNode!
    var walls: SKNode!
    var height: Int = 540, bestEasy: Int = 0, bestMedium: Int = 0, bestHard: Int = 0
    
    override func didMoveToView(view: SKView) {
        NSNotificationCenter.defaultCenter().postNotificationName("showAd", object: nil)
        
        startLabel = self.childNodeWithName("tapToStart") as! SKLabelNode
        let action1 = SKAction.scaleBy(6/5, duration: 0.5)
        let action2 = SKAction.scaleBy(5/6, duration: 0.5)
        let sequence1 = SKAction.sequence([action1, action2])
        startLabel.runAction(SKAction.repeatActionForever(sequence1))
        
        easy = self.childNodeWithName("easy") as! SKSpriteNode
        medium = self.childNodeWithName("medium") as! SKSpriteNode
        hard = self.childNodeWithName("hard") as! SKSpriteNode
        arrow = self.childNodeWithName("arrow") as! SKSpriteNode
        arrow.position = arrowPos
        gameCenter = self.childNodeWithName("gameCenter") as! SKSpriteNode
        
        // Load best scores
        let defaults = NSUserDefaults.standardUserDefaults()
        bestEasy = defaults.integerForKey("bestEasyScore")
        bestMedium = defaults.integerForKey("bestMedScore")
        bestHard = defaults.integerForKey("bestHardScore")
        if difficulty == Difficulty.Easy {
            best = bestEasy
        }
        else if difficulty == Difficulty.Medium {
            best = bestMedium
        }
        else if difficulty == Difficulty.Hard {
            best = bestHard
        }
        
        easyLabel = self.childNodeWithName("easyLabel") as! SKLabelNode
        easyLabel.text = "Best: \(bestEasy)"
        mediumLabel = self.childNodeWithName("mediumLabel") as! SKLabelNode
        mediumLabel.text = "Best: \(bestMedium)"
        hardLabel = self.childNodeWithName("hardLabel") as! SKLabelNode
        hardLabel.text = "Best: \(bestHard)"
        
        let spawn = SKAction.runBlock(self.spawnWalls)
        let wait = SKAction.waitForDuration(wallFreq)
        let sequence2 = SKAction.sequence([spawn, wait])
        self.runAction(SKAction.repeatActionForever(sequence2))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if easy.containsPoint(touchLocation) {
            if arrow.position.y != easy.position.y {
                arrow.position.y = easy.position.y
                arrowPos.y = easy.position.y
                wallSpeed = 3
                wallFreq = 0.5
                difficulty = .Easy
                best = bestEasy
                identifier = "easy"
                resetScene()
            }
        }
        else if medium.containsPoint(touchLocation) {
            if arrow.position.y != medium.position.y {
                arrow.position.y = medium.position.y
                arrowPos.y = medium.position.y
                wallSpeed = 2
                wallFreq = 0.3
                difficulty = .Medium
                best = bestMedium
                identifier = "medium"
                resetScene()
            }
        }
        else if hard.containsPoint(touchLocation) {
            if arrow.position.y != hard.position.y {
                arrow.position.y = hard.position.y
                arrowPos.y = hard.position.y
                wallSpeed = 1.5
                wallFreq = 0.25
                difficulty = .Hard
                best = bestHard
                identifier = "hard"
                resetScene()
            }
        }
        else if gameCenter.containsPoint(touchLocation) {
            showLeaderboard()
        }
        else {
            let game: GameScene = GameScene(fileNamed: "GameScene")!
            game.scaleMode = .AspectFit
            self.view?.presentScene(game, transition: SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1))
        }
    }
    
    func spawnWalls() {
        walls = SKScene(fileNamed: "Walls")!.childNodeWithName("walls")!
        walls.removeFromParent()
        self.addChild(walls)
        
        let direction = Int(arc4random_uniform(2))
        if direction == 0 { // down
            if height > 180 {
                height = height - 60
            }
        }
        else if direction == 1 { // up
            if height < 900 {
                height = height + 60
            }
        }
        walls.position = CGPoint(x: 1940, y: height)
        
        let action1 = SKAction.moveToX(-20, duration: wallSpeed)
        let action2 = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([action1, action2])
        walls.runAction(moveAndRemove)
    }
    
    func resetScene() {
        let newMain: MainScene = MainScene(fileNamed: "MainScene")!
        newMain.scaleMode = .AspectFit
        self.view?.presentScene(newMain, transition: SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1))
    }
    
    // show leaderboard screen
    func showLeaderboard() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
}

