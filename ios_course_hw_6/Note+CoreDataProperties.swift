//
//  Note+CoreDataProperties.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 04.06.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note");
    }

    @NSManaged public var uid: String?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var color: String?
    @NSManaged public var expireDate: String?

}
