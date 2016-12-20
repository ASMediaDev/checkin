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
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return 20
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "mycell")
        if (attendees.isEmpty){
            
            cell.textLabel?.text = "empty"
            
        }else{
            
        cell.textLabel?.text = attendees[0]
        
        }
        
        return cell
    }
  
    @IBAction func selectevent(_ sender: Any) {
      
        label.text = "Selected Event: \(events[placementAnswer])"
        print("btn_pressed")
        
        self.view.viewWithTag(1)?.isHidden = true
        UserDefaults.standard.setValue(placementAnswer, forKey: "selectedEvent")
        print(UserDefaults.standard.value(forKey: "selectedEvent")!)
        getAttendees(eventId: (UserDefaults.standard.value(forKey: "selectedEvent") as! Int)+1)
        attendeesTableView.reloadData()
        self.view.viewWithTag(3)?.isHidden = false
        //print(attendees)
        
        
       
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
    
    var Array = [""]
    
    var events = [String]()
    
    var attendees = [String]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.viewWithTag(1)?.isHidden = true
        let storedEvent = UserDefaults.standard.value(forKey: "selectedEvent") as! Int
        getEvents()
       
        
        print(storedEvent)
        //print(events[storedEvent])
        
        //label.text = "Selected Event: \(events[storedEvent])"
        
        eventpicker.delegate = self
        eventpicker.dataSource = self
        //getAttendees(eventId: (UserDefaults.standard.value(forKey: "selectedEvent") as! Int)+1)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Array = getEventNamesFromAPI()
       
        return events[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //Array = getEventNamesFromAPI()
        return events.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
   
        placementAnswer = row
        //print(placementAnswer)
    
    }
    
   
    
    
    func getEvents() {
        print("Inside Events")
        let url = URL(string: "http://api.ticketval.de/getEvents.php")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil
            {
                print ("ERROR")
            }
            else
            {
                if let content = data
                {
                    do
                    {
                        //Array
                        let myJson = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject
                    
                        for dictionary in myJson as! [[String: AnyObject]]{
                            //print(dictionary)
                            
                            self.events.append((dictionary["title"] as AnyObject) as! String)
                    }
                      
                    print(self.events)
                    self.eventpicker.reloadAllComponents()
                    }
                    catch
                    {
                        
                    }
                }
            }
        }
        task.resume()
        self.eventpicker.reloadAllComponents()
}
    
    func getAttendees(eventId: Int){
        
        print("Inside attendees")
        let urlstring = "http://api.ticketval.de/getAttendees.php"
        let eventIdString = "?eventId=\(eventId)"
        let url = URL(string: urlstring + eventIdString)
        
        //print(url!)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil
            {
                print ("ERROR")
            }
            else
            {
                if let content = data
                {
                    do
                    {
                        //Array
                        let myJson = try JSONSerialization.jsonObject(with: content, options: .mutableContainers) as AnyObject
                        
                        for dictionary in myJson as! [[String: AnyObject]]{
                            //print(dictionary)
                            
                            //print ("Dictionary:")
                            //print(((dictionary["first_name"] as AnyObject) as! String))
                            self.attendees.append((dictionary["first_name"] as AnyObject) as! String)
                        }
                        
                        
                        //print(self.attendees)
                        self.attendeesTableView.reloadData()
                    }
                    catch
                    {
                        
                    }
                }
            }
        }
        task.resume()

        
       
        
        
        
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
