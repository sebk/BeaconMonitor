//
//  BeaconSender.swift
//  BeaconMonitor
//
//  Created by Sebastian Kruschwitz on 16.09.15.
//  Copyright © 2015 seb. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

public class BeaconSender: NSObject {
    
    public static let sharedInstance = BeaconSender()
    
    fileprivate var _region: CLBeaconRegion?
    fileprivate var _peripheralManager: CBPeripheralManager!
    
    fileprivate var _uuid = ""
    fileprivate var _identifier = ""
    
    
    public func startSending(uuid: String, majorID: CLBeaconMajorValue, minorID: CLBeaconMinorValue, identifier: String) {
        
        _uuid = uuid
        _identifier = identifier
        
        stopSending() //stop sending when it's active
        
        // create the region that will be used to send
        _region = CLBeaconRegion(
            proximityUUID: UUID(uuidString: uuid)!,
            major: majorID,
            minor: minorID,
            identifier: identifier)
        
        _peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    open func stopSending() {
        
        _peripheralManager?.stopAdvertising()
    }
    
}

//MARK: - CBPeripheralManagerDelegate

extension BeaconSender: CBPeripheralManagerDelegate {
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn {
            
            let data = ((_region?.peripheralData(withMeasuredPower: nil))! as NSDictionary) as! Dictionary<String, Any>
            peripheral.startAdvertising(data)
            
            print("Powered On -> start advertising")
        }
        else if peripheral.state == .poweredOff {
            
            peripheral.stopAdvertising()
            
            print("Powered Off -> stop advertising")
        }
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Error starting advertising: \(error)")
        }
        else {
            print("Did start advertising")
        }
    }
}
