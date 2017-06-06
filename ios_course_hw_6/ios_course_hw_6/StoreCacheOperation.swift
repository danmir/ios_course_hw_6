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
    
    init(cacheFile: URL, apiRequestStatus: APIRequestStatus, cachePolicy: CachePolicy, complitionHandler: @escaping (Void) -> Void) {
        self.complitionHandler = complitionHandler
        self.cacheFile = cacheFile
        self.apiRequestStatus = apiRequestStatus
        self.cachePolicy = cachePolicy
        
//        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
//        importContext.mergePolicy = NSOverwriteMergePolicy
        
        let context = CoreDataManager.instance.getBackgroundContext()
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
                        context.performAndWait({
                            self.insert(parsed: note)
                        })
                    }
                }
            } else if let jsonResult = jsonResult as? [String: Any] {
                if let note = Note.parse(json: jsonResult) {
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
                    if let expireDate = parsed.expireDate {
                        entity.expireDate = String(expireDate.secondsSince1970)
                    } else {
                        entity.expireDate = nil
                    }
                } else {
                    let note = NSEntityDescription.insertNewObject(forEntityName: NoteEntity.entityName, into: self.context) as! NoteEntity
                    note.uid = parsed.uid
                    note.title = parsed.title
                    note.content = parsed.content
                    note.color = parsed.color.toHexString()
                    if let expireDate = parsed.expireDate {
                        note.expireDate = String(expireDate.secondsSince1970)
                    } else {
                        note.expireDate = nil
                    }
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
                print("Save error in StoreCacheOperation \(error)")
            }
        }
        
        return error
    }
}
