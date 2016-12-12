//
//  BroadcastViewController.swift
//  BeaconMonitorApp
//
//  Created by Sebastian Kruschwitz on 20.09.15.
//  Copyright © 2015 seb. All rights reserved.
//

import Foundation
import UIKit
import BeaconMonitor

// ViewController that is used to enable iBeacon broadcasting (broadcast/transmit the decive as a iBeacon).
class BroadcastViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var uuidTextField: UITextField!
    
    @IBOutlet weak var majorTextField: UITextField!
    
    @IBOutlet weak var minorTextField: UITextField!
    
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            
            if uuidTextField.text != "" && majorTextField.text != "" && minorTextField.text != "" {
                
                BeaconSender.sharedInstance.startSending(uuid: uuidTextField.text!,
                    majorID: UInt16(majorTextField.text!)!,
                    minorID: UInt16(minorTextField.text!)!,
                    identifier: "TEST")
            }
            else {
                sender.setOn(false, animated: true)
            }
        }
        else {
            
            BeaconSender.sharedInstance.stopSending()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}
