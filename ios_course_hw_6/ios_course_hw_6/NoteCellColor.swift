//
//  NoteCellColor.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 10.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

class NoteCellColor: UIView {
    var color: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    init(withColor color: UIColor) {
        super.init(frame: CGRect.zero)
        self.color = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: rect.width, y: 0))
        context.addLine(to: CGPoint(x: 0, y: rect.height))
        context.addLine(to: CGPoint(x: 0, y: 0))
        //context.closePath()
        
        color.set()
        context.fillPath()
    }

}
