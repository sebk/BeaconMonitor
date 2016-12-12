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
    
    fileprivate var _region: CLBeaconRegion?
    fileprivate var _peripheralManager: CBPeripheralManager?
    
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
    
    
    // MARK: CBPeripheralManagerDelegate
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn {
            
            let dataToBeAdvertised:[String: Any] = [
                CBAdvertisementDataLocalNameKey : _identifier as ImplicitlyUnwrappedOptional<AnyObject>,
                CBAdvertisementDataManufacturerDataKey : _region!.peripheralData(withMeasuredPower: nil),
                CBAdvertisementDataServiceUUIDsKey : [_uuid]
            ]
            
            //let data = _region!.peripheralDataWithMeasuredPower(nil)
            peripheral.startAdvertising(dataToBeAdvertised)
            
            print("Start advertising as Beacon")
        }
        else if peripheral.state == .poweredOff {
            
            peripheral.stopAdvertising()
            
            print("Stop advertising as Beacon")
        }
    }
    
}
