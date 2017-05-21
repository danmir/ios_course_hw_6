//
//  URLSessionTaskOperation.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 19.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

private var URLSessionTaskOperationKVOContext = 0

class URLSessionTaskOperation: AsyncOperation {
    let task: URLSessionTask
    
    fileprivate var observerRemoved = false
    fileprivate let stateLock = NSLock()
    
    init(task: URLSessionTask) {
        self.task = task
        super.init()
    }
    
    override func main() {
        task.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions(), context: &URLSessionTaskOperationKVOContext)
        task.resume()
    }
    
    override func didCancel() {
        task.cancel()
        finish()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &URLSessionTaskOperationKVOContext else { return }
        guard let object = object else { return }
        
        stateLock.withCriticalScope {
            if object as AnyObject === task && keyPath == "state" && !observerRemoved {
                switch task.state {
                case .completed:
                    finish()
                    fallthrough
                case .canceling:
                    observerRemoved = true
                    task.removeObserver(self, forKeyPath: "state")
                default:
                    return
                }
            }
        }
    }
    
}
