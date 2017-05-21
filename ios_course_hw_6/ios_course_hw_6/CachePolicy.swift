//
//  CachePolicy.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 20.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

enum CachePolicies: Int {
    case add
    case delete
    case replace
    case edit
}

class CachePolicy {
    let state: CachePolicies
    
    init(withPolicy policy: CachePolicies) {
        self.state = policy
    }
}
