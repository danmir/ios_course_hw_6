//
//  NotesManager.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 18.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import CoreData

private let _sharedManager = NotesManager()

class NotesManager {
    class var shared: NotesManager {
        return _sharedManager
    }
    
    func getCachedNotes() -> [Note]? {
        return DummyNotebookCache.shared.notesCollection
    }
    
    func getNotes(context: NSManagedObjectContext, complitionHandler: @escaping ([Note]?) -> ()) {
        if DummyNotebookCache.shared.notesCollection.count == 0 {
            updateCache(context: context) { error in
                if (error != nil) {
                    complitionHandler(nil)
                }
                complitionHandler(DummyNotebookCache.shared.notesCollection)
            }
        } else {
            complitionHandler(DummyNotebookCache.shared.notesCollection)
        }
    }
    
    func getCacheFile(withName name: String? = nil) -> URL {
        let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let cacheFileName = name ?? randomString(length: 10)
        return cachesFolder.appendingPathComponent(cacheFileName)
    }
    
//    func updateOperations(cacheFile: URL, apiRequestStatus: APIRequestStatus, cachePolicy: CachePolicy) ->
//        (getNotesOperation: APINotesOperation, storeCacheOperation: StoreCacheOperation) {
//            let getNotesOperation = APINotesOperation(method: .GET, cacheFile: cacheFile, apiRequestStatus: apiRequestStatus) { error in
//                print("getNotesOperationHandler")
//            }
//            let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy) {
//                print("storeCacheHandler after get")
//            }
//            getNotesOperation.taskQOS = .network
//            storeCacheOperation.taskQOS = .cache
//            storeCacheOperation.addDependency(getNotesOperation)
//            return (getNotesOperation, storeCacheOperation)
//    }
    
    func updateCache(context: NSManagedObjectContext, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.replace)
        
        let apiRequestStatus = APIRequestStatus()
        
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy, context: context) {
            print("storeCacheHandler after get")
            complitionHandler(apiRequestStatus.lastError)
        }
        storeCacheOperation.taskQOS = .cache

        var lastGetNotesOperation: APINotesOperation?
        for _ in 0..<APIManager.shared.maxRetriesCount {
            let getNotesOperation = APINotesOperation(method: .GET, cacheFile: cacheFile, apiRequestStatus: apiRequestStatus) { error in
                print("getNotesOperationHandler")
            }
            getNotesOperation.taskQOS = .network
            storeCacheOperation.addDependency(getNotesOperation)
            if let lastGetNotesOperation = lastGetNotesOperation {
                getNotesOperation.addDependency(lastGetNotesOperation)
            }
            lastGetNotesOperation = getNotesOperation
            Dispatcher.shared.addOperation(operation: getNotesOperation)
        }
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
    
    func addNote(context: NSManagedObjectContext, note: Note, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.add)
        
        let apiRequestStatus = APIRequestStatus()
        
        let postNoteOperation = APINotesOperation(method: .POST, note: note, cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, completeHandler: { error in print("postNoteOperationHandler") })
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy, context: context) {
            print("storeCacheHandler after add")
            complitionHandler(apiRequestStatus.lastError)
        }
        
        storeCacheOperation.addDependency(postNoteOperation)
        
        postNoteOperation.taskQOS = .network
        storeCacheOperation.taskQOS = .cache
        Dispatcher.shared.addOperation(operation: postNoteOperation)
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
    
    func editNote(context: NSManagedObjectContext, note: Note, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.edit)
        
        let apiRequestStatus = APIRequestStatus()
        
        let putNoteOperation = APINotesOperation(method: .PUT, note: note, cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, completeHandler: { error in print("putNoteOperationHandler") })
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy, context: context) {
            print("storeCacheHandler after add")
            complitionHandler(apiRequestStatus.lastError)
        }
        
        storeCacheOperation.addDependency(putNoteOperation)
        
        putNoteOperation.taskQOS = .network
        storeCacheOperation.taskQOS = .cache
        Dispatcher.shared.addOperation(operation: putNoteOperation)
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
    
    func deleteNote(context: NSManagedObjectContext, note: Note, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.delete)
        
        let apiRequestStatus = APIRequestStatus()
        
        let deleteNoteOperation = APINotesOperation(method: .DELETE, note: note, cacheFile: cacheFile, apiRequestStatus: apiRequestStatus) { error in print("deleteNoteOperationHandler") }
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy, context: context) {
            print("storeCacheHandler after delete")
            complitionHandler(apiRequestStatus.lastError)
        }
        
        storeCacheOperation.addDependency(deleteNoteOperation)
        
        deleteNoteOperation.taskQOS = .network
        storeCacheOperation.taskQOS = .cache
        Dispatcher.shared.addOperation(operation: deleteNoteOperation)
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
}
