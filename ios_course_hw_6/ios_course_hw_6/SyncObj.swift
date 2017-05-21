//
//  SyncObj.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 20.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

class SyncObj {
    enum State: Int {
        case New
        case Sucsess
        case Failed
        case Cancelled
    }
    
    static let shared = SyncObj()
    
    var networkTries = 0
    
    var state = State.New
    var errors = [Error]()
    var lastError: Error?
    
    func add(error: Error) {
        errors.append(error)
        lastError = error
    }
    
    func resetState() {
        lastError = nil
        errors = [Error]()
        state = .New
    }
}
