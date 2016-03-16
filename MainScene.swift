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
var arrowPos: CGPoint = CGPoint(x: 100, y: 530)
var bestEasy: Int = 0, bestMedium: Int = 0, bestHard: Int = 0
enum Difficulty {
    case Easy, Medium, Hard
}
var difficulty = Difficulty.Easy
var best: Int = 0
let defaults = NSUserDefaults.standardUserDefaults()
var identifier: String = "easy"

class MainScene: SKScene, GKGameCenterControllerDelegate {
    var touchLocation: CGPoint = CGPointZero
    var startLabel, easyLabel, mediumLabel, hardLabel: SKLabelNode!
    var easy, medium, hard, arrow, gameCenter, safeZone: SKSpriteNode!
    var walls: SKNode!
    var height: Int = 540
    
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
        safeZone = self.childNodeWithName("safeZone") as! SKSpriteNode
        
        // load local high scores
        bestEasy = defaults.integerForKey("bestEasyScore")
        bestMedium = defaults.integerForKey("bestMediumScore")
        bestHard = defaults.integerForKey("bestHardScore")
        
        // wait a second and check authentication
        performSelector("checkAuthentication", withObject: nil, afterDelay: 3)
        
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
    
    func checkAuthentication() {
        if player.authenticated {
            getBestScores()
        }
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
        else if self.containsPoint(touchLocation) && !(safeZone.containsPoint(touchLocation)) {
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
    
    // compare local high scores with Game Center high scores
    func getBestScores() {
        if bestEasy >= bestEasyGC {
            //print("\nlocal easy score equal or better")
            saveHighScore(bestEasy, ident: "easy")
        }
        else {
            //print("\nGC easy score better")
            bestEasy = bestEasyGC
            defaults.setInteger(bestEasy, forKey: "bestEasyScore")
            easyLabel.text = "Best: \(bestEasy)"
        }
        
        if bestMedium >= bestMediumGC {
            //print("\nlocal medium score equal or better")
            saveHighScore(bestMedium, ident: "medium")
        }
        else {
            //print("\nGC medium score better")
            bestMedium = bestMediumGC
            defaults.setInteger(bestMedium, forKey: "bestMediumScore")
            mediumLabel.text = "Best: \(bestMedium)"
        }
        
        if bestHard >= bestHardGC {
            //print("\nlocal hard score equal or better")
            saveHighScore(bestHard, ident: "hard")
        }
        else {
            //print("\nGC hard score better")
            bestHard = bestHardGC
            defaults.setInteger(bestHard, forKey: "bestHardScore")
            hardLabel.text = "Best: \(bestHard)"
        }
    }
    
    // send high score to leaderboard
    func saveHighScore(highScore: Int, ident: String) {
        // check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: ident)
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

