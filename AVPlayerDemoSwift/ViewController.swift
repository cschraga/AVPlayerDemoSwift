//
//  ViewController.swift
//  AVPlayerDemoSwift
//
//  Created by Christian Schraga on 6/15/16.
//  Copyright © 2016 Straight Edge Digital. All rights reserved.
//

import UIKit

class ViewController: UIViewController, VideoCommunicationsProtocol {

    @IBOutlet var videoWrapper: UIView!
    var videoViewController: VideoViewController?
    let kFileName = "HandsToMyself"
    var landscape = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let storyboard = self.storyboard {
            videoViewController = storyboard.instantiateViewControllerWithIdentifier("videoViewController") as? VideoViewController
            
            if videoViewController != nil {
                self.videoWrapper.addSubview(videoViewController!.view)
                videoViewController!.viewCommunicationsDelegate = self
            }
            
            //Notification to change UI on rotation. I was getting some strange behaviour from autosize
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.drawViewController), name: UIDeviceOrientationDidChangeNotification, object: nil)
        }
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let vvc = videoViewController {
            if let path = NSBundle.mainBundle().pathForResource(kFileName, ofType: "mp4") {
                let url = NSURL(fileURLWithPath: path)
                vvc.loadVideoURL(url)
                
                updateOrientation()
                vvc.view.frame = videoWrapper.bounds
                vvc.drawUI()
            }
            
        }
    }
    
    func drawViewController(){
        if let vvc = videoViewController {
            updateOrientation()
            vvc.view.frame = videoWrapper.bounds
            vvc.drawUI()
        }
    }
        
    func updateOrientation(){
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
            print("nav controller sees landscape")
            self.landscape = true
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)){
            print("nav controller sees portrait")
            self.landscape = false
        }
    }

    //delegate methods.  I usually have a lot more but I always need to access time and have some way of communicating back to the parent via a gesture
    
    func vpDoubleTap(controller: VideoViewController) {
        print("double tap")
    }
    
    func vpUpdateTime(controller: VideoViewController, seconds: Int, duration: Int) {
        //input time synching procedures here
    }
    
    //cleanup
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

