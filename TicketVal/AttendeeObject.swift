//
//  Attendee.swift
//  Checkin
//
//  Created by Alex Seitz on 20.12.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation


class AttendeeObject {
    
    var orderid : Int!
    var ticketid : Int!
    var firstname : String!
    var lastname : String!
    var private_reference_number : Int!
    
    
    
    
    init(data : NSDictionary){
        
       
        self.orderid = (data["order_id"] as! NSString).integerValue
        self.ticketid = (data["ticket_id"] as! NSString).integerValue
        self.firstname = getStringFromJSON(data: data, key: "first_name")
        self.lastname = getStringFromJSON(data: data, key: "last_name")
        self.private_reference_number = (data["private_reference_number"] as! NSString).integerValue
        
        
        
    }
    
    
    func getStringFromJSON(data: NSDictionary, key: String) -> String{
        
        if let info = data[key] as? String {
            //print("Info: \(info)")
            return info
        }
        return ""
        
        
    }
    
    
}
