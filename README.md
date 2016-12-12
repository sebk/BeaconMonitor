# BeaconMonitor
Yet another Swift framework to monitor and range iBeacons.


## Act as Beacon

To use a iDevice as a Beacon:

    BeaconSender.sharedInstance.startSending("A1111111-B111-C111-D111-E11111111111",
                    majorID: 1,
                    minorID: 2,
                    identifier: "TEST")


## Listen for Beacons

The BeaconMonitor class provides different init methods:

* `init(uuid: NSUUID)`: Listen for Beacons with the given proximity UUID
* `init(uuids: [NSUUID])`: Listen for multiple UUIDs
* `init(beacons: [Beacon])`: Listen for explicit Beacons


**Example:**

	import BeaconMonitor
    import CoreLocation

    class ListenViewController: UIViewController {

        var monitor: BeaconMonitor?

        override func viewDidLoad() {
        	super.viewDidLoad()

        	monitor = BeaconMonitor(uuid: NSUUID(UUIDString: uuidTextfield.text!)!)
        	monitor!.delegate = self
        	monitor!.startListening()
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

**Stop listening**:

* `stopListening()`: Stop listening completly
* `stopListening(uuid: NSUUID)`: Stop listening for a concrete UUID


# Icon

iBeacon icon in tableView by [icons8](https://icons8.com/web-app/13645/ibeacon)
