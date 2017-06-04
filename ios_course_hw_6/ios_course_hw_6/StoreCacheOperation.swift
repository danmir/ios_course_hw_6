//
//  StoreCacheOperation.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 18.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

enum StoreCacheOperationError: Error {
    case parseTmpError
    case openTmpError
}

class StoreCacheOperation: AsyncOperation {
    var complitionHandler: (Void) -> Void
    let cacheFile: URL
    let apiRequestStatus: APIRequestStatus
    let cachePolicy: CachePolicy
    
    init(cacheFile: URL, apiRequestStatus: APIRequestStatus, cachePolicy: CachePolicy, complitionHandler: @escaping (Void) -> Void) {
        self.complitionHandler = complitionHandler
        self.cacheFile = cacheFile
        self.apiRequestStatus = apiRequestStatus
        self.cachePolicy = cachePolicy
        super.init()
    }
    
    override func main() {
        if apiRequestStatus.state == .Failed || apiRequestStatus.state == .Cancelled {
            print("Prev op status \(apiRequestStatus.state). Nothing to do with cache")
            self.complitionHandler()
            self.finish()
            return
        }
        
        do {
            let data = try Data(contentsOf: cacheFile)
            let jsonResult = try JSONSerialization.jsonObject(with: data)
            if let jsonResult = jsonResult as? [[String: Any]] {
                for note in jsonResult {
                    if let note = Note.parse(json: note) {
                        cachePolicyApplier(note: note)
                    }
                }
            } else if let jsonResult = jsonResult as? [String: Any] {
                if let note = Note.parse(json: jsonResult) {
                    cachePolicyApplier(note: note)
                }
            }
        } catch {
            print("Unable to parse")
            apiRequestStatus.state = .Failed
            apiRequestStatus.add(error: StoreCacheOperationError.parseTmpError)
        }
        
        self.complitionHandler()
        self.finish()
    }
    
    func cachePolicyApplier(note: Note) {
        switch cachePolicy.state {
        case .add:
            DummyNotebookCache.shared.addNote(note: note)
        case .delete:
            DummyNotebookCache.shared.removeNote(byUid: note.uid)
        case .replace, .edit:
            DummyNotebookCache.shared.removeNote(byUid: note.uid)
            DummyNotebookCache.shared.addNote(note: note)
        }
    }
    
}
