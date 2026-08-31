import CoreGraphics
import Foundation

enum AppVersion {
    static let marketing = "2.0.3"
    static let channel = "alpha"
    static let display = "2.0.3 alpha"
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
            return "Vision-Detektor (Revision 3) plus nächstes Face-Print-Exemplar."
        case .landmarkGeo:
            return "Landmark-Form, Augen-Procrustes IOD=1. Lichtunabhängig, diagnostisch."
        case .ratios:
            return "Reproduzierbare Verhältnisse zur Augenabstands-Einheit. Unabhängig von Lage, Größe und Mimik."
        case .faceShape:
            return "Kiefer/Höhe, Wangen/Höhe, Kiefer/Wangen, Nase/Kiefer. Keine Bildposition, keine Boxgröße."
        case .eyeRegion:
            return "Lidspalten und Augenwinkel / IOD. Nicht Lidöffnung (Mimik)."
        case .midface:
            return "Nasenlänge, Nasenbreite, Nasenindex, Philtrum/Nase."
        case .jawline:
            return "Kieferbreite/IOD, Untergesicht/Höhe, Kinn. Unabhängig vom Lächeln."
        case .graphBio:
            return "KNN-6 über feste anatomische Punkte (ohne Mund). Alterungsstabil, unabhängig von Textur."
        case .geom3d:
            return "IOD-Verhältnisse, Kieferwinkel, Nasenfläche — keine Punktzählung, keine Box."
        case .texture:
            return "Aussehen: Gesichtsmaße plus Raster. Das ist die Basis der Zuordnung — nicht der Face-Print."
        case .qualityGate:
            return "Nächstes Feature-Print-Exemplar. Dunkelheit ist keine Unschärfe; nur winzige Crowd-Gesichter werden gedämpft."
        case .temporal:
            return "Nächstes Video-Feature-Print über Tracks, ohne Kreuzer zu tauschen."
        case .featurePrint:
            return "Gesichts-Print (VNGenerateFacePrintRequest). Diagnostisch. Darf Aussehen nicht mehr totmachen."
        case .terFusion:
            return "Wu/Wan: Scores → Total Error Rate, min-max nach Jain, probabilistisch gewichtet."
        case .aegis:
            return "Aussehen zuerst: Maße, Form, Augen, Kiefer. Face-Print darf nicht 97 % Form auf 8 % drücken. Unbekannt bleibt, wenn die Teile nicht passen."
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
