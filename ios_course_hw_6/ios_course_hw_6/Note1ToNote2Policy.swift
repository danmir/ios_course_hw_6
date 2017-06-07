//
//  Note1ToNote2Policy.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 07.06.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import CoreData


class Note1ToNote2Policy: NSEntityMigrationPolicy {
    override func begin(_ mapping: NSEntityMapping, with manager: NSMigrationManager) throws {
        print("Begin mapping")
        try super.begin(mapping, with: manager)
    }
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        print("createDestinationInstances")
        let newNoteEntity = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
        newNoteEntity.setValue(sInstance.value(forKey: "uid"), forKey: "uid")
        newNoteEntity.setValue(sInstance.value(forKey: "title"), forKey: "title")
        newNoteEntity.setValue(sInstance.value(forKey: "content"), forKey: "content")
        newNoteEntity.setValue(sInstance.value(forKey: "color"), forKey: "color")
        
        if let expireDate = sInstance.value(forKey: "expireDate") as? String {
            newNoteEntity.setValue(Date(seconds: expireDate), forKey: "expireDate")
        }
        
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newNoteEntity, for: mapping)
    }
    
    override func end(_ mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        print("End mapping")
        try super.end(mapping, manager: manager)
    }
}
