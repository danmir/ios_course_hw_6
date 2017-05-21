//
//  SchedulerRandomPolicy.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 20.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

class SchedulerRandomPolicy: SchedulerPolicyProtocol {
    let numberOfQueues: Int
    
    required init(numberOfQueues: Int) {
        self.numberOfQueues = numberOfQueues
    }
    
    func next(params: [String: Any]? = nil) -> Int {
        return randomInt(min: 0, max: numberOfQueues - 1)
    }
}
