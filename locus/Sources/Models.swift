import Foundation
import CoreLocation

enum TrackKind: String, Codable, CaseIterable, Identifiable {
    case device, item, person, thisMac, importFile
    var id: String { rawValue }
    var label: String {
        switch self {
        case .device: return "Gerät"
        case .item: return "Item"
        case .person: return "Person"
        case .thisMac: return "Dieser Mac"
        case .importFile: return "Import"
        }
    }
}

struct Fix: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var kind: TrackKind
    var lat: Double
    var lon: Double
    var altitude: Double?
    var accuracy: Double?
    var timestamp: Date
    var source: String

    var coord: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var timeLabel: String {
        Fix.stamp.string(from: timestamp)
    }

    static let stamp: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_CH")
        f.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return f
    }()
}

struct Track: Identifiable, Hashable {
    var id: String
    var name: String
    var kind: TrackKind
    var points: [Fix]
}
