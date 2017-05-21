//
//  ColorPreviewItemView.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 29.04.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

@IBDesignable class ColorPreviewItemView: UIView {
    
    @IBInspectable var isChecked = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var isGradient = false
    private var color:UIColor = .red
    
    init(withGradient: Bool) {
        super.init(frame: CGRect.zero)
        self.isGradient = true
    }
    
    init(withColor color: UIColor) {
        super.init(frame: CGRect.zero)
        self.color = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        if isGradient {
            GradientHelper.drawGradient(inRect: rect, withContext: context, withBrightness: 1)
        } else {
            drawSquare(inRect: rect, withContext: context, withColor: color)
        }
        
        context.stroke(rect, width: CGFloat(2))
        if isChecked {
            drawTick(inRect: rect, withContext: context)
        }
    }
    
    func drawSquare(inRect rect: CGRect, withContext ctx: CGContext, withColor color: UIColor) {
        ctx.setFillColor(color.cgColor)
        ctx.setStrokeColor(UIColor.black.cgColor)
        
        let rectangle = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        ctx.fill(rectangle)
        ctx.setLineWidth(3)
        ctx.stroke(rectangle)
    }
    
    func drawTick(inRect rect: CGRect, withContext ctx: CGContext) {
        ctx.setStrokeColor(UIColor.black.cgColor)
        let ovalRect = CGRect(x: 30, y: 1, width: 19, height: 19)
        let ovalPath = UIBezierPath(ovalIn: ovalRect)
        ovalPath.stroke()
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 35, y: 10))
        bezierPath.addLine(to: CGPoint(x: 39, y: 15))
        bezierPath.addLine(to: CGPoint(x: 43, y: 5))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 1.3
        bezierPath.stroke()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 50, height: 50)
    }

}
