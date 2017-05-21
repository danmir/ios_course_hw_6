//
//  colorCursor.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 02.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

class ColorCursor: UIView {
    static let cursorSize = CGSize(width: 28, height: 28)

    var color: UIColor? {
        didSet {
            var h = CGFloat(0), s = CGFloat(0), v = CGFloat(0)
            color?.getHue(&h, saturation: &s, brightness: &v, alpha: nil)
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        //UIColor.black.set()
        //context.setLineWidth(1)
        context.move(to: CGPoint(x: 0, y: rect.midY))
        context.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        context.move(to: CGPoint(x: rect.midX, y: 0))
        context.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        context.addEllipse(in: rect.insetBy(dx: 4, dy: 4))
        context.strokePath()
        
        color?.set()
        context.fillEllipse(in: rect.insetBy(dx: 4, dy: 4))
    }
    
    init(withPoint point: CGPoint) {
        let size = ColorCursor.cursorSize
        let frame = CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
