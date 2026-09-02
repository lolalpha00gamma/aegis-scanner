import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import Vision

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
            kCGImageSourceShouldCache: false,
            kCGImageSourceShouldCacheImmediately: false,
            kCGImageSourceThumbnailMaxPixelSize: 1280,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        let count = CGImageSourceGetCount(src)
        if count <= 1 {
            return CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary)
        }
        // HEIC Live Photo / Burst: schärfstes der ersten 8 Frames, nicht Index 0.
        let n = min(8, count)
        var best: CGImage?
        var bestScore = -1.0
        for i in 0 ..< n {
            guard let img = CGImageSourceCreateThumbnailAtIndex(src, i, options as CFDictionary) else { continue }
            let s = structure(img)
            if s > bestScore {
                bestScore = s
                best = img
            }
        }
        return best ?? CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary)
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
        let kept = pickDiverse(scored, maxFrames: maxFrames)
        return kept.map { ($0.0, $0.1) }
    }

    /// Schärfe plus Yaw-Diversität: nicht 20× dieselbe Frontal-Pose.
    private static func pickDiverse(_ scored: [(Double, CGImage, Double)], maxFrames: Int) -> [(Double, CGImage, Double)] {
        guard scored.count > maxFrames else { return scored.sorted { $0.0 < $1.0 } }
        var yawOf: [Int: Double] = [:]
        for (i, item) in scored.enumerated() {
            yawOf[i] = faceYaw(item.1) ?? 999
        }
        var picked: [Int] = []
        // Schärfstes zuerst, dann Frames deren Yaw sich um ≥ 0,22 unterscheidet.
        for (i, _) in scored.enumerated() {
            if picked.count >= maxFrames { break }
            let y = yawOf[i] ?? 999
            guard y != 999 else { continue }
            let far = picked.allSatisfy { abs((yawOf[$0] ?? 0) - y) >= 0.22 }
            if picked.isEmpty || far { picked.append(i) }
        }
        for (i, _) in scored.enumerated() where !picked.contains(i) {
            if picked.count >= maxFrames { break }
            picked.append(i)
        }
        return picked.map { scored[$0] }.sorted { $0.0 < $1.0 }
    }

    private static func faceYaw(_ image: CGImage) -> Double? {
        let req = VNDetectFaceRectanglesRequest()
        req.revision = VNDetectFaceRectanglesRequestRevision3
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        guard (try? handler.perform([req])) != nil else { return nil }
        let best = req.results?.max {
            $0.boundingBox.width * $0.boundingBox.height < $1.boundingBox.width * $1.boundingBox.height
        }
        return best?.yaw?.doubleValue
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
        let score: Double = pixels.withUnsafeMutableBytes { raw in
            guard let ctx = CGContext(
                data: raw.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGImageAlphaInfo.none.rawValue
            ) else { return 0 }
            ctx.interpolationQuality = .low
            ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            let buf = raw.bindMemory(to: UInt8.self)
            var acc = 0.0
            var n = 0
            for y in 1 ..< (height - 1) {
                for x in 1 ..< (width - 1) {
                    let c = Double(buf[y * width + x])
                    let l = Double(buf[y * width + x - 1])
                    let r = Double(buf[y * width + x + 1])
                    let u = Double(buf[(y - 1) * width + x])
                    let d = Double(buf[(y + 1) * width + x])
                    acc += abs(4 * c - l - r - u - d)
                    n += 1
                }
            }
            return n > 0 ? acc / Double(n) / 255.0 : 0
        }
        return score
    }

    static func exifOrientation(url: URL) -> Int {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any],
              let o = props[kCGImagePropertyOrientation] as? Int
        else { return 1 }
        return o
    }

    static func walk(folder: URL, shouldContinue: () -> Bool = { true }) -> [URL] {
        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        guard let enumerator = FileManager.default.enumerator(
            at: folder,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return [] }
        var urls: [URL] = []
        for case let url as URL in enumerator {
            if !shouldContinue() { break }
            if isImage(url) || isVideo(url) { urls.append(url) }
        }
        return urls.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }
}
