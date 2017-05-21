//
//  Note.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 09.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import UIKit

struct Note {
    let uid: String
    let title: String
    let content: String
    let color: UIColor
    let expireDate: Date?
    
    init(title: String, content: String,
         color: UIColor = UIColor.white, uid: String = UUID().uuidString, expireDate: Date? = nil) {
        self.uid = uid
        self.title = title
        self.content = content
        self.expireDate = expireDate
        self.color = color
    }
    
    static func generateNote(withTitleLen titleLen: Int, contentLen: Int) -> Note {
        let title = randomString(length: titleLen)
        let content = randomString(length: contentLen)
        let color = randomColor()
        return Note(title: title, content: content, color: color)
    }
}

extension Note {
    static func parse(json: [String: Any]) -> Note? {
        guard let uid = json["uid"] as? String,
            let title = json["title"] as? String,
            let content = json["content"] as? String
            else {
                return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        var expireDate: Date? = nil
        if let expireDateInt = json["destroy_date"] as? Int {
            expireDate = Date(timeIntervalSince1970: TimeInterval(expireDateInt))
        }
        
        if let colorString = json["color"] as? String,
            let color = UIColor(hexString: colorString) {
            return Note(title: title, content: content, color: color, uid: uid, expireDate: expireDate)
        }
        
        return Note(title: title, content: content, uid: uid, expireDate: expireDate)
    }
    
    var json: [String: Any] {
        var res: [String: Any] = [:]
        res["uid"] = uid
        res["title"] = title
        res["content"] = content
        
        if color != UIColor.white {
            res["color"] = color.toHexString()
        }
        
        if let expireDate = expireDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            res["destroy_date"] = dateFormatter.string(from: expireDate)
        }
        
        return res
    }
}

extension UIColor {
    convenience init?(hexString: String) {
        do {
            let regex = try NSRegularExpression(pattern: "#[a-fA-F0-9]{6}")
            let results = regex.matches(in: hexString, range: NSRange(location: 0, length: hexString.characters.count))
            if results.count == 0 { return nil }
        } catch { return nil }
        
        let scanner = Scanner(string: hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        if !scanner.scanHexInt32(&color) { return nil }
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return NSString(format:"#%06x", rgb) as String
    }
}

extension UIColor {
    func isEqualWithConversion(_ color: UIColor) -> Bool {
        guard let space = cgColor.colorSpace else {
            return false
        }
        guard let converted = color.cgColor.converted(to: space, intent: .absoluteColorimetric, options: nil) else {
            return false
        }
        return cgColor == converted
    }
}



