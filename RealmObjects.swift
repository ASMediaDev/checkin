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

    
    @objc dynamic var ticketId: Int = Int(0)
    @objc dynamic var private_reference_number: Int = Int(0)
    @objc dynamic var orderId: Int = Int(0)
    @objc dynamic var lastName: String = ""
    @objc dynamic var firstName: String = ""
    @objc dynamic var checkinTime: String = ""
    @objc dynamic var arrived: Bool = false
    @objc dynamic var eventName: String = ""
    @objc dynamic var is_cancelled: Bool = false
    
    override static func primaryKey() -> String? {
        return "private_reference_number"
    }
}
