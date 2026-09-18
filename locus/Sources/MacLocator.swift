import Foundation
import CoreLocation

final class MacLocator: NSObject, CLLocationManagerDelegate {
    private let mgr = CLLocationManager()
    private var last: CLLocation?

    override init() {
        super.init()
        mgr.delegate = self
        mgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func request() {
        mgr.requestWhenInUseAuthorization()
        mgr.startUpdatingLocation()
    }

    func currentFix() -> Fix? {
        guard let loc = last ?? mgr.location else { return nil }
        return Fix(
            id: "this-mac",
            name: Host.current().localizedName ?? "Dieser Mac",
            kind: .thisMac,
            lat: loc.coordinate.latitude,
            lon: loc.coordinate.longitude,
            altitude: loc.altitude,
            accuracy: loc.horizontalAccuracy,
            timestamp: loc.timestamp,
            source: "CoreLocation"
        )
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        last = locations.last
    }
}
