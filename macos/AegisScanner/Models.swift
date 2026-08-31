import CoreGraphics
import Foundation

enum AppVersion {
    static let marketing = "2.0.1"
    static let channel = "alpha"
    static let display = "2.0.1 alpha"
}

enum StrategyID: String, CaseIterable, Identifiable, Codable {
    case photosStyle
    case visionBox
    case landmarkGeo
    case ratios
    case faceShape
    case eyeRegion
    case midface
    case jawline
    case graphBio
    case geom3d
    case texture
    case qualityGate
    case temporal
    case featurePrint
    case terFusion
    case aegis

    var id: String { rawValue }

    var label: String {
        switch self {
        case .photosStyle: return "Fotos-Stil"
        case .visionBox: return "Vision Box"
        case .landmarkGeo: return "Landmark-Geometrie"
        case .ratios: return "Gesichtsmaße"
        case .faceShape: return "Gesichtsform"
        case .eyeRegion: return "Augenregion"
        case .midface: return "Mittelgesicht"
        case .jawline: return "Kieferlinie"
        case .graphBio: return "Graph-Biomarker"
        case .geom3d: return "3D-Geometrie"
        case .texture: return "Aussehen"
        case .qualityGate: return "Quality-Gate"
        case .temporal: return "Temporal"
        case .featurePrint: return "Feature Print"
        case .terFusion: return "TER-Fusion"
        case .aegis: return "Aegis Ensemble"
        }
    }

    var blurb: String {
        switch self {
        case .photosStyle: return "Einzelnes Best-Frame, harte Qualitätsgrenze."
        case .visionBox: return "Vision-Detektor plus Face-Print."
        case .landmarkGeo: return "Landmark-Form, Augen-Procrustes IOD=1."
        case .ratios: return "Verhältnisse zur Augenabstands-Einheit."
        case .faceShape: return "Kiefer, Wangen, Höhe."
        case .eyeRegion: return "Lidspalten und Augenwinkel / IOD."
        case .midface: return "Nase und Philtrum."
        case .jawline: return "Kieferbreite und Kinn."
        case .graphBio: return "KNN-6 über Knochenpunkte."
        case .geom3d: return "IOD-Verhältnisse und Winkel."
        case .texture: return "Helligkeitsraster, nur Veto."
        case .qualityGate: return "Qualität vor Zuordnung."
        case .temporal: return "Video-Face-Print über Tracks."
        case .featurePrint: return "VNGenerateFacePrintRequest."
        case .terFusion: return "TER-Fusion nach Jain."
        case .aegis: return "Beweis-Identifikation. Unbekannt bleibt normal."
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
    enum Kind: String, Hashable { case photo, video, frame, live }
}

struct LandmarkStroke: Hashable {
    var label: String
    var closed: Bool
    var points: [Point2]
}

struct NamedRatio: Hashable {
    var id: String
    var label: String
    var value: Double
    var group: String
    var identity: Bool
}

struct FaceObservation: Identifiable, Hashable {
    let id: UUID
    var mediaId: UUID
    var box: FaceBox
    var score: Double
    var landmarks: [Point2]
    var aligned: [Point2]
    var featurePrint: Data
    var appearance: [Double]
    var graph: [Double]
    var geom3d: [Double]
    var quality: FaceQuality
    var trackId: UUID?
    var strokes: [LandmarkStroke] = []
    var namedAligned: [Point2] = []
    var ratioSheet: [NamedRatio] = []
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
    var note: String = ""
}

struct MatchResult: Hashable {
    var faceId: UUID
    var hits: [StrategyHit]
}
