import CoreGraphics
import Foundation

enum AppVersion {
    static let marketing = "1.0.4"
    static let channel = "alpha"
    static let display = "1.0.4 alpha"
}

enum StrategyID: String, CaseIterable, Identifiable, Codable {
    case photosStyle
    case visionBox
    case landmarkGeo
    case ratios
    case faceShape
    case qualityGate
    case temporal
    case featurePrint
    case aegis

    var id: String { rawValue }

    var label: String {
        switch self {
        case .photosStyle: return "Fotos-Stil"
        case .visionBox: return "Vision Box"
        case .landmarkGeo: return "Landmark-Geometrie"
        case .ratios: return "Gesichtsmaße"
        case .faceShape: return "Gesichtsform"
        case .qualityGate: return "Quality-Gate"
        case .temporal: return "Temporal"
        case .featurePrint: return "Feature Print"
        case .aegis: return "Aegis Ensemble"
        }
    }

    var blurb: String {
        switch self {
        case .photosStyle:
            return "Einzelnes Best-Frame, harte Qualitätsgrenze — analog zur Apple-Fotos-Pipeline."
        case .visionBox:
            return "Vision-Detektor (Revision 3) plus Feature Print auf dem Zuschnitt."
        case .landmarkGeo:
            return "Landmark-Form, Procrustes-normalisiert. Lichtunabhängig."
        case .ratios:
            return "Nasenhöhe zu Augen, Augenbreite, Mund — trennt ähnliche Gesichter."
        case .faceShape:
            return "Kiefer, Wangen, Aspekt, Kinn. Unabhängig vom Feature Print."
        case .qualityGate:
            return "Feature Print, gewichtet mit VNFaceCaptureQuality statt Verwerfung."
        case .temporal:
            return "Qualitätsgewichteter Mittelwert über Video-Tracks."
        case .featurePrint:
            return "VNGenerateImageFeaturePrintRequest auf ausgerichtetem Gesicht."
        case .aegis:
            return "Fusion aller Signale. Hält schwierige Frames, statt sie zu löschen."
        }
    }
}

struct FaceBox: Codable, Hashable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

struct Point2: Codable, Hashable {
    var x: Double
    var y: Double
}

struct FaceQuality: Codable, Hashable {
    var sharpness: Double
    var size: Double
    var frontal: Double
    var capture: Double
}

struct MediaItem: Identifiable, Hashable {
    let id: UUID
    var url: URL
    var name: String
    var kind: Kind
    var width: Int
    var height: Int
    var duration: Double?
    var parentId: UUID?
    var timeSec: Double?
    var preview: CGImage?

    enum Kind: String, Hashable {
        case photo, video, frame, live
    }
}

struct FaceObservation: Identifiable, Hashable {
    let id: UUID
    var mediaId: UUID
    var box: FaceBox
    var score: Double
    var landmarks: [Point2]
    var aligned: [Point2]
    var featurePrint: Data
    var quality: FaceQuality
    var trackId: UUID?
}

struct Identity: Identifiable, Hashable {
    let id: UUID
    var name: String
    var faceIds: [UUID]
}

struct IdentityScore: Hashable {
    var identityId: UUID
    var percent: Double
    var distance: Double? = nil
}

struct StrategyHit: Hashable {
    var strategy: StrategyID
    var identityId: UUID?
    var percent: Double
    var distance: Double? = nil
    var margin: Double = 0
    var versus: [IdentityScore] = []
}

struct MatchResult: Hashable {
    var faceId: UUID
    var hits: [StrategyHit]
}
