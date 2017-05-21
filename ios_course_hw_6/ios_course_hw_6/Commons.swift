//
//  Commons.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 09.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import UIKit

func randomInt(min: Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}

func randomString(length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

func randomColor() -> UIColor {
    let hue : CGFloat = CGFloat(arc4random() % 256) / 256
    let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
    let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5
    
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    
}
