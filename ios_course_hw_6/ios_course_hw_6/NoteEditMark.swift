//
//  NoteEditMark.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 11.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

@IBDesignable class NoteEditMark: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = UIColor.red
        alpha = 0
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let circleRect = rect.insetBy(dx: 20, dy: 20)
        let radius = min(circleRect.width / 2, circleRect.height / 2)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: circleRect.midX, y: circleRect.midY), radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        context.addPath(circlePath.cgPath)
        
        context.move(to: CGPoint(x: circleRect.midX + radius / 2, y: circleRect.midY - radius / 2))
        context.addLine(to: CGPoint(x: circleRect.midX - radius / 2, y: circleRect.midY + radius / 2))
        context.move(to: CGPoint(x: circleRect.midX - radius / 2, y: circleRect.midY - radius / 2))
        context.addLine(to: CGPoint(x: circleRect.midX + radius / 2, y: circleRect.midY + radius / 2))
        
        context.setLineWidth(5)
        context.strokePath()
    }

}
