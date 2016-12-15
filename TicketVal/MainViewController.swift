//
//  MainViewController.swift
//  TicketVal
//
//  Created by Alex on 16.11.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let gradientLayer = CAGradientLayer()

    @IBOutlet weak var scan: UIButton!
    
    @IBOutlet weak var database: UIButton!
    
    @IBOutlet weak var databasewarning: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topcolor = UIColor(red:0.90, green:0.62, blue:0.01, alpha:1.0)
        let bottomcolor = UIColor(red:1.00, green:0.45, blue:0.00, alpha:1.0)
        
        let gradientColors: [CGColor] = [topcolor.cgColor, bottomcolor.cgColor]
        let gradientLocations : [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        scan.layer.cornerRadius = 10.0
        database.layer.cornerRadius = 10.0
        
        print("landingpage")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkdb()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkdb(){
        let count = DBViewController().countcodes()
        
        if count == 0{
            
            databasewarning.text = "Achtung: Es befinden sich keine Tickets in der Datenbank!"
            
        }
        else{
            
              databasewarning.text = "Es befinden sich \(count) Tickets in der Datenbank"
            
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

}
