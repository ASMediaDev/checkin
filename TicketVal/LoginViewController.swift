//
//  LoginViewController.swift
//  Checkin
//
//  Created by Alex Seitz on 15.12.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith


class LoginViewController: UIViewController {
    
    var clientID: String = ""
    var clientSecret:String = ""
    
    
    @IBOutlet weak var userEmailAddressTextField: UITextField!

    @IBOutlet weak var userPasswordTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var userNameKeychain: String?
        var userPasswordKeychain: Any?
     
        
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "TicketVal")
        
       
        
        if (dictionary?.isEmpty == false){
            
            print("Found Credentials - Performing Login")
            
            for (key,value) in dictionary!{
                userNameKeychain = key
                userPasswordKeychain = value
                
            }
            let myUrl = URL(string: "http://laravel.ticketval.de/api/login")
            
       
            
            var statusCode = 0
            
            let param : [String: String] =
                [
                    "userName": userNameKeychain!,
                    "userPassword": userPasswordKeychain! as! String
            ]
            
            Alamofire.request(myUrl!, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseJSON{ response in
                
                //alamofireresponse = response
                print(response.result.value as Any)
                
                if let result = response.result.value{
                    let JSON = result as! NSDictionary
                    print(JSON.value(forKey: "status")!)
                    
                    statusCode = Int((JSON.value(forKey: "status")) as! String)!
                    
                }
                if statusCode == 200{
                    
                    print("Login succesful")
                    
                    print("Getting AccessToken")
                    self.getAccessToken(userName: userNameKeychain! , userPassword: userPasswordKeychain as! String)
                    
                    
                    
                }else{
                    
                    print("Login not succesful")
                }
                
                
            }
            

            
           
            
            
        }
     

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signInButtonTapped(_ sender: AnyObject) {
        
        
        
        let userName = self.userEmailAddressTextField.text
        let userPassword = self.userPasswordTextField.text
        
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
        
        do{
        
        try Locksmith.saveData(data: [userName!:userPassword!], forUserAccount: "TicketVal")
            
        }catch{
            
            //catch
        }
        
        let myUrl = URL(string: "http://laravel.ticketval.de/api/login")
        
        //var alamofireresponse: DataResponse<Any>?
        
        var statusCode = 0
        
        let param : [String: String] =
            [
                "userName": userName!,
                "userPassword": userPassword!
        ]
        
        Alamofire.request(myUrl!, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseJSON{ response in
            
            //alamofireresponse = response
            print(response.result.value as Any)
            
            if let result = response.result.value{
                let JSON = result as! NSDictionary
                print(JSON.value(forKey: "status")!)
                
                statusCode = Int((JSON.value(forKey: "status")) as! String)!
               
            }
            if statusCode == 200{
                
                print("Login succesful")
                self.getAccessToken(userName: userName!, userPassword: userPassword!)
                
                
                
                
            }else{
                
                print("Login not succesful")
            }
            
        }
    
    }
    
    public func getAccessToken(userName: String, userPassword: String){
        
        let myUrl = URL(string: "http://laravel.ticketval.de/oauth/token")
        
        //var alamofireresponse: DataResponse<Any>?
        
       
        
        let param : [String: String] =
            [
                "grant_type": "password",
                "client_id": "4",
                "client_secret": "WGy6yOMh1730nI71mKR2V02FT6b8JrgS6A0GDKTm",
                "username": userName,
                "password": userPassword
        ]
        
        Alamofire.request(myUrl!, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseJSON{ response in
            if let result = response.result.value{
                let JSON = result as! NSDictionary
                print(JSON.value(forKey: "access_token")!)
                
                do{
                    try Locksmith.saveData(data: [userName : JSON.value(forKey: "access_token")!], forUserAccount: "TicketValAPI")
                }catch{
                    
                    //catch
                }
                
                print("Redirecting...")
                
                [self .performSegue(withIdentifier:"login_redirect", sender: nil)]

                
        }
    
    }
    
    
    }
}



    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



