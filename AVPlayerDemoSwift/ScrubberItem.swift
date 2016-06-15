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
    var color: CGColorRef
    var lineWidth: CGFloat
    var baseColor: CGColorRef
    var nickname: String
    
    override init(frame: CGRect) {
        baseColor = kScrubWhite.CGColor
        color = baseColor
        lineWidth = 4.0
        nickname = "none"
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        baseColor = kScrubWhite.CGColor
        color = baseColor
        lineWidth = 4.0
        nickname = "none"
        super.init(coder: aDecoder)
        setup()
    }
    
    init(){
        baseColor = kScrubWhite.CGColor
        color = baseColor
        lineWidth = 4.0
        nickname = "none"
        super.init(frame: CGRectZero)
        setup()
    }
    
    init(lineWidth: CGFloat, color: UIColor){
        self.lineWidth = lineWidth
        baseColor = color.CGColor
        self.color = baseColor
        nickname = "none"
        super.init(frame: CGRectZero)
        setup()
    }
    
    func setup(){
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
    }
    
    func highlight(){
        color = hlColor.CGColor
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
        super.init(frame: CGRectZero)
        nickname = "scrubber"
    }
    
    override func drawRect(rect: CGRect) {
        var x = rect.minX + 2.0
        var y = rect.minY
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextBeginPath(ctx)
        CGContextSetStrokeColorWithColor(ctx, color)
        CGContextSetBlendMode(ctx, .SoftLight)
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextSetLineCap(ctx, CGLineCap.Round)
        
        y = rect.midY - lineWidth / 2.0
        CGContextMoveToPoint(ctx, x, y)
        
        x = rect.maxX - 2.0
        CGContextAddLineToPoint(ctx, x, y)
        CGContextStrokePath(ctx)
        
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
        super.init(frame: CGRectZero)
        nickname = "play"
    }
    
    override func drawRect(rect: CGRect) {
        var x     = rect.minX
        var y     = rect.minY
        let width = lineWidth
        let margin = CGSizeMake(rect.width * 0.10, rect.height * 0.10)
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextBeginPath(ctx)
        CGContextSetStrokeColorWithColor(ctx, color)
        CGContextSetBlendMode(ctx, .SoftLight)
        CGContextSetLineJoin(ctx, CGLineJoin.Miter)
        CGContextSetLineWidth(ctx, width)
        
        x += margin.width
        y += margin.height
        CGContextMoveToPoint(ctx, x, y)
        
        y = rect.maxY - margin.height
        CGContextAddLineToPoint(ctx, x, y)
        
        x = rect.maxX - margin.width
        y = rect.midY - width / 2.0
        CGContextAddLineToPoint(ctx, x, y)
        
        x = rect.minX + margin.width
        y = rect.minY + margin.height
        CGContextAddLineToPoint(ctx, x, y)
        CGContextClosePath(ctx)
        
        CGContextDrawPath(ctx, .Stroke)
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
        super.init(frame: CGRectZero)
        nickname = "pause"
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let margin = CGFloat(2.0)
        var x = rect.minX + rect.width / 4.0
        var y = rect.minY + margin
        
        CGContextBeginPath(ctx)
        CGContextSetStrokeColorWithColor(ctx, color)
        CGContextSetBlendMode(ctx, .SoftLight)
        CGContextSetLineCap(ctx, CGLineCap.Round)
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextMoveToPoint(ctx, x, y)
        
        y = rect.maxY - margin
        CGContextAddLineToPoint(ctx, x, y)
        
        y = rect.minY + margin
        x = rect.minX + rect.width * 3.0 / 4.0
        CGContextMoveToPoint(ctx, x, y)
        
        y = rect.maxY - margin
        CGContextAddLineToPoint(ctx, x, y)
        CGContextStrokePath(ctx)
        
    }
    
}

class KleineLinie: ScrubberItem {
    
    override func drawRect(rect: CGRect) {
        let x = rect.midX - lineWidth / 2.0
        var y = rect.minY + 1.0
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextBeginPath(ctx)
        CGContextSetStrokeColorWithColor(ctx, color)
        CGContextSetBlendMode(ctx, .SoftLight)
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextMoveToPoint(ctx, x, y)
        y = rect.maxY - 1.0
        CGContextAddLineToPoint(ctx, x, y)
        CGContextStrokePath(ctx)
    }
    
    
}


