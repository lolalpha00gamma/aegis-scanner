import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum FrameExtractor {
    static func isVideo(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["mp4", "mov", "m4v", "avi", "mkv"].contains(ext)
    }

    static func isImage(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["jpg", "jpeg", "png", "heic", "heif", "tif", "tiff", "webp"].contains(ext)
    }

    static func loadCGImage(url: URL) -> CGImage? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: true,
            kCGImageSourceThumbnailMaxPixelSize: 2048,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        return CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary)
            ?? CGImageSourceCreateImageAtIndex(src, 0, nil)
    }

    static func extract(from url: URL, interval: Double = 0.45, maxFrames: Int = 14) async throws -> [(time: Double, image: CGImage)] {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = CMTime(seconds: 0.05, preferredTimescale: 600)
        generator.maximumSize = CGSize(width: 1280, height: 1280)

        let duration = try await asset.load(.duration)
        let seconds = duration.seconds
        guard seconds.isFinite, seconds > 0 else { return [] }

        var times: [Double] = []
        var t = 0.08
        while t < seconds - 0.04, times.count < maxFrames {
            times.append(t)
            t += interval
        }
        if times.isEmpty { times = [min(0.1, seconds / 2)] }

        var frames: [(Double, CGImage)] = []
        for time in times {
            let cm = CMTime(seconds: time, preferredTimescale: 600)
            let image = try generator.copyCGImage(at: cm, actualTime: nil)
            frames.append((time, image))
        }
        return frames
    }

    static func walk(folder: URL) -> [URL] {
        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        guard let enumerator = FileManager.default.enumerator(
            at: folder,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return [] }
        var urls: [URL] = []
        for case let url as URL in enumerator {
            if isImage(url) || isVideo(url) { urls.append(url) }
        }
        return urls.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }
}
