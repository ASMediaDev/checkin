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
    
    @IBOutlet weak var scanStatus: UILabel!
 
    
    @IBOutlet weak var eventStatusTextView: UITextView!
    
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanStatus.backgroundColor = UIColor.lightGray
        
        view.backgroundColor = UIColor.black
        
        //Erzeugen einer neuen captureSession vom Typ AVCaptureSession
        captureSession = AVCaptureSession()
        
        //Anlegen und instanziierung eines neuen Capturedevices
        let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera , for: AVMediaType.video, position: .back)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
        } catch {
            return
        }
        
        //Hinzufügen des Devices zur captureSession
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        //Erzeugen und Hinzufügen eines Outputs zur captureSession
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resize;
        self.view.layer.addSublayer(previewLayer);
        
        captureSession.startRunning();
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dbview = DBViewController()
        
        print(dbview.countAttendees())
        
        if (dbview.countAttendees() == 0){
            
            print("Database empty")
            
            eventStatusTextView.text = "Bitte ein Event synchronisieren!"
            
            let alertController = UIAlertController(title: "Leere Datenbank!", message: "Bitte ein Event synchronisieren!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Verwaltung", style: .default) { action in
                
                self.performSegue(withIdentifier: "scan_to_login", sender: nil)
                
            }
            
            alertController.addAction(defaultAction)
            
            let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                
                
            }
            alertController.addAction(destroyAction)
            
            self.present(alertController, animated: true) {
                
            }
            
        }else{
            
            updateEventStatus()
        }
        
        
        
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
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            found(code: readableObject.stringValue!);
            
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: readableObject.stringValue!);
        }
    }
    
    func found(code: String) {
        
        let t1 = mach_absolute_time()
        
        
        let dbview = DBViewController()
        
        var attendee: String = ""
        
        let reference = Int(code)
        
        if(reference == nil){
            
            scanStatus.backgroundColor = UIColor.red
            scanStatus.text = "Code nicht lesbar!"
            
            self.scanStatus.backgroundColor = UIColor.lightGray
            self.scanStatus.text = "Kein QR-Code erkannt!"
            self.captureSession.startRunning()
            self.updateEventStatus()
            
            }else if(dbview.ticketExists(private_reference_number: reference!)){
            
                if(dbview.hasArrived(private_reference_number: reference!)==false){
                
                    attendee = dbview.getNameForTicket(private_reference_number: reference!)
                
                    scanStatus.backgroundColor = UIColor.green
                    scanStatus.text = attendee
                    
                    let t2 = mach_absolute_time()
                    
                    let elapsed = t2 - t1
                    var timeBaseInfo = mach_timebase_info_data_t()
                    mach_timebase_info(&timeBaseInfo)
                    let elapsedNano = elapsed * UInt64(timeBaseInfo.numer) / UInt64(timeBaseInfo.denom);
                    print("Validierungszeite: \(elapsedNano)")
                
                    let alertController = UIAlertController(title: "GÜLTIG", message: "Gast: \(attendee)", preferredStyle: .alert)
            
                    let defaultAction = UIAlertAction(title: "einchecken", style: .default) { action in
                        print(action)
                        dbview.checkIn(private_reference_number: reference!)
                        print("Checked in!")
                        self.scanStatus.backgroundColor = UIColor.lightGray
                        self.scanStatus.text = "Kein QR-Code erkannt!"
                        self.captureSession.startRunning()
                        self.updateEventStatus()
                    
                    }
                
                alertController.addAction(defaultAction)
            
                let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                print(action)
                self.scanStatus.backgroundColor = UIColor.lightGray
                self.scanStatus.text = "Kein QR-Code erkannt!"
                self.captureSession.startRunning()
               
                }
                alertController.addAction(destroyAction)
            
                self.present(alertController, animated: true) {
                
                }
            }
            else if(dbview.hasArrived(private_reference_number: reference!)==true){
                
                attendee = dbview.getNameForTicket(private_reference_number: reference!)
                
                let checkin_time = dbview.getCheckinTime(private_reference_number: reference!)
                                    
                scanStatus.backgroundColor = UIColor.yellow
                scanStatus.text = attendee
                
                
                let alertController = UIAlertController(title: "UNGÜLTIG", message: "Das Ticket wurde bereits verwendet. Datum: \(checkin_time)", preferredStyle: .alert)
                
                
                let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                    print(action)
                    self.captureSession.startRunning()
                    self.scanStatus.backgroundColor = UIColor.lightGray
                    self.scanStatus.text = "Kein QR-Code erkannt!"
                   
                }
                alertController.addAction(destroyAction)
                
                let cancelAction = UIAlertAction(title: "auschecken", style: .cancel) { action in
                    dbview.checkOut(private_reference_number: reference!)
                    self.captureSession.startRunning()
                    self.updateEventStatus()
                    self.scanStatus.backgroundColor = UIColor.lightGray
                    self.scanStatus.text = "Kein QR-Code erkannt!"
                }
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true) {
                    // ...
                }

                
                }
            
            } else {
            
            scanStatus.backgroundColor = UIColor.red
            let alertController = UIAlertController(title: "UNGÜLTIG", message: "Das Ticket ist nicht gültig", preferredStyle: .alert)
            
            
            let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                print(action)
                self.captureSession.startRunning()
                self.scanStatus.backgroundColor = UIColor.lightGray
                self.scanStatus.text = "Kein QR-Code erkannt!"
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

   
    
    @IBAction func toggleFlash(_ sender: Any) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {return}
        //let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        
        
    }
    
    
    func updateEventStatus(){
        
        let dbview = DBViewController()
        
        eventStatusTextView.text = "Event: \(dbview.getSyncedEvent()) Attendees: \(dbview.countAttendeesArrived())/\(dbview.countAttendees())"
        
    }
    
 
}

