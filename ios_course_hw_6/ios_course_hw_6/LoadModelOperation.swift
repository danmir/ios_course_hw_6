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
        
        var pscCompatibile = true
        do {
            let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: "", at: storeurl, options: nil)
            let destinationModel = persistentStoreCoordinator.managedObjectModel
            pscCompatibile = destinationModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata)
        } catch let error {
            print("sourceMetadata error \(error)")
        }
        
        if !pscCompatibile {
            let url1 = Bundle.main.url(forResource: "Model", withExtension: "mom", subdirectory: "Model.momd")!
            let url2 = Bundle.main.url(forResource: "Model 2", withExtension: "omo", subdirectory: "Model.momd")!
            let model1 = NSManagedObjectModel(contentsOf: url1)!
            let model2 = NSManagedObjectModel(contentsOf: url2)!
            let mappingModel = NSMappingModel(from: nil, forSourceModel: model1, destinationModel: model2)
            
            let sourceURL = storeurl
            let targetURL = URL(fileURLWithPath:NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("model.sqlite")
            
            let manager = NSMigrationManager(sourceModel: model1, destinationModel: model2)
            try! manager.migrateStore(from: sourceURL, sourceType: NSSQLiteStoreType, options: nil, with: mappingModel, toDestinationURL: targetURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
            
            let fileManager = FileManager.default
            do {
                if fileManager.fileExists(atPath: sourceURL.path) {
                    try fileManager.removeItem(atPath: sourceURL.path)
                }
                try fileManager.copyItem(atPath: targetURL.path, toPath: sourceURL.path)
                
            } catch {
                print(error)
            }
//            let psc = NSPersistentStoreCoordinator(managedObjectModel: model!)
//            try! psc.replacePersistentStore(at: targetURL, destinationOptions: nil, withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
        }
        
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
