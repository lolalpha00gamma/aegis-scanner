import CoreGraphics
import Foundation

enum AppVersion {
    static let marketing = "2.1.192"
    static let build = 217
    static let channel = "alpha"
    static let display = "2.1.192 alpha"
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
