import SwiftUI
import MapKit

struct MapPane: NSViewRepresentable {
    var points: [Fix]
    var selected: Fix?
    var onSelect: (Fix) -> Void

    func makeNSView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsCompass = true
        map.showsZoomControls = true
        map.showsScale = true
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.isRotateEnabled = true
        return map
    }

    func updateNSView(_ map: MKMapView, context: Context) {
        context.coordinator.onSelect = onSelect
        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations)
        let coords = points.map(\.coord)
        if coords.count >= 2 {
            let line = MKPolyline(coordinates: coords, count: coords.count)
            map.addOverlay(line)
        }
        for p in points {
            let a = MKPointAnnotation()
            a.coordinate = p.coord
            a.title = p.name
            a.subtitle = p.timeLabel
            map.addAnnotation(a)
        }
        if let s = selected {
            map.setCenter(s.coord, animated: true)
        } else if !coords.isEmpty {
            let r = MKCoordinateRegion(center: coords[coords.count / 2], latitudinalMeters: 4000, longitudinalMeters: 4000)
            map.setRegion(r, animated: false)
        }
    }

    func makeCoordinator() -> Coord { Coord() }

    final class Coord: NSObject, MKMapViewDelegate {
        var onSelect: ((Fix) -> Void)?
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let r = MKPolylineRenderer(overlay: overlay)
            r.strokeColor = NSColor.systemOrange
            r.lineWidth = 3
            return r
        }
    }
}
