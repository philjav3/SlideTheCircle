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
import GoogleMobileAds

var adBanner: GADBannerView = GADBannerView()
var player = GKLocalPlayer.localPlayer()
var gameCenterEnabled: Bool = false
var bestEasyGC: Int = 0, bestMediumGC: Int = 0, bestHardGC: Int = 0

class GameViewController: UIViewController {
    
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
    
    func loadAds() {
        adBanner.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height/7.5)
        //adBanner.adUnitID = "ca-app-pub-3940256099942544/2934735716" // for test ads
        adBanner.adUnitID = "ca-app-pub-6416730604045860/5281247703"
        adBanner.rootViewController = self
        
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID] // for simulator
        adBanner.loadRequest(request)
        self.view.addSubview(adBanner)
    }
    
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        adBanner.hidden = true
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
}