//
//  SchedulerPolicyProtocol.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 20.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

protocol SchedulerPolicyProtocol {
    init(numberOfQueues: Int)
    func next(params: [String: Any]?) -> Int
}
