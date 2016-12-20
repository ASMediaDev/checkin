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
  
    @IBAction func selectevent(_ sender: Any) {
      
        label.text = "Selected Event: \(eventarray[placementAnswer])"
        
        tableViewTitle.text = "Attendees for: \(eventarray[placementAnswer])"
        
        print("btn_pressed")
        
        self.view.viewWithTag(1)?.isHidden = true
        UserDefaults.standard.setValue(placementAnswer, forKey: "selectedEvent")
        print(UserDefaults.standard.value(forKey: "selectedEvent")!)
        //getAttendees(eventId: (UserDefaults.standard.value(forKey: "selectedEvent") as! Int)+1)
        //attendeesTableView.reloadData()
        self.view.viewWithTag(3)?.isHidden = false
        //print(attendees)
        
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
    
    
    var placementAnswer = 0;

       @IBAction func openpicker(_ sender: Any) {
        
        self.eventpicker.reloadAllComponents()
        self.view.viewWithTag(3)?.isHidden = true
        self.view.viewWithTag(1)?.isHidden = false
        
        
        
    }
    
    var codes = [NSManagedObject]()
    
    //var Array = [""]
    
    var eventarray = [String]()
    
    var attendees = [String]()
    
    
    
    
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
                for event in events {
                    self.eventarray.append(event.title)
                    }
                }
            }
        
       
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
