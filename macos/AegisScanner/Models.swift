import CoreGraphics
import Foundation

enum AppVersion {
    static let marketing = "1.0.9"
    static let channel = "alpha"
    static let display = "1.0.9 alpha"
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
        case .photosStyle:
            return "Einzelnes Best-Frame, harte Qualitätsgrenze — analog zur Apple-Fotos-Pipeline."
        case .visionBox:
            return "Vision-Detektor (Revision 3) plus nächstes Feature-Print-Exemplar."
        case .landmarkGeo:
            return "Landmark-Form, Procrustes-normalisiert. Lichtunabhängig."
        case .ratios:
            return "Nasenhöhe zu Augen, Augenbreite, Mund — trennt ähnliche Gesichter."
        case .faceShape:
            return "Kiefer, Wangen, Aspekt, Kinn. Unabhängig vom Feature Print."
        case .eyeRegion:
            return "Augenbreite und Brauen — eigenes Klassifizierungssystem."
        case .midface:
            return "Nase, Philtrum, Mund. Trennt Lookalikes über das Mittelgesicht."
        case .jawline:
            return "Kieferbreite, Wangen, Kinn. Unabhängig von Augen und Nase."
        case .graphBio:
            return "KNN-6 Landmark-Graph: fünf Spektralenergien. Alterungsstabil, unabhängig von Textur."
        case .geom3d:
            return "Distanzen, Winkel und Flächen aus Landmark-Formen — Cheese3D-Analog in 2D."
        case .texture:
            return "Helligkeitsraster des ausgerichteten Gesichts. Kann nur widersprechen, nie zuordnen."
        case .qualityGate:
            return "Nächstes Exemplar, gewichtet mit VNFaceCaptureQuality statt Verwerfung."
        case .temporal:
            return "Nächstes Video-Exemplar über Tracks, ohne Kreuzer zu tauschen."
        case .featurePrint:
            return "VNGenerateImageFeaturePrintRequest auf ausgerichtetem Gesicht."
        case .terFusion:
            return "Wu/Wan: Scores → Total Error Rate, min-max nach Jain, probabilistisch gewichtet."
        case .aegis:
            return "Beweis-Identifikation: Aussehen muss hoch liegen, Maße dürfen widersprechen. Unbekannt ist der Normalzustand."
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
    var appearance: [Double]
    var graph: [Double]
    var geom3d: [Double]
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
    var note: String = ""
}

struct MatchResult: Hashable {
    var faceId: UUID
    var hits: [StrategyHit]
}
