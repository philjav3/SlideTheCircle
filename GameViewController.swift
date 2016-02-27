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

class GameViewController: UIViewController, ADBannerViewDelegate {
    var gameCenterEnabled: Bool = false
    var leaderboardIdentifier: String = "easy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        loadAds()
        authenticatePlayer()
    }
    
    // initiate GameCenter
    func authenticatePlayer() {
        let player = GKLocalPlayer()
        player.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
            else {
                if player.authenticated {
                    self.gameCenterEnabled = true
                    
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
                    self.gameCenterEnabled = false
                }
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