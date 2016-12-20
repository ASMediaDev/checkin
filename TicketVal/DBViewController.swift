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
    
    @IBOutlet weak var tableViewTitle: UITextView!
    
    
    
    @IBAction func selectevent(_ sender: Any) {
        label.text = "Selected Event: \(eventarray[placementAnswer])"
        tableViewTitle.text = "Attendees for: \(eventarray[placementAnswer])"
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
        
        checkDataStore()
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
        
        
        
        let fetchRequest:NSFetchRequest<Attendees> = Attendees.fetchRequest()
        
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            print("number of results: \(searchResults.count)")
         
            for result in searchResults as [Attendees]{
                print("\(result.first_name!)")
                print("\(result.last_name!)")
                print(result.private_reference_number!)
            }
        }
        catch{
            print("Error: \(error)")
        }
        
        
    }
    
    func insertIntoDataStore() {
        
        let attendee:Attendees = NSEntityDescription.insertNewObject(forEntityName: "Attendees", into: DatabaseController.getContext()) as! Attendees
        
        attendee.first_name = "John"
        attendee.last_name = "Smith"
        attendee.ticket_id = 2
        attendee.order_id = 1
        attendee.private_reference_number = 817283627
        
        DatabaseController.saveContext()
        
        
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
