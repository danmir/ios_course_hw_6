//
//  RetryOperation.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 22.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

class RetryOperation: AsyncOperation {
    let complitionHandler: (Void) -> Void
    let apiRequestStatus: APIRequestStatus
    
    init(apiRequestStatus: APIRequestStatus, complitionHandler: @escaping (Void) -> Void) {
        self.complitionHandler = complitionHandler
        self.apiRequestStatus = apiRequestStatus
        super.init()
    }
    
    override func main() {
        print("RetryOperation deps \(dependencies)")
//        if self.syncObj.state != .Failed && self.syncObj.state != .Cancelled {
//            finish()
//            return
//        }
        complitionHandler()
        finish()
    }
    
}
