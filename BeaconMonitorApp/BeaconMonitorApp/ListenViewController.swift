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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        //let beacon = Beacon(uuid: NSUUID(UUIDString: "A1111111-B111-C111-D111-E11111111111")!, minor: 121, major: 3)
        
        //monitor = BeaconMonitor(beacons: [beacon])
        
        

        
    }

    @IBAction func switchChanged(sender: UISwitch) {
        
        if sender.on {
            
            if uuidTextfield.text != "" {
                
                monitor = BeaconMonitor(uuid: NSUUID(UUIDString: uuidTextfield.text!)!)
            }
            
            monitor!.delegate = self
            monitor!.startListening()
        }
        else {
            
            monitor?.stopListening()
        }

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}

extension ListenViewController: BeaconMonitorDelegate {
    
    @objc func receivedAllBeacons(monitor: BeaconMonitor, beacons: [CLBeacon]) {
        
        print("All Beacons: \(beacons)")
    }
    
    @objc func receivedMatchingBeacons(monitor: BeaconMonitor, beacons: [CLBeacon]) {
        
        print("Matching Beacons: \(beacons)")
        
    }
    
}

