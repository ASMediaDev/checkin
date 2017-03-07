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
import GradientCircularProgress


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
        
        /*
        if (dictionary?.isEmpty == false){
            
            let progress = GradientCircularProgress()
            
            progress.show(message: "Logging in...", style: tvStyle())
            
            for (key,value) in dictionary!{
                userNameKeychain = key
                userPasswordKeychain = value
                
            }
            
            let manager = Alamofire.SessionManager.default
            
            manager.session.configuration.timeoutIntervalForRequest = 120
            
            let myUrl = URL(string: "https://ticketval.de/api/login")
            
            var statusCode = 0
            
            let param : [String: String] =
                [
                    "userName": userNameKeychain!,
                    "userPassword": userPasswordKeychain! as! String
            ]
            
            manager.request(myUrl!, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseJSON{ response in
                
                switch(response.result){
                case .success:
                    
                    if let result = response.result.value{
                        let JSON = result as! NSDictionary
                        print(JSON.value(forKey: "status")!)
                        
                        statusCode = Int((JSON.value(forKey: "status")) as! String)!
                        
                    }
                    if statusCode == 200{
                
                        self.validateAccessToken(userName: userNameKeychain! , userPassword: userPasswordKeychain as! String, progress: progress)
                        
                    }else{
                        
                        print("Login not succesful")
                        progress.dismiss()
                    }

                    break
                    
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {

                    }
                    
                    let alert = UIAlertController(title: "Alert", message: "Your internet connection appears to be offline", preferredStyle: UIAlertControllerStyle.alert)
                    let backView = alert.view.subviews.last?.subviews.last
                    backView?.layer.cornerRadius = 10.0
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("\n\nAuth request failed with error:\n \(error)")
                    progress.dismiss()
                    break
            }
            
        }
    }
 */
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signInButtonTapped(_ sender: AnyObject) {
        
        
        let progress = GradientCircularProgress()
        
        progress.show(message: "Logging in...", style: tvStyle())
        
        let userName = self.userEmailAddressTextField.text
        let userPassword = self.userPasswordTextField.text
        
        print(userName!)
        print(userPassword!)
        
        if((userName?.isEmpty)! || (userPassword?.isEmpty)!){
       
            let alert = UIAlertController(title: "Alert", message: "All fields are required to sign in!", preferredStyle: UIAlertControllerStyle.alert)
            let backView = alert.view.subviews.last?.subviews.last
            backView?.layer.cornerRadius = 10.0
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        /*
        
        do{
        
        try Locksmith.saveData(data: [userName!:userPassword!], forUserAccount: "TicketVal")
            
        }catch{
            
            //catch
        }
        */
        
        let myUrl = URL(string: "https://ticketval.de/api/login")

        var statusCode = 0
        
        let param : [String: String] =
            [
                "userName": userName!,
                "userPassword": userPassword!
        ]
        
        Alamofire.request(myUrl!, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseJSON{ response in
            
            print(response.result.value as Any)
            
            if let result = response.result.value{
                let JSON = result as! NSDictionary
                print(JSON.value(forKey: "status")!)
                
                statusCode = Int((JSON.value(forKey: "status")) as! String)!
               
            }
            if statusCode == 200{
                
                print("Login succesful")
                self.validateAccessToken(userName: userName!, userPassword: userPassword!, progress: progress)
                
            }else{
                
                print("Login not succesful")
            }
            
        }
    
    }
    
//AccessToken Methods:
    
    public func getAccessToken(userName: String, userPassword: String, progress: GradientCircularProgress){
        
        let myUrl = URL(string: "https://ticketval.de/oauth/token")
        
        let manager = Alamofire.SessionManager.default
        
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        let param : [String: String] =
            [
                "grant_type": "password",
                "client_id": "9",
                "client_secret": "gj7A2WkvpltIA3pIbDAQv0NziJc1sLc9JmYCazli",
                "username": userName,
                "password": userPassword
        ]
        
        manager.request(myUrl!, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseJSON{ response in
            
            switch(response.result){
            case .success:
                
                if let result = response.result.value{
                    let JSON = result as! NSDictionary
                    print(JSON.value(forKey: "access_token")!)
                    
                    do{
                        try Locksmith.saveData(data: [userName : JSON.value(forKey: "access_token")!], forUserAccount: "TicketValAPI")
                    }catch{
                        
                        //catch
                    }
                    
                    self.performSegue(withIdentifier:"login_redirect", sender: nil)
                    progress.dismiss()
                }
                break
                
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //timeout here
                }
                print("\n\nAuth request failed with error:\n \(error)")
                break
            }
        }
    }
    
    public func validateAccessToken(userName: String, userPassword: String, progress: GradientCircularProgress){
        
        var userNameKeychain: String = ""
        var accessTokenKeychain: Any = ""
        
        var statusCode = 0
        
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "TicketValAPI")
        
        if (dictionary?.isEmpty == false){
            
            print("Found AccessToken")
            
            for (key,value) in dictionary!{
                userNameKeychain = key
                accessTokenKeychain = value
            }
            
            let queue = DispatchQueue(label: "com.asmedia.ticketval.response-queue", qos: .utility, attributes: [.concurrent])
            
            let myUrl = URL(string: "https://ticketval.de/api/validateToken")
            
            let headers = ["Authorization":"Bearer \(accessTokenKeychain)"]
            
            Alamofire.request(myUrl!, method: .get, headers: headers).responseJSON(
                queue: queue,
                completionHandler: { response in
                    
                    if let result = response.result.value{
                        let JSON = result as! NSDictionary
                        print(JSON.value(forKey: "status")!)
                        
                        statusCode = Int((JSON.value(forKey: "status")) as! String)!
                        
                    }
                    if statusCode == 200{
                     
                        DispatchQueue.main.sync {
            
                            self.performSegue(withIdentifier:"login_redirect", sender: nil)
                            
                        }
                        progress.dismiss()
                        
                    }else{
                        
                        print("Token not valid!")
                        
                        self.getAccessToken(userName: userName, userPassword: userPassword, progress: progress)
                    }
                    
                    
            })
            } else{
            
                print("No Token found")
                self.getAccessToken(userName: userName, userPassword: userPassword, progress: progress)
        }
    }
    
    
    public func redirect(){
        
            self.performSegue(withIdentifier:"login_redirect", sender: nil)
    }

}



