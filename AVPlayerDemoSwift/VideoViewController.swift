//
//  VideoViewController.swift
//  HardwireDemo
//
//  Created by Christian Schraga on 5/20/16.
//  Copyright © 2016 Straight Edge Digital. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoCommunicationsProtocol {
    
    func vpUpdateTime(controller: VideoViewController, seconds: Int, duration: Int)
    func vpDoubleTap(controller: VideoViewController)
    
}


class VideoViewController: UIViewController, ScrubberDelegate, UIGestureRecognizerDelegate{
    
    //UI
    var videoView: UIView!
    var mScrubber: Scrubber!
    var bufferingIndicator: UIActivityIndicatorView!
    
    //Decides fit. True fills screen, false fits video
    var fillScreen = true
    var aspectRatio: CGFloat = 4.0 / 3.0
    var borderSize = CGSizeMake(5.0, 5.0)
    
    //Player
    var mPlayer: AVPlayer?
    var mPlayerLayer: AVPlayerLayer?
    
    //Title
    var titleLabel: VideoTitleLabel!
    var showTitle = false
    
    //Data
    var asset: AVURLAsset?
    var hwPlayerItem: AVPlayerItem?
    var startTime: Double?
    var endTime: Double?
    var titleString: String?
    
    //recognizer that is disable-able
    var panner: UIPanGestureRecognizer!
    var singleTap: UITapGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    
    //colors
    let kScrubWhite = UIColor(white: 1.0, alpha: 0.667)
    
    //Status Variables
    var isPlaying: Bool {
        get {
            var playing = false
            if let restore = mRestoreAfterScrubbingRate{
                playing = restore > 0.0
            }
            if let player = mPlayer {
                playing = player.rate > 0.0
            }
            return playing
        }
    }
    var isPaused: Bool = false
    var readyToPlay: Bool = false
    var isSeeking: Bool = false
    
    //constant for positioning pre-rendering
    let kCenter = CGRectMake(UIScreen.mainScreen().bounds.midX, UIScreen.mainScreen().bounds.midY, 0.0, 0.0)
    
    //Time Variables
    var timeObserver: AnyObject?
    var timeClipObserver: AnyObject?
    var mRestoreAfterScrubbingRate: Float?
    //Timer to hide scrubber and title
    var scrubTimer: NSTimer?
    
    //Notifications, Keys, Flags, Contexts
    private var VideoControllerRateObservationContext = 1
    private var VideoControllerStatusObservationContext = 2
    private var VideoControllerCurrentItemObservationContext = 3
    private var VideoControllerLikelyToKeepUpObservationContext = 4
    private var VideoControllerRateFlag = false
    private var VideoControllerStatusFlag = false
    private var VideoControllerCurrentItemFlag = false
    private var VideoControllerLikelyToKeepUpFlag = false
    
    //Delegates
    var viewCommunicationsDelegate: VideoCommunicationsProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        drawScrubberAndLabel()
    }
    
    func setup(){
        
        self.view.backgroundColor = UIColor.clearColor()
        
        videoView = UIView(frame: kCenter)
        videoView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(videoView)
        
        //scrubber / controls
        mScrubber = Scrubber(lineWidth: 3.0, color: kScrubWhite)
        mScrubber.delegate = self
        self.view.addSubview(mScrubber)
        
        //add title label so we know what video we're on
        titleLabel = VideoTitleLabel()
        self.view.addSubview(titleLabel)
        
        singleTap = UITapGestureRecognizer(target: self, action: #selector(VideoViewController.handleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        self.view.addGestureRecognizer(singleTap)
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(VideoViewController.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        singleTap.requireGestureRecognizerToFail(doubleTap)
        self.view.addGestureRecognizer(doubleTap)
        
        panner = UIPanGestureRecognizer(target: self, action: #selector(VideoViewController.handlePan(_:)))
        //panner.requireGestureRecognizerToFail(swipeUp)
        //panner.requireGestureRecognizerToFail(swipeDown)
        self.view.addGestureRecognizer(panner)
        
        bufferingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        bufferingIndicator.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin,
                                               UIViewAutoresizing.FlexibleTopMargin,
                                               UIViewAutoresizing.FlexibleHeight,
                                               UIViewAutoresizing.FlexibleLeftMargin,
                                               UIViewAutoresizing.FlexibleRightMargin,
                                               UIViewAutoresizing.FlexibleWidth]
        bufferingIndicator.center = self.view.center
        self.view.addSubview(bufferingIndicator)
        
        //add player layer
        mPlayerLayer = AVPlayerLayer(player: mPlayer)
        mPlayerLayer!.frame = videoView.layer.bounds
        mPlayerLayer!.bounds = mPlayerLayer!.frame
        mPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoView.layer.addSublayer(mPlayerLayer!)

        
    }

    func handleTap(recognizer: UITapGestureRecognizer){
        print("tapped")
        if !isPaused{
            pause(recognizer)
        } else {
            play(recognizer)
        }
        if mScrubber.alpha == 1.0 {
            scrubberAndTitle(false)
        } else {
            scrubberAndTitle(true)
        }
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer){
        print("double tapped")
        viewCommunicationsDelegate?.vpDoubleTap(self)
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer){
        
        if recognizer.state == .Began {
            beginScrubbing(mScrubber)
        } else if recognizer.state == .Cancelled || recognizer.state == .Ended {
            self.endScrubbing(mScrubber)
        } else {
            let change = recognizer.translationInView(self.view)
            mScrubber.scrubPct(Double(change.x/1024.0))
            self.scrub(mScrubber)
        }
        recognizer.setTranslation(CGPointZero, inView: view)
    }

    
    func drawUI() {
        let rect = self.view.bounds.width > 0.0 ? self.view.bounds : kCenter
        resizeVideoView(rect)
    }
    
    func resizeVideoView(rect: CGRect) {
        //1) draw video player
        var width:  CGFloat = 0.0
        var height: CGFloat = 0.0
        var x:      CGFloat = 0.0
        var y:      CGFloat = 0.0
        
        if fillScreen {
            
            videoView.frame = CGRectInset(rect, borderSize.width, borderSize.height)
            if let playerLayer = mPlayerLayer {
                playerLayer.frame  = videoView.bounds
                playerLayer.bounds = playerLayer.frame
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
            
            
            
        } else {
            
            //first see if we're restricted by width or height
            if rect.size.width * 9 / 16 < rect.size.height {
                //width constrained
                width  = rect.size.width
                height = width * 9.0 / 16.0
            } else {
                //height constrained
                height = rect.size.height
                width  = height * 16/9
            }
            
            x = rect.midX - width / 2.0
            y = max(rect.midY - height / 2.0, rect.minY)
            
            videoView.frame = CGRectInset(CGRectMake(x,y,width,height), borderSize.width, borderSize.height)
            
            if let playerLayer = mPlayerLayer {
                playerLayer.frame  = videoView.bounds
                playerLayer.bounds = playerLayer.frame
            }
            
        }
        
        
        print("redraw video controller view bounds: \(self.view.bounds), video view frame: \(videoView.frame). fill screen = \(fillScreen)")
        
        
        drawScrubberAndLabel()
    }
    
    func drawScrubberAndLabel() {
        
        var width  = videoView.bounds.width * 0.625
        var height = width / 2.5
        
        var x      = videoView.bounds.midX - width / 2
        var y      = videoView.bounds.midY - height / 2
        mScrubber.frame = CGRectMake(x, y, width, height)
        
        
        mScrubber.drawUI()
        mScrubber.setNeedsDisplay()
        
        width = view.bounds.width * 0.80
        height = mScrubber.bounds.height / 2
        x      = self.view.bounds.midX - width / 2.0
        y      = mScrubber.frame.maxY
        titleLabel.frame = showTitle ? CGRectMake(x, y, width, height) : CGRectZero
        titleLabel.drawUI()
        
        print("video controller bounds: \(self.view.bounds) titleframe \(titleLabel.frame)")
        
    }

    func loadVideoURL(url: NSURL){
        
        asset = AVURLAsset(URL: url)
        if asset != nil {
            //self.scrubberAndTitle(false)
            asset!.loadValuesAsynchronouslyForKeys(["playable"], completionHandler: { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("asset playable key loaded")
                    self.prepareToPlayAsset(self.asset!, withKeys: ["playable"])
                })
            })
        } else {
            print("asset never got ready to play")
        }
        
    }
    
    func videoClip(url: NSURL, startTime: Double, endTime: Double){
        self.startTime = startTime
        self.endTime   = endTime
        loadVideoURL(url)
    }
    
    func prepareToPlayAsset(asset: AVURLAsset, withKeys: [String]){
        
        //check to make sure the url contains a playable asset
        for thisKey in withKeys{
            var error: NSError? = nil
            _ = asset.statusOfValueForKey(thisKey, error: &error)
            if error != nil {
                print("error in making AVURLAsset: \(error!.localizedDescription)")
            }
        }
        
        if !asset.playable {
            //error handling here
            print("The assets tracks were loaded, but could not be made playable")
        }
        
        //kill old observers
        if let existingItem = hwPlayerItem {
            if VideoControllerStatusFlag {
                existingItem.removeObserver(self, forKeyPath: "status")
            }
            
            if VideoControllerLikelyToKeepUpFlag {
                existingItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            }
        }
        
        //INSTANTIATE NEW PLAYER ITEM
        hwPlayerItem = AVPlayerItem(asset: asset)
        
        //assuming the item is good to go...
        if let goodItem = hwPlayerItem {
            
            //add observers
            goodItem.addObserver(self, forKeyPath: "status",
                                 options: [.Initial, .New],
                                 context: &VideoControllerStatusObservationContext)
            goodItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp",
                                 options: [.Initial, .New],
                                 context: &VideoControllerLikelyToKeepUpObservationContext)
            VideoControllerLikelyToKeepUpFlag = true
            VideoControllerStatusFlag         = true
            
            
            if self.mPlayer == nil {
                self.mPlayer = AVPlayer(playerItem: goodItem)
                print("loaded new player with new player item")
                mPlayer!.addObserver(self, forKeyPath: "currentItem", options: [.Initial, .New], context: &VideoControllerCurrentItemObservationContext)
                mPlayer!.addObserver(self, forKeyPath: "rate", options: [.Initial, .New], context: &VideoControllerRateObservationContext)
                VideoControllerRateFlag = true
                VideoControllerCurrentItemFlag = true
            }
            
            if let item = self.mPlayer!.currentItem {
                if item != goodItem {
                    mPlayer!.replaceCurrentItemWithPlayerItem(goodItem)
                    print("replaced player with new player item")
                }
            } else {
                print("replaced player with new player item")
                mPlayer!.replaceCurrentItemWithPlayerItem(goodItem)
            }
        
        }
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &VideoControllerStatusObservationContext {
            
            //1.) set status flags
            // VideoControllerStatusFlag = false
            syncPlayPauseButtons()
            
            //2.) check item status and react accordingly
            if let status = change?[NSKeyValueChangeNewKey] {
                let enumStatus = AVPlayerItemStatus(rawValue: status as! Int)!
                switch (enumStatus) {
                    
                case AVPlayerItemStatus.Unknown:
                    self.removePlayerTimeObserver()
                    self.syncScrubber()
                    break;
                    
                case AVPlayerItemStatus.ReadyToPlay:
                    self.readyToPlay = true
                    print("observe asset ready to play")
                    
                    if let object = object {
                        
                        if let b = object as? AVPlayerItem {
                            print("object as player item")
                            if VideoControllerStatusFlag {
                                b.removeObserver(self, forKeyPath: "status", context: &VideoControllerStatusObservationContext)
                                VideoControllerStatusFlag = false
                            }
                        }
                        
                    }
                    
                    self.initScrubberTimer()
                    if !isPaused {
                    //go to start time
                    if let sTime = self.startTime{
                        if sTime > 0.0 {
                            if let _ = mPlayer{
                                if let eTime = self.endTime {
                                    self.scrubberAndTitle(true)
                                    self.playClip(sTime, endTime: eTime)
                                    self.endTime = nil
                                } else {
                                    self.scrubberAndTitle(true)
                                    self.play(self)
                                }
                                self.startTime = nil
                            }
                            
                        } else {
                            self.scrubberAndTitle(true)
                            self.play(self)
                        }
                    } else {
                        self.scrubberAndTitle(true)
                        self.play(self)
                    }
                    }
                    break;
                    
                case AVPlayerItemStatus.Failed:
                    print("observe asset failed")
                    let localItem = object as! AVPlayerItem
                    self.assetFailedToPrepareForPlayback(localItem.error)
                    break;
                }
            }
            
        } else if context == &VideoControllerRateObservationContext {
            //VideoControllerRateFlag = false
            
            syncPlayPauseButtons()
            
        } else if context == &VideoControllerCurrentItemObservationContext {
            //VideoControllerCurrentItemFlag = false
            
            if let _ = change?[NSKeyValueChangeNewKey] {
                
                if let player = mPlayer, playerLayer = mPlayerLayer {
                    print("replacing player asset")
                    playerLayer.player = player
                    mPlayerLayer!.frame = videoView.layer.bounds
                    mPlayerLayer!.bounds = mPlayerLayer!.frame
                    mPlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                }
                
            }
            
        } else if context == &VideoControllerLikelyToKeepUpObservationContext {
            //VideoControllerLikelyToKeepUpFlag = false
            
            if let likelyToKeepUp = change?[NSKeyValueChangeNewKey]?.boolValue {
                if likelyToKeepUp {
                    self.bufferingIndicator.hidden = true
                    self.bufferingIndicator.stopAnimating()
                    NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(VideoViewController.onBufferingTimeout(_:)), object: nil)
                } else {
                    self.bufferingIndicator.startAnimating()
                    self.bufferingIndicator.hidden = false
                    self.performSelector(#selector(VideoViewController.onBufferingTimeout(_:)), withObject: nil, afterDelay: 10.0)
                }
            }
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func assetFailedToPrepareForPlayback(error: NSError?){
        self.removePlayerTimeObserver()
        self.syncScrubber()
        
        if let isError = error {
            let title = isError.localizedDescription
            let message = isError.localizedFailureReason
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let onlyAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(onlyAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func onBufferingTimeout(sender: AnyObject?){
        
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(VideoViewController.onBufferingTimeout(_:)), object: nil)
        let title = "Video is having difficulty streaming. Please check your network connection and try again."
        let message = ""
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let onlyAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(onlyAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func syncPlayPauseButtons(){
        if let scrubber = mScrubber {
            scrubber.playTruePauseFalse = !self.isPlaying
        }
    }
    
    func syncScrubber(){
        
        if let playerDuration = playerItemDuration(), player = mPlayer {
            
            let duration = Float(CMTimeGetSeconds(playerDuration))
            if isfinite(duration){
                let time = Double(CMTimeGetSeconds(player.currentTime()))
                self.mScrubber.setSliderValue(time)
                self.titleLabel.addTime(Double(duration))
                viewCommunicationsDelegate?.vpUpdateTime(self, seconds:Int(time), duration: Int(duration))
            }
        } else {
            self.mScrubber.minimumValue = 0.0
        }
        
    }
    
    func initScrubberTimer(){
        var interval = Double(0.1)
        
        if let playerDuration = playerItemDuration(), player = mPlayer {
            
            let duration = CGFloat(CMTimeGetSeconds(playerDuration))
            if isfinite(duration){
                self.mScrubber.newFile(Double(duration), startTime: nil)
                self.titleLabel.addTime(Double(duration))
                let width = self.mScrubber.bounds.width
                interval = min(Double(0.5 * duration / width), 1.0)
                timeObserver = player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC)), queue: nil, usingBlock: { (time: CMTime) -> Void in
                    self.syncScrubber()
                })
            }
        }
    }
    
    func beginScrubbing(scrubber: Scrubber){
        if let player = mPlayer {
            mRestoreAfterScrubbingRate = player.rate
            mPlayer!.rate = 0.0
            self.removePlayerTimeObserver()
        }
    }
    
    func scrub(scrubber: Scrubber){
        
        if !isSeeking {
            isSeeking = true
            
            if let playerDuration = self.playerItemDuration(), player = mPlayer {
                let duration = Float(CMTimeGetSeconds(playerDuration))
                let minValue = Float(scrubber.minimumValue)
                let maxValue = Float(scrubber.maximumValue)
                let value    = Float(scrubber.value)
                let time     = Double(duration * (value - minValue) / (maxValue - minValue))
                
                player.seekToTime(CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)), completionHandler: { (finished) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.isSeeking = false
                    })
                })
            }
            
        }
    }
    
    
    func endScrubbing(scrubber: Scrubber){
        if self.timeObserver != nil {
            
        } else {
            if let playerDuration = self.playerItemDuration(), player = mPlayer {
                let duration = CMTimeGetSeconds(playerDuration)
                let width = scrubber.bounds.width
                let tolerance = min(Double(0.5 * duration / Double(width)), 1.0)
                
                timeObserver = player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(tolerance, Int32(NSEC_PER_SEC)), queue: nil, usingBlock: { (time) -> Void in
                    self.syncScrubber()
                })
            }
        }
        
        if let restoreRate = mRestoreAfterScrubbingRate, player = mPlayer {
            player.rate = restoreRate
            mRestoreAfterScrubbingRate = 0.0
        }
        
        
    }
    
    
    func removePlayerTimeObserver(){
        if timeObserver != nil && mPlayer != nil {
            mPlayer!.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    func playerItemDuration() -> CMTime? {
        var answer: CMTime?
        if let player = mPlayer, playerItem = player.currentItem {
            if playerItem.status == .ReadyToPlay {
                answer = playerItem.duration
            }
        }
        return answer
    }
    
    
    func toggleScrubRecognizer(on: Bool){
        panner.enabled = on
    }
    
    func toggleTitle(on: Bool){
        showTitle = on
    }
    
    func updateAspectRatio(ratio: CGFloat) {
        self.aspectRatio = ratio
    }
    
    func updateBorderSize(size: CGSize) {
        self.borderSize = size
    }
    
    func addTitle(title: String){
        self.titleString = title
        self.titleLabel.addText(self.titleString!)
    }
    
    func addTime(time: Double){
        self.titleLabel.addTime(time)
    }
    
    //MARK: VIDEO CONTROL FUNCTIONS
    
    func play(sender: AnyObject?){
        if let player = mPlayer {
            player.seekToTime(kCMTimeZero)
            player.play()
            isPaused = false
            //viewCommunicationsDelegate?.vpIsPlaying(self, isPlaying: true)
        }
    }
    
    func pause(sender: AnyObject?){
        if let player = mPlayer {
            player.pause()
            isPaused = true
            //viewCommunicationsDelegate?.vpIsPlaying(self, isPlaying: false)
        }
    }
    
    func hideScrubberAndTitle(){
        if !isPaused {
            self.scrubberAndTitle(false)
        }
    }
    
    func playAtTime(startTime: Double){
        self.startTime = startTime
        
        if let player = mPlayer{
            
            //kill the old observer if there is one
            let seekTime = CMTimeMakeWithSeconds(startTime, Int32(NSEC_PER_SEC))
            player.seekToTime(seekTime) { (finished) -> Void in
                print("playing clip from \(startTime)")
                self.play(nil)
            }
        }
        
    }
    
    func resetTimer(scrubber: Scrubber){
        if let goodTimer = self.scrubTimer {
            goodTimer.invalidate()
            self.scrubTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(VideoViewController.hideScrubberAndTitle), userInfo: nil, repeats: false)
        }
    }
    
    func playAtDelta(sender: AnyObject?, delta time: NSTimeInterval){
        if let player = mPlayer {
            let timeNow  = player.currentTime()
            let timeNext = CMTimeMakeWithSeconds(time, 1)
            let timeGoTo = CMTimeAdd(timeNow, timeNext)
            
            player.seekToTime(timeGoTo) { (finished) -> Void in
                self.play(nil)
            }
        }
    }
    
    
    func rw15(){
        playAtDelta(nil, delta: -15.0)
    }
    
    func ff15(){
        playAtDelta(nil, delta: 15.0)
    }
    
    
    func playClip(startTime: Double, endTime: Double){
        self.startTime = startTime
        
        if let player = mPlayer{
            
            //kill the old observer if there is one
            if self.timeClipObserver != nil{
                player.removeTimeObserver(self.timeClipObserver!)
                timeClipObserver = nil
            }
            
            let seekTime = CMTimeMakeWithSeconds(startTime, Int32(NSEC_PER_SEC))
            player.seekToTime(seekTime) { (finished) -> Void in
                print("playing clip from \(startTime) to \(endTime)")
                self.play(nil)
            }
            
            timeClipObserver = player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC)), queue: nil, usingBlock: { (time: CMTime) -> Void in
                let evalTime = Double(player.currentTime().value) / Double(player.currentTime().timescale)
                if evalTime >= endTime {
                    self.pause(nil)
                }
                
            })
            
        }
        
    }
    
    func scrubberAndTitle(on: Bool){
        if on {
            UIView.animateWithDuration(1.0) { () -> Void in
                self.mScrubber.showSelf()
                self.titleLabel.appear(true)
            }
            
            self.scrubTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(VideoViewController.hideScrubberAndTitle), userInfo: nil, repeats: false)
            
        } else {
            UIView.animateWithDuration(1.0) { () -> Void in
                self.mScrubber.hideSelf()
                self.titleLabel.appear(false)
            }
            
            if self.scrubTimer != nil {
                self.scrubTimer!.invalidate()
                self.scrubTimer = nil
            }
        }
    }
    
    //MARK: Scrubber Delegate Methods
    func scrubberPlayReleased() {
        self.play(self)
        syncPlayPauseButtons()
    }
    
    func scrubberPauseReleased() {
        self.pause(self)
        syncPlayPauseButtons()
    }

    
    func prepareForDeletion(){
        //this dispatch thing took me forever to figure out.
        dispatch_async(dispatch_get_main_queue()) {
            
            self.garbageCollection()
            
            if self.videoView != nil {
                self.videoView = nil
            }
            if self.mPlayer != nil {
                //self.mPlayer!.pause()
                self.mPlayer = nil
            }
            if self.mPlayerLayer != nil {
                self.mPlayerLayer!.removeFromSuperlayer()
                self.mPlayerLayer = nil
            }
            if self.asset != nil {
                self.asset = nil
            }
            if self.hwPlayerItem != nil {
                self.hwPlayerItem = nil
            }
            self.titleLabel.text = ""
            self.titleString = nil
        }
        
        
    }
    
    func garbageCollection(){
        removePlayerTimeObserver()
        if self.timeClipObserver != nil && self.mPlayer != nil {
            self.mPlayer!.removeTimeObserver(self.timeClipObserver!)
            timeClipObserver = nil
        }
        if VideoControllerLikelyToKeepUpFlag {
            self.mPlayer?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            VideoControllerLikelyToKeepUpFlag = false
        }
        if VideoControllerRateFlag {
            self.mPlayer?.removeObserver(self, forKeyPath: "rate")
            VideoControllerRateFlag = false
        }
        if VideoControllerCurrentItemFlag {
            self.mPlayer?.removeObserver(self, forKeyPath: "currentItem")
            VideoControllerCurrentItemFlag = false
        }
        if VideoControllerStatusFlag {
            self.mPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
            VideoControllerStatusFlag = false
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        
        garbageCollection()
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
