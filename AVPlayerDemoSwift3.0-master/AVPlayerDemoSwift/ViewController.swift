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
            videoViewController = storyboard.instantiateViewController(withIdentifier: "videoViewController") as? VideoViewController
            
            if videoViewController != nil {
                self.videoWrapper.addSubview(videoViewController!.view)
                videoViewController!.viewCommunicationsDelegate = self
            }
            
            //Notification to change UI on rotation. I was getting some strange behaviour from autosize
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.drawViewController), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let vvc = videoViewController {
            if let path = Bundle.main.path(forResource: kFileName, ofType: "mp4") {
                let url = URL(fileURLWithPath: path)
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
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            print("nav controller sees landscape")
            self.landscape = true
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
            print("nav controller sees portrait")
            self.landscape = false
        }
    }

    //delegate methods.  I usually have a lot more but I always need to access time and have some way of communicating back to the parent via a gesture
    
    func vpDoubleTap(_ controller: VideoViewController) {
        print("double tap")
    }
    
    func vpUpdateTime(_ controller: VideoViewController, seconds: Int, duration: Int) {
        //input time synching procedures here
    }
    
    //cleanup
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

