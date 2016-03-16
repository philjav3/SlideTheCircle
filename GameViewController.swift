//
//  GameViewController.swift
//  SlideTheCircle
//
//  Created by Phil Javinsky III on 2/26/16.
//  Copyright (c) 2016 Phil Javinsky III. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import iAd

var player = GKLocalPlayer.localPlayer()
var gameCenterEnabled: Bool = false
var bestEasyGC: Int = 0, bestMediumGC: Int = 0, bestHardGC: Int = 0

class GameViewController: UIViewController, ADBannerViewDelegate {
    //var leaderboardIdentifier: String = "easy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticatePlayer()
        
        loadGCScore("easy")
        loadGCScore("medium")
        loadGCScore("hard")
        
        loadAds()
        
        if let scene = MainScene(fileNamed:"MainScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFit
            
            skView.presentScene(scene)
        }
    }
    
    // Game Center sign in screen
    func authenticatePlayer() {
        player.authenticateHandler = {(viewController, error) -> Void in
            // present sign in screen if device doesn't have an authenticated player
            if viewController != nil {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
            
            /*if player.authenticated {
                gameCenterEnabled = true
                print("\nGC enabled\n")
                print("\nAuthentication: \(player.authenticated)")
                
                player.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier : String?, error : NSError?) -> Void in
                    if error != nil {
                        print(error!.localizedDescription)
                    }
                    else {
                        self.leaderboardIdentifier = leaderboardIdentifier!
                    }
                })
                
            }
            else {
                gameCenterEnabled = false
                print("\nGC disabled\n")
                print("\nAuthentication: \(player.authenticated)")
            }*/
        }
    }
    
    // load high scores from Game Center
    func loadGCScore(leaderboard: String) {
        let leaderboardRequest = GKLeaderboard()
        leaderboardRequest.identifier = leaderboard
        leaderboardRequest.loadScoresWithCompletionHandler { (scores, error) -> Void in
            if error != nil {
                print("Error: \(error))")
            }
            else if leaderboardRequest.localPlayerScore != nil {
                let leaderboardScore = leaderboardRequest.localPlayerScore!.value
                if leaderboard == "easy" {
                    bestEasyGC = Int(leaderboardScore)
                }
                else if leaderboard == "medium" {
                    bestMediumGC = Int(leaderboardScore)
                }
                else if leaderboard == "hard" {
                    bestHardGC = Int(leaderboardScore)
                }
                
            }
            else {
                bestEasyGC = 0
                bestMediumGC = 0
                bestHardGC = 0
            }
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // iAd functions
    func loadAds() {
        adBanner = ADBannerView(frame: CGRectZero)
        adBanner.delegate = self
        adBanner.hidden = true
        view!.addSubview(adBanner)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBanner.center = CGPoint(x: adBanner.center.x, y: view!.bounds.size.height - view!.bounds.size.height + adBanner.frame.size.height / 2)
        adBanner.hidden = false
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBanner.hidden = true
    }
}