//
//  Beacon.swift
//  BeaconMonitor
//
//  Created by Sebastian Kruschwitz on 18.09.15.
//  Copyright © 2015 seb. All rights reserved.
//

import Foundation

/**
Struct to represent a Beacon the BeaconMonitor should be listening to.
*/
public struct Beacon {
    
    public var uuid: UUID
    public var minor: NSNumber
    public var major: NSNumber
    
    public init(uuid: UUID, minor: NSNumber, major: NSNumber) {
        self.uuid = uuid
        self.minor = minor
        self.major = major
    }
}
