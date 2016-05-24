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


@objc public protocol BeaconMonitorDelegate {
    
    optional func receivedAllBeacons(monitor: BeaconMonitor, beacons: [CLBeacon])
    
    optional func receivedMatchingBeacons(monitor: BeaconMonitor, beacons: [CLBeacon])
    
}


public class BeaconMonitor: NSObject  {
    
    public var delegate: BeaconMonitorDelegate?
    
    // Name that is used as the prefix for the region identifier.
    private let regionIdentifier = "BeaconMonitor"
    
    // CLLocationManager that will listen and react to Beacons.
    private var locationManager: CLLocationManager?

    // Dictionary containing the CLBeaconRegions the locationManager is listening to. Each region is assigned to it's UUID as the key.
    private var regions = [NSUUID: CLBeaconRegion]()
    
    private var beaconsListening: [Beacon]?
    
    
    // MARK: - Init methods
    
    /**
    Init the BeaconMonitor and listen only to the given UUID.
    - parameter uuid: NSUUID for the region the locationManager is listening to.
    - returns: Instance
    */
    public init(uuid: NSUUID) {
        super.init()
        
        regions[uuid] = self.regionForUUID(uuid)
    }
    
    /**
    Init the BeaconMonitor and listen to multiple UUIDs.
    - parameter uuids: Array of UUIDs for the regions the locationManager should listen to.
    - returns: Instance
    */
    public init(uuids: [NSUUID]) {
        super.init()
        
        for uuid in uuids {
            regions[uuid] = self.regionForUUID(uuid)
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
            
            regions[uuid] = self.regionForUUID(uuid)
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
        
        regions[beacon.uuid] = self.regionForBeacon(beacon)
    }
    
    
    // MARK: - Listen/Stop
    
    /**
    Start listening for Beacons.
    The settings are used from the init mthod.
    */
    public func startListening() {
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager!.requestAlwaysAuthorization()
        }
    }
    
    /**
    Stop listening for all regions.
    */
    public func stopListening() {
        for (uuid, region) in regions {
            stopListening(region)
            regions[uuid] = nil
        }
    }
    
    /**
    Stop listening only for the region with the given UUID.
    - parameter uuid: UUID of the region to stop listening for
    */
    public func stopListening(uuid: NSUUID) {
        if let region = regions[uuid] {
            stopListening(region)
            regions[uuid] = nil
        }
    }
    
    
    // MARK: - Private Helper
    
    private func regionForUUID(uuid: NSUUID) -> CLBeaconRegion {
        let region = CLBeaconRegion(proximityUUID: uuid, identifier: "\(regionIdentifier)-\(uuid)")
        region.notifyEntryStateOnDisplay = true
        return region
    }
    
    private func regionForBeacon(beacon: Beacon) -> CLBeaconRegion {
        let region = CLBeaconRegion(proximityUUID: beacon.uuid,
                                    major: CLBeaconMajorValue(beacon.major.intValue),
                                    minor: CLBeaconMinorValue(beacon.minor.intValue),
                                    identifier: "\(regionIdentifier)-\(beacon.uuid)")
        region.notifyEntryStateOnDisplay = true
        return region
    }
    
    private func stopListening(region: CLBeaconRegion) {
        locationManager?.stopRangingBeaconsInRegion(region)
        locationManager?.stopMonitoringForRegion(region)
    }
    
    // http://stackoverflow.com/a/26358719/470964
    private func distinctUnionOfUUIDs(beacons: [Beacon]) -> [NSUUID] {
        var dict = [NSUUID : Bool]()
        let filtered = beacons.filter { (element: Beacon) -> Bool in
            if dict[element.uuid] == nil {
                dict[element.uuid] = true
                return true
            }
            return false
        }
        
        return filtered.map { $0.uuid}
    }
    
}


// MARK: - CLLocationManagerDelegate

extension BeaconMonitor: CLLocationManagerDelegate {
    
    public func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        
        // Filter received Beacons with the provided Beacon array
        var matchingBeacons = [CLBeacon]()
        if beaconsListening != nil {
            for b in knownBeacons {
                if beaconsListening!.contains({ $0.major == b.major && $0.minor == b.minor && $0.uuid == b.proximityUUID }) {
                    matchingBeacons.append(b)
                }
            }
        }
        
        if matchingBeacons.count > 0 {
            delegate?.receivedMatchingBeacons?(self, beacons: matchingBeacons)
        }
        
        if knownBeacons.count > 0 {
            delegate?.receivedAllBeacons?(self, beacons: knownBeacons)
        }
        
    }
    
    public func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        
        print("did start monitoring")
        
        manager.requestStateForRegion(region)
    }
    
    public func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
        print("Did determine state")
        
        if (state == .Inside) {
            manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
        }
        else {
            manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
        }
    }
    
    // When is this method called? -> http://stackoverflow.com/a/30107511/470964
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        switch status {
        case .NotDetermined:
            manager.requestAlwaysAuthorization()

        case .AuthorizedWhenInUse, .AuthorizedAlways:
           
            for (_, region) in regions {
                print("start monitoring")
                manager.startMonitoringForRegion(region)
            }
            
        case .Restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .Denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
    }
    
    public func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("Did Enter region")
    }
    
    public func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        print("Did Exit region")
    }
    
}