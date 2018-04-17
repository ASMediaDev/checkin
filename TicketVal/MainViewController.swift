//
//  MainViewController.swift
//  TicketVal
//
//  Created by Alex on 16.11.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Locksmith

class MainViewController: UIViewController {
    
    let gradientLayer = CAGradientLayer()
    
    let dbview = DBViewController()
    
    @IBOutlet weak var scan: UIButton!
    
    @IBOutlet weak var maint: UIButton!
    
    @IBOutlet weak var status_textview: UITextView!
 

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
        maint.layer.cornerRadius = 10.0
    
        if(dbview.countAttendees()==0){
            
            status_textview.text = "Es befinden sich keine Gäste in der Datenbank!"
            
        }else {
            
            status_textview.text = "Synchronisiertes Event: \n \(dbview.getSyncedEvent()) \n \n Anzahl der Gäste: \(dbview.countAttendees())"
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
