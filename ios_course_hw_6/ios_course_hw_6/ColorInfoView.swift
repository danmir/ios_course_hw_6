//
//  ColorInfoView.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 01.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

class ColorInfoView: CommonView {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    
    var upperLabelBorder = CALayer()
    
    var color: UIColor? {
        didSet {
           var r = CGFloat(0), g = CGFloat(0), b = CGFloat(0)
            color?.getRed(&r, green: &g, blue: &b, alpha: nil)
            let rgb = Int(r * CGFloat(255)) << 16 | Int(g * CGFloat(255)) << 8 | Int(b * CGFloat(255)) << 0
            colorLabel.text = String(format: "#%06x", rgb)
            colorView.backgroundColor = color
        }
    }

    private let infoViewCornerRadius = CGFloat(5)
    
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = UIColor.clear
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.cornerRadius = infoViewCornerRadius
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        
        clipsToBounds = true
        
        upperLabelBorder.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(upperLabelBorder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        upperLabelBorder.frame = CGRect(x: 0, y: colorView.frame.origin.y + colorView.frame.height, width: colorView.frame.width, height: 1)
    }
}
