//
//  HWVideoTitleLabel.swift
//  Hardwire2.0
//
//  Created by Christian Schraga on 5/5/16.
//  Copyright © 2016 Straight Edge Digital. All rights reserved.
//

import UIKit

class VideoTitleLabel: UIView {

    var titleLabel: UILabel!
    var timeLabel: UILabel!
    var text: String = ""
    var time: Double = 0.0
    var padding: CGSize!
    var fontMultiplier: CGFloat!
    var visible = true
    var fullAlpha: CGFloat = 0.80
    var fontName = "AppleSDGothicNeo-Bold"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func appear(_ visible: Bool){
        self.visible = visible
        self.alpha = visible ? fullAlpha : 0.0
    }
    
    func addText(_ text: String){
        self.text = text
        titleLabel.text = text
    }
    
    func addTime(_ seconds: Double){
        self.time = seconds
        self.timeLabel.text = "Length: \(self.convertSecondsToString(seconds))"
    }
    
    func convertSecondsToString(_ seconds: Double) -> String {
        var result = "00:00:00"
        let hours = Int(floor(seconds/3600))
        let mins = (Int(seconds) - hours * 3600) / 60
        let secs = Int(seconds) - hours * 3600 - mins * 60
        result = String(format: "%02d:%02d:%02d", hours, mins,secs)
        
        return result
    }

    
    func drawUI(){
        self.backgroundColor = UIColor.clear
        
        fontMultiplier = 0.75
        
        padding.width = self.bounds.width * 0.05
        padding.height = self.bounds.height * 0.05
        
        let x = padding.width
        var y = padding.height
        let w = self.bounds.width - 2.0 * padding.width
        var h = self.bounds.height * 0.50
        titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        titleLabel.font = UIFont(name: fontName, size: h * fontMultiplier)
        titleLabel.textAlignment = .center
        
        y = titleLabel.frame.maxY
        h = self.bounds.height * 0.33
        timeLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        timeLabel.font = UIFont(name: fontName, size: h * fontMultiplier)
        timeLabel.textAlignment = .center
        
    }
    
    override func layoutSubviews() {
        drawUI()
    }
    
    func setup(){
        self.backgroundColor = UIColor.black
        self.alpha = fullAlpha
        self.clipsToBounds = true
        
        titleLabel = UILabel()
        titleLabel.clipsToBounds = true
        titleLabel.textColor = UIColor.white
        titleLabel.text = text
        self.addSubview(titleLabel)
        
        timeLabel = UILabel()
        timeLabel.clipsToBounds = true
        timeLabel.textColor = UIColor.white
        timeLabel.text = text
        self.addSubview(timeLabel)
        
        padding = CGSize(width: 5.0, height: 5.0)
        
        fontMultiplier = 0.6667
    }

}
