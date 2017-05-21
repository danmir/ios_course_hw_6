//
//  Dispatcher.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 20.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

private class DispatcherSetup {
    var schedulerPolicy: SchedulerPolicyProtocol?
}

class Dispatcher {
    static let shared = Dispatcher()
    private static let setup = DispatcherSetup()
    
    class func setup(schedulerPolicy: SchedulerPolicyProtocol) {
        Dispatcher.setup.schedulerPolicy = schedulerPolicy
    }
    
    static let queuesCount = 4
    let queuesNum = ["cacheQueue", "networkQueue", "userInteractiveQueue", "utilityQueue"]
    let queues = ["cacheQueue": OperationQueue(), "networkQueue": OperationQueue() ,
                  "userInteractiveQueue": OperationQueue(), "utilityQueue": OperationQueue()]
    
    let schedulerPolicy: SchedulerPolicyProtocol
    
    private init() {
        guard let schedulerPolicy = Dispatcher.setup.schedulerPolicy else {
            fatalError("Setup Scheduler Policy first")
        }
        self.schedulerPolicy = schedulerPolicy
    }
    
    func addOperation(operation: Operation) {
        if let op = operation as? AsyncOperation {
            print("AsyncOperation \(op.taskQOS)")
            switch op.taskQOS {
            case .cache:
                if let cacheQueue = queues["cacheQueue"] {
                    cacheQueue.addOperation(op)
                }
            case .network:
                if let networkQueue = queues["networkQueue"] {
                    networkQueue.addOperation(op)
                }
            case .user:
                if let userInteractiveQueue = queues["userInteractiveQueue"] {
                    userInteractiveQueue.addOperation(op)
                }
            case .utility:
                if let utilityQueue = queues["utilityQueue"] {
                    utilityQueue.addOperation(op)
                }
            }
        } else {
            if let utilityQueue = queues["utilityQueue"] {
                utilityQueue.addOperation(operation)
            }
        }
    }
    
    func reSchedule() {
        let nextNum = schedulerPolicy.next(params: nil)
//        print("nextNum \(nextNum)")
        for queueNum in 0..<Dispatcher.queuesCount {
            let queueName = queuesNum[nextNum]
            guard let activeQueue = queues[queueName] else {
                print("No such queue")
                return
            }
            if queueNum == nextNum {
                activeQueue.isSuspended = false
            } else {
                activeQueue.isSuspended = true
            }
        }
    }
}
