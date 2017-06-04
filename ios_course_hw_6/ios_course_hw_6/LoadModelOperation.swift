//
//  LoadModelOperation.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 04.06.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import CoreData

class LoadModelOperation: AsyncOperation {
    var complitionHandler: (NSManagedObjectContext) -> Void
    
    init(complitionHandler: @escaping (NSManagedObjectContext) -> Void) {
        self.complitionHandler = complitionHandler
        super.init()
    }
    
    override func main() {
        guard let url = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            // process error
            self.finish()
            return
        }
        let model = NSManagedObjectModel(contentsOf: url)
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator

        let docurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let storeurl = docurl.appendingPathComponent("model.sqlite")
        do {
            _ = try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeurl, options: nil)
        }
        catch let storeError as NSError {
            print(storeError)
        }
        
        if persistentStoreCoordinator.persistentStores.isEmpty {
            print("Error creating SQLite store.")
            self.finish()
        }
        
        self.complitionHandler(context)
        self.finish()
    }
}
