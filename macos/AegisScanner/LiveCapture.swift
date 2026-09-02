import AppKit
import AVFoundation
import CoreGraphics
import CoreMedia
import CoreVideo
import Foundation
import Vision

enum LiveKind: String {
    case webcam, hls, mjpeg, httpVideo, snapshot, rtsp
}

@MainActor
final class LiveCapture: NSObject {
    private var player: AVPlayer?
    private var output: AVPlayerItemVideoOutput?
    private var session: AVCaptureSession?
    private var outputQueue = DispatchQueue(label: "aegis.live")
    private var timer: Timer?
    private var snapshotURL: URL?
    private var failObserver: NSObjectProtocol?
    private var snapshotInFlight = false
    var onFrame: ((CGImage) -> Void)?
    var onError: ((String) -> Void)?
    var onReady: (() -> Void)?

    func start(url: URL, kind: LiveKind) {
        stop()
        switch kind {
        case .webcam:
            startCamera()
        case .snapshot, .mjpeg:
            snapshotURL = url
            onReady?()
            startTimer()
        case .hls, .httpVideo, .rtsp:
            startPlayer(url: url)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        snapshotURL = nil
        snapshotInFlight = false
        if let failObserver {
            NotificationCenter.default.removeObserver(failObserver)
            self.failObserver = nil
        }
        player?.pause()
        player = nil
        output = nil
        session?.stopRunning()
        session = nil
    }

    private func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] ok in
                Task { @MainActor in
                    if ok { self?.configureCamera() }
                    else { self?.onError?("Kamera-Zugriff blockiert.") }
                }
            }
        default:
            onError?("Kamera-Zugriff blockiert. In Systemeinstellungen erlauben.")
        }
    }

    private func configureCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720
        guard
            let device = preferredCamera(),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            onError?("Keine Webcam gefunden.")
            return
        }
        if session.canAddInput(input) { session.addInput(input) }
        let out = AVCaptureVideoDataOutput()
        out.alwaysDiscardsLateVideoFrames = true
        out.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        let delegate = FrameTap { [weak self] image in
            self?.onFrame?(image)
        }
        self.tap = delegate
        out.setSampleBufferDelegate(delegate, queue: outputQueue)
        if session.canAddOutput(out) { session.addOutput(out) }
        if let conn = out.connection(with: .video) {
            if conn.isVideoOrientationSupported {
                conn.videoOrientation = .landscapeRight
            }
            if conn.isVideoMirroringSupported {
                conn.isVideoMirrored = device.position == .front || device.position == .unspecified
            }
        }
        self.session = session
        outputQueue.async { session.startRunning() }
        onReady?()
    }

    private func preferredCamera() -> AVCaptureDevice? {
        let types: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .continuityCamera,
            .external
        ]
        let found = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .unspecified
        ).devices
        if let front = found.first(where: { $0.position == .front }) { return front }
        if let wide = found.first(where: { $0.deviceType == .builtInWideAngleCamera }) { return wide }
        return found.first ?? AVCaptureDevice.default(for: .video)
    }

    private var tap: FrameTap?

    private func startPlayer(url: URL) {
        let item = AVPlayerItem(url: url)
        let attrs: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        ]
        let videoOut = AVPlayerItemVideoOutput(pixelBufferAttributes: attrs)
        item.add(videoOut)
        let player = AVPlayer(playerItem: item)
        player.isMuted = true
        self.output = videoOut
        self.player = player
        player.play()
        onReady?()
        startTimer()
        if let failObserver {
            NotificationCenter.default.removeObserver(failObserver)
        }
        failObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] note in
            let err = (note.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error)?.localizedDescription
            let capture = self
            Task { @MainActor in
                capture?.onError?(err ?? "Stream abgebrochen")
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.22, repeats: true) { [weak self] _ in
            let capture = self
            Task { @MainActor in
                capture?.grab()
            }
        }
    }

    private func grab() {
        if let snapshotURL {
            if snapshotInFlight { return }
            snapshotInFlight = true
            URLSession.shared.dataTask(with: bust(snapshotURL)) { [weak self] data, _, err in
                let capture = self
                Task { @MainActor in
                    capture?.snapshotInFlight = false
                    if let err {
                        capture?.onError?(err.localizedDescription)
                        return
                    }
                    guard let data, let image = cgImage(from: data) else { return }
                    capture?.onFrame?(image)
                }
            }.resume()
            return
        }
        guard let output, let player, let item = player.currentItem else { return }
        let t = item.currentTime()
        if output.hasNewPixelBuffer(forItemTime: t),
           let pb = output.copyPixelBuffer(forItemTime: t, itemTimeForDisplay: nil),
           let image = cgImage(from: pb)
        {
            onFrame?(image)
        }
        if player.timeControlStatus == .paused, item.duration.isNumeric {
            player.seek(to: .zero)
            player.play()
        }
    }
}

private final class FrameTap: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var last: TimeInterval = 0
    private let emit: (CGImage) -> Void
    init(emit: @escaping (CGImage) -> Void) { self.emit = emit }
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let now = Date().timeIntervalSince1970
        guard now - last >= 0.18 else { return }
        last = now
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer), let image = cgImage(from: pb) else { return }
        DispatchQueue.main.async { self.emit(image) }
    }
}

private func bust(_ url: URL) -> URL {
    var c = URLComponents(url: url, resolvingAgainstBaseURL: false)
    var items = c?.queryItems ?? []
    items.append(URLQueryItem(name: "t", value: String(Int(Date().timeIntervalSince1970 * 1000))))
    c?.queryItems = items
    return c?.url ?? url
}

private func cgImage(from data: Data) -> CGImage? {
    NSImage(data: data)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
}

private func cgImage(from pb: CVPixelBuffer) -> CGImage? {
    let w = CVPixelBufferGetWidth(pb)
    let h = CVPixelBufferGetHeight(pb)
    CVPixelBufferLockBaseAddress(pb, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pb, .readOnly) }
    guard let base = CVPixelBufferGetBaseAddress(pb) else { return nil }
    let bpr = CVPixelBufferGetBytesPerRow(pb)
    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: base,
        width: w,
        height: h,
        bitsPerComponent: 8,
        bytesPerRow: bpr,
        space: cs,
        bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
    ) else { return nil }
    return ctx.makeImage()
}

func sniffLiveKind(_ raw: String) -> (LiveKind, URL)? {
    guard let url = URL(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
    let s = url.scheme?.lowercased() ?? ""
    let href = url.absoluteString
    if s == "rtsp" || s == "rtsps" { return (.rtsp, url) }
    if href.contains(".m3u8") || href.contains("/hls/") { return (.hls, url) }
    if href.range(of: "mjpeg|mjpg|videostream", options: .regularExpression) != nil { return (.mjpeg, url) }
    if href.range(of: "snapshot|picture|/jpg/", options: .regularExpression) != nil { return (.snapshot, url) }
    if s == "http" || s == "https" { return (.httpVideo, url) }
    return nil
}
