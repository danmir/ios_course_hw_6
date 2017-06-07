//
//  NoteEntity+CoreDataClass.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 04.06.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(NoteEntity)
public class NoteEntity: NSManagedObject {
    static let entityName = "Note"
    
    static func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }
    
    static func entityToNote(noteEntity: NoteEntity) -> Note {
        let color = UIColor(hexString: noteEntity.color!)
   
        if let expireDate = noteEntity.expireDate {
            let note = Note(title: noteEntity.title!, content: noteEntity.content!, color: color!, uid: noteEntity.uid!, expireDate: expireDate)
            return note
        }
        let note = Note(title: noteEntity.title!, content: noteEntity.content!, color: color!, uid: noteEntity.uid!, expireDate: nil)
        return note
    }
}
