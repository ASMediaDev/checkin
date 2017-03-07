//
//  TicketValAPI.swift
//  Checkin
//
//  Created by Alex Seitz on 20.12.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation
import Alamofire
import Locksmith





class TicketValAPI{
    
    func getEvents(completion: @escaping (Error?, [EventObject]) -> Void) {
        
        var userNameKeychain: String = ""
        var accessTokenKeychain: Any = ""
        
        var events = [EventObject]()
        
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "TicketValAPI")
        
        if (dictionary?.isEmpty == false){
            
            print("Found AccessToken")
            
            for (key,value) in dictionary!{
                userNameKeychain = key
                accessTokenKeychain = value
            }
        
        let queue = DispatchQueue(label: "com.asmedia.ticketval.response-queue", qos: .utility, attributes: [.concurrent])
        
        let myUrl = URL(string: "https://ticketval.de/api/getEvents")
            
        let headers = ["Authorization":"Bearer \(accessTokenKeychain)"]
            
            Alamofire.request(myUrl!, method: .get, headers: headers).responseJSON(
            queue: queue,
                completionHandler: { response in
                
                    let eventsData = response.result.value as! NSArray
                
                    for event in eventsData{
                    
                    let event = EventObject(data: event as! NSDictionary)
                    //print(event.title)
                    events.append(event)
                    
                }
                
                completion(nil, events)

                    DispatchQueue.main.async {
                    print(events[0].title)
                    }
                }
            )
        }
    }
    
    func getAttendees(eventId: Int, completion: @escaping (Error?, [AttendeeObject]) -> Void) {
        
        var userNameKeychain: String = ""
        var accessTokenKeychain: Any = ""
        
        var attendees = [AttendeeObject]()
        
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "TicketValAPI")
        
        if (dictionary?.isEmpty == false){
            
            print("Found AccessToken")
            
            for (key,value) in dictionary!{
                userNameKeychain = key
                accessTokenKeychain = value
            }
            
            let queue = DispatchQueue(label: "com.asmedia.ticketval.response-queue", qos: .utility, attributes: [.concurrent])
            
            let myUrl = URL(string: "https://ticketval.de/api/getAttendees/\(eventId)")
            
            
           let headers = ["Authorization":"Bearer \(accessTokenKeychain)"]
            
            
            
            Alamofire.request(myUrl!, method: .get, headers: headers).responseJSON(
                queue: queue,
                completionHandler: { response in
                    
                    let attendeesData = response.result.value as! NSArray
                    
                    for attendee in attendeesData{
                        
                        let attendee = AttendeeObject(data: attendee as! NSDictionary)
                        //print(event.title)
                        attendees.append(attendee)
                        
                    }
                    
                    completion(nil, attendees)
                    
                    
                    DispatchQueue.main.async {
                        
                        //print(attendees[0].firstname)
                        
                        
                    }
            }
            )
        }
    }
}



    
    
    
    

