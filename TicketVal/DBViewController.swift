//
//  DBViewController.swift
//  TicketVal
//
//  Created by Alex Seitz on 21.11.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import Alamofire
import RealmSwift
import Locksmith


class DBViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource  {
    
   
    @IBAction func logoutBtn(_ sender: AnyObject) {
        
        
        do{
            try Locksmith.deleteDataForUserAccount(userAccount: "TicketVal")
        }catch{
            
            
        }
        let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = loginPage
        
    }
    @IBAction func insertAttendeesButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "WARNUNG", message: "Durch den Import werden alle bisher importierten Datensätze gelöscht!", preferredStyle: .alert)
        
        
        let okAction = UIAlertAction(title: "Fortfahren", style: .default) { action in
            
            self.insertAttendees(eventId: (self.placementAnswer)+1)
            
            print("Attendees inserted")
            self.attendeesCount.text = "Number of Attendees in Databse: \(self.countAttendees())"
           
            
            
        }
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { action in
            
        }
        alertController.addAction(cancelAction)
        
        
        
        self.present(alertController, animated: true) {
            // ...
        }

        
        
        
    }
    
    @IBOutlet weak var attendeesCount: UITextView!
    
    @IBOutlet weak var tableViewTitle: UITextView!
    
    @IBAction func showDatabase(_ sender: Any) {
        checkDataStore()
        print("Ticket exists: \(ticketExists(private_reference_number: 787313345))")
        print("Arrived: \(hasArrived(private_reference_number: 787313345))")
    }
    
    
    @IBAction func truncateDatabase(_ sender: Any) {
        emptyDataStore()
         attendeesCount.text = "Number of Attendees in Databse: \(countAttendees())"
        print("Database truncated")
        
    }
    
    
    
    @IBAction func selectevent(_ sender: Any) {
        label.text = "Selected Event from Webservice: \(eventarray[placementAnswer])"
        tableViewTitle.text = "Attendees found online for: \(eventarray[placementAnswer])"
        self.view.viewWithTag(1)?.isHidden = true
        UserDefaults.standard.setValue(placementAnswer, forKey: "selectedEvent")
        print(UserDefaults.standard.value(forKey: "selectedEvent")!)
        self.view.viewWithTag(3)?.isHidden = false
        
        attendees = []
        
        let api = TicketValAPI()
        api.getAttendees(eventId: (placementAnswer)+1) {(error, attendees) in
            if let error = error{
                print(error)
            }else {
                //print("Content:")
                for attendee in attendees {
                    self.attendees.append(attendee.firstname + " " + attendee.lastname)
                }
                
                print(self.attendees)
                DispatchQueue.main.async {
                    self.attendeesTableView.reloadData()
                }
            }
        }
    }
    
    
    
    
    
    @IBOutlet weak var attendeesTableView: UITableView!
    
    @IBOutlet weak var eventpicker: UIPickerView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var attendeesTextView: UITextView!
    

    @IBAction func openpicker(_ sender: Any) {
        
        self.eventpicker.reloadAllComponents()
        self.view.viewWithTag(3)?.isHidden = true
        self.view.viewWithTag(1)?.isHidden = false
    }
    
    var placementAnswer = 0;
    
    var eventarray = [String]()
    
    var eventsdictionary = NSDictionary()
    
    var attendees = [String]()
    
    var attendeesdictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.viewWithTag(1)?.isHidden = true
        eventpicker.delegate = self
        eventpicker.dataSource = self
        
        let api = TicketValAPI()
        
        api.getEvents() {(error, events) in
            if let error = error{
                print(error)
            }else {
                //print("Content:")
                print(events[0].startdate)
                
                for event in events {
                    self.eventarray.append(event.title)
                    }
                }
        }
 
        
        //checkDataStore()
        
        //print(ticketExists(private_reference_number: 617191322))
        
        attendeesCount.text = "Number of Attendees in Databse: \(countAttendees())"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //pickerview methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Array = getEventNamesFromAPI()
       
        return eventarray[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //Array = getEventNamesFromAPI()
        return eventarray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
   
        placementAnswer = row
        print(placementAnswer)
    
    }
    
    //tableview methods
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return attendees.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        
        
        if (attendees.isEmpty){
            
            cell.textLabel?.text = "empty"
        } else {
            
            cell.textLabel?.text = attendees[indexPath.item]
            
        }
        return cell
    }
    
    //Realm methods
    
    func checkDataStore() {
        
                let realm = try! Realm()
                let AttendeesFromRealm = realm.objects(Attendee.self)
        
                for attendee in AttendeesFromRealm{
            
                    print("Attendee \(attendee.firstName) \(attendee.lastName) is attending \(attendee.eventName) ")
                }
    }
    
    func emptyDataStore(){
        
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
  
    
    func insertAttendees(eventId: Int){
        
        let api = TicketValAPI()
        api.getAttendees(eventId: eventId) {(error, attendees) in
            if let error = error{
                print(error)
            }else {
                
                self.emptyDataStore()
                
                var insertcounter = 0
                for attendee in attendees {
                    
                    let attendeeRealmObject = Attendee()
                    attendeeRealmObject.ticketId = attendee.ticketid
                    attendeeRealmObject.orderId = attendee.orderid
                    attendeeRealmObject.firstName = attendee.firstname
                    attendeeRealmObject.lastName = attendee.lastname
                    attendeeRealmObject.private_reference_number = attendee.private_reference_number
                    attendeeRealmObject.arrived = false
                    attendeeRealmObject.eventName = self.eventarray[(attendee.eventid)-1]
                    
                    let realm = try! Realm()
                    
                    try! realm.write {
                        realm.add(attendeeRealmObject)
                        print("Added \(attendeeRealmObject.firstName) to Realm")
                        insertcounter = insertcounter + 1
                        }
                }
                
                let alertController = UIAlertController(title: "Import abgeschlossen", message: "Es wurden \(insertcounter) Datensätze importiert", preferredStyle: .alert)
                
                
                let destroyAction = UIAlertAction(title: "ok", style: .default) { action in
                    
                }
                
                alertController.addAction(destroyAction)
                self.present(alertController, animated: true) {
                    // ...
                }
            }
        }
    }
    
   func ticketExists(private_reference_number: Int) -> Bool{
    
        let realm = try! Realm()
    
        let attendees = realm.objects(Attendee.self).filter("private_reference_number = \(private_reference_number)")
    
        if (attendees.count != 0){
            
            return true
        
        } else{
            
            return false
        }
    }
    
    func hasArrived(private_reference_number: Int) -> Bool{
        
        let realm = try! Realm()
        
        let attendees = realm.objects(Attendee.self).filter("private_reference_number = \(private_reference_number) AND arrived = true")
        
        if (attendees.count != 0){
        
            return true
        
        } else{
        
            return false
        }
    }
    
    func checkIn(private_reference_number: Int){
        
        
        let realm = try! Realm()
        
        let attendees = realm.objects(Attendee.self).filter("private_reference_number = \(private_reference_number)")
        
        if(attendees.count > 1){
            
            print("Error: TicketID not unique!")
        }else if (attendees.count == 0){
            
            print("Error: Ticket doesn't exist")
            
        }else{
            
            let date = NSDate()
            let calendar = NSCalendar.current
            let month = calendar.component(.month, from: date as Date)
            let day = calendar.component(.day, from: date as Date)
            let hour = calendar.component(.hour, from: date as Date)
            let minute = calendar.component(.minute, from: date as Date)
            
            let timestamp: String = ("\(day).\(month) \(hour):\(minute)")
            
            try! realm.write {
                realm.create(Attendee.self, value: ["private_reference_number": private_reference_number, "arrived": true, "checkinTime": timestamp], update: true)
            }
        }
    }
    
    func checkOut(private_reference_number: Int){
        
        let realm = try! Realm()
        
        let attendees = realm.objects(Attendee.self).filter("private_reference_number = \(private_reference_number)")
        
        if(attendees.count > 1){
            
            print("Error: TicketID not unique!")
        }else if (attendees.count == 0){
            
            print("Error: Ticket doesn't exist")
            
        }else{
            
            try! realm.write {
                realm.create(Attendee.self, value: ["private_reference_number": private_reference_number, "arrived": false], update: true)
            }
        }
    }
    
    func getNameforTicket(private_reference_number: Int) -> String{
        
        var attendeeName = ""
        
        let realm = try! Realm()
        
        let attendees = realm.objects(Attendee.self).filter("private_reference_number = \(private_reference_number)")
        
        if (attendees.count == 1){
            
            attendeeName = (attendees[0].firstName + "" + attendees[0].lastName)
        }else{
            
            attendeeName = "Attendeename not found!"
            
        }
        
        return attendeeName
        
    }
    
    func getCheckinTime(private_reference_number: Int) -> String{
        
        var checkinTime = ""
        
        let realm = try! Realm()
        
        let attendees = realm.objects(Attendee.self).filter("private_reference_number = \(private_reference_number)")
        
        if (attendees.count == 1){
            
            checkinTime = attendees[0].checkinTime
            
        }else{
            
            checkinTime = "Not checked in yet"
            
        }
        
        return checkinTime
        
    }
    
    func countAttendees() -> Int{
        
        let realm = try! Realm()
        
        let attendees = realm.objects(Attendee.self)
        
        return attendees.count
    
    }
    
    func countAttendeesArrived() -> Int{
        
        let realm = try! Realm()
        
        let attendeesArrived = realm.objects(Attendee.self).filter("arrived = true")

        return attendeesArrived.count
        
        
    }
    
    func getSyncedEvent() -> String{
        
        let realm = try! Realm()
        
        let attendees = realm.objects(Attendee.self)
        
        return (attendees.first?.eventName)!
    }
}
