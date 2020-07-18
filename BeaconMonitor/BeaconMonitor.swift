//
//  BeaconMonitor.swift
//  BeaconMonitor
//
//  Created by Sebastian Kruschwitz on 17.09.15.
//  Copyright © 2015 seb. All rights reserved.
//

import Foundation
import CoreLocation

/*
https://community.estimote.com/hc/en-us/articles/203356607-What-are-region-Monitoring-and-Ranging-
Monitoring: 
    * actions triggered on entering/exiting region’s range; works in the foreground, background, and even when the app is killed.
    * Monitoring a region enables your app to know when a device enters or exits the range of beacons defined by the region.
Ranging: 
    * actions triggered based on proximity to a beacon; works only in the foreground.
    * It returns a list of beacons in range, together with an estimated distance to each of them.

Background vs Foreground:
http://www.scriptscoop.com/t/194508ceaf47/ios-detecting-beacons-via-ibeacon-monitoring-ranging-vs-corebluetooth-scan.html
*/

/// Implement this protocol to receive notifications.
@objc public protocol BeaconMonitorDelegate {
    
    /// Will be called every time the CLLocationManager receives CLBeacons.
    @objc optional func receivedAllBeacons(_ monitor: BeaconMonitor, beacons: [CLBeacon])
    
    /// Will be called every time the CLLOcationManager receives CLBeacons, that matches to a set list of Beacons.
    @objc optional func receivedMatchingBeacons(_ monitor: BeaconMonitor, beacons: [CLBeacon])
    
    /// Will be called when the CLLocationManager reports the "did enter region" event.
    @objc optional func didEnterRegion(_ region: CLRegion)
    
    /// Will be called when the CLLocationManager reports the "did exit region" event.
    @objc optional func didExitRegion(_ region: CLRegion)
}

/// Class to receive CLBeacons and notify the delegate.
open class BeaconMonitor: NSObject  {
    
    open var delegate: BeaconMonitorDelegate?
    
    /// Define if the BeaconMonitorDelegate methods should also be called when the received list of beacons is empty.
    open var reportWhenEmpty = false
    
    // Name that is used as the prefix for the region identifier.
    fileprivate let regionIdentifier = "BeaconMonitor"
    
    // CLLocationManager that will listen and react to Beacons.
    fileprivate var locationManager: CLLocationManager?

    /* Dictionary containing the CLBeaconRegions the locationManager is listening to. Each region is assigned to it's UUID String as the key.
        The String key in this dictionary is used as the unique key: This means, that each CLBeaconRegion will be unique by it's UUID.
        A CLBeaconRegion is unique by it's 'identifier' and not it's UUID. When using this default unique key a dictionary would not be necessary. */
    fileprivate var regions = [String: CLBeaconRegion]()
    
    // List of Beacons the monitor should listen on.
    fileprivate var beaconsListening: [Beacon]?
    
    
    // MARK: - Init methods
    
    /**
    Init the BeaconMonitor and listen only to the given UUID.
    - parameter uuid: NSUUID for the region the locationManager is listening to.
    - returns: Instance
    */
    public init(uuid: UUID) {
        super.init()
        
        regions[uuid.uuidString] = self.regionForUUID(uuid)
    }
    
    /**
    Init the BeaconMonitor and listen to multiple UUIDs.
    - parameter uuids: Array of UUIDs for the regions the locationManager should listen to.
    - returns: Instance
    */
    public init(uuids: [UUID]) {
        super.init()
        
        for uuid in uuids {
            regions[uuid.uuidString] = self.regionForUUID(uuid)
        }
    }
    
    /**
    Init the BeaconMonitor and listen only to the given Beacons.
    The UUID(s) for the regions will be extracted from the Beacon Array. When Beacons with different UUIDs are defined multiple regions will be created.
    - parameter beacons: Beacon instances the BeaconMonitor is listening for
    - returns: Instance
    */
    public init(beacons: [Beacon]) {
        super.init()
        
        beaconsListening = beacons
        
        // create a CLBeaconRegion for each different UUID
        for uuid in distinctUnionOfUUIDs(beacons) {
            
            regions[uuid.uuidString] = self.regionForUUID(uuid)
        }
    }
    
    /**
     Init the BeaconMonitor and listen to the given Beacon.
     From the Beacon values (uuid, major and minor) a concrete CLBeaconRegion will be created.
     - parameter beacon: Beacon instance the BeaconMonitor is listening for and it will be used to create a concrete CLBeaconRegion.
     - returns: Instance
     */
    public init(beacon: Beacon) {
        super.init()
        
        beaconsListening = [beacon]
        
        regions[beacon.uuid.uuidString] = self.regionForBeacon(beacon)
    }
    
    
    // MARK: - Listen/Stop
    
    /**
    Start listening for Beacons.
    The settings are used from the init mthod.
    */
    open func startListening() {
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager!.requestAlwaysAuthorization()
        }
    }
    
    /**
    Stop listening for all regions.
    */
    open func stopListening() {
        for (uuid, region) in regions {
            stopListening(region)
            regions[uuid] = nil
        }
    }
    
    /**
    Stop listening only for the region with the given UUID.
    - parameter uuid: UUID of the region to stop listening for
    */
    open func stopListening(_ uuid: UUID) {
        if let region = regions[uuid.uuidString] {
            stopListening(region)
            regions[uuid.uuidString] = nil
        }
    }
    
    
    // MARK: - Private Helper
    
    fileprivate func regionForUUID(_ uuid: UUID) -> CLBeaconRegion {
        let region = CLBeaconRegion(proximityUUID: uuid, identifier: "\(regionIdentifier)-\(uuid.uuidString)")
        region.notifyEntryStateOnDisplay = true
        return region
    }
    
    fileprivate func regionForBeacon(_ beacon: Beacon) -> CLBeaconRegion {
        let region = CLBeaconRegion(proximityUUID: beacon.uuid as UUID,
                                    major: CLBeaconMajorValue(beacon.major.int32Value),
                                    minor: CLBeaconMinorValue(beacon.minor.int32Value),
                                    identifier: "\(regionIdentifier)-\(beacon.uuid.uuidString)")
        region.notifyEntryStateOnDisplay = true
        return region
    }
    
    fileprivate func stopListening(_ region: CLBeaconRegion) {
        locationManager?.stopRangingBeacons(in: region)
        locationManager?.stopMonitoring(for: region)
    }
    
    // http://stackoverflow.com/a/26358719/470964
    fileprivate func distinctUnionOfUUIDs(_ beacons: [Beacon]) -> [UUID] {
        var dict = [UUID : Bool]()
        let filtered = beacons.filter { (element: Beacon) -> Bool in
            if dict[element.uuid as UUID] == nil {
                dict[element.uuid as UUID] = true
                return true
            }
            return false
        }
        
        return filtered.map { ($0.uuid as UUID)}
    }
    
}


// MARK: - CLLocationManagerDelegate

extension BeaconMonitor: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        let allBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        
        // Filter received Beacons with the provided Beacon array
        var matchingBeacons = [CLBeacon]()
        if beaconsListening != nil {
            for b in allBeacons {
                if beaconsListening!.contains(where: { $0.major == b.major && $0.minor == b.minor && $0.uuid as UUID == b.proximityUUID }) {
                    matchingBeacons.append(b)
                }
            }
        }
        
        
        /* Call the delegate methods and provide the CLBeacon array */
        
        if reportWhenEmpty && matchingBeacons.isEmpty {
            delegate?.receivedMatchingBeacons?(self, beacons: matchingBeacons)
        }
        else if !matchingBeacons.isEmpty {
            delegate?.receivedMatchingBeacons?(self, beacons: matchingBeacons)
        }
        
        if reportWhenEmpty && allBeacons.isEmpty {
            delegate?.receivedAllBeacons?(self, beacons: allBeacons)
        }
        else if !allBeacons.isEmpty {
            delegate?.receivedAllBeacons?(self, beacons: allBeacons)
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("did start monitoring")
        
        manager.requestState(for: region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        print("Did determine state")
        
        if (state == .inside) {
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        }
        else {
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        }
    }
    
    // When is this method called? -> http://stackoverflow.com/a/30107511/470964
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .notDetermined:
            manager.requestAlwaysAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
           
            for (_, region) in regions {
                print("start monitoring")
                manager.startMonitoring(for: region)
            }
            
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        @unknown default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("Did Enter region \(region.identifier)")
        
        delegate?.didEnterRegion?(region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        print("Did Exit region \(region.identifier)")
        
        delegate?.didExitRegion?(region)
    }
    
}
