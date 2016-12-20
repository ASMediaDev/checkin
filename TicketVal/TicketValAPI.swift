//
//  TicketValAPI.swift
//  Checkin
//
//  Created by Alex Seitz on 20.12.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Foundation

class TicketValAPI{
    
    func getEvents(completion: @escaping (Error?, [Event]) -> Void) {
        print("Inside Events/API")
        let url = URL(string: "http://api.ticketval.de/getEvents.php")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) -> Void in
            if error != nil
            {
                print ("ERROR")
            }
            else
            {
                
                do{
                
                let eventsData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                    
                //print(eventsData)
                var events = [Event]()
                    
                    for event in eventsData{
                        
                        let event = Event(data: event as! NSDictionary)
                        events.append(event)
                        
                    }
                    completion(nil, events)
                    //print(events[0].title)
                    
                   
                    
                    
                }catch{
                    print(error)
                }
                
              
                
                }
                
                
    
                
            }
        
        task.resume()
    }

    
    
}
