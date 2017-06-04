//
//  Date+Interval.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 05.06.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

extension Date {
    var secondsSince1970: Int {
        return Int(self.timeIntervalSince1970)
    }
    
    init(seconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    
    init(seconds: String) {
        self = Date(timeIntervalSince1970: TimeInterval(Int(seconds)!))
    }
}
