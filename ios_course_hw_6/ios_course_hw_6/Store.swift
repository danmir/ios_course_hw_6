//
//  Store.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 06.06.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import CoreData

class Store {
    static let instance = Store()
    
    var notesCache: [Note]?
    
    func performFetch() {
        let context = CoreDataManager.instance.getBackgroundContext()
        context.performAndWait {
            let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
            request.returnsObjectsAsFaults = false
            request.sortDescriptors = [NSSortDescriptor(key: "uid", ascending: false)]
            do {
                let res = try context.fetch(request)
                print("performFetch: \(res)")
                self.notesCache = res.map {NoteEntity.entityToNote(noteEntity: $0)}
            } catch {
                print("Can't perform fetch in Store")
            }
        }
    }
}
