//
//  AsyncOperation.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 18.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    @objc enum State: Int {
        case isReady
        case isExecuting
        case isFinished
        
        func canTransition(toState state: State) -> Bool {
            switch (self, state) {
            case (.isReady, .isExecuting):
                return true
            case (.isReady, .isFinished):
                return true
            case (.isExecuting, .isFinished):
                return true
            default:
                return false
            }
        }
    }
    
    enum QOS {
        case cache
        case network
        case user
        case utility
    }
    
    // use the KVO mechanism to indicate that changes to `state` affect other properties as well
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return [#keyPath(state) as NSObject]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return [#keyPath(state) as NSObject]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return [#keyPath(state) as NSObject]
    }
    
    // A lock to guard reads and writes to the `_state` property
    private let stateLock = NSRecursiveLock()
    
    private var _state = State.isReady
    var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        set (newState) {
            // Note that the KVO notifications MUST NOT be called from inside the lock. If they were, the app would deadlock.
            willChangeValue(forKey: #keyPath(state))
            
            stateLock.withCriticalScope { Void -> Void in
                guard _state != .isFinished else { return }
                assert(_state.canTransition(toState: newState), "Performing invalid state transition from \(_state) to \(newState).")
                _state = newState
            }
            didChangeValue(forKey: #keyPath(state))
        }
    }
    
    var taskQOS: QOS
    
    override open var isExecuting: Bool {
        return state == .isExecuting
    }
    
    override open var isFinished: Bool {
        return state == .isFinished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    var hasCancelledDependencies: Bool {
        // Return true if this operation has any dependency (parent) operation that is cancelled
        return dependencies.reduce(false) { $0 || $1.isCancelled }
    }
    
    public override init() {
        self.taskQOS = .utility
        super.init()
        addObserver(self, forKeyPath: #keyPath(isCancelled), options: [], context: nil)
    }
    
    // Observing `cancelled` status gives us a chance to react to this status in `didCancel` method if necessary
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(isCancelled) else { return }
        if isCancelled {
            didCancel()
        }
    }
    
    override final public func start() {
        // If any dependency (parent operation) is cancelled, we should also cancel this operation
        if hasCancelledDependencies {
            finish()
            return
        }
        
        if isCancelled {
            finish()
            return
        }
        
        state = .isExecuting
        main()
    }
    
    override func main() {
        fatalError("This method has to be overriden and has to call `finish()` at some point")
    }
    
    func didCancel() {
        finish()
    }
    
    fileprivate func finishWithError(_ error: NSError?) {
        if let error = error {
            finish([error])
        }
        else {
            finish()
        }
    }

    func finish(_ errors: [NSError] = []) {
        state = .isFinished
        finished(errors)
    }

    open func finished(_ errors: [NSError]) {
        // No op.
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(isCancelled))
    }
    
}

//class AsyncOperation: Operation {
//    fileprivate var _executing = false
//    fileprivate var _finished = false
//    
//    override func start() {
//        guard !isCancelled else {
//            finish()
//            return
//        }
//        
//        willChangeValue(forKey: "isExecuting")
//        _executing = true
//        main()
//        didChangeValue(forKey: "isExecuting")
//    }
//    
//    override func main() {
//        // NOTE: should be overriden
//        finish()
//    }
//    
//    fileprivate func finishWithError(_ error: NSError?) {
//        if let error = error {
//            finish([error])
//        }
//        else {
//            finish()
//        }
//    }
//
//    fileprivate func finish(_ errors: [NSError] = []) {
//        willChangeValue(forKey: "isFinished")
//        _finished = true
//        finished(errors)
//        didChangeValue(forKey: "isFinished")
//    }
//
//    /**
//     Subclasses may override `finished(_:)` if they wish to react to the operation
//     finishing with errors.
//     */
//    open func finished(_ errors: [NSError]) {
//        // No op.
//    }
//
//    override var isAsynchronous: Bool {
//        return true
//    }
//    
//    override var isExecuting: Bool {
//        return _executing
//    }
//    
//    override var isFinished: Bool {
//        return _finished
//    }
//}
