//
//  HWScrubberItem.swift
//  HWCarousel
//
//  Created by Christian Schraga on 1/26/16.
//  Copyright © 2016 Straight Edge Digital. All rights reserved.
//

import UIKit

class ScrubberItem: UIView {
    var hlColor   = UIColor(red: 240/255, green: 255/255, blue: 142/2455, alpha: 0.35)
    let kScrubWhite = UIColor(white: 1.0, alpha: 0.667)
    var color: CGColor
    var lineWidth: CGFloat
    var baseColor: CGColor
    var nickname: String
    
    override init(frame: CGRect) {
        baseColor = kScrubWhite.cgColor
        color = baseColor
        lineWidth = 4.0
        nickname = "none"
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        baseColor = kScrubWhite.cgColor
        color = baseColor
        lineWidth = 4.0
        nickname = "none"
        super.init(coder: aDecoder)
        setup()
    }
    
    init(){
        baseColor = kScrubWhite.cgColor
        color = baseColor
        lineWidth = 4.0
        nickname = "none"
        super.init(frame: CGRect.zero)
        setup()
    }
    
    init(lineWidth: CGFloat, color: UIColor){
        self.lineWidth = lineWidth
        baseColor = color.cgColor
        self.color = baseColor
        nickname = "none"
        super.init(frame: CGRect.zero)
        setup()
    }
    
    func setup(){
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
    }
    
    func highlight(){
        color = hlColor.cgColor
        setNeedsDisplay()
    }
    
    func lowlight(){
        color = baseColor
        setNeedsDisplay()
    }
    
    //override draw rect in subclasses
    
}

class ScrubberBGView: ScrubberItem {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nickname = "scrubber"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nickname = "scrubber"
    }
    
    override init(){
        super.init()
        nickname = "scrubber"
    }
    
    override init(lineWidth: CGFloat, color: UIColor){
        super.init(frame: CGRect.zero)
        nickname = "scrubber"
    }
    
    override func draw(_ rect: CGRect) {
        var x = rect.minX + 2.0
        var y = rect.minY
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.beginPath()
        ctx?.setStrokeColor(color)
        ctx?.setBlendMode(.softLight)
        ctx?.setLineWidth(lineWidth)
        ctx?.setLineCap(CGLineCap.round)
        
        y = rect.midY - lineWidth / 2.0
        ctx?.move(to: CGPoint(x: x, y: y))
        
        x = rect.maxX - 2.0
        ctx?.addLine(to: CGPoint(x: x, y: y))
        ctx?.strokePath()
        
    }
}

class PlayButtonView: ScrubberItem {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nickname = "play"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nickname = "play"
    }
    
    override init(){
        super.init()
        nickname = "play"
    }
    
    override init(lineWidth: CGFloat, color: UIColor){
        super.init(frame: CGRect.zero)
        nickname = "play"
    }
    
    override func draw(_ rect: CGRect) {
        var x     = rect.minX
        var y     = rect.minY
        let width = lineWidth
        let margin = CGSize(width: rect.width * 0.10, height: rect.height * 0.10)
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.beginPath()
        ctx?.setStrokeColor(color)
        ctx?.setBlendMode(.softLight)
        ctx?.setLineJoin(CGLineJoin.miter)
        ctx?.setLineWidth(width)
        
        x += margin.width
        y += margin.height
        ctx?.move(to: CGPoint(x: x, y: y))
        
        y = rect.maxY - margin.height
        ctx?.addLine(to: CGPoint(x: x, y: y))
        
        x = rect.maxX - margin.width
        y = rect.midY - width / 2.0
        ctx?.addLine(to: CGPoint(x: x, y: y))
        
        x = rect.minX + margin.width
        y = rect.minY + margin.height
        ctx?.addLine(to: CGPoint(x: x, y: y))
        ctx?.closePath()
        
        ctx?.drawPath(using: .stroke)
    }
    
    
}


class PauseButtonView: ScrubberItem {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nickname = "pause"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nickname = "pause"
    }
    
    override init(){
        super.init()
        nickname = "pause"
    }
    
    override init(lineWidth: CGFloat, color: UIColor){
        super.init(frame: CGRect.zero)
        nickname = "pause"
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let margin = CGFloat(2.0)
        var x = rect.minX + rect.width / 4.0
        var y = rect.minY + margin
        
        ctx?.beginPath()
        ctx?.setStrokeColor(color)
        ctx?.setBlendMode(.softLight)
        ctx?.setLineCap(CGLineCap.round)
        ctx?.setLineWidth(lineWidth)
        ctx?.move(to: CGPoint(x: x, y: y))
        
        y = rect.maxY - margin
        ctx?.addLine(to: CGPoint(x: x, y: y))
        
        y = rect.minY + margin
        x = rect.minX + rect.width * 3.0 / 4.0
        ctx?.move(to: CGPoint(x: x, y: y))
        
        y = rect.maxY - margin
        ctx?.addLine(to: CGPoint(x: x, y: y))
        ctx?.strokePath()
        
    }
    
}

class KleineLinie: ScrubberItem {
    
    override func draw(_ rect: CGRect) {
        let x = rect.midX - lineWidth / 2.0
        var y = rect.minY + 1.0
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.beginPath()
        ctx?.setStrokeColor(color)
        ctx?.setBlendMode(.softLight)
        ctx?.setLineWidth(lineWidth)
        ctx?.move(to: CGPoint(x: x, y: y))
        y = rect.maxY - 1.0
        ctx?.addLine(to: CGPoint(x: x, y: y))
        ctx?.strokePath()
    }
    
    
}


