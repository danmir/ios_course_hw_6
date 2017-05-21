//
//  ColorPickerView.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 01.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

class ColorPickerView: CommonControl {
    static let defaultColor = UIColor.green
    
    @IBOutlet weak var colorInfoView: ColorInfoView!
    @IBOutlet weak var colorMapView: ColorMapView!
    @IBOutlet weak var colorBrightnessSlider: UISlider!
    
    private var currentHSVColor = HSVColor(h: 0, s: 0, v: 1)
    var color: UIColor {
        get {
            return UIColor(hue: currentHSVColor.h, saturation: currentHSVColor.s, brightness: currentHSVColor.v, alpha: 1)
        }
        set(color) {
            color.getHue(&currentHSVColor.h, saturation: &currentHSVColor.s, brightness: &currentHSVColor.v, alpha: nil)
            
            colorMapView.color = color
            colorMapView.brightness = currentHSVColor.v
            
            colorInfoView.color = color
            
            sendActions(for: UIControlEvents.valueChanged)
        }
    }
    
    override func commonInit() {
        super.commonInit()
        clipsToBounds = true
        
        color = ColorPickerView.defaultColor
        
        colorBrightnessSlider.addTarget(self, action: #selector(brightnessChanged), for: UIControlEvents.valueChanged)
        colorBrightnessSlider.value = 1
        
        colorMapView.addTarget(self, action: #selector(colorMapColorChanged(_:)), for: UIControlEvents.valueChanged)
        
        //colorMapView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func brightnessChanged(_ sender: UISlider) {
        currentHSVColor.v = CGFloat(sender.value)
        colorMapView.brightness = currentHSVColor.v
        colorMapView.color = color
        colorInfoView.color = color
        
        sendActions(for: UIControlEvents.valueChanged)
    }
    
    func colorMapColorChanged(_ sender: ColorMapView) {
        sender.color.getHue(&currentHSVColor.h, saturation: &currentHSVColor.s, brightness: &currentHSVColor.v, alpha: nil)
        colorInfoView.color = color
        
        sendActions(for: UIControlEvents.valueChanged)
    }

}
