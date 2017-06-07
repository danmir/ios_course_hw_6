//
//  StoreCacheOperation.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 18.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum StoreCacheOperationError: Error {
    case parseTmpError
    case openTmpError
}

class StoreCacheOperation: AsyncOperation {
    var complitionHandler: (Void) -> Void
    let cacheFile: URL
    let apiRequestStatus: APIRequestStatus
    let cachePolicy: CachePolicy
    let context: NSManagedObjectContext
    
    init(cacheFile: URL, apiRequestStatus: APIRequestStatus, cachePolicy: CachePolicy, context: NSManagedObjectContext, complitionHandler: @escaping (Void) -> Void) {
        self.complitionHandler = complitionHandler
        self.cacheFile = cacheFile
        self.apiRequestStatus = apiRequestStatus
        self.cachePolicy = cachePolicy
        
//        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
//        importContext.mergePolicy = NSOverwriteMergePolicy
        self.context = context
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
                        //cachePolicyApplier(note: note)
                        context.performAndWait({
                            self.insert(parsed: note)
                        })
                    }
                }
            } else if let jsonResult = jsonResult as? [String: Any] {
                if let note = Note.parse(json: jsonResult) {
                    //cachePolicyApplier(note: note)
                    context.performAndWait({
                        self.insert(parsed: note)
                    })
                }
            }
        } catch {
            print("Unable to parse")
            apiRequestStatus.state = .Failed
            apiRequestStatus.add(error: StoreCacheOperationError.parseTmpError)
        }
        
        context.performAndWait({
            let error = self.saveContext()
            print("Saved to contextStoreCacaheOper  error: \(error)")
        })
        
        self.complitionHandler()
        self.finish()
    }
    
    private func insert(parsed: Note) {
        // Find if any with current uid and replace
        let req: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "uid", ascending: false)
        req.predicate = NSPredicate(format: "uid == %@", parsed.uid)
        req.sortDescriptors = [sort]
        
        context.performAndWait {
            do {
                let res = try self.context.fetch(req)
                if let entity = res.first {
                    entity.title = parsed.title
                    entity.content = parsed.content
                    // TODO: Fix multiple transformation
                    entity.color = parsed.color.toHexString()
                    entity.expireDate = parsed.expireDate
                } else {
                    let note = NSEntityDescription.insertNewObject(forEntityName: NoteEntity.entityName, into: self.context) as! NoteEntity
                    note.uid = parsed.uid
                    note.title = parsed.title
                    note.content = parsed.content
                    note.color = parsed.color.toHexString()
                    note.expireDate = parsed.expireDate
                }
            } catch {
                print("Error in finding current entities")
            }
        }
    }
    
    private func saveContext() -> NSError? {
        var error: NSError?
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch let saveError as NSError {
                error = saveError
            }
        }
        
        return error
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
