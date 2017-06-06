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
    
    func getNotes(complitionHandler: @escaping ([Note]?) -> ()) {
        if DummyNotebookCache.shared.notesCollection.count == 0 {
            updateCache { error in
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
    
    func updateCache(complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.replace)
        
        let apiRequestStatus = APIRequestStatus()
        
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy) {
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
    
    func addNote(note: Note, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.add)
        
        let apiRequestStatus = APIRequestStatus()
        
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy) {
            print("storeCacheHandler after add")
            complitionHandler(apiRequestStatus.lastError)
        }
        storeCacheOperation.taskQOS = .cache
        
        var lastPostNoteOperation: APINotesOperation?
        for _ in 0..<APIManager.shared.maxRetriesCount {
            let postNoteOperation = APINotesOperation(method: .POST, note: note, cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, completeHandler: { error in
                print("postNoteOperationHandler") })
            postNoteOperation.taskQOS = .network
            storeCacheOperation.addDependency(postNoteOperation)
            if let lastPostNoteOperation = lastPostNoteOperation {
                postNoteOperation.addDependency(lastPostNoteOperation)
            }
            lastPostNoteOperation = postNoteOperation
            Dispatcher.shared.addOperation(operation: postNoteOperation)
        }
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
    
    func editNote(note: Note, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.edit)
        
        let apiRequestStatus = APIRequestStatus()
        
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy) {
            print("storeCacheHandler after add")
            complitionHandler(apiRequestStatus.lastError)
        }
        storeCacheOperation.taskQOS = .cache
        
        var lastPutNoteOperation: APINotesOperation?
        for _ in 0..<APIManager.shared.maxRetriesCount {
            let putNoteOperation = APINotesOperation(method: .PUT, note: note, cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, completeHandler: { error in
                print("putNoteOperationHandler") })
            putNoteOperation.taskQOS = .network
            storeCacheOperation.addDependency(putNoteOperation)
            if let lastPutNoteOperation = lastPutNoteOperation {
                putNoteOperation.addDependency(lastPutNoteOperation)
            }
            lastPutNoteOperation = putNoteOperation
            Dispatcher.shared.addOperation(operation: putNoteOperation)
        }
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
    
    func deleteNote(note: Note, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.delete)
        
        let apiRequestStatus = APIRequestStatus()
        
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, apiRequestStatus: apiRequestStatus, cachePolicy: cachePolicy) {
            print("storeCacheHandler after delete")
            complitionHandler(apiRequestStatus.lastError)
        }
        storeCacheOperation.taskQOS = .cache
        
        var lastDeleteNoteOperation: APINotesOperation?
        for _ in 0..<APIManager.shared.maxRetriesCount {
            let deleteNoteOperation = APINotesOperation(method: .DELETE, note: note, cacheFile: cacheFile, apiRequestStatus: apiRequestStatus) { error in
                print("deleteNoteOperationHandler") }
            deleteNoteOperation.taskQOS = .network
            storeCacheOperation.addDependency(deleteNoteOperation)
            if let lastDeleteNoteOperation = lastDeleteNoteOperation {
                deleteNoteOperation.addDependency(lastDeleteNoteOperation)
            }
            lastDeleteNoteOperation = deleteNoteOperation
            Dispatcher.shared.addOperation(operation: deleteNoteOperation)
        }
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
}
