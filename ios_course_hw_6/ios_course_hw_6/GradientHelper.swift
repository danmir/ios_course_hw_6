//
//  GradientHelper.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 05.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import UIKit

class GradientHelper {
    static func drawGradient(inRect rect: CGRect, withContext ctx: CGContext, withBrightness brightness: CGFloat = 1) {
        for y in stride(from: (0 as CGFloat), to: rect.height, by: 1) {
            let saturation = CGFloat(rect.height - y) / rect.height
            for x in stride(from: (0 as CGFloat), to: rect.width, by: 1) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                
                ctx.setFillColor(color.cgColor)
                ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }
    
    static func getColor(inRect rect: CGRect, atPoint point: CGPoint, withBrightness brightness: CGFloat = 1) -> UIColor {
        let saturation = CGFloat(rect.height - point.y) / rect.height
        let hue = point.x / rect.width
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    static func getPoint(inRect rect: CGRect, forColor color: UIColor) -> CGPoint {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0;
        color.getHue(&h, saturation: &s, brightness: &b, alpha: nil);

        return CGPoint(x: h * rect.width, y: rect.height - (CGFloat(s) * rect.height))

    }
}
