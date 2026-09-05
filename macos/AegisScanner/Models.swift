import CoreGraphics
import Foundation

enum AppVersion {
    static let marketing = "2.1.105"
    static let channel = "alpha"
    static let display = "2.1.105 alpha"
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

    static var diagnoseOnly: Set<StrategyID> { [.terFusion] }

    static var defaultEnabled: Set<StrategyID> {
        Set(allCases.filter { !diagnoseOnly.contains($0) })
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
            return "Diagnose: aktive Spuren → Total Error Rate. Default aus — `.aegis` tauft über lookOf."
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
    var roll: Double = 0

    enum CodingKeys: String, CodingKey {
        case sharpness, size, frontal, capture, yaw, pitch, roll
    }

    init(sharpness: Double, size: Double, frontal: Double, capture: Double, yaw: Double = 0, pitch: Double = 0, roll: Double = 0) {
        self.sharpness = sharpness
        self.size = size
        self.frontal = frontal
        self.capture = capture
        self.yaw = yaw
        self.pitch = pitch
        self.roll = roll
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sharpness = try c.decode(Double.self, forKey: .sharpness)
        size = try c.decode(Double.self, forKey: .size)
        frontal = try c.decode(Double.self, forKey: .frontal)
        capture = try c.decode(Double.self, forKey: .capture)
        yaw = try c.decodeIfPresent(Double.self, forKey: .yaw) ?? 0
        pitch = try c.decodeIfPresent(Double.self, forKey: .pitch) ?? 0
        roll = try c.decodeIfPresent(Double.self, forKey: .roll) ?? 0
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
        case photo, video, frame, live, snapshot
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
    /// Stirn/Augen-Print bei okkludierter unterer Hälfte. Persistiert, Vec nicht.
    var partialPrint: Data = Data()
    var partialVec: [Double] = []
    /// Taste „als Teil-Print speichern“ — Slot U auch ohne Auto-Maske.
    var forcedPartial: Bool = false
    /// Live-Ampel-History, RAM-only.
    var qualitySpark: [FaceQuality] = []
    /// Wann die Face-ID in die Galerie kam. Print-Alter, nicht Capture-Zeit.
    var enrolledAt: Date? = nil

    enum CodingKeys: String, CodingKey {
        case id, mediaId, box, score, landmarks, aligned, featurePrint
        case appearance, graph, geom3d, quality, trackId, strokes, namedAligned, ratioSheet
        case partialPrint, forcedPartial, enrolledAt
    }

    init(
        id: UUID,
        mediaId: UUID,
        box: FaceBox,
        score: Double,
        landmarks: [Point2],
        aligned: [Point2],
        featurePrint: Data,
        appearance: [Double],
        graph: [Double],
        geom3d: [Double],
        quality: FaceQuality,
        trackId: UUID?,
        strokes: [LandmarkStroke] = [],
        namedAligned: [Point2] = [],
        ratioSheet: [NamedRatio] = [],
        printVec: [Double] = [],
        partialPrint: Data = Data(),
        partialVec: [Double] = [],
        forcedPartial: Bool = false,
        enrolledAt: Date? = nil
    ) {
        self.id = id
        self.mediaId = mediaId
        self.box = box
        self.score = score
        self.landmarks = landmarks
        self.aligned = aligned
        self.featurePrint = featurePrint
        self.appearance = appearance
        self.graph = graph
        self.geom3d = geom3d
        self.quality = quality
        self.trackId = trackId
        self.strokes = strokes
        self.namedAligned = namedAligned
        self.ratioSheet = ratioSheet
        self.printVec = printVec
        self.partialPrint = partialPrint
        self.partialVec = partialVec
        self.forcedPartial = forcedPartial
        self.enrolledAt = enrolledAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        mediaId = try c.decode(UUID.self, forKey: .mediaId)
        box = try c.decode(FaceBox.self, forKey: .box)
        score = try c.decode(Double.self, forKey: .score)
        landmarks = try c.decode([Point2].self, forKey: .landmarks)
        aligned = try c.decode([Point2].self, forKey: .aligned)
        featurePrint = try c.decode(Data.self, forKey: .featurePrint)
        appearance = try c.decode([Double].self, forKey: .appearance)
        graph = try c.decode([Double].self, forKey: .graph)
        geom3d = try c.decode([Double].self, forKey: .geom3d)
        quality = try c.decode(FaceQuality.self, forKey: .quality)
        trackId = try c.decodeIfPresent(UUID.self, forKey: .trackId)
        strokes = try c.decodeIfPresent([LandmarkStroke].self, forKey: .strokes) ?? []
        namedAligned = try c.decodeIfPresent([Point2].self, forKey: .namedAligned) ?? []
        ratioSheet = try c.decodeIfPresent([NamedRatio].self, forKey: .ratioSheet) ?? []
        partialPrint = try c.decodeIfPresent(Data.self, forKey: .partialPrint) ?? Data()
        forcedPartial = try c.decodeIfPresent(Bool.self, forKey: .forcedPartial) ?? false
        enrolledAt = try c.decodeIfPresent(Date.self, forKey: .enrolledAt)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(mediaId, forKey: .mediaId)
        try c.encode(box, forKey: .box)
        try c.encode(score, forKey: .score)
        try c.encode(landmarks, forKey: .landmarks)
        try c.encode(aligned, forKey: .aligned)
        try c.encode(featurePrint, forKey: .featurePrint)
        try c.encode(appearance, forKey: .appearance)
        try c.encode(graph, forKey: .graph)
        try c.encode(geom3d, forKey: .geom3d)
        try c.encode(quality, forKey: .quality)
        try c.encodeIfPresent(trackId, forKey: .trackId)
        try c.encode(strokes, forKey: .strokes)
        try c.encode(namedAligned, forKey: .namedAligned)
        try c.encode(ratioSheet, forKey: .ratioSheet)
        try c.encode(partialPrint, forKey: .partialPrint)
        if forcedPartial { try c.encode(forcedPartial, forKey: .forcedPartial) }
        try c.encodeIfPresent(enrolledAt, forKey: .enrolledAt)
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
    var geoMix: Double? = nil
    /// Centroid-Cosine Look-Sieger vs Zweiter. Close-Pair braucht echte Nähe, nicht nur Look-Delta 8.
    var pairCosine: Double? = nil
}

struct MatchResult: Hashable {
    var faceId: UUID
    var hits: [StrategyHit]
}
