//
//  LoginViewController.swift
//  Checkin
//
//  Created by Alex Seitz on 15.12.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var userEmailAddressTextField: UITextField!

    @IBOutlet weak var userPasswordTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

     

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signInButtonTapped(_ sender: AnyObject) {
        
        let userName = userEmailAddressTextField.text
        let userPassword = userPasswordTextField.text
        
        print(userName!)
        print(userPassword!)
        
        if((userName?.isEmpty)! || (userPassword?.isEmpty)!){
            //Display an alert message
            
            let alert = UIAlertController(title: "Alert", message: "All fields are required to sign in!", preferredStyle: UIAlertControllerStyle.alert)
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 10.0
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        let myUrl = URL(string: "http://api.ticketval.de/signin.php")
        
        var request = URLRequest(url: myUrl!)
        
        request.httpMethod = "POST"
        
        let postString = "userName=\(userName!)&userPassword=\(userPassword!)"
        
    
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
       
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            DispatchQueue.main.async
                {
                    if(error != nil)
                    {
                        //Display an alert message
                        let myAlert = UIAlertController(title: "Alert", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil)
                        myAlert.addAction(okAction)
                        self.present(myAlert, animated: true, completion: nil)
                        return
                    }
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        if let parseJSON = json {
                            
                            let userId = parseJSON["userId"] as? String
                            if(userId != nil)
                            {
                                
                                UserDefaults.standard.set(parseJSON["userFirstName"], forKey: "userFirstName")
                                UserDefaults.standard.set(parseJSON["userLastName"], forKey: "userLastName")
                                UserDefaults.standard.set(parseJSON["userId"], forKey: "userId")
                                UserDefaults.standard.synchronize()
                                
                                // take user to a protected page
                                
                                [self .performSegue(withIdentifier:"login_redirect", sender: nil)]
                                 
                                 //appDelegate?.window??.rootViewController = mainPageNav
                                
                                
                                
                                
                                
                                
                            } else {
                                // display an alert message
                                let userMessage = parseJSON["message"] as? String
                                let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil)
                                myAlert.addAction(okAction);
                                self.present(myAlert, animated: true, completion: nil)
                            }
                            
                        }
                    } catch
                    {
                        print(error)
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
