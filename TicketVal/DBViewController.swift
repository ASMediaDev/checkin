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


class DBViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource  {
    
   
    @IBAction func logoutBtn(_ sender: AnyObject) {
        
        UserDefaults.standard.removeObject(forKey: "userFirstName")
        UserDefaults.standard.removeObject(forKey: "userLastName")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.synchronize()
        
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
    
    //coredata methods
    
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
        
        let fetchRequest:NSFetchRequest<Attendees> = Attendees.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "private_reference_number == \(private_reference_number)")
        
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
           
            if (searchResults.count != 0){
                
                return true
                
            }
            
        }
        catch{
            print("Error: \(error)")
        }
        
        
        return false
        
    }
    
    func hasArrived(private_reference_number: Int) -> Bool{
        
        let fetchRequest:NSFetchRequest<Attendees> = Attendees.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "private_reference_number == \(private_reference_number) AND arrived == false")
        
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            
            if (searchResults.count != 0){
                print("Arrival status = false")
                return false
              
                
                
            }
            
        }
        catch{
            print("Error: \(error)")
        }

        return true
        
    }
    
    func checkIn(private_reference_number: Int){
        
        let fetchRequest:NSFetchRequest<Attendees> = Attendees.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "private_reference_number == \(private_reference_number)")
        
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            
            if (searchResults.count > 1){
                
                print("Error: TicketID not unique!")
                
            }
            else{
                
                let arrivedAttendee = searchResults[0] as NSManagedObject
                
                arrivedAttendee.setValue(true, forKey: "arrived")
                arrivedAttendee.setValue(NSDate(), forKey: "checkin_time")
                
                
                do{
                    try arrivedAttendee.managedObjectContext?.save()
                }
                catch{
                    let saveError = error as NSError
                    print(saveError)
                }
                
            }
            
            
            
        }
        catch{
            print("Error: \(error)")
        }

        
    }
    
    func checkOut(private_reference_number: Int){
        let fetchRequest:NSFetchRequest<Attendees> = Attendees.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "private_reference_number == \(private_reference_number)")
        
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            
            if (searchResults.count > 1){
                
                print("Error: TicketID not unique!")
                
            }
            else{
                
                let arrivedAttendee = searchResults[0] as NSManagedObject
                
                arrivedAttendee.setValue(false, forKey: "arrived")
                
                do{
                    try arrivedAttendee.managedObjectContext?.save()
                }
                catch{
                    let saveError = error as NSError
                    print(saveError)
                }
                
            }
            
            
            
        }
        catch{
            print("Error: \(error)")
        }
        
        
    }
    
    func getNameforTicket(private_reference_number: Int) -> String{
        
        var attendeeName = ""
        
        let fetchRequest:NSFetchRequest<Attendees> = Attendees.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "private_reference_number == \(private_reference_number)")
        
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            
            if (searchResults.count == 1){
                
                attendeeName = ((searchResults.first?.first_name)! + " " + (searchResults.first?.last_name)!)
                
            } else {
                
                attendeeName = "ERROR"
                
            }
            
        }
        catch{
            print("Error: \(error)")
        }

        return attendeeName
       
    }
    
    func countAttendees() -> Int{
        
        let fetchRequest:NSFetchRequest<Attendees> = Attendees.fetchRequest()
        
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            print("number of results: \(searchResults.count)")
            
            //attendeesCount.text = "Number of Attendees in Databse: \(searchResults.count)"
            return (searchResults.count)
            
            
            
        }
        
        catch{
            print("Error: \(error)")
        }
        
        return 0
        
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
