//
//  MainViewController.swift
//  TicketVal
//
//  Created by Alex on 20.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData


class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    

    
    @IBOutlet weak var displaycode: UILabel!
    
    @IBOutlet weak var previewOverlay: UIView!
    
    @IBOutlet weak var eventStatusTextView: UITextView!
    
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displaycode.backgroundColor = UIColor.lightGray
        //displaycode.alpha = 0.2
        //displaycode.text = "NO QR-CODE DETECTED"
        
        let dbview = DBViewController()
        
        if (dbview.countAttendees() == 0){
            
            eventStatusTextView.text = "No Event synchronized"
    
        }else{
            
            updateEventStatus()
        }
        

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResize;
        self.view.layer.addSublayer(previewLayer);
        
        captureSession.startRunning();
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: readableObject.stringValue);
        }
        
        //dismiss(animated: true)
    }
    
    func found(code: String) {
        
        print(code)
        displaycode.backgroundColor = UIColor.green
        //displaycode.text = code
        
        let dbview = DBViewController()
        
        var attendee: String = ""
        
        let reference = Int(code)
        
        if(reference == nil){
            
            print("false input")
            
            }else if(dbview.ticketExists(private_reference_number: reference!)){
            
                //print("Ticket exists")
            
            if(dbview.hasArrived(private_reference_number: reference!)==false){
                
            
                attendee = dbview.getNameforTicket(private_reference_number: reference!)
                
                displaycode.backgroundColor = UIColor.green
                displaycode.text = attendee
                
                
            
                let alertController = UIAlertController(title: "GÜLTIG", message: "Gast: \(attendee)", preferredStyle: .alert)
            
                let cancelAction = UIAlertAction(title: "einchecken", style: .cancel) { action in
                    print(action)
                    dbview.checkIn(private_reference_number: reference!)
                    print("Checked in!")
                    self.displaycode.backgroundColor = UIColor.lightGray
                    self.displaycode.text = "Kein QR-Code erkannt!"
                    self.captureSession.startRunning()
                    self.updateEventStatus()
                    
                }
                alertController.addAction(cancelAction)
            
                let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                print(action)
                self.displaycode.backgroundColor = UIColor.lightGray
                self.displaycode.text = "Kein QR-Code erkannt!"
                self.captureSession.startRunning()
               
                }
                alertController.addAction(destroyAction)
            
                self.present(alertController, animated: true) {
                
                }
            }
            else if(dbview.hasArrived(private_reference_number: reference!)==true){
                
                attendee = dbview.getNameforTicket(private_reference_number: reference!)
                
                let checkin_time = dbview.getCheckinTime(private_reference_number: reference!)
                                    
                displaycode.backgroundColor = UIColor.yellow
                displaycode.text = attendee
                
                
                let alertController = UIAlertController(title: "UNGÜLTIG", message: "Das Ticket wurde bereits verwendet. Datum: \(checkin_time)", preferredStyle: .alert)
                
                
                let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                    print(action)
                    self.captureSession.startRunning()
                    self.displaycode.backgroundColor = UIColor.lightGray
                    self.displaycode.text = "Kein QR-Code erkannt!"
                   
                }
                alertController.addAction(destroyAction)
                
                let cancelAction = UIAlertAction(title: "auschecken", style: .cancel) { action in
                    print(action)
                    dbview.checkOut(private_reference_number: reference!)
                    print("Checked out!")
                    self.captureSession.startRunning()
                    self.updateEventStatus()
                    self.displaycode.backgroundColor = UIColor.lightGray
                    self.displaycode.text = "Kein QR-Code erkannt!"
                }
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true) {
                    // ...
                }

                
                }
            
            } else {
            
            displaycode.backgroundColor = UIColor.red
            
                //print("Ticket doesn't exist!")
            let alertController = UIAlertController(title: "UNGÜLTIG", message: "Das Ticket ist nicht gültig", preferredStyle: .alert)
            
            
            let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                print(action)
                self.captureSession.startRunning()
                self.displaycode.backgroundColor = UIColor.lightGray
                self.displaycode.text = "Kein QR-Code erkannt!"
            }
            alertController.addAction(destroyAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        
}
        
        
        
     
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

   
    
    func toggleFlash() {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                } else {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    func updateEventStatus(){
        
        let dbview = DBViewController()
        
        eventStatusTextView.text = "Event: \(dbview.getSyncedEvent()) Attendees: \(dbview.countAttendeesArrived())/\(dbview.countAttendees())"
        
    }
    
 
}

