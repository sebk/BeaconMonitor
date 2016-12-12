//
//  ViewController.swift
//  BeaconMonitorApp
//
//  Created by Sebastian Kruschwitz on 16.09.15.
//  Copyright © 2015 seb. All rights reserved.
//

import UIKit
import BeaconMonitor
import CoreLocation

class ListenViewController: UIViewController , UITextFieldDelegate {
    
    var monitor: BeaconMonitor?
    
    @IBOutlet weak var uuidTextfield: UITextField!

    @IBAction func switchChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            
            if uuidTextfield.text != "" {
                
                monitor = BeaconMonitor(uuid: UUID(uuidString: uuidTextfield.text!)!)
            }
            
            monitor!.delegate = self
            monitor!.startListening()
        }
        else {
            
            monitor?.stopListening()
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}

extension ListenViewController: BeaconMonitorDelegate {
    
    @objc func receivedAllBeacons(_ monitor: BeaconMonitor, beacons: [CLBeacon]) {
        
        print("All Beacons: \(beacons)")
    }
    
    @objc func receivedMatchingBeacons(_ monitor: BeaconMonitor, beacons: [CLBeacon]) {
        
        print("Matching Beacons: \(beacons)")
        
    }
    
}

