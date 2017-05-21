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
    let syncObj: SyncObj
    
    init(syncObj: SyncObj, complitionHandler: @escaping (Void) -> Void) {
        self.complitionHandler = complitionHandler
        self.syncObj = syncObj
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
