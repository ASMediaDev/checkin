//
//  Event.swift
//  Checkin
//
//  Created by Alex Seitz on 20.12.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation

class Event {
    
    var title: String!
    var id : Int!
    var startdate : String!
    var enddate : String!
    var organiserid : Int!
    



    init(data : NSDictionary){
    
        self.title = getStringFromJSON(data: data, key: "title")
        self.id = (data["id"] as! NSString).integerValue
        self.startdate = getStringFromJSON(data: data, key: "start_date")
        self.enddate = getStringFromJSON(data: data, key: "end_date")
        self.organiserid = (data["organiser_id"] as! NSString).integerValue
     
        

    }
    
    
    func getStringFromJSON(data: NSDictionary, key: String) -> String{
        
        if let info = data[key] as? String {
            //print("Info: \(info)")
            return info
        }
        return ""
    
        
    }
    

}
