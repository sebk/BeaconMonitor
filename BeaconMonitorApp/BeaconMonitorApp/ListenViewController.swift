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

// Demo ViewController to show a list of received CLBeacons.
class ListenViewController: UIViewController , UITextFieldDelegate {
    
    // BeaconMonitor ro receive CLBeacons
    private var monitor: BeaconMonitor?
    
    // Defines the states of the UISegmentedControl
    private enum SegmentControlSelection: Int {
        case allBeaconsSelection = 0
        case knownBeaconsSelection = 1
    }
    // Holds the current selected UISegmentedControl enum definition.
    private var selectedList = SegmentControlSelection.allBeaconsSelection
    
    // Holds are currently received CLBeacons.
    fileprivate var allBeacons: [CLBeacon]? {
        didSet {
            self.tableView.reloadData() //simple, only for demo; In a real App this should be handled better.
        }
    }
    // Holds are currently received CLBeacons, that matches defined Beacons.
    fileprivate var knownBeacons: [CLBeacon]? {
        didSet {
            self.tableView.reloadData() //simple, only for demo; In a real App this should be handled better.
        }
    }
    
    // Returns the correct CLBeacon Array according to the UISegmentedControl selection.
    fileprivate var currentDataSource: [CLBeacon]? {
        get {
            if self.selectedList == SegmentControlSelection.allBeaconsSelection {
                return self.allBeacons
            }
            else {
                return self.knownBeacons
            }
        }
    }
    
    @IBOutlet weak var uuidTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!

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
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        selectedList = ListenViewController.SegmentControlSelection(rawValue: sender.selectedSegmentIndex)!
        
        tableView.reloadData()
    }


}

extension ListenViewController: BeaconMonitorDelegate {
    
    @objc func receivedAllBeacons(_ monitor: BeaconMonitor, beacons: [CLBeacon]) {
        
        print("All Beacons: \(beacons)")
        
        allBeacons = beacons
    }
    
    @objc func receivedMatchingBeacons(_ monitor: BeaconMonitor, beacons: [CLBeacon]) {
        
        print("Matching Beacons: \(beacons)")
        
        knownBeacons = beacons
    }
    
}

// Show the received CLBeacons in a tableView
extension ListenViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = currentDataSource?.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if !(cell != nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell?.selectionStyle = .none
        }
        
        if let beacon = currentDataSource?[indexPath.row] {
            
            cell?.textLabel?.text = "Major: \(beacon.major), Minor: \(beacon.minor)"
            cell?.imageView?.image = UIImage(named: "iBeacon")
        }
        
        return cell!
    }
    
}

