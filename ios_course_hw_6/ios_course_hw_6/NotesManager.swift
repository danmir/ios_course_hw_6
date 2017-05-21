//
//  NotesManager.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 18.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

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
    
    func updateOperations(cacheFile: URL, syncObj: SyncObj, cachePolicy: CachePolicy) ->
        (getNotesOperation: APINotesOperation, storeCacheOperation: StoreCacheOperation) {
            let getNotesOperation = APINotesOperation(method: .GET, cacheFile: cacheFile, syncObj: syncObj) { error in
                print("getNotesOperationHandler")
            }
            let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, syncObj: syncObj, cachePolicy: cachePolicy) {
                print("storeCacheHandler after get")
            }
            getNotesOperation.taskQOS = .network
            storeCacheOperation.taskQOS = .cache
            storeCacheOperation.addDependency(getNotesOperation)
            return (getNotesOperation, storeCacheOperation)
    }
    
    func updateCache(complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.replace)
        
        let syncObj = SyncObj()
        
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, syncObj: syncObj, cachePolicy: cachePolicy) {
            print("storeCacheHandler after get")
            complitionHandler(syncObj.lastError)
        }
        storeCacheOperation.taskQOS = .cache

        var lastGetNotesOperation: APINotesOperation?
        for _ in 0..<APIManager.shared.maxRetriesCount {
            let getNotesOperation = APINotesOperation(method: .GET, cacheFile: cacheFile, syncObj: syncObj) { error in
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
        
        let syncObj = SyncObj()
        
        let postNoteOperation = APINotesOperation(method: .POST, note: note, cacheFile: cacheFile, syncObj: syncObj, completeHandler: { error in print("postNoteOperationHandler") })
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, syncObj: syncObj, cachePolicy: cachePolicy) {
            print("storeCacheHandler after add")
            complitionHandler(syncObj.lastError)
        }
        
        storeCacheOperation.addDependency(postNoteOperation)
        
        postNoteOperation.taskQOS = .network
        storeCacheOperation.taskQOS = .cache
        Dispatcher.shared.addOperation(operation: postNoteOperation)
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
    
    func editNote(note: Note, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.edit)
        
        let syncObj = SyncObj()
        
        let putNoteOperation = APINotesOperation(method: .PUT, note: note, cacheFile: cacheFile, syncObj: syncObj, completeHandler: { error in print("putNoteOperationHandler") })
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, syncObj: syncObj, cachePolicy: cachePolicy) {
            print("storeCacheHandler after add")
            complitionHandler(syncObj.lastError)
        }
        
        storeCacheOperation.addDependency(putNoteOperation)
        
        putNoteOperation.taskQOS = .network
        storeCacheOperation.taskQOS = .cache
        Dispatcher.shared.addOperation(operation: putNoteOperation)
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
    
    func deleteNote(note: Note, complitionHandler: @escaping (Error?) -> ()) {
        let cacheFile = getCacheFile()
        let cachePolicy = CachePolicy(withPolicy: CachePolicies.delete)
        
        let syncObj = SyncObj()
        
        let deleteNoteOperation = APINotesOperation(method: .DELETE, note: note, cacheFile: cacheFile, syncObj: syncObj) { error in print("deleteNoteOperationHandler") }
        let storeCacheOperation = StoreCacheOperation(cacheFile: cacheFile, syncObj: syncObj, cachePolicy: cachePolicy) {
            print("storeCacheHandler after delete")
            complitionHandler(syncObj.lastError)
        }
        
        storeCacheOperation.addDependency(deleteNoteOperation)
        
        deleteNoteOperation.taskQOS = .network
        storeCacheOperation.taskQOS = .cache
        Dispatcher.shared.addOperation(operation: deleteNoteOperation)
        Dispatcher.shared.addOperation(operation: storeCacheOperation)
    }
}
