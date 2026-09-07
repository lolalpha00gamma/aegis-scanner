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
