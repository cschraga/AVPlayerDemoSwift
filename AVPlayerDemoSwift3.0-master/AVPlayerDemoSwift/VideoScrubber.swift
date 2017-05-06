//
//  Scrubber.swift
//  HWCarousel
//
//  Created by Christian Schraga on 1/26/16.
//  Copyright © 2016 Straight Edge Digital. All rights reserved.
//

import UIKit

protocol ScrubberDelegate {
    func scrubberPlayReleased()
    func scrubberPauseReleased()
    func beginScrubbing(_ scrubber: Scrubber)
    func scrub(_ scrubber: Scrubber)
    func endScrubbing(_ scrubber: Scrubber)
    func resetTimer(_ scrubber: Scrubber)
}

class Scrubber: UIView {
    
    //Subviews
    var bgLine: ScrubberBGView!
    var playButton: PlayButtonView!
    var pauseButton: PauseButtonView!
    var ccButton: UIImageView!
    var scrubIcon: KleineLinie!
    var timeLabel: UILabel!
    
    //Aesthetics
    var color: UIColor
    var lineWidth: CGFloat
    var landscape: Bool = false
    
    //delegate
    var delegate: ScrubberDelegate?
    
    //Placement of Scrub Indicator
    var minimumValue = Double(0.0)
    var maximumValue = Double(0.0)
    var value = Double(0.0)
    
    //colors
    let kScrubWhite = UIColor(white: 1.0, alpha: 0.667)
    var hlColor   = UIColor(red: 240/255, green: 255/255, blue: 142/2455, alpha: 0.35)
    
    //Play / Pause Condition
    var playTruePauseFalse = true {
        didSet{
            drawUI()
            print((playTruePauseFalse) ? "play button now showing" : "pause button now showing")
        }
    }
    
    override init(frame: CGRect) {
        color = UIColor.white
        lineWidth = 4.0
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        color = UIColor.white
        lineWidth = 4.0
        super.init(coder: aDecoder)
        setup()
    }
    
    init(){
        color = UIColor.white
        lineWidth = 4.0
        super.init(frame: CGRect.zero)
        setup()
    }
    
    init(lineWidth: CGFloat, color: UIColor){
        self.lineWidth = lineWidth
        self.color = color
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup(){
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clear
        playButton = PlayButtonView(lineWidth: lineWidth, color: kScrubWhite)
        pauseButton = PauseButtonView(lineWidth: lineWidth, color: kScrubWhite)
        bgLine = ScrubberBGView(lineWidth: lineWidth, color: kScrubWhite)
        ccButton = UIImageView(image: UIImage(named: "cc"))
        ccButton.isUserInteractionEnabled = true
        ccButton.contentMode = .scaleAspectFit
        ccButton.image = ccButton.image?.withRenderingMode(.alwaysTemplate)
        ccButton.tintColor = kScrubWhite
        ccButton.tag = 63
        scrubIcon = KleineLinie(lineWidth: lineWidth * 0.80, color: color)
        timeLabel = UILabel()
        timeLabel.text = "00:00"
        timeLabel.textColor = kScrubWhite
        timeLabel.backgroundColor = UIColor.clear
        timeLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12.0)
        timeLabel.textAlignment = .center
        self.addSubview(scrubIcon)
        self.addSubview(playButton)
        self.addSubview(pauseButton)
        self.addSubview(bgLine)
        //self.addSubview(ccButton)
        self.addSubview(timeLabel)
        pauseButton.alpha = 0.0
        
        //add gesture recognizers to each contro
        let pan = UIPanGestureRecognizer(target: self, action: #selector(Scrubber.handlePan(_:)))
        self.addGestureRecognizer(pan)
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(Scrubber.handlePress(_:)))
        press.minimumPressDuration = 0.01
        press.allowableMovement = 5000.0
        press.require(toFail: pan)
        playButton.addGestureRecognizer(press)
        pauseButton.addGestureRecognizer(press)
        ccButton.addGestureRecognizer(press)
    }
    
    override func layoutSubviews() {
        drawUI()
    }
    
    func hideSelf(){
        self.alpha = 0.0
        print("hiding scrubber")
    }
    
    func showSelf(){
        print("showing scrubber")
        self.alpha = 1.0
    }
    
    func newFile(_ duration: Double, startTime: Double?){
        if startTime != nil {
            self.minimumValue = startTime!
        } else {
            self.minimumValue = 0.0
        }
        
        self.maximumValue = self.minimumValue + duration
        
        self.value = self.minimumValue
        setSliderValue(self.value)
    }
    
    func setSliderValue(_ value: Double){
        self.value = (value < maximumValue) ? ((value > minimumValue) ? value : minimumValue) : maximumValue
        let goalX = (maximumValue > 0) ? bgLine.frame.minX + CGFloat(value) / CGFloat(maximumValue) * bgLine.frame.width : 0.0
        self.scrubIcon.center.x = goalX
        self.timeLabel.center.x = goalX
        self.timeLabel.text = self.convertSecondsToStringNoHours(self.value)
    }
    
    func drawUI(){
        let margin = CGSize(width: self.bounds.width * 0.05, height: self.bounds.height * 0.10)
        var width = self.bounds.width - margin.width * 4.0
        var height = CGFloat(10.0)
        var x = self.bounds.minX + 2.0 * margin.width
        var y = self.bounds.midY - lineWidth / 2.0
        bgLine.frame = CGRect(x: x,y: y,width: width,height: height)
        
        width = CGFloat(35.0)
        height = width
        x = self.bounds.midX - width / 2.0
        y = bgLine.frame.maxY + margin.height
        ccButton.frame = CGRect(x: x,y: y,width: width,height: height)
        
        width  = bgLine.bounds.width * 0.20
        height = lineWidth * 4
        y = self.bounds.midY - height / 2.0
        x = self.bounds.midX + margin.width
        scrubIcon.frame = CGRect(x: x,y: y,width: width,height: height)
        
        height = width * 9.0 / 16.0
        y = scrubIcon.frame.maxY + 5.0
        timeLabel.frame = CGRect(x: x,y: y,width: width,height: height)
        timeLabel.font  = UIFont(name: "AppleSDGothicNeo-Bold", size: timeLabel.bounds.height * 0.5)
        
        let topArea = scrubIcon.frame.minY - self.bounds.minY
        height = topArea - 3.0 * margin.height
        width = height
        y     = scrubIcon.frame.minY - margin.height - height
        x     = self.bounds.midX - width / 2.0
        
        
        playButton.frame  = CGRect(x: x,y: y,width: width,height: height)
        pauseButton.frame = CGRect(x: x,y: y,width: width,height: height)
        if playTruePauseFalse {
            playButton.alpha  = 1.0
            pauseButton.alpha = 0.0
        } else {
            playButton.alpha  = 0.0
            pauseButton.alpha = 1.0
        }
        print("scrubber size is \(self.frame)")
        setSliderValue(value)
    }
    
    func handlePan(_ recognizer: UILongPressGestureRecognizer){
        let currentTouch = recognizer.location(in: self)
        
        if recognizer.state == .began {
            timeLabel.textColor = hlColor
            bgLine.highlight()
            scrubIcon.highlight()
            delegate?.beginScrubbing(self)
        } else if recognizer.state == .changed {
            if bgLine.bounds.width > 0 {
                let localX = Double(bgLine.convert(currentTouch, from: self).x)
                let pct    = localX / Double(bgLine.bounds.width)
                setSliderValue(pct * self.maximumValue + self.minimumValue)
            }
            delegate?.scrub(self)
        } else if recognizer.state == .ended {
            timeLabel.textColor = kScrubWhite
            bgLine.lowlight()
            scrubIcon.lowlight()
            delegate?.endScrubbing(self)
            
        }
    }
    
    func handlePress(_ recognizer: UILongPressGestureRecognizer){
        if let sender = recognizer.view {
            if recognizer.state == .began {
                
                if let pauseSender = sender as? PauseButtonView{
                    playTruePauseFalse = true
                    pauseSender.highlight()
                } else if let playSender = sender as? PlayButtonView{
                    playTruePauseFalse = false
                    playSender.highlight()
                } else if let ccSender = sender as? UIImageView{
                    if ccSender.tag == 63 {
                        ccSender.tintColor = hlColor
                    }
                }
                
            } else if recognizer.state == .ended {
                playButton.lowlight()
                pauseButton.lowlight()
                bgLine.lowlight()
                scrubIcon.lowlight()
                timeLabel.textColor = UIColor.white
                print("touch ended")
                
                if let pauseSender = sender as? PauseButtonView{
                    delegate?.scrubberPauseReleased()
                    pauseSender.lowlight()
                } else if let playSender = sender as? PlayButtonView{
                    delegate?.scrubberPlayReleased()
                    playSender.lowlight()
                }
            }
            
        }
        
    }
    
    
    func scrubPct(_ pct: Double){
        setSliderValue(self.value + pct * maximumValue)
    }
    
    func convertSecondsToStringNoHours(_ seconds: Double) -> String {
        var result = "00:00"
        let mins = Int(floor(seconds/60))
        let secs = Int(seconds) - mins * 60
        result = String(format: "%02d:%02d", mins,secs)
        
        return result
    }
    
}

