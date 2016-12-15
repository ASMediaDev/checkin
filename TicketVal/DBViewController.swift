//
//  DBViewController.swift
//  TicketVal
//
//  Created by Alex Seitz on 21.11.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import CoreData


class DBViewController: UIViewController {
    
    @IBOutlet weak var count: UITextView!
    
    @IBAction func importTickets(_ sender: Any) {
        //insert()

    }
    @IBAction func truncate(_ sender: UIButton) {
        truncateCoreData()
    }
    
    var codes = [NSManagedObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displaycount()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func saveCode (_ code: String){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Tickets", in: managedContext)
        
        let ticket = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        ticket.setValue(code, forKey: "code")
        
        do{
            try managedContext.save()
            
            codes.append(ticket)
            
        } catch let error as NSError{
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func insert () {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let contentsOfUrl = Bundle.main.url(forResource: "Midsemester_Tickets_2", withExtension: "csv")
        
        let items = appDelegate.parseCSV(contentsOfUrl!, encoding: String.Encoding.utf8)
        
        var counter = 0
        
        for element in items! {
            saveCode(element)
            print ("\(element) inserted")
            counter = counter + 1
        }
        
        print("Import complete")
        print("\(counter) items imported")
        displaycount()
        
        let alert = UIAlertController(title: "Import erfolgreich", message: "\(counter) Tickets importiert", preferredStyle: UIAlertControllerStyle.alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 10.0
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func truncateCoreData(){
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let coord = appDel.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tickets")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.execute(deleteRequest, with: context)
        } catch let error as NSError {
            debugPrint(error)
        }
        
        print("Coredata truncated")
        displaycount()
        let alert = UIAlertController(title: "Leeren erfolgreich", message: "Alle Tickets wurden aus der Datenbank gelöscht", preferredStyle: UIAlertControllerStyle.alert)
        let backView = alert.view.subviews.last?.subviews.last
        backView?.layer.cornerRadius = 10.0
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
        func validate(_ scan: String) -> Bool{
            
        var valid = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tickets")
        
        let predicate = NSPredicate(format: "code == %@", scan)
        
        fetchRequest.predicate = predicate
        
        do{
            let results = try managedContext.fetch(fetchRequest)
            
            codes = results as! [NSManagedObject]
            
            //print("Codes:")
            //print(codes[0])
            
            if results.isEmpty{
                print("invalid")
                valid = false
            }else{
                print("valid")
                valid = true
            }
        
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
            
        }
            return valid
    }
    
    func displaycount(){
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tickets")
        
        
        //fetchRequest.predicate = predicate
        
        do{
            let results = try managedContext.fetch(fetchRequest)
            
            codes = results as! [NSManagedObject]
            
            count.text = "Es befinden sich \(codes.count) Tickets in der Datenbank"
            
            
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
            
        }
    }
    
    func countcodes() -> Int{
        var numberofcodes : Int = 0
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tickets")
        
        
        //fetchRequest.predicate = predicate
        
        do{
            let results = try managedContext.fetch(fetchRequest)
            
            codes = results as! [NSManagedObject]
            
            numberofcodes = (codes.count)
            
            print(numberofcodes)
            
            
        } catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
            
        }
        
        return numberofcodes
        
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
