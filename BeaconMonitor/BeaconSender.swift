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

public class BeaconSender: NSObject, CBPeripheralManagerDelegate {
    
    public static let sharedInstance = BeaconSender()
    
    private var _region: CLBeaconRegion?
    private var _peripheralManager: CBPeripheralManager?
    
    private var _uuid = ""
    private var _identifier = ""
    
    
    public func startSending(UUID uuid: String, majorID: CLBeaconMajorValue, minorID: CLBeaconMinorValue, identifier: String) {
        
        _uuid = uuid
        _identifier = identifier
        
        stopSending() //stop sending when it's active
        
        // create the region that will be used to send
        _region = CLBeaconRegion(
            proximityUUID: NSUUID(UUIDString: uuid)!,
            major: majorID,
            minor: minorID,
            identifier: identifier)
        
        _peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    public func stopSending() {
        
        _peripheralManager?.stopAdvertising()
    }
    
    
    // MARK: CBPeripheralManagerDelegate
    
    public func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {

        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            
            let dataToBeAdvertised:[String: AnyObject!] = [
                CBAdvertisementDataLocalNameKey : _identifier,
                CBAdvertisementDataManufacturerDataKey : _region!.peripheralDataWithMeasuredPower(nil),
                CBAdvertisementDataServiceUUIDsKey : [_uuid],
            ]
            
            //let data = _region!.peripheralDataWithMeasuredPower(nil)
            peripheral.startAdvertising(dataToBeAdvertised)
            
            print("Start advertising as Beacon")
        }
        else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            
            peripheral.stopAdvertising()
            
            print("Stop advertising as Beacon")
        }
        
    }
    
}