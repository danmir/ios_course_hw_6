//
//  Dispatcher.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 20.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation


class Dispatcher {
    static let shared = Dispatcher()
    
    static let queuesCount = 4
    let cacheQueue = OperationQueue()
    let networkQueue = OperationQueue()
    let userInteractiveQueue = OperationQueue()
    let utilityQueue = OperationQueue()
    
    
    private init() {
        cacheQueue.qualityOfService = .background
        cacheQueue.maxConcurrentOperationCount = 3
        
        networkQueue.qualityOfService = .background
        networkQueue.maxConcurrentOperationCount = 3
        
        userInteractiveQueue.qualityOfService = .userInteractive
        userInteractiveQueue.maxConcurrentOperationCount = 7
        
        utilityQueue.qualityOfService = .utility
        utilityQueue.maxConcurrentOperationCount = 2
    }
    
    func addOperation(operation: Operation) {
        if let op = operation as? AsyncOperation {
            print("AsyncOperation \(op.taskQOS)")
            switch op.taskQOS {
            case .cache:
                cacheQueue.addOperation(op)
            case .network:
                networkQueue.addOperation(op)
            case .user:
                userInteractiveQueue.addOperation(op)
            case .utility:
                utilityQueue.addOperation(op)
            }
        } else {
            utilityQueue.addOperation(operation)
        }
    }
}
