//
//  RealmObjects.swift
//  Checkin
//
//  Created by Alex Seitz on 25.01.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation
import RealmSwift

class Attendee: Object {

    
    dynamic var ticketId: Int = Int(0)
    dynamic var private_reference_number: Int = Int(0)
    dynamic var orderId: Int = Int(0)
    dynamic var lastName: String = ""
    dynamic var firstName: String = ""
    dynamic var checkinTime: String = ""
    dynamic var arrived: Bool = false
    dynamic var eventName: String = ""
    dynamic var is_cancelled: Bool = false
    
    override static func primaryKey() -> String? {
        return "private_reference_number"
    }
    
    
    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
