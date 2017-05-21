//
//  ColorMapView.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 01.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

@IBDesignable class ColorMapView: CommonControl {
    private var colorCursor = ColorCursor(withPoint: CGPoint.zero)
    private var tintView = UIView()
    
    @IBInspectable var color: UIColor = UIColor.green {
        didSet {
            self.updateColorCursor()
        }
    }
    var brightness = CGFloat(1) {
        didSet {
            tintView.alpha = 1 - brightness
            self.updateColorCursor()
        }
    }
    
    override func commonInit() {
        backgroundColor = UIColor.white

        updateColorCursor()
        addSubview(colorCursor)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)

        addTintView()
        
        clipsToBounds = true
    }
    
    func addTintView() {
        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.backgroundColor = UIColor.black
        tintView.alpha = 1 - brightness
        
        insertSubview(tintView, at: 0)
        
        NSLayoutConstraint(item: tintView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tintView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tintView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tintView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        GradientHelper.drawGradient(inRect: rect, withContext: context, withBrightness: 1)
        context.stroke(rect, width: CGFloat(2))
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            if sender.numberOfTouches <= 0 {
                return
            }
            let tapPoint = sender.location(ofTouch: 0, in: self)
            update(tapPoint: tapPoint)
        }
    }
    
    func handlePan(_ sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.changed || sender.state == UIGestureRecognizerState.ended {
            if sender.numberOfTouches <= 0 {
                return
            }
        }
        let tapPoint = sender.location(ofTouch: 0, in: self)
        update(tapPoint: tapPoint)
    }
    
    func update(tapPoint: CGPoint) {
        if !CGRect(origin: CGPoint.zero, size: frame.size).contains(tapPoint) {
            return
        }
        let selectedColor = GradientHelper.getColor(inRect: frame, atPoint: tapPoint, withBrightness: brightness)
        color = selectedColor
        sendActions(for: UIControlEvents.valueChanged)
    }
    
    func updateColorCursor() {
        let newPoint = GradientHelper.getPoint(inRect: frame, forColor: color)
        colorCursor.color = color
        colorCursor.center = newPoint
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        updateColorCursor()
    }
}
