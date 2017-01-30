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
        
        let myUrl = URL(string: "http://laravel.ticketval.de/api/getEvents")
            
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
    
    func getAttendees(eventId: Int, completion: @escaping (Error?, [AttendeeObject]) -> Void){
        
        print("Inside attendees")
        let urlstring = "http://api.ticketval.de/getAttendees.php"
        let eventIdString = "?eventId=\(eventId)"
        let url = URL(string: urlstring + eventIdString)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            if error != nil
            {
                print ("ERROR")
            }
            else
            {
                do{
                    let attendeesData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                    
                    //print(eventsData)
                    
                    var attendees = [AttendeeObject]()
                    
                    for attendee in attendeesData{
                        
                        let attendee = AttendeeObject(data: attendee as! NSDictionary)
                        attendees.append(attendee)
                        
                    }
                    
                    completion(nil, attendees)
                    //print(events[0].title)
                    
                }catch{
                    print(error)
                }
                
            }
        }
        task.resume()
    }

     
        
        
        
}



    
    
    
    

