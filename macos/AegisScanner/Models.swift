import CoreGraphics
import Foundation

enum AppVersion {
    static let marketing = "2.1.7"
    static let channel = "alpha"
    static let display = "2.1.7 alpha"
}

enum StrategyTrack: String, CaseIterable, Identifiable {
    case ki, geo2d, geo3d, fusion
    var id: String { rawValue }
    var label: String {
        switch self {
        case .ki: return "KI / Face-Print"
        case .geo2d: return "2D-Geometrie"
        case .geo3d: return "3D (Pose-Anhebung)"
        case .fusion: return "Fusion"
        }
    }
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

    var track: StrategyTrack {
        switch self {
        case .photosStyle, .visionBox, .qualityGate, .temporal, .featurePrint: return .ki
        case .landmarkGeo, .ratios, .faceShape, .eyeRegion, .midface, .jawline, .graphBio, .texture: return .geo2d
        case .geom3d: return .geo3d
        case .terFusion, .aegis: return .fusion
        }
    }

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
        case .texture: return "Aussehen (LBP)"
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
            return "KNN-6 über feste Knochenpunkte (ohne Mund). Alterungsstabil, unabhängig von Textur."
        case .geom3d:
            return "2D-Landmarks mit Yaw/Pitch auf die Frontalebene gehoben. Kein neuronales 3DMM."
        case .texture:
            return "Tan–Triggs + LBP auf dem ausgerichteten Crop. Keine Zuordnungsstimme."
        case .qualityGate:
            return "Nächstes Feature-Print-Exemplar. Dunkelheit ist keine Unschärfe; nur winzige Crowd-Gesichter werden gedämpft."
        case .temporal:
            return "Nächstes Video-Feature-Print über Tracks, ohne Kreuzer zu tauschen."
        case .featurePrint:
            return "Gesichts-Print (VNGenerateFacePrintRequest) auf dem ganzen Foto. Kein Bild-Print von Jacke/Hintergrund."
        case .terFusion:
            return "Aktive Spuren → Total Error Rate, min-max nach Jain, nur eingeschaltete Matcher."
        case .aegis:
            return "Fusion der eingeschalteten Spuren. Print führt, Geometrie stützt und vetoiert. Aus = keine Namensvergabe."
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
    var yaw: Double = 0
    var pitch: Double = 0

    enum CodingKeys: String, CodingKey {
        case sharpness, size, frontal, capture, yaw, pitch
    }

    init(sharpness: Double, size: Double, frontal: Double, capture: Double, yaw: Double = 0, pitch: Double = 0) {
        self.sharpness = sharpness
        self.size = size
        self.frontal = frontal
        self.capture = capture
        self.yaw = yaw
        self.pitch = pitch
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sharpness = try c.decode(Double.self, forKey: .sharpness)
        size = try c.decode(Double.self, forKey: .size)
        frontal = try c.decode(Double.self, forKey: .frontal)
        capture = try c.decode(Double.self, forKey: .capture)
        yaw = try c.decodeIfPresent(Double.self, forKey: .yaw) ?? 0
        pitch = try c.decodeIfPresent(Double.self, forKey: .pitch) ?? 0
    }
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

struct LandmarkStroke: Hashable, Codable {
    var label: String
    var closed: Bool
    var points: [Point2]
}

struct NamedRatio: Hashable, Codable {
    var id: String
    var label: String
    var value: Double
    var group: String
    var identity: Bool
}

struct FaceObservation: Identifiable, Hashable, Codable {
    var id: UUID
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
    /// Live-EMA des Print-Vektors. Nicht persistiert — der archivierte
    /// `featurePrint` bleibt die Quelle auf Disk.
    var printVec: [Double] = []

    enum CodingKeys: String, CodingKey {
        case id, mediaId, box, score, landmarks, aligned, featurePrint
        case appearance, graph, geom3d, quality, trackId, strokes, namedAligned, ratioSheet
    }
}

struct Identity: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var faceIds: [UUID]
    /// Hard-Negatives: Prints, die ausdrücklich *nicht* diese Person sind.
    var rejectedVecs: [[Double]] = []

    enum CodingKeys: String, CodingKey {
        case id, name, faceIds, rejectedVecs
    }

    init(id: UUID, name: String, faceIds: [UUID], rejectedVecs: [[Double]] = []) {
        self.id = id
        self.name = name
        self.faceIds = faceIds
        self.rejectedVecs = rejectedVecs
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        faceIds = try c.decode([UUID].self, forKey: .faceIds)
        rejectedVecs = try c.decodeIfPresent([[Double]].self, forKey: .rejectedVecs) ?? []
    }
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
    var measured: Bool = true
}

struct MatchResult: Hashable {
    var faceId: UUID
    var hits: [StrategyHit]
}
