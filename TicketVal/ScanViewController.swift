//
//  MainViewController.swift
//  TicketVal
//
//  Created by Alex on 20.06.16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import AVFoundation


class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    

    
    @IBOutlet weak var displaycode: UILabel!
   
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        displaycode.backgroundColor = UIColor.red
        displaycode.text = "NO QR-CODE DETECTED"
        
        
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
        displaycode.text = code
        
        let attendee = "Alexander Seitz"
        
        
        if (code == "JSKDJAKSJ"){
            
            displaycode.text = attendee
        
            let alertController = UIAlertController(title: "GÜLTIG", message: "Gast: \(attendee)", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "einchecken", style: .cancel) { action in
                print(action)
                self.captureSession.startRunning()
            }
            alertController.addAction(cancelAction)
            
            let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                print(action)
                self.captureSession.startRunning()
            }
            alertController.addAction(destroyAction)
            
            self.present(alertController, animated: true) {
                
            }
            
        }else{
            
            let alertController = UIAlertController(title: "UNGÜLTIG", message: "Das Ticket ist nicht gültig", preferredStyle: .alert)
            
            
            let destroyAction = UIAlertAction(title: "abbrechen", style: .destructive) { action in
                print(action)
                self.captureSession.startRunning()
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
    
 
}

