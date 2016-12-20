//
//  Attendees+CoreDataProperties.swift
//  
//
//  Created by Alex Seitz on 20.12.16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Attendees {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attendees> {
        return NSFetchRequest<Attendees>(entityName: "Attendees");
    }

    @NSManaged public var first_name: String?
    @NSManaged public var last_name: String?
    @NSManaged public var order_id: NSNumber?
    @NSManaged public var private_reference_number: NSNumber?
    @NSManaged public var ticket_id: NSNumber?

}
