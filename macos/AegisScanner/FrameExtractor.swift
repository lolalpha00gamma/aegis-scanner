import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum FrameExtractor {
    static func isVideo(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["mp4", "mov", "m4v", "avi", "mkv", "webm"].contains(ext)
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

    static func extract(from url: URL, interval: Double = 0.33, maxFrames: Int = 20) async throws -> [(time: Double, image: CGImage)] {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = CMTime(seconds: 0.05, preferredTimescale: 600)
        generator.maximumSize = CGSize(width: 1280, height: 1280)

        let duration = try await asset.load(.duration)
        let seconds = duration.seconds
        guard seconds.isFinite, seconds > 0 else { return [] }

        let n = min(48, max(maxFrames, Int((Double(maxFrames) * 2.2).rounded())))
        let start = min(0.06, seconds * 0.03)
        let end = max(start + 0.01, seconds - 0.05)
        var times: [Double] = []
        if n <= 1 {
            times = [start]
        } else {
            for i in 0 ..< n {
                times.append(start + (Double(i) / Double(n - 1)) * (end - start))
            }
        }

        var scored: [(Double, CGImage, Double)] = []
        for time in times {
            let cm = CMTime(seconds: time, preferredTimescale: 600)
            do {
                let image = try generator.copyCGImage(at: cm, actualTime: nil)
                scored.append((time, image, structure(image)))
            } catch {
                continue
            }
        }
        scored.sort { $0.2 > $1.2 }
        let kept = Array(scored.prefix(maxFrames)).sorted { $0.0 < $1.0 }
        return kept.map { ($0.0, $0.1) }
    }

    static func structure(_ image: CGImage) -> Double {
        sharpness(equalizeGray(image) ?? image)
    }

    private static func equalizeGray(_ image: CGImage) -> CGImage? {
        let width = min(96, image.width)
        let height = min(96, image.height)
        guard width > 2, height > 2 else { return nil }
        var pixels = [UInt8](repeating: 0, count: width * height)
        return pixels.withUnsafeMutableBytes { raw -> CGImage? in
            guard let base = raw.baseAddress,
                  let ctx = CGContext(
                    data: base,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width,
                    space: CGColorSpaceCreateDeviceGray(),
                    bitmapInfo: CGImageAlphaInfo.none.rawValue
                  ) else { return nil }
            ctx.interpolationQuality = .low
            ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            let ptr = base.bindMemory(to: UInt8.self, capacity: width * height)
            var hist = [Int](repeating: 0, count: 256)
            var sum = 0.0
            let n = width * height
            for i in 0 ..< n {
                hist[Int(ptr[i])] += 1
                sum += Double(ptr[i])
            }
            let mean = sum / Double(max(n, 1))
            func percentile(_ p: Double) -> Double {
                let target = p * Double(n)
                var acc = 0.0
                for i in 0 ..< 256 {
                    acc += Double(hist[i])
                    if acc >= target { return Double(i) }
                }
                return 255
            }
            let p5 = percentile(0.05)
            let p95 = percentile(0.95)
            if mean >= 78 && p5 >= 22 { return ctx.makeImage() }
            let span = max(p95 - p5, 12.0)
            let gamma = mean < 55 ? 0.55 : mean < 70 ? 0.62 : 0.78
            for i in 0 ..< n {
                let y = Double(ptr[i])
                var y2 = ((y - p5) / span) * 240 + 8
                y2 = min(255, max(0, y2))
                y2 = 255 * pow(y2 / 255, gamma)
                ptr[i] = UInt8(min(255, max(0, y2.rounded())))
            }
            return ctx.makeImage()
        }
    }

    static func sharpness(_ image: CGImage) -> Double {
        let width = min(64, image.width)
        let height = min(64, image.height)
        guard width > 2, height > 2 else { return 0 }
        var pixels = [UInt8](repeating: 0, count: width * height)
        guard let ctx = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return 0 }
        ctx.interpolationQuality = .low
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        var acc = 0.0
        var n = 0
        for y in 1 ..< (height - 1) {
            for x in 1 ..< (width - 1) {
                let c = Double(pixels[y * width + x])
                let l = Double(pixels[y * width + x - 1])
                let r = Double(pixels[y * width + x + 1])
                let u = Double(pixels[(y - 1) * width + x])
                let d = Double(pixels[(y + 1) * width + x])
                let lap = abs(4 * c - l - r - u - d)
                acc += lap
                n += 1
            }
        }
        return n > 0 ? acc / Double(n) / 255.0 : 0
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
