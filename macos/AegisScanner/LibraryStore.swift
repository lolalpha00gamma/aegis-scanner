import AppKit
import Combine
import Foundation
import Photos
import UniformTypeIdentifiers

private final class AegisScanFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var _alive = true
    func reset() { lock.lock(); _alive = true; lock.unlock() }
    func stop() { lock.lock(); _alive = false; lock.unlock() }
    var alive: Bool { lock.lock(); defer { lock.unlock() }; return _alive }
}

@MainActor
final class LibraryStore: ObservableObject {
    @Published var media: [MediaItem] = []
    @Published var faces: [FaceObservation] = []
    @Published var identities: [Identity] = []
    @Published var matches: [MatchResult] = []
    @Published var selectedMediaId: UUID?
    @Published var selectedFaceId: UUID?
    @Published var threshold: Double = 78
    @Published var holdTTLFloor: Double = 1.2
    @Published var nameLockSec: Double = 1.2
    @Published var adoptLockSec: Double = 0.8
    @Published var assignLiveGate: Int = 1
    @Published var fillXRescue: Double = MatchMath.leftoverFillXRescue
    @Published var fillXPad: Double = MatchMath.leftoverFillXPad
    @Published var jpegProbeTTL: Double = 0.80
    @Published var leftoverMissNeed: Int = 2
    @Published var kalmanJump: Double = MatchMath.leftoverIoUJump
    @Published var strategy: StrategyID = .aegis
    @Published var showAnatomy = true
    @Published var showNMSDebug = false
    @Published var nmsDropped: [FaceBox] = []
    @Published var status: String = "Bereit"
    @Published var busy = false
    @Published var newPersonName = ""
    @Published var liveURLText = ""
    @Published var liveActive = false
    @Published var enabled: Set<StrategyID> = StrategyID.defaultEnabled
    @Published var pendingDuplicateName: String?
    @Published var revisionWarning: String = ""
    @Published var canResumeScan = false
    @Published var cameraOrient: String = "auto"
    @Published var cameraUniqueID: String = ""
    @Published var liveHeldIds: Set<UUID> = []
    @Published var leftoverHold: [UUID: Double] = [:]
    private var leftoverHoldBins: [String: Double] = [:]
    private var peopleAlbumSeedAt: TimeInterval = 0
    @Published var leftoverPending: [UUID: String] = [:]
    @Published var cameraChoice: CameraChoice = .builtIn
    @Published var liveFormatChip: String = ""
    @Published var mutexChip: String = "—"
    @Published var yawCoverageChip: String = "YAW —"
    @Published var enrollSMChip: String = "ENROLL —"
    @Published var enrollYawChip: String = "YAW F"
    @Published var guestTTLChip: String = "—"
    @Published var enrollQualityChip: String = "Q —"
    @Published var captureSparkChip: String = "CQ —"
    @Published var faReplayChip: String = "FA —"
    @Published var faReplayMatrix: String = "FA —"
    @Published var overlayBeat: TimeInterval = 0
    @Published var yieldAutoReturn = true
    @Published var yieldGrace: Double = 4
    @Published var mutexKill = false
    @Published var freezeAxis: [UUID: String] = [:]
    @Published var swapFlashUntil: TimeInterval = 0
    @Published var headCountFlashUntil: TimeInterval = 0
    @Published var mergeHint: String = ""
    private var mergeUndoAt: TimeInterval?
    private var twinSplits: Set<String> = []

    private let liveCapture = LiveCapture()
    private var overlayTrack: Timer?
    private var faLogLastDecided: [String: String] = [:]
    private var faLogLines: Int = 0
    private var liveMediaId: UUID?
    private var leftoverStreak: [UUID: Int] = [:]
    private var leftoverStreakBox: [UUID: FaceBox] = [:]
    private var leftoverStreakSince: [UUID: TimeInterval] = [:]
    private var leftoverMissFrames: [UUID: Int] = [:]
    private var leftoverWipeUntil: [UUID: TimeInterval] = [:]
    private var leftoverPairLast: [UUID: UUID] = [:]
    private var leftoverPairStreak: [UUID: Int] = [:]
    private var leftoverPairCommit: [UUID: UUID] = [:]
    private var leftoverPairCommitMiss: [UUID: Int] = [:]
    private var tapGuestPending: Set<UUID> = []
    private var lastLiveVisMs: Double = 0
    private var liveSlotHold: [UUID: (slot: String, n: Int)] = [:]
    private var lastLiveHeadCount: Int = 0
    private var lastHeadCountLabel: String?
    private var scopedRoots: [URL] = []
    private var liveBusy = false
    private var livePending: (image: CGImage, mediaId: UUID, stamp: TimeInterval)?
    private var liveDetectGen: UInt64 = 0
    private var liveBusySince: TimeInterval = 0
    private var liveCoastAt: TimeInterval = 0
    private var leftoverPrintCache: [String] = []
    private var liveRoiTick = 0
    private var liveRoiSkipOnce = false
    private var maskHoldSince: [UUID: TimeInterval] = [:]
    private var lastUSlotHint: TimeInterval = 0
    private var scanGeneration = 0
    private let scanFlag = AegisScanFlag()
    private let enabledKey = "aegis.enabledStrategies"
    private let resumeBookmarkKey = "aegis.scanResume.bookmark"
    private let resumeRemainingKey = "aegis.scanResume.remaining"
    private let resumeDetectKey = "aegis.scanResume.detect"
    private var liveGhosts: [(face: FaceObservation, until: TimeInterval)] = []
    private var reconnectGhosts: [FaceObservation] = []
    private var boxEuro: [UUID: (x: MatchMath.OneEuro, y: MatchMath.OneEuro, w: MatchMath.OneEuro, h: MatchMath.OneEuro)] = [:]
    private var boxJumpPending: [UUID: FaceBox] = [:]
    private var liveNameHist: [UUID: [String]] = [:]
    private var liveNameLock: [UUID: UUID] = [:]
    private var liveScoreEma: [UUID: Double] = [:]
    private var liveScoreTicks: [UUID: [Double]] = [:]
    private var liveYaw: [UUID: Double] = [:]
    private var livePitch: [UUID: Double] = [:]
    private var liveRoll: [UUID: Double] = [:]
    private var liveLastStamp: TimeInterval = 0
    private var liveDt: TimeInterval = 0.125
    var liveFrameDt: TimeInterval { liveDt }
    private var liveDtSamples: [TimeInterval] = []
    private var liveNameVoteAt: [UUID: TimeInterval] = [:]
    private var tapNameLockUntil: [UUID: TimeInterval] = [:]
    private var liveFaceStreak = 0
    private var livePrintTrail: [UUID: [[Double]]] = [:]
    private var livePrintTrailSlot: [UUID: String] = [:]
    private var liveStillFor: [UUID: TimeInterval] = [:]
    private var livePrintDrift: [UUID: [Double]] = [:]
    private var livePoseAt: [UUID: TimeInterval] = [:]
    private var liveExposureUntil: [UUID: TimeInterval] = [:]
    private var liveCaptureHist: [UUID: [Double]] = [:]
    private var livePosterJitter: [UUID: Double] = [:]
    private var livePosterStill: [UUID: Int] = [:]
    private var liveLandmarkPrev: [UUID: [Point2]] = [:]
    private var liveLidClosed: [UUID: Bool] = [:]
    private var liveBlinkSeen: [UUID: Bool] = [:]
    private var leftoverBlinkByIdentity: [UUID: Bool] = [:]
    private var liveOpenStreak: [UUID: Int] = [:]
    private var workspaceObs: [NSObjectProtocol] = []
    private var leftoverDisagree: [UUID: Int] = [:]
    private var boxKalman: [UUID: (x: Double, y: Double, w: Double, h: Double, px: Double, py: Double, pw: Double, ph: Double)] = [:]
    private var boxKalmanV: [UUID: (vx: Double, vy: Double)] = [:]
    private var boxKalmanWHV: [UUID: (vw: Double, vh: Double)] = [:]
    private var leftoverHoldTrail: [UUID: [Double]] = [:]
    private var leftoverHoldTrailBins: [String: [Double]] = [:]
    private var leftoverHoldByHash: [String: (cosine: Double, at: TimeInterval)] = [:]
    private var leftoverHoldTrailByHash: [String: (samples: [Double], at: TimeInterval)] = [:]
    private var leftoverHashNeedsRebase = false
    private var leftoverHashRebasedTick = false
    private var leftoverHoldSeenSlow = false
    private var leftoverHoldFastFor: TimeInterval = 0
    private var leftoverHoldTTL: TimeInterval {
        MatchMath.leftoverHoldTTLOf(seenSlow: leftoverHoldSeenSlow, pref: holdTTLFloor)
    }
    private var leftoverLiveHashTick: [UUID: String] = [:]
    private var leftoverMissCoastTicks: Int = 0
    private var leftoverKalmanRestoredAgo: Int = 99
    private func leftoverOccupiedHashes(except id: UUID? = nil) -> [String] {
        let liveYawRows: [(hash: String, yawAbs: Double)] = leftoverLiveHashTick.compactMap { key, value in
            if key == id { return nil }
            let yaw = MatchMath.leftoverOccupiedYawLive(
                live: liveYaw[key] ?? faces.first(where: { $0.id == key })?.quality.yaw,
                printed: leftoverPrintYaw[key]
            )
            return (hash: value, yawAbs: yaw)
        }
        let storedRowsAll: [(id: UUID, hash: String)] = leftoverLastHash.compactMap { key, value in
            key == id ? nil : (id: key, hash: value)
        }
        var liveIDs = Set(leftoverLiveHashTick.keys)
        if let id { liveIDs.remove(id) }
        let storedDropped = MatchMath.leftoverOccupiedGhostDrop(
            stored: storedRowsAll,
            liveIDs: liveIDs,
            coastIDs: Set(leftoverCoastPrint.keys)
        )
        let coastExpired = leftoverCoastPrint.isEmpty || leftoverCoastPrint.allSatisfy { id, vec in
            MatchMath.leftoverCoastPrintFresh(
                vec: vec, stamped: leftoverCoastPrintAt[id], now: liveLastStamp
            ).isEmpty
        }
        let storedKept = coastExpired
            ? MatchMath.leftoverOccupiedLiveOnly(stored: storedDropped, live: [], coastExpired: true)
            : storedDropped
        let merged = MatchMath.leftoverOccupiedMergeYaw(stored: storedKept, live: liveYawRows)
        guard let id else { return merged }
        let hash = leftoverLiveHashTick[id] ?? leftoverLastHash[id] ?? ""
        let x = boxKalman[id]?.x ?? faces.first(where: { $0.id == id })?.box.x ?? 0
        let liveRows: [(id: UUID, hash: String, x: Double)] = leftoverLiveHashTick.compactMap { key, value in
            let ox = boxKalman[key]?.x ?? faces.first(where: { $0.id == key })?.box.x ?? 0
            return (id: key, hash: value, x: ox)
        }
        let storedRows: [(id: UUID, hash: String, x: Double)] = leftoverLastHash.compactMap { key, value in
            let ox = boxKalman[key]?.x ?? faces.first(where: { $0.id == key })?.box.x ?? 0
            return (id: key, hash: value, x: ox)
        }
        let others = MatchMath.leftoverOccupiedOthers(live: liveRows, stored: storedRows, except: id)
        let rows = MatchMath.leftoverOccupiedOtherRows(live: liveRows, stored: storedRows, except: id)
        let yawOf: (UUID) -> Double = { fid in
            MatchMath.leftoverOccupiedYawLive(
                live: self.liveYaw[fid] ?? self.faces.first(where: { $0.id == fid })?.quality.yaw,
                printed: self.leftoverPrintYaw[fid]
            )
        }
        let otherYaws: [Double] = rows.map { row in
            MatchMath.leftoverOccupiedYaw(key: row.key, yawOf: yawOf)
        }
        return MatchMath.leftoverHashTwinOccupied(
            occupied: merged,
            hash: hash,
            x: x,
            others: others,
            yawAbs: yawOf(id),
            otherYaws: otherYaws,
            tieKey: id.uuidString,
            otherTieKeys: rows.map(\.key)
        )
    }
    private var leftoverNameLockUntil: [UUID: TimeInterval] = [:]
    private var leftoverNameLockHeld: [UUID: String] = [:]
    private var leftoverOverlayPeakHeld: [UUID: String] = [:]
    private var leftoverOverlayPeakRemain: [UUID: Int] = [:]
    private var leftoverLastHash: [UUID: String] = [:]
    /// Eine Map für Hold/Hash/NameLock/Coast. 20 Dicts bleiben, AssignAtomic schreibt hier.
    private var leftoverTracks: [UUID: LeftoverTrack] = [:]
    private var leftoverCaptureHistByHash: [String: [Double]] = [:]
    private var leftoverCaptureHistAt: [String: TimeInterval] = [:]
    private var leftoverLastIoU: [UUID: Double] = [:]
    private var leftoverCoastPrint: [UUID: [Double]] = [:]
    private var leftoverCoastPrintAt: [UUID: TimeInterval] = [:]
    private var leftoverCoastAt: [UUID: TimeInterval] = [:]
    private var leftoverUnsureTicks: [UUID: Int] = [:]
    private var leftoverPrintYaw: [UUID: Double] = [:]
    private var leftoverDetectAt: TimeInterval = 0
    private var leftoverPrintAt: TimeInterval = 0
    private var leftoverPrintSkipIds: Set<UUID> = []
    private var leftoverSparkChipHeld: [UUID: (chip: String, hold: Int)] = [:]
    private var leftoverSparkChipByHash: [String: String] = [:]
    private var leftoverJpegDelta: [UUID: Double] = [:]
    private var leftoverJpegAt: [UUID: TimeInterval] = [:]
    private var leftoverJpegHash: [UUID: String] = [:]
    private var leftoverJpegCos: [UUID: Double] = [:]
    private var leftoverJpegByHash: [String: (delta: Double, at: TimeInterval, cosine: Double)] = [:]
    private var leftoverEmptySince: TimeInterval?
    private var guestOrder: [UUID] = []
    private var guestSeenAt: [UUID: TimeInterval] = [:]
    private var lastCameraUniqueID: String = ""
    private var lastCameraName: String = ""
    private var lastCameraRole: String = ""
    private var liveDetectInflight: Int = 0
    private var pendingRenameId: UUID?
    private var pendingRenameName: String?
    private var pendingRenameAt: TimeInterval?

    init() {
        let packed = GalleryFile.load()
        identities = packed.identities
        faces = packed.faces
        leftoverStreakSince = MatchMath.leftoverStreakSinceDecode(packed.leftoverStreakSince)
        leftoverHoldBins = MatchMath.leftoverHoldBinsDecode(packed.leftoverHoldBins)
        leftoverHoldTrailBins = MatchMath.leftoverHoldTrailBinsDecode(packed.leftoverHoldTrailBins)
        leftoverHoldByHash = MatchMath.leftoverHashHoldDecode(
            packed.leftoverHoldHash,
            now: Date().timeIntervalSince1970,
            remaining: GalleryFile.loadPayload()?.leftoverHoldHashRemaining,
            ttl: leftoverHoldTTL
        )
        leftoverHoldTrailByHash = MatchMath.leftoverHashTrailDecode(
            packed.leftoverHoldTrailHash,
            now: Date().timeIntervalSince1970,
            remaining: GalleryFile.loadPayload()?.leftoverHoldTrailRemaining,
            ttl: leftoverHoldTTL
        )
        leftoverCaptureHistByHash = MatchMath.leftoverCaptureHistTableDecodeFresh(
            packed.leftoverCaptureHist,
            remaining: GalleryFile.loadPayload()?.leftoverCaptureHistRemaining,
            keep: leftoverHoldByHash.keys.flatMap { [$0, MatchMath.leftoverHoldHashSpatial($0)] }
        )
        leftoverCaptureHistAt = MatchMath.leftoverHashRankRebase(
            MatchMath.leftoverCaptureHistAtDecode(
                remaining: GalleryFile.loadPayload()?.leftoverCaptureHistRemaining,
                now: Date().timeIntervalSince1970,
                ttl: leftoverHoldTTL
            )
        )
        leftoverLastHash = MatchMath.leftoverLastHashRankRebase(
            MatchMath.leftoverUUIDStringMapDecode(packed.leftoverLastHash)
        )
        leftoverHold = MatchMath.leftoverStreakSinceDecode(packed.leftoverHold)
        leftoverNameLockHeld = MatchMath.leftoverNameLockHeldSurvive(
            held: MatchMath.leftoverUUIDStringMapDecode(packed.leftoverNameLockHeld),
            until: MatchMath.leftoverNameLockUntilDecode(packed.leftoverNameLockUntil, now: 0)
        )
        leftoverPairLast = MatchMath.leftoverUUIDUUIDMapDecode(packed.leftoverPairLast)
        leftoverHoldTrail = MatchMath.leftoverUUIDTrailDecode(packed.leftoverHoldTrail)
        leftoverHoldByHash = MatchMath.leftoverHashRankRebase(leftoverHoldByHash)
        leftoverHoldTrailByHash = MatchMath.leftoverHashRankRebase(leftoverHoldTrailByHash)
        leftoverCaptureHistByHash = MatchMath.leftoverHashRankRebase(leftoverCaptureHistByHash)
        leftoverCaptureHistAt = MatchMath.leftoverHashRankRebase(leftoverCaptureHistAt)
        leftoverHashNeedsRebase = !leftoverHoldByHash.isEmpty || !leftoverHoldTrailByHash.isEmpty
        if let stored = packed.printRevision, stored != MatchMath.printRevision {
            revisionWarning = "Galerie-Print \(stored), App \(MatchMath.printRevision) — Scores können springen. Neu scannen."
        }
        if let raw = UserDefaults.standard.array(forKey: enabledKey) as? [String] {
            let set = Set(raw.compactMap(StrategyID.init(rawValue:)))
            if !set.isEmpty { enabled = set }
        }
        if !UserDefaults.standard.bool(forKey: "aegis.terFusionDefaultOff") {
            enabled.remove(.terFusion)
            UserDefaults.standard.set(true, forKey: "aegis.terFusionDefaultOff")
            UserDefaults.standard.set(enabled.map(\.rawValue), forKey: enabledKey)
        }
        canResumeScan = hasResumeWork()
        if !identities.isEmpty {
            status = revisionWarning.isEmpty
                ? "Galerie · \(identities.count) Personen"
                : revisionWarning
        }
        if let raw = UserDefaults.standard.string(forKey: "aegis.cameraChoice"),
           UserDefaults.standard.object(forKey: "aegis.cameraPair.v188") != nil,
           let c = CameraChoice(rawValue: raw)
        {
            cameraChoice = c
        } else {
            UserDefaults.standard.set(true, forKey: "aegis.cameraPair.v188")
            let next = MatchMath.cameraPairAegisMigrates(
                UserDefaults.standard.string(forKey: "aegis.cameraChoice")
            )
            cameraChoice = CameraChoice(rawValue: next) ?? .builtIn
            UserDefaults.standard.set(cameraChoice.rawValue, forKey: "aegis.cameraChoice")
        }
        twinSplits = MatchMath.twinSplitDecode(
            UserDefaults.standard.stringArray(forKey: MatchMath.twinSplitStoreKey())
        )
        mutexKill = MatchMath.cameraMutexKillPref(UserDefaults.standard.bool(forKey: "aegis.mutexKill"))
        liveCapture.mutexKillEnabled = mutexKill
        installSleepWatch()
        if UserDefaults.standard.object(forKey: "aegis.yieldAutoReturn") != nil {
            yieldAutoReturn = MatchMath.cameraMutexYieldAutoReturnPref(
                UserDefaults.standard.bool(forKey: "aegis.yieldAutoReturn")
            )
        }
        let yg = UserDefaults.standard.double(forKey: "aegis.yieldGrace")
        if UserDefaults.standard.object(forKey: "aegis.yieldGrace") != nil {
            yieldGrace = MatchMath.cameraMutexYieldGracePref(yg)
        }
        liveCapture.yieldAutoReturn = yieldAutoReturn
        liveCapture.yieldGrace = yieldGrace
        let ttlStored = UserDefaults.standard.double(forKey: "aegis.holdTTLFloor")
        if ttlStored > 0 {
            holdTTLFloor = MatchMath.leftoverHoldTTLPref(ttlStored)
        }
        leftoverStreakSince = MatchMath.leftoverSeenRestore(
            packed.leftoverStreakSince,
            now: Date().timeIntervalSince1970,
            ttl: holdTTLFloor
        )
        if let extra = GalleryFile.loadPayload() {
            leftoverPairStreak = MatchMath.leftoverUUIDIntMapDecode(extra.leftoverPairStreak)
            leftoverPairCommit = MatchMath.leftoverUUIDUUIDMapDecode(extra.leftoverPairCommit)
            let walLoad = GalleryFile.loadWAL()
            if let applied = MatchMath.leftoverPairCommitWALApply(
                gallery: extra.leftoverPairCommit,
                wal: walLoad.pairs,
                galleryMtime: GalleryFile.galleryMtime(),
                walMtime: walLoad.mtime,
                now: Date().timeIntervalSince1970
            ) {
                leftoverPairCommit = MatchMath.leftoverUUIDUUIDMapDecode(applied)
            }
            leftoverPairCommitMiss = MatchMath.leftoverUUIDIntMapDecode(extra.leftoverPairCommitMiss)
            leftoverLastIoU = MatchMath.leftoverStreakSinceDecode(extra.leftoverLastIoU)
            let sparkPack = MatchMath.leftoverSparkChipUnpack(extra.leftoverSparkChip)
            leftoverSparkChipHeld = sparkPack.uuid
            leftoverSparkChipByHash = sparkPack.hash
            leftoverStreak = MatchMath.leftoverUUIDIntMapDecode(extra.leftoverStreak)
            leftoverStreakBox = MatchMath.leftoverStreakBoxDecode(extra.leftoverStreakBox)
            leftoverJpegByHash = MatchMath.leftoverJpegByHashDecode(
                extra.leftoverJpegByHash,
                now: Date().timeIntervalSince1970,
                ttl: jpegProbeTTL
            )
            if let gate = extra.leftoverAssignLiveGate {
                assignLiveGate = MatchMath.leftoverAssignLiveGateNeed(gate)
            }
            let kal = MatchMath.leftoverHoldKalmanDecode(extra.leftoverHoldKalman)
            boxKalman = kal.kalman
            boxKalmanV = kal.vel
            boxKalmanWHV = kal.whv
            leftoverKalmanRestoredAgo = boxKalman.isEmpty ? 99 : 0
            let coast = MatchMath.leftoverCoastPrintAgeDecode(
                vecs: extra.leftoverCoastPrint,
                remaining: extra.leftoverCoastPrintAge,
                now: Date().timeIntervalSince1970
            )
            leftoverCoastPrint = coast.print
            leftoverCoastPrintAt = coast.at
            leftoverPrintYaw = MatchMath.leftoverPrintYawDecode(extra.leftoverPrintYaw)
            leftoverPrintCache = MatchMath.leftoverPrintCacheDecodeOrder(extra.leftoverPrintCache)
        }
        let lockStored = UserDefaults.standard.double(forKey: "aegis.nameLockSec")
        if lockStored > 0 {
            nameLockSec = MatchMath.leftoverNameLockSecPref(lockStored)
        }
        let adoptStored = UserDefaults.standard.double(forKey: "aegis.adoptLockSec")
        if adoptStored > 0 {
            adoptLockSec = MatchMath.leftoverAdoptSecLockPref(adoptStored)
        }
        let gateStored = UserDefaults.standard.object(forKey: "aegis.assignLiveGate") as? Int
        if let gateStored {
            assignLiveGate = MatchMath.leftoverAssignLiveGateNeed(gateStored)
        }
        leftoverNameLockUntil = MatchMath.leftoverNameLockUntilRestore(
            held: leftoverNameLockHeld,
            remaining: MatchMath.leftoverNameLockUntilDecode(
                packed.leftoverNameLockUntil,
                now: 0
            ),
            now: Date().timeIntervalSince1970,
            arm: nameLockSec
        )
        let fillStored = UserDefaults.standard.double(forKey: "aegis.fillXRescue")
        if fillStored > 0 {
            fillXRescue = MatchMath.leftoverFillXRescuePref(fillStored)
        }
        let padStored = UserDefaults.standard.double(forKey: "aegis.fillXPad")
        if padStored > 0 {
            fillXPad = MatchMath.leftoverFillXPadPref(padStored)
        }
        let jpegStored = UserDefaults.standard.double(forKey: "aegis.jpegProbeTTL")
        if jpegStored > 0 {
            jpegProbeTTL = MatchMath.leftoverJpegProbeTTLPref(jpegStored)
        }
        let missStored = UserDefaults.standard.object(forKey: "aegis.missNeed") as? Int
        if let missStored {
            leftoverMissNeed = MatchMath.leftoverHoldMissNeedPref(missStored)
        }
        let jumpStored = UserDefaults.standard.double(forKey: "aegis.kalmanJump")
        if jumpStored > 0 {
            kalmanJump = MatchMath.leftoverHoldKalmanJumpPref(jumpStored)
        }
        liveCapture.choice = cameraChoice
        liveCapture.mutexKillEnabled = mutexKill
        let digest = GalleryFile.digestStatus()
        if let note = MatchMath.shaVerifyNote(ok: digest.ok, missing: digest.missing) {
            revisionWarning = revisionWarning.isEmpty ? note : revisionWarning + " · " + note
            if identities.isEmpty {
                status = note
            } else if revisionWarning == note {
                status = note
            }
        }
    }

    private func pruneGuestTTL() {
        let now = Date()
        var nearest: TimeInterval?
        let drop = identities.filter { ident in
            let enrolled = ident.faceIds.compactMap { fid in
                faces.first { $0.id == fid }?.enrolledAt
            }.min()
            let guest = MatchMath.guestPersistKeeps(name: ident.name)
            if let remain = MatchMath.guestTTLRemain(
                isGuest: guest,
                enrolledAt: enrolled,
                now: now,
                lastSeen: leftoverStreakSince[ident.id.uuidString]
            ) {
                if nearest == nil || remain < nearest! { nearest = remain }
            }
            return MatchMath.guestTTLExpired(
                isGuest: guest,
                enrolledAt: enrolled,
                now: now,
                lastSeen: leftoverStreakSince[ident.id.uuidString]
            )
        }
        guestTTLChip = MatchMath.guestTTLChip(remain: nearest) ?? "—"
        guard !drop.isEmpty else { return }
        let ids = Set(drop.map(\.id))
        identities.removeAll { ids.contains($0.id) }
    }

    private func persist() {
        pruneGuestTTL()
        GalleryFile.save(
            identities: identities,
            faces: faces,
            leftoverStreakSince: MatchMath.leftoverSeenRemainingEncode(
                since: leftoverStreakSince,
                now: Date().timeIntervalSince1970,
                ttl: leftoverHoldTTL
            ),
            leftoverHoldBins: MatchMath.leftoverHoldBinsEncode(leftoverHoldBins),
            leftoverHoldTrailBins: MatchMath.leftoverHoldTrailBinsEncode(leftoverHoldTrailBins),
            leftoverHoldHash: MatchMath.leftoverHashHoldEncode(leftoverHoldByHash),
            leftoverHoldTrailHash: MatchMath.leftoverHashTrailEncode(leftoverHoldTrailByHash),
            leftoverCaptureHist: MatchMath.leftoverCaptureHistTableEncode(
                leftoverCaptureHistByHash,
                keep: Array(leftoverLastHash.values)
            ),
            leftoverLastHash: MatchMath.leftoverUUIDStringMapEncode(
                MatchMath.leftoverLastHashRankRebase(
                    MatchMath.leftoverStoredHashMerge(last: leftoverLastHash, tick: leftoverLiveHashTick)
                )
            ),
            leftoverHold: MatchMath.leftoverStreakSinceEncode(leftoverHold),
            leftoverNameLockHeld: MatchMath.leftoverUUIDStringMapEncode(leftoverNameLockHeld),
            leftoverPairLast: MatchMath.leftoverUUIDUUIDMapEncode(leftoverPairLast),
            leftoverNameLockUntil: MatchMath.leftoverNameLockUntilEncode(
                until: leftoverNameLockUntil,
                now: Date().timeIntervalSince1970
            ),
            leftoverHoldTrail: MatchMath.leftoverUUIDTrailEncode(leftoverHoldTrail),
            leftoverPairStreak: MatchMath.leftoverUUIDIntMapEncode(leftoverPairStreak),
            leftoverPairCommit: MatchMath.leftoverUUIDUUIDMapEncode(leftoverPairCommit),
            leftoverStreak: MatchMath.leftoverUUIDIntMapEncode(leftoverStreak),
            leftoverStreakBox: MatchMath.leftoverStreakBoxEncode(leftoverStreakBox),
            leftoverAssignLiveGate: assignLiveGate,
            leftoverJpegByHash: MatchMath.leftoverJpegByHashEncode(
                leftoverJpegByHash,
                now: Date().timeIntervalSince1970,
                ttl: jpegProbeTTL
            ),
            leftoverHoldKalman: MatchMath.leftoverHoldKalmanEncode(boxKalman, vel: boxKalmanV, whv: boxKalmanWHV),
            leftoverHoldHashRemaining: MatchMath.leftoverHashHoldRemainingEncode(
                leftoverHoldByHash,
                now: Date().timeIntervalSince1970,
                ttl: leftoverHoldTTL
            ),
            leftoverHoldTrailRemaining: MatchMath.leftoverHashTrailRemainingEncode(
                leftoverHoldTrailByHash,
                now: Date().timeIntervalSince1970,
                ttl: leftoverHoldTTL
            ),
            leftoverPairCommitMiss: MatchMath.leftoverUUIDIntMapEncode(leftoverPairCommitMiss),
            leftoverLastIoU: MatchMath.leftoverStreakSinceEncode(leftoverLastIoU),
            leftoverCaptureHistRemaining: MatchMath.leftoverCaptureHistRemainingEncode(
                leftoverCaptureHistByHash,
                at: leftoverCaptureHistAt,
                now: Date().timeIntervalSince1970,
                ttl: leftoverHoldTTL
            ),
            leftoverSparkChip: MatchMath.leftoverSparkChipPack(
                uuid: leftoverSparkChipHeld,
                hash: leftoverSparkChipByHash
            ),
            leftoverCoastPrint: MatchMath.leftoverCoastPrintVecEncode(leftoverCoastPrint),
            leftoverCoastPrintAge: MatchMath.leftoverCoastPrintAgeEncode(
                vecs: leftoverCoastPrint,
                stamped: leftoverCoastPrintAt,
                now: Date().timeIntervalSince1970
            ),
            leftoverPrintYaw: MatchMath.leftoverPrintYawEncode(leftoverPrintYaw),
            leftoverPrintCache: MatchMath.leftoverPrintCacheEncode(leftoverPrintCache)
        )
        if !liveActive {
            refreshMergeHint()
        }
    }

    func refreshMergeHint() {
        let pairs = IdentityDesk.mergePairs(identities: identities, gallery: faces)
        if let p = pairs.first {
            mergeHint = MatchMath.mergeHintLabel(count: pairs.count, a: p.keepName, b: p.dropName, cosine: p.cosine)
        } else {
            mergeHint = ""
        }
    }

    func acceptMergeHint() {
        let pairs = IdentityDesk.mergePairs(identities: identities, gallery: faces)
        guard let p = pairs.first else { return }
        mergeIdentities(keep: p.keep, drop: p.drop)
    }

    func mergeIdentities(keep: UUID, drop: UUID) {
        guard keep != drop,
              let ki = identities.firstIndex(where: { $0.id == keep }),
              let di = identities.firstIndex(where: { $0.id == drop })
        else { return }
        let extra = identities[di].faceIds
        identities[ki].faceIds.append(contentsOf: extra.filter { !identities[ki].faceIds.contains($0) })
        identities[ki].rejectedVecs.append(contentsOf: identities[di].rejectedVecs)
        let name = identities[ki].name
        identities.remove(at: di)
        if leftoverBlinkByIdentity[drop] == true {
            leftoverBlinkByIdentity[keep] = true
        }
        leftoverBlinkByIdentity.removeValue(forKey: drop)
        persist()
        rematch()
        status = "\(name) zusammengeführt"
    }

    var canRestoreBackup: Bool { GalleryFile.backupExists }

    func restoreFromBackup() {
        guard let packed = GalleryFile.loadBackup() else {
            status = "Kein gallery.json.bak"
            return
        }
        identities = packed.identities
        faces = packed.faces
        leftoverStreakSince = MatchMath.leftoverStreakSinceDecode(packed.leftoverStreakSince)
        leftoverHoldBins = MatchMath.leftoverHoldBinsDecode(packed.leftoverHoldBins)
        leftoverHoldTrailBins = MatchMath.leftoverHoldTrailBinsDecode(packed.leftoverHoldTrailBins)
        leftoverHoldByHash = MatchMath.leftoverHashHoldDecode(
            packed.leftoverHoldHash,
            now: Date().timeIntervalSince1970,
            remaining: GalleryFile.loadBackupPayload()?.leftoverHoldHashRemaining,
            ttl: leftoverHoldTTL
        )
        leftoverHoldTrailByHash = MatchMath.leftoverHashTrailDecode(
            packed.leftoverHoldTrailHash,
            now: Date().timeIntervalSince1970,
            remaining: GalleryFile.loadBackupPayload()?.leftoverHoldTrailRemaining,
            ttl: leftoverHoldTTL
        )
        leftoverCaptureHistByHash = MatchMath.leftoverCaptureHistTableDecodeFresh(
            packed.leftoverCaptureHist,
            remaining: GalleryFile.loadBackupPayload()?.leftoverCaptureHistRemaining,
            keep: leftoverHoldByHash.keys.flatMap { [$0, MatchMath.leftoverHoldHashSpatial($0)] }
        )
        leftoverCaptureHistAt = MatchMath.leftoverHashRankRebase(
            MatchMath.leftoverCaptureHistAtDecode(
                remaining: GalleryFile.loadBackupPayload()?.leftoverCaptureHistRemaining,
                now: Date().timeIntervalSince1970,
                ttl: leftoverHoldTTL
            )
        )
        leftoverLastHash = MatchMath.leftoverLastHashRankRebase(
            MatchMath.leftoverUUIDStringMapDecode(packed.leftoverLastHash)
        )
        leftoverHold = MatchMath.leftoverStreakSinceDecode(packed.leftoverHold)
        leftoverNameLockHeld = MatchMath.leftoverNameLockHeldSurvive(
            held: MatchMath.leftoverUUIDStringMapDecode(packed.leftoverNameLockHeld),
            until: MatchMath.leftoverNameLockUntilDecode(packed.leftoverNameLockUntil, now: 0)
        )
        leftoverPairLast = MatchMath.leftoverUUIDUUIDMapDecode(packed.leftoverPairLast)
        leftoverHoldTrail = MatchMath.leftoverUUIDTrailDecode(packed.leftoverHoldTrail)
        leftoverNameLockUntil = MatchMath.leftoverNameLockUntilRestore(
            held: leftoverNameLockHeld,
            remaining: MatchMath.leftoverNameLockUntilDecode(packed.leftoverNameLockUntil, now: 0),
            now: Date().timeIntervalSince1970,
            arm: nameLockSec
        )
        leftoverStreakSince = MatchMath.leftoverSeenRestore(
            packed.leftoverStreakSince,
            now: Date().timeIntervalSince1970,
            ttl: holdTTLFloor
        )
        leftoverHoldByHash = MatchMath.leftoverHashRankRebase(leftoverHoldByHash)
        leftoverHoldTrailByHash = MatchMath.leftoverHashRankRebase(leftoverHoldTrailByHash)
        leftoverCaptureHistByHash = MatchMath.leftoverHashRankRebase(leftoverCaptureHistByHash)
        leftoverCaptureHistAt = MatchMath.leftoverHashRankRebase(leftoverCaptureHistAt)
        leftoverHashNeedsRebase = !leftoverHoldByHash.isEmpty || !leftoverHoldTrailByHash.isEmpty
        liveNameHist = [:]
        liveNameLock = [:]
        liveScoreEma = [:]
        liveScoreTicks = [:]
        liveYaw = [:]
        livePitch = [:]
        liveRoll = [:]
        liveLastStamp = 0
        liveDt = 0.125
        liveDtSamples = []
        leftoverHoldSeenSlow = false
        leftoverHoldFastFor = 0
        leftoverLiveHashTick = [:]
        leftoverMissCoastTicks = 0
        liveNameVoteAt = [:]
        tapNameLockUntil = [:]
        liveFaceStreak = 0
        leftoverStreak = [:]
        leftoverPairStreak = [:]
        leftoverPairCommit = [:]
        leftoverPairCommitMiss = [:]
        leftoverPending = [:]
        if let extra = GalleryFile.loadBackupPayload() {
            leftoverPairStreak = MatchMath.leftoverUUIDIntMapDecode(extra.leftoverPairStreak)
            leftoverPairCommit = MatchMath.leftoverUUIDUUIDMapDecode(extra.leftoverPairCommit)
            leftoverPairCommitMiss = MatchMath.leftoverUUIDIntMapDecode(extra.leftoverPairCommitMiss)
            leftoverLastIoU = MatchMath.leftoverStreakSinceDecode(extra.leftoverLastIoU)
            let sparkPack = MatchMath.leftoverSparkChipUnpack(extra.leftoverSparkChip)
            leftoverSparkChipHeld = sparkPack.uuid
            leftoverSparkChipByHash = sparkPack.hash
            leftoverStreak = MatchMath.leftoverUUIDIntMapDecode(extra.leftoverStreak)
            leftoverStreakBox = MatchMath.leftoverStreakBoxDecode(extra.leftoverStreakBox)
            leftoverJpegByHash = MatchMath.leftoverJpegByHashDecode(
                extra.leftoverJpegByHash,
                now: Date().timeIntervalSince1970,
                ttl: jpegProbeTTL
            )
            if let gate = extra.leftoverAssignLiveGate {
                assignLiveGate = MatchMath.leftoverAssignLiveGateNeed(gate)
            }
            let kal = MatchMath.leftoverHoldKalmanDecode(extra.leftoverHoldKalman)
            boxKalman = kal.kalman
            boxKalmanV = kal.vel
            boxKalmanWHV = kal.whv
            leftoverKalmanRestoredAgo = boxKalman.isEmpty ? 99 : 0
            let coast = MatchMath.leftoverCoastPrintAgeDecode(
                vecs: extra.leftoverCoastPrint,
                remaining: extra.leftoverCoastPrintAge,
                now: Date().timeIntervalSince1970
            )
            leftoverCoastPrint = coast.print
            leftoverCoastPrintAt = coast.at
            leftoverPrintYaw = MatchMath.leftoverPrintYawDecode(extra.leftoverPrintYaw)
            leftoverPrintCache = MatchMath.leftoverPrintCacheDecodeOrder(extra.leftoverPrintCache)
        } else {
            leftoverStreak = [:]
            leftoverPairStreak = [:]
            leftoverPairCommit = [:]
            leftoverPairCommitMiss = [:]
            leftoverStreakBox = [:]
            leftoverJpegByHash = [:]
            boxKalman = [:]
            boxKalmanV = [:]
            boxKalmanWHV = [:]
            leftoverKalmanRestoredAgo = 99
        }
        liveGhosts = []
        guestOrder = []
        guestSeenAt = [:]
        rematch()
        persist()
        let schema = packed.schemaVersion.map { "Schema \($0)" } ?? "Schema <2"
        status = "Galerie aus Backup · \(identities.count) Personen · \(faces.count) Gesichter · \(schema)"
    }

    func restoreWarning() -> String {
        let age = GalleryFile.backupAgeDays() ?? 0
        let packed = GalleryFile.loadBackup()
        return MatchMath.restoreNote(
            ageDays: age,
            schemaVersion: packed?.schemaVersion,
            printRevision: packed?.printRevision
        )
    }

    var selectedMedia: MediaItem? {
        media.first { $0.id == selectedMediaId }
    }

    var browseItems: [MediaItem] {
        media.filter { $0.kind != .frame && $0.kind != .snapshot }
    }

    var browseIndex: Int {
        let id: UUID?
        if let item = selectedMedia, item.kind == .frame {
            id = item.parentId
        } else {
            id = selectedMediaId
        }
        guard let id else { return 0 }
        return browseItems.firstIndex { $0.id == id } ?? 0
    }

    var browseLabel: String {
        let n = browseItems.count
        guard n > 0 else { return "0 / 0" }
        let name = selectedMedia?.name ?? browseItems[browseIndex].name
        return "\(browseIndex + 1) / \(n)  ·  \(name)"
    }

    var selectedFace: FaceObservation? {
        if let id = selectedFaceId, let face = faces.first(where: { $0.id == id }) {
            return face
        }
        if let mediaId = selectedMediaId {
            return faces.first { $0.mediaId == mediaId }
        }
        return nil
    }

    var liveContinuity: Bool { liveActive && liveCapture.isContinuity }

    var floorHint: String {
        let f = FaceEngine.effectiveFloors(galleryCount: identities.count, slider: threshold)
        let open = Int(MatchMath.unknownRejectFloor(slider: threshold).rounded())
        let unnamed = leftoverPending.values.filter { $0 == MatchMath.conflictTickNote() || $0.hasPrefix("Gast") }.count
        let named = identities.count
        if named + unnamed > 0, unnamed > 0 {
            let far = MatchMath.liveFAR(impostorAbove: unnamed, totalImpostor: named + unnamed)
            return "Galerie \(identities.count): Floor \(Int(f.match)) · Solo \(Int(f.solo)) · Open-Set \(open) · \(MatchMath.liveFARLabel(far))"
        }
        return "Galerie \(identities.count): Floor \(Int(f.match)) · Solo \(Int(f.solo)) · Open-Set \(open)"
    }

    var benchHome: URL { BenchFetch.root() }

    var benchHint: String {
        if BenchFetch.ident20Ready() {
            return "Testdaten bereit in Downloads/AegisBench — Test starten."
        }
        return "Fotos stehen nicht auf GitHub (Lizenz). Testdaten holen: ~170 MB, einmalig."
    }

    var enrollmentHint: String {
        guard let face = selectedFace else { return "" }
        let dest = FaceEngine.identityOwning(face: face, identities: identities, faces: faces)
            ?? (identities.count == 1 ? identities[0] : nil)
        return FaceEngine.enrollmentPreview(
            face: face,
            identities: identities,
            faces: faces,
            addingTo: dest,
            haveBlink: leftoverBlinkSeen(faceId: face.id, identityId: dest?.id)
        )
    }

    var selectedHits: [StrategyHit] {
        guard let id = selectedFace?.id else { return [] }
        return matches.first { $0.faceId == id }?.hits ?? []
    }

    func selectMedia(_ id: UUID?) {
        selectedMediaId = id
        if let id {
            if let current = selectedFaceId,
               faces.contains(where: { $0.id == current && $0.mediaId == id }) {
                return
            }
            selectedFaceId = faces.first { $0.mediaId == id }?.id
        } else {
            selectedFaceId = nil
        }
    }

    func stepMedia(_ delta: Int) {
        let items = browseItems
        guard items.count >= 2 else { return }
        let next = (browseIndex + delta % items.count + items.count) % items.count
        let item = items[next]
        if item.kind == .video {
            selectMedia(media.first { $0.parentId == item.id }?.id ?? item.id)
        } else {
            selectMedia(item.id)
        }
    }

    func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.folder, .image, .movie, .jpeg, .png, .heic, .mpeg4Movie, .quickTimeMovie]
        panel.prompt = "Scannen"
        panel.message = "Ordner oder mehrere Fotos wählen — danach mit ← → blättern."
        if let data = UserDefaults.standard.data(forKey: resumeBookmarkKey) {
            var stale = false
            if let url = try? URL(
                resolvingBookmarkData: data,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            ) {
                panel.directoryURL = url
            }
        }
        guard panel.runModal() == .OK else { return }
        var roots: [URL] = []
        var files: [URL] = []
        var folders: [URL] = []
        for url in panel.urls {
            roots.append(url)
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
            if isDir.boolValue {
                folders.append(url)
            } else {
                files.append(url)
            }
        }
        retainAccess(roots)
        rememberFolder(roots.first)
        scanGeneration += 1
        scanFlag.reset()
        let gen = scanGeneration
        let flag = scanFlag
        busy = true
        status = "Ordner lesen …"
        Task {
            var urls = files
            for folder in folders {
                if gen != self.scanGeneration { return }
                let found = await Task.detached {
                    FrameExtractor.walk(folder: folder) { flag.alive }
                }.value
                if gen != self.scanGeneration {
                    self.rememberRemaining(urls)
                    self.status = "Scan abgebrochen — Fortsetzen möglich"
                    self.busy = false
                    return
                }
                urls.append(contentsOf: found)
            }
            if gen != self.scanGeneration {
                self.rememberRemaining(urls)
                self.status = "Scan abgebrochen — Fortsetzen möglich"
                self.busy = false
                return
            }
            await self.ingestAndScan(urls: urls, generation: gen)
        }
    }

    func resumeScan() {
        openResumeBookmark()
        let paths = UserDefaults.standard.stringArray(forKey: resumeRemainingKey) ?? []
        let urls = paths.map { URL(fileURLWithPath: $0) }.filter { FileManager.default.fileExists(atPath: $0.path) }
        let detectRaw = UserDefaults.standard.stringArray(forKey: resumeDetectKey) ?? []
        let detectIds = detectRaw.compactMap(UUID.init(uuidString:))
        let detectPaths = detectRaw.filter { UUID(uuidString: $0) == nil }
        let detectURLs = detectPaths.map { URL(fileURLWithPath: $0) }.filter { FileManager.default.fileExists(atPath: $0.path) }
        if urls.isEmpty, detectIds.isEmpty, detectURLs.isEmpty {
            canResumeScan = false
            status = "Nichts zum Fortsetzen"
            return
        }
        if urls.isEmpty, !detectIds.isEmpty, media.isEmpty, detectURLs.isEmpty {
            UserDefaults.standard.removeObject(forKey: resumeDetectKey)
            canResumeScan = false
            status = "Erkennung nach Neustart nicht fortsetzbar — Ordner erneut wählen"
            return
        }
        scanGeneration += 1
        scanFlag.reset()
        let gen = scanGeneration
        busy = true
        if !urls.isEmpty {
            status = "Scan fortsetzen · \(urls.count) Dateien"
            Task {
                await self.ingestAndScan(urls: urls, generation: gen)
            }
        } else {
            let missing = detectURLs.filter { u in !media.contains { $0.url.path == u.path } }
            if !missing.isEmpty {
                ingest(urls: missing)
            }
            let fromPaths = Set(media.filter { item in detectURLs.contains { $0.path == item.url.path } }.map(\.id))
            let ids = detectIds.isEmpty ? Array(fromPaths) : detectIds
            status = "Erkennung fortsetzen · \(ids.count) Medien"
            Task {
                await self.scan(generation: gen, onlyMedia: ids)
            }
        }
    }

    private func ingestAndScan(urls: [URL], generation: Int) async {
        var remaining = urls
        let before = media.count
        var batch: [URL] = []
        func flush() {
            guard !batch.isEmpty else { return }
            ingest(urls: batch)
            remaining.removeAll { batch.contains($0) }
            batch.removeAll(keepingCapacity: true)
        }
        for url in urls {
            if generation != scanGeneration {
                flush()
                rememberRemaining(remaining)
                status = "Scan abgebrochen — Fortsetzen möglich"
                busy = false
                canResumeScan = true
                return
            }
            batch.append(url)
            if batch.count >= 24 { flush() }
        }
        flush()
        rememberRemaining([])
        canResumeScan = false
        if let firstNew = media.dropFirst(before).first(where: { $0.kind == .photo })
            ?? media.dropFirst(before).first
        {
            selectedMediaId = firstNew.id
        }
        if generation != scanGeneration {
            busy = false
            return
        }
        await scan(generation: generation)
    }

    private func rememberFolder(_ url: URL?) {
        guard let url else { return }
        if let data = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
            UserDefaults.standard.set(data, forKey: resumeBookmarkKey)
        }
    }

    private func rememberRemaining(_ urls: [URL]) {
        UserDefaults.standard.set(urls.map(\.path), forKey: resumeRemainingKey)
        canResumeScan = hasResumeWork()
    }

    private func rememberDetectRemaining(_ ids: [UUID]) {
        let paths = ids.compactMap { id in media.first { $0.id == id }?.url.path }
        UserDefaults.standard.set(paths, forKey: resumeDetectKey)
        canResumeScan = hasResumeWork()
    }

    private func hasResumeWork() -> Bool {
        let files = UserDefaults.standard.stringArray(forKey: resumeRemainingKey) ?? []
        let detect = UserDefaults.standard.stringArray(forKey: resumeDetectKey) ?? []
        return !files.isEmpty || !detect.isEmpty
    }

    private func openResumeBookmark() {
        guard let data = UserDefaults.standard.data(forKey: resumeBookmarkKey) else { return }
        var stale = false
        guard let url = try? URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        ) else { return }
        _ = url.startAccessingSecurityScopedResource()
        if stale { rememberFolder(url) }
        retainAccess([url] + scopedRoots.filter { $0.path != url.path })
    }

    private func retainAccess(_ urls: [URL]) {
        let previous = scopedRoots
        scopedRoots = urls
        let newPaths = Set(urls.map(\.path))
        for url in urls {
            _ = url.startAccessingSecurityScopedResource()
        }
        for url in previous where !newPaths.contains(url.path) {
            url.stopAccessingSecurityScopedResource()
        }
    }

    func ingest(urls: [URL]) {
        var skipped = 0
        for url in urls {
            if FrameExtractor.isVideo(url) {
                media.append(
                    MediaItem(
                        id: UUID(),
                        url: url,
                        name: url.lastPathComponent,
                        kind: .video,
                        width: 0,
                        height: 0,
                        duration: nil
                    )
                )
            } else if FrameExtractor.isImage(url) {
                if let image = FrameExtractor.loadCGImage(url: url) {
                    media.append(
                        MediaItem(
                            id: UUID(),
                            url: url,
                            name: url.lastPathComponent,
                            kind: .photo,
                            width: image.width,
                            height: image.height,
                            preview: image
                        )
                    )
                } else {
                    skipped += 1
                }
            } else {
                skipped += 1
            }
        }
        selectedMediaId = media.first { $0.kind == .photo }?.id ?? media.first?.id
        let photos = media.filter { $0.kind == .photo }.count
        let videos = media.filter { $0.kind == .video }.count
        if media.isEmpty {
            status = skipped > 0 ? "\(skipped) Dateien unlesbar" : "Keine Medien"
        } else if skipped > 0 {
            status = "\(photos) Fotos, \(videos) Videos · \(skipped) übersprungen · ← → blättern"
        } else {
            status = "\(photos) Fotos, \(videos) Videos · ← → blättern"
        }
    }

    func cancelScan() {
        guard busy else { return }
        scanFlag.stop()
        scanGeneration += 1
        busy = false
        canResumeScan = hasResumeWork()
        status = canResumeScan ? "Scan abgebrochen — Fortsetzen möglich" : "Scan abgebrochen"
    }

    func scan() async {
        scanGeneration += 1
        scanFlag.reset()
        await scan(generation: scanGeneration)
    }

    private func scan(generation: Int, onlyMedia: [UUID]? = nil) async {
        busy = true
        status = "Frames extrahieren"
        let videos = media.filter { $0.kind == .video }
        let haveFrames = Set(media.compactMap { $0.parentId })
        for video in videos where !haveFrames.contains(video.id) {
            if generation != scanGeneration {
                status = "Scan abgebrochen"
                busy = false
                return
            }
            status = "Video · \(video.name)"
            do {
                let frames = try await FrameExtractor.extract(from: video.url)
                if generation != scanGeneration {
                    status = "Scan abgebrochen"
                    busy = false
                    return
                }
                if frames.isEmpty {
                    status = "\(video.name): keine Frames"
                    continue
                }
                for frame in frames {
                    media.append(
                        MediaItem(
                            id: UUID(),
                            url: video.url,
                            name: String(format: "%@ · %.2fs", video.name, frame.time),
                            kind: .frame,
                            width: frame.image.width,
                            height: frame.image.height,
                            parentId: video.id,
                            timeSec: frame.time,
                            preview: frame.image
                        )
                    )
                }
            } catch {
                status = "\(video.name): \(error.localizedDescription)"
                continue
            }
        }
        var pending = media.filter { item in
            (item.kind == .photo || item.kind == .frame) && !faces.contains { $0.mediaId == item.id }
        }
        if let only = onlyMedia, !only.isEmpty {
            let set = Set(only)
            pending = pending.filter { set.contains($0.id) }
        }
        var ingestSkipped = 0
        for (i, item) in pending.enumerated() {
            if generation != scanGeneration {
                rememberDetectRemaining(Array(pending.dropFirst(i).map(\.id)))
                status = "Scan abgebrochen — Fortsetzen möglich"
                busy = false
                canResumeScan = true
                return
            }
            status = "Gesicht · \(i + 1)/\(pending.count)"
            let image = item.preview ?? FrameExtractor.loadCGImage(url: item.url)
            guard let image else { continue }
            let mediaId = item.id
            do {
                let found = try await Task.detached(priority: .userInitiated) {
                    try FaceEngine.detect(in: image, mediaId: mediaId, cheapGraph: true)
                }.value
                if generation != scanGeneration {
                    rememberDetectRemaining(Array(pending.dropFirst(i).map(\.id)))
                    status = "Scan abgebrochen — Fortsetzen möglich"
                    busy = false
                    canResumeScan = true
                    return
                }
                let kept = FaceEngine.filterIngestDuplicates(found, existing: faces)
                let skipped = found.count - kept.count
                ingestSkipped += skipped
                faces.append(contentsOf: kept)
                if skipped > 0 {
                    status = "Gesicht · \(i + 1)/\(pending.count) · \(skipped) Burst-Kopien übersprungen"
                }
            } catch {
                continue
            }
        }
        rememberDetectRemaining([])
        if generation != scanGeneration {
            status = "Scan abgebrochen — Fortsetzen möglich"
            busy = false
            canResumeScan = hasResumeWork()
            return
        }
        status = "Abgleich"
        nmsDropped = FaceEngine.lastNMSDropped
        rematch()
        if let mediaId = selectedMediaId {
            if selectedFaceId == nil || !(faces.contains { $0.id == selectedFaceId && $0.mediaId == mediaId }) {
                selectedFaceId = faces.first { $0.mediaId == mediaId }?.id
            }
        } else if selectedFaceId == nil {
            selectedFaceId = faces.first?.id
        }
        let emptyPrints = faces.filter { $0.featurePrint.isEmpty }.count
        let skipNote = ingestSkipped > 0 ? " · \(ingestSkipped) Burst-Kopien übersprungen" : ""
        if !FaceEngine.facePrintAvailable {
            status = "Fertig · \(faces.count) Gesichter · Face-Print nicht verfügbar — nur Geometrie\(skipNote)"
        } else if !faces.isEmpty, emptyPrints == faces.count {
            status = "Fertig · \(faces.count) Gesichter · Face-Print leer — nur Geometrie\(skipNote)"
        } else {
            status = "Fertig · \(faces.count) Gesichter\(skipNote)"
        }
        busy = false
    }

    func rematch() {
        matches = FaceEngine.match(
            faces: faces,
            identities: identities,
            media: media,
            threshold: threshold,
            enabled: enabled,
            continuity: liveContinuity
        )
        if !liveActive {
            refreshMergeHint()
        }
    }

    /// Live-Frame: Sonden gegen Identitäts-Centroids, nicht jedes Galerie-Foto.
    func rematchLive() {
        guard liveActive, let liveId = liveMediaId else {
            rematch()
            return
        }
        let enrolled = Set(identities.flatMap(\.faceIds))
        let live = faces.filter { $0.mediaId == liveId }
        let gallery = faces.filter { enrolled.contains($0.id) && $0.mediaId != liveId }
        let next = FaceEngine.matchLive(
            probes: live,
            identities: identities,
            gallery: gallery,
            threshold: threshold,
            continuity: liveContinuity
        )
        let probeIds = Set(live.map(\.id))
        matches = matches.filter { !probeIds.contains($0.faceId) } + next
        stabilizeLiveMatches()
    }

    /// Live: 5-Tick-Namensmehrheit + Score der gewählten ID, sonst flackert Overlay zwischen Geschwistern.
    private func stabilizeLiveMatches() {
        guard liveActive, let liveId = liveMediaId else { return }
        let liveFaceIds = Set(faces.filter { $0.mediaId == liveId }.map(\.id))
        liveNameHist = liveNameHist.filter { liveFaceIds.contains($0.key) }
        liveNameLock = liveNameLock.filter { liveFaceIds.contains($0.key) }
        liveNameVoteAt = liveNameVoteAt.filter { liveFaceIds.contains($0.key) }
        liveScoreEma = liveScoreEma.filter { liveFaceIds.contains($0.key) }
        liveScoreTicks = liveScoreTicks.filter { liveFaceIds.contains($0.key) }
        liveYaw = liveYaw.filter { liveFaceIds.contains($0.key) }
        livePitch = livePitch.filter { liveFaceIds.contains($0.key) }
        liveRoll = liveRoll.filter { liveFaceIds.contains($0.key) }
        livePrintDrift = livePrintDrift.filter { liveFaceIds.contains($0.key) }
        livePoseAt = livePoseAt.filter { liveFaceIds.contains($0.key) }
        freezeAxis = freezeAxis.filter { liveFaceIds.contains($0.key) }
        let frameNow = liveLastStamp > 0 ? liveLastStamp : Date().timeIntervalSince1970
        let smBins = MatchMath.enrollSMCacheBins(cache: Set(leftoverPrintCache), liveHashes: [])
        let smFlags = MatchMath.enrollSMReady(
            haveFrontal: smBins.contains(0),
            haveLeft: smBins.contains(-1),
            haveRight: smBins.contains(1),
            haveBlink: true
        )
        for i in matches.indices {
            let fid = matches[i].faceId
            guard liveFaceIds.contains(fid),
                  let hi = matches[i].hits.firstIndex(where: { $0.strategy == .aegis })
            else { continue }
            var hit = matches[i].hits[hi]
            if !hit.measured {
                continue
            }
            let face = faces.first { $0.id == fid }
            let yaw = face?.quality.yaw ?? 0
            let pitch = face?.quality.pitch ?? 0
            let roll = face?.quality.roll ?? 0
            let prevYaw = liveYaw[fid]
            let prevPitch = livePitch[fid]
            let prevRoll = liveRoll[fid]
            let gap = livePoseAt[fid].map { frameNow - $0 } ?? 0
            let dt = MatchMath.trackDt(now: frameNow, last: livePoseAt[fid], cameraDt: liveDt)
            let dropped = MatchMath.poseDropoutResets(gap: gap, cameraDt: liveDt) && livePoseAt[fid] != nil
            liveYaw[fid] = yaw
            livePitch[fid] = pitch
            liveRoll[fid] = roll
            livePoseAt[fid] = frameNow
            let spinning = !dropped && MatchMath.poseVelocityFreeze(
                yawDelta: prevYaw.map { yaw - $0 } ?? 0,
                pitchDelta: prevPitch.map { pitch - $0 } ?? 0,
                rollDelta: prevRoll.map { roll - $0 } ?? 0,
                dt: dt
            ) && (prevYaw != nil || prevPitch != nil || prevRoll != nil)
            freezeAxis.removeValue(forKey: fid)
            if spinning, let axis = MatchMath.poseFreezeAxis(
                yawDelta: prevYaw.map { yaw - $0 } ?? 0,
                pitchDelta: prevPitch.map { pitch - $0 } ?? 0,
                rollDelta: prevRoll.map { roll - $0 } ?? 0,
                dt: dt
            ) {
                freezeAxis[fid] = axis
            }
            let qualityOK = MatchMath.nameVoteAccepts(
                sharpness: face?.quality.sharpness,
                continuity: liveContinuity,
                occluded: face.map { FaceEngine.lowerFaceOccluded($0) } ?? false,
                gazeAway: MatchMath.gazeAway(yaw: face?.quality.yaw ?? 0, pitch: face?.quality.pitch ?? 0),
                eyesClosed: MatchMath.eyesClosed(
                    openIod: face?.ratioSheet.first { $0.id == "eyeOpen_iod" }?.value
                ),
                mouthOpen: MatchMath.mouthOpen(
                    heightIod: face?.ratioSheet.first { $0.id == "mouthH_iod" }?.value
                )
            )
            let muted = MatchMath.leftoverWipeMutes(
                until: leftoverWipeUntil[fid],
                now: frameNow,
                histCount: (liveNameHist[fid] ?? []).filter { !$0.isEmpty }.count
            )
            // leftover wischt Hist einmal am Pin (applyLiveFaces). Hier nicht jeden Tick
            // leere Tokens füttern — sonst tauft Genuine 0,64–0,79 nie.
            // Drehung / Unschärfe / Gähnen / Wipe-Mute: Token leer = Skip, Lock hält.
            let token: String = {
                if muted { return "" }
                if MatchMath.leftoverStarvesVote() && leftoverHold[fid] != nil { return "" }
                if spinning || !qualityOK { return "" }
                if MatchMath.leftoverNameLockBlocks(until: leftoverNameLockUntil[fid], now: frameNow) { return "" }
                return hit.identityId?.uuidString ?? ""
            }()
            let vs = hit.versus
            let close = MatchMath.nameClosePair(
                best: vs.first?.percent ?? 0,
                second: vs.dropFirst().first?.percent,
                pairCosine: hit.pairCosine
            )
            let need = MatchMath.nameTemporalNeed(family: close, dt: dt)
            let cap = MatchMath.nameHistCap(need: need, dt: dt)
            let hist = MatchMath.nameHistAppend(liveNameHist[fid] ?? [], token: token, cap: cap)
            liveNameHist[fid] = hist
            let voted = MatchMath.leftoverLiveNameAnd(
                voted: MatchMath.nameTemporalVote(hist, dt: dt, family: close),
                hist: hist,
                need: need,
                locked: MatchMath.leftoverNameLockBlocks(until: leftoverNameLockUntil[fid], now: frameNow),
                held: liveNameLock[fid]?.uuidString,
                enrollReady: MatchMath.enrollSMReadyFromChip(enrollSMChip, needProfile: !twinSplits.isEmpty) && smFlags,
                alreadyNamed: liveNameLock[fid] != nil
            )
            if let voted, !voted.isEmpty {
                liveNameVoteAt[fid] = frameNow
                let hash = leftoverLastHash[fid] ?? fid.uuidString
                let expected = liveNameLock[fid]?.uuidString ?? ""
                let cos = MatchMath.falseAcceptJSONLCosine(
                    hold: leftoverHoldNow(faceId: fid, yawAbs: liveYaw[fid] ?? face?.quality.yaw),
                    emaPercent: liveScoreEma[fid]
                )
                appendFalseAcceptLog(hash: hash, identity: expected, cosine: cos, decided: voted)
            }
            let holding = leftoverHold[fid] != nil
            let lockedId = liveNameLock[fid]
            let lockedPrint: Double? = {
                guard let lockedId else { return nil }
                if let row = vs.first(where: { $0.identityId == lockedId }) {
                    return row.percent / 100
                }
                return nil
            }()
            let lockedMissing = lockedId != nil && lockedPrint == nil && !vs.isEmpty
            let keep = MatchMath.nameLockHolds(
                voted: voted,
                locked: MatchMath.leftoverLocked(locked: lockedId?.uuidString, holding: holding),
                lockedPrint: lockedMissing ? 0 : lockedPrint,
                lastVote: liveNameVoteAt[fid],
                now: frameNow
            )
            if let keep, let ident = identities.first(where: { $0.id.uuidString == keep }) {
                leftoverHold.removeValue(forKey: fid)
                liveNameLock[fid] = ident.id
                hit.identityId = ident.id
                hit.percent = MatchMath.votedPercent(
                    versus: hit.versus.map { ($0.identityId, $0.percent) },
                    identityId: ident.id,
                    fallback: hit.percent
                )
            } else {
                liveNameLock.removeValue(forKey: fid)
                hit.identityId = nil
            }
            let rawPct = hit.percent
            let ema = MatchMath.liveScoreEMA(prev: liveScoreEma[fid], next: rawPct)
            liveScoreEma[fid] = ema
            let ticks = MatchMath.leftoverScoreTickPut(rawPct, onto: liveScoreTicks[fid] ?? [])
            liveScoreTicks[fid] = ticks
            hit.percent = MatchMath.leftoverScoreTickOverlay(ema: ema, ticks: ticks)
            matches[i].hits[hi] = hit
            var spark = livePrintDrift[fid] ?? []
            let identId = hit.identityId ?? liveNameLock[fid]
            if let identId,
               let ident = identities.first(where: { $0.id == identId }),
               let face
            {
                let owned = faces.filter { ident.faceIds.contains($0.id) }
                let centroid = FaceEngine.liveCentroid(owned, slot: FaceEngine.poseSlot(face))
                let pv = face.printVec.count >= 32 ? face.printVec : FaceEngine.embedding(of: face)
                if pv.count >= 32, centroid.count == pv.count,
                   let sample = MatchMath.printDriftSample(centroidCosine: MatchMath.cosine(pv, centroid))
                {
                    spark.append(sample)
                }
            }
            if spark.count > 8 { spark.removeFirst(spark.count - 8) }
            livePrintDrift[fid] = spark
        }
        tickLeftoverSparkChips(liveFaceIds: liveFaceIds)
    }

    private func stampEnrolled(_ faceId: UUID) {
        if let i = faces.firstIndex(where: { $0.id == faceId }), faces[i].enrolledAt == nil {
            faces[i].enrolledAt = Date()
        }
    }

    func setEnabled(_ id: StrategyID, _ on: Bool) {
        if on { enabled.insert(id) } else { enabled.remove(id) }
        UserDefaults.standard.set(enabled.map(\.rawValue), forKey: enabledKey)
        rematch()
    }

    func setTrack(_ track: StrategyTrack, on: Bool) {
        for id in StrategyID.allCases where id.track == track {
            if on { enabled.insert(id) } else { enabled.remove(id) }
        }
        UserDefaults.standard.set(enabled.map(\.rawValue), forKey: enabledKey)
        rematch()
    }

    func createIdentity() {
        let name = newPersonName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        guard let raw = FaceEngine.faceForNewIdentity(
            selected: selectedFace,
            visibleMediaId: selectedMediaId,
            faces: faces,
            identities: identities
        ) else {
            if let selected = selectedFace,
               let owner = FaceEngine.identityOwning(face: selected, identities: identities, faces: faces) {
                status = "Dieses Gesicht gehört schon zu \(owner.name). Anderes Gesicht anklicken für eine neue Person."
            } else if selectedFace == nil {
                status = "Zuerst ein Gesicht auf dem Foto anklicken"
            } else {
                status = "Kein unbenanntes Gesicht auf diesem Foto"
            }
            return
        }
        let face = snapshotLiveIfNeeded(raw)
        let liveFace = liveActive && liveMediaId == face.mediaId
        if MatchMath.enrollBlocksWithoutBlink(
            liveFace: liveFace,
            haveBlink: leftoverBlinkSeen(faceId: face.id)
        ) {
            status = "einmal blinzeln — sonst Foto vor der Cam"
            dropOrphanSnapshot(face, original: raw)
            return
        }
        if MatchMath.printQualityBlocksEnroll(yawAbs: abs(face.quality.yaw)) {
            status = String(
                format: "Profil (Yaw %.0f°) — erste Person frontal anlegen, sonst verdreht der Centroid.",
                face.quality.yaw * 180 / .pi
            )
            dropOrphanSnapshot(face, original: raw)
            return
        }
        if let why = FaceEngine.referenceRejected(face, asFirstReference: true, continuity: liveContinuity) {
            status = why
            dropOrphanSnapshot(face, original: raw)
            return
        }
        if let dup = FaceEngine.duplicateOf(face: face, identities: identities, faces: faces) {
            if pendingDuplicateName != name {
                pendingDuplicateName = name
                status = "Ähnlich \(dup.0.name) (\(Int(dup.1 * 100)) %). Nochmal Anlegen bestätigt (Centroid ≥ 82 %), sonst anderen Namen."
                dropOrphanSnapshot(face, original: raw)
                return
            }
        }
        pendingDuplicateName = nil
        let preview = FaceEngine.enrollmentPreview(
            face: face,
            identities: identities,
            faces: faces,
            haveBlink: leftoverBlinkSeen(faceId: face.id)
        )
        let note = preview.isEmpty ? "" : " · \(preview)"
        let newId = UUID()
        identities.append(Identity(id: newId, name: name, faceIds: [face.id]))
        if leftoverBlinkSeen(faceId: face.id) || leftoverBlinkSeen(faceId: raw.id) {
            leftoverBlinkByIdentity[newId] = true
        }
        stampEnrolled(face.id)
        tapNameLockUntil[face.id] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        tapNameLockUntil[raw.id] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        newPersonName = ""
        selectedFaceId = raw.id
        rematch()
        if let next = FaceEngine.unnamedFace(on: raw.mediaId, faces: faces, identities: identities) {
            selectedFaceId = next.id
            status = "\(name) angelegt · nächstes Gesicht gewählt\(note)"
        } else {
            status = "\(name) angelegt\(note)"
        }
        persist()
    }

    func addSelectedTo(_ identityId: UUID) {
        guard let raw = selectedFace else {
            status = "Zuerst ein Gesicht anklicken"
            return
        }
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        let live = selectedMedia?.kind == .live
        if let owner = FaceEngine.identityOwning(face: raw, identities: identities, faces: faces) {
            if owner.id != identityId {
                status = "Dieses Gesicht gehört zu \(owner.name). Anlegen für eine neue Person, nicht +."
                return
            }
            if !live {
                status = "Dieses Gesicht ist schon Referenz von \(owner.name)"
                return
            }
            // Live-Track trägt die UUID der ersten Referenz. + speichert eine Kopie.
        } else if identities[idx].faceIds.contains(raw.id) {
            if !live {
                status = "Dieses Gesicht ist schon Referenz von \(identities[idx].name)"
                return
            }
        }
        let face = snapshotLiveIfNeeded(raw)
        if let why = FaceEngine.referenceRejected(
            face,
            asFirstReference: identities[idx].faceIds.isEmpty,
            continuity: liveContinuity
        ) {
            status = why
            dropOrphanSnapshot(face, original: raw)
            return
        }
        let incoming = FaceEngine.embedding(of: face)
        let incomingSlot = FaceEngine.poseSlot(face).rawValue
        if incoming.count >= 32 {
            for existingId in identities[idx].faceIds {
                guard let old = faces.first(where: { $0.id == existingId }) else { continue }
                let ov = FaceEngine.embedding(of: old)
                guard ov.count == incoming.count else { continue }
                let c = MatchMath.cosine(incoming, ov)
                let age = Date().timeIntervalSince(old.enrolledAt ?? .distantPast)
                if MatchMath.enrollmentBurstDup(
                    sameSlot: FaceEngine.poseSlot(old).rawValue == incomingSlot,
                    cosine: c,
                    within: age
                ) {
                    let smBins = MatchMath.enrollSMCacheBins(cache: Set(leftoverPrintCache), liveHashes: [])
                    let smReady = MatchMath.enrollSMReady(
                        haveFrontal: smBins.contains(0),
                        haveLeft: smBins.contains(-1),
                        haveRight: smBins.contains(1),
                        haveBlink: leftoverBlinkSeen(faceId: face.id, identityId: identities[idx].id)
                    ) && MatchMath.enrollSMReadyFromChip(enrollSMChip, needProfile: !twinSplits.isEmpty)
                    if smReady,
                       MatchMath.enrollBurstReady(count: identities[idx].faceIds.count),
                       MatchMath.enrollBurstReplace(
                        incomingSharp: face.quality.sharpness,
                        existingSharp: old.quality.sharpness
                    ) {
                        identities[idx].faceIds.removeAll { $0 == old.id }
                    } else {
                        dropOrphanSnapshot(face, original: raw)
                        status = "Burst-Duplikat — schärfere Referenz von \(identities[idx].name) bleibt"
                        return
                    }
                }
                if let keepNew = MatchMath.pruneKeepIncoming(
                    cosine: c,
                    incomingSharp: face.quality.sharpness,
                    existingSharp: old.quality.sharpness
                ) {
                    if keepNew {
                        identities[idx].faceIds.removeAll { $0 == old.id }
                    } else {
                        dropOrphanSnapshot(face, original: raw)
                        status = "Burst-Duplikat — schärfere Referenz von \(identities[idx].name) bleibt"
                        return
                    }
                }
            }
        }
        var note = ""
        if let blocked = FaceEngine.poseCoverageBlocks(adding: face, to: identities[idx], faces: faces) {
            status = blocked
            dropOrphanSnapshot(face, original: raw)
            return
        }
        if let warn = FaceEngine.poseCoverageWarning(adding: face, to: identities[idx], faces: faces) {
            note = " · \(warn)"
        }
        let preview = FaceEngine.enrollmentPreview(
            face: face,
            identities: identities,
            faces: faces,
            addingTo: identities[idx],
            haveBlink: leftoverBlinkSeen(faceId: face.id, identityId: identities[idx].id)
        )
        if !identities[idx].faceIds.contains(face.id) {
            identities[idx].faceIds.append(face.id)
        }
        if leftoverBlinkSeen(faceId: face.id) {
            leftoverBlinkByIdentity[identities[idx].id] = true
        }
        stampEnrolled(face.id)
        tapNameLockUntil[face.id] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        tapNameLockUntil[raw.id] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        rematch()
        persist()
        livePrintTrail.removeAll()
        livePrintTrailSlot.removeAll()
        let extra = preview.isEmpty ? note : " · \(preview)\(note)"
        let cov = FaceEngine.poseCoverage(identity: identities[idx], faces: faces)
        let meter = MatchMath.poseMeterLabel(
            frontal: cov.frontal, threeQuarter: cov.threeQuarter, profile: cov.profile, upper: cov.upper
        )
        status = extra.isEmpty
            ? "Referenz zu \(identities[idx].name) hinzugefügt · \(meter)"
            : "Referenz zu \(identities[idx].name)\(extra)"
    }

    /// Live-UUID ist der Track, nicht die Galerie. +/Anlegen legt eine stabile Kopie an,
    /// sonst überschreibt der nächste Frame die Referenz und + sagt „schon drin“.
    private func snapshotLiveIfNeeded(_ face: FaceObservation) -> FaceObservation {
        guard selectedMedia?.kind == .live else { return face }
        var copy = face
        copy.id = UUID()
        copy.mediaId = UUID()
        copy.trackId = face.trackId ?? face.id
        copy.enrolledAt = Date()
        copy.qualitySpark = []
        if !faces.contains(where: { $0.id == copy.id }) {
            faces.append(copy)
        }
        if !media.contains(where: { $0.id == copy.mediaId }) {
            let live = selectedMedia
            media.append(MediaItem(
                id: copy.mediaId,
                url: live?.url ?? URL(fileURLWithPath: "/tmp/aegis-snapshot-\(copy.mediaId.uuidString)"),
                name: "Live-Kopie",
                kind: .snapshot,
                width: live?.width ?? 0,
                height: live?.height ?? 0,
                duration: nil,
                parentId: live?.id,
                timeSec: nil,
                preview: live?.preview
            ))
        }
        return copy
    }

    private func dropOrphanSnapshot(_ face: FaceObservation, original: FaceObservation) {
        guard face.id != original.id else { return }
        faces.removeAll { $0.id == face.id }
    }

    func addSelectedAsPartial(_ identityId: UUID) {
        guard var face = selectedFace else {
            status = "Zuerst ein Gesicht anklicken"
            return
        }
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        guard let item = selectedMedia, let image = item.preview else {
            status = "Kein Bild für Teil-Print"
            return
        }
        if identities[idx].faceIds.isEmpty {
            status = "Erste Referenz muss frei sein — U-Slot nur als Zusatz."
            return
        }
        if let owner = FaceEngine.identityOwning(face: face, identities: identities, faces: faces),
           owner.id != identityId
        {
            status = "Dieses Gesicht gehört zu \(owner.name)"
            return
        }
        face = snapshotLiveIfNeeded(face)
        guard let stamped = FaceEngine.stampForcedPartial(face, from: image) else {
            status = "Teil-Print fehlgeschlagen — Crop ohne Face-Print"
            dropOrphanSnapshot(face, original: selectedFace ?? face)
            return
        }
        if let i = faces.firstIndex(where: { $0.id == stamped.id }) {
            faces[i] = stamped
            face = stamped
        }
        if !identities[idx].faceIds.contains(face.id) {
            identities[idx].faceIds.append(face.id)
        }
        stampEnrolled(face.id)
        rematch()
        persist()
        status = "Teil-Print (U) zu \(identities[idx].name)"
    }

    func setCameraOrient(_ value: String) {
        cameraOrient = value
        liveCapture.setOrientOverride(value)
        if value == "auto" {
            status = "Kamera-Orientierung auto"
        } else {
            status = "Kamera-Orientierung \(value)° — Auto (videoRotationAngle) ignoriert"
        }
    }

    func setCameraChoice(_ choice: CameraChoice) {
        cameraChoice = choice
        liveCapture.choice = choice
        UserDefaults.standard.set(choice.rawValue, forKey: "aegis.cameraChoice")
        status = "Kamera: \(choice.titleDE)"
        if liveActive {
            startWebcam()
        }
    }

    func setHoldTTLFloor(_ v: Double) {
        holdTTLFloor = MatchMath.leftoverHoldTTLPref(v)
        UserDefaults.standard.set(holdTTLFloor, forKey: "aegis.holdTTLFloor")
    }

    func setYieldAutoReturn(_ v: Bool) {
        yieldAutoReturn = MatchMath.cameraMutexYieldAutoReturnPref(v)
        liveCapture.yieldAutoReturn = yieldAutoReturn
        UserDefaults.standard.set(yieldAutoReturn, forKey: "aegis.yieldAutoReturn")
    }

    func setYieldGrace(_ s: Double) {
        yieldGrace = MatchMath.cameraMutexYieldGracePref(s)
        liveCapture.yieldGrace = yieldGrace
        UserDefaults.standard.set(yieldGrace, forKey: "aegis.yieldGrace")
    }

    func setMutexKill(_ on: Bool) {
        mutexKill = MatchMath.cameraMutexKillPref(on)
        liveCapture.mutexKillEnabled = mutexKill
        UserDefaults.standard.set(mutexKill, forKey: "aegis.mutexKill")
    }

    func setNameLockSec(_ v: Double) {
        nameLockSec = MatchMath.leftoverNameLockSecPref(v)
        UserDefaults.standard.set(nameLockSec, forKey: "aegis.nameLockSec")
    }

    func setAdoptLockSec(_ v: Double) {
        adoptLockSec = MatchMath.leftoverAdoptSecLockPref(v)
        UserDefaults.standard.set(adoptLockSec, forKey: "aegis.adoptLockSec")
    }

    func setAssignLiveGate(_ v: Int) {
        assignLiveGate = MatchMath.leftoverAssignLiveGateNeed(v)
        UserDefaults.standard.set(assignLiveGate, forKey: "aegis.assignLiveGate")
        persist()
        status = assignLiveGate == 1 ? "AssignLive Solo 1" : "AssignLive Crowd \(assignLiveGate)"
    }

    func setFillXRescue(_ v: Double) {
        fillXRescue = MatchMath.leftoverFillXRescuePref(v)
        UserDefaults.standard.set(fillXRescue, forKey: "aegis.fillXRescue")
    }

    func setFillXPad(_ v: Double) {
        fillXPad = MatchMath.leftoverFillXPadPref(v)
        UserDefaults.standard.set(fillXPad, forKey: "aegis.fillXPad")
    }

    func setJpegProbeTTL(_ v: Double) {
        jpegProbeTTL = MatchMath.leftoverJpegProbeTTLPref(v)
        UserDefaults.standard.set(jpegProbeTTL, forKey: "aegis.jpegProbeTTL")
    }

    func setLeftoverMissNeed(_ v: Double) {
        leftoverMissNeed = MatchMath.leftoverHoldMissNeedPref(Int(v.rounded()))
        UserDefaults.standard.set(leftoverMissNeed, forKey: "aegis.missNeed")
    }

    func setKalmanJump(_ v: Double) {
        kalmanJump = MatchMath.leftoverHoldKalmanJumpPref(v)
        UserDefaults.standard.set(kalmanJump, forKey: "aegis.kalmanJump")
    }

    func voteProgress(faceId: UUID) -> String? {
        let hist = liveNameHist[faceId] ?? []
        let hit = matches.first { $0.faceId == faceId }?.hits.first { $0.strategy == .aegis }
        let vs = hit?.versus ?? []
        let close = MatchMath.nameClosePair(
            best: vs.first?.percent ?? 0,
            second: vs.dropFirst().first?.percent,
            pairCosine: hit?.pairCosine
        )
        let need = MatchMath.nameAgreeNeed(family: close, dt: liveDt)
        let progress = MatchMath.nameVoteProgress(history: hist, need: need)
        return MatchMath.nameLockLabel(
            locked: liveNameLock[faceId] != nil,
            leftover: leftoverHold[faceId] != nil,
            progress: progress,
            ttl: liveNameLock[faceId] == nil ? nil : MatchMath.nameLockTTLLabel(
                lastVote: liveNameVoteAt[faceId],
                now: liveLastStamp
            )
        )
    }

    /// Overlay. Mutiert nicht — SwiftUI-Body darf das lesen.
    func guestName(for id: UUID) -> String {
        MatchMath.unknownStickyName(index: MatchMath.guestIndex(of: id, order: guestOrder))
    }

    /// Mehrheit < Need: „?“ statt Gast-Taufe Tick 1. Streak 2 = „??“.
    /// Peak-Hold 3 Frames über Remint-UUID — SwiftUI-Body mutiert nicht.
    func leftoverOverlayGuestRaw(for id: UUID) -> String {
        let hist = liveNameHist[id] ?? []
        let need = MatchMath.nameTemporalNeed(family: false, dt: 0.125)
        let faceQ = faces.first(where: { $0.id == id })?.quality
        let sharpness = faceQ?.sharpness
        let capture = faceQ?.capture
        return MatchMath.leftoverOverlayGuestOf(
            storeName: MatchMath.leftoverOverlayFirmName(
                storeName: leftoverStoreName(for: id),
                cosine: leftoverHold[id],
                continuity: liveCapture.isContinuity,
                sharpness: sharpness,
                yawAbs: liveYaw[id],
                capture: capture
            ),
            voted: MatchMath.nameTemporalVote(hist, dt: 0.125, family: false),
            hist: hist,
            need: need,
            guest: guestName(for: id),
            streak: leftoverUnsureTicks[id] ?? 0,
            sticky: MatchMath.leftoverOverlayFirmName(
                storeName: leftoverNameLockHeld[id],
                cosine: leftoverHold[id],
                continuity: liveCapture.isContinuity,
                sharpness: sharpness,
                yawAbs: liveYaw[id],
                capture: capture
            ),
            openSetUnsure: (leftoverUnsureTicks[id] ?? 0) >= 1
        )
    }

    func leftoverOverlayGuest(for id: UUID) -> String {
        let raw = leftoverOverlayGuestRaw(for: id)
        if leftoverUnsureTicks[id] ?? 0 >= 1 {
            return raw
        }
        return MatchMath.leftoverOverlayPeakName(
            guest: raw,
            held: leftoverOverlayPeakHeld[id],
            remaining: leftoverOverlayPeakRemain[id] ?? 0
        )
    }

    func leftoverStoreName(for id: UUID) -> String? {
        MatchMath.leftoverFaceTrackStoreNameOf(
            hold: MatchMath.leftoverHoldMaxOf(
                frontal: leftoverHold[id],
                bins: leftoverHoldBins,
                id: id
            ),
            nameHeld: leftoverNameLockHeld[id] ?? "",
            nameUntil: leftoverNameLockUntil[id] ?? 0,
            now: liveLastStamp,
            poseAt: livePoseAt[id] ?? 0
        )
    }

    func leftoverSparkChip(faceId: UUID, yawAbs: Double? = nil) -> String? {
        leftoverSparkChipHeld[faceId]?.chip
            ?? MatchMath.leftoverSparkChipHashGet(
                table: leftoverSparkChipByHash,
                hash: leftoverLastHash[faceId] ?? leftoverLiveHashTick[faceId]
            )
            ?? leftoverSparkChipNow(faceId: faceId, yawAbs: yawAbs)
    }

    func leftoverGateChip(faceId: UUID) -> String? {
        var bits: [String] = []
        if let hash = leftoverLastHash[faceId] {
            let cos = leftoverHoldByHash[hash]?.cosine
                ?? leftoverHoldByHash[MatchMath.leftoverHoldHashKey(hash: hash, bin: 0)]?.cosine
            if let chip = MatchMath.leftoverHashHoldChip(cos) { bits.append(chip) }
        }
        let printReady = faces.first { $0.id == faceId }.map { !$0.featurePrint.isEmpty } ?? false
        if let chip = MatchMath.leftoverJpegChip(stored: leftoverJpegDelta[faceId], printReady: printReady) {
            bits.append(chip)
        }
        if let chip = MatchMath.leftoverIoUJumpChip(
            leftoverLastIoU[faceId],
            jump: MatchMath.leftoverHoldKalmanJumpCam(dt: liveDt, pref: kalmanJump)
        ) {
            bits.append(chip)
        }
        if let chip = MatchMath.leftoverNameLockChip(until: leftoverNameLockUntil[faceId], now: liveLastStamp) {
            bits.append(chip)
        } else if let chip = MatchMath.leftoverStoreChip(name: leftoverStoreName(for: faceId)) {
            bits.append(chip)
        }
        if let chip = MatchMath.leftoverHoldFastChip(seenSlow: leftoverHoldSeenSlow, dt: liveDt) {
            bits.append(chip)
        }
        if let chip = MatchMath.leftoverHoldIndoorChip(seenSlow: leftoverHoldSeenSlow, ttl: leftoverHoldTTL) {
            bits.append(chip)
        }
        let twinHash = leftoverLiveHashTick[faceId] ?? leftoverLastHash[faceId]
        if let twinHash {
            let oxs: [(x: Double, yaw: Double)] = leftoverLiveHashTick.compactMap { key, value in
                if key == faceId { return nil }
                if MatchMath.leftoverHoldHashBare(value) != MatchMath.leftoverHoldHashBare(twinHash) { return nil }
                let x = boxKalman[key]?.x ?? faces.first(where: { $0.id == key })?.box.x ?? 0
                let yaw = MatchMath.leftoverOccupiedYawLive(
                    live: liveYaw[key] ?? faces.first(where: { $0.id == key })?.quality.yaw,
                    printed: leftoverPrintYaw[key]
                )
                return (x: x, yaw: yaw)
            }
            if let chip = MatchMath.leftoverHashTwinChip(
                x: boxKalman[faceId]?.x ?? faces.first(where: { $0.id == faceId })?.box.x ?? 0,
                others: oxs.map(\.x),
                yawAbs: MatchMath.leftoverOccupiedYawLive(
                    live: liveYaw[faceId] ?? faces.first(where: { $0.id == faceId })?.quality.yaw,
                    printed: leftoverPrintYaw[faceId]
                ),
                otherYaws: oxs.map(\.yaw)
            ) {
                bits.append(chip)
            }
        }
        let neighborDist: Int = {
            guard let hash = leftoverLastHash[faceId] else { return 0 }
            return MatchMath.leftoverHoldNeighborDist(
                hash: hash,
                table: leftoverHoldByHash,
                now: liveLastStamp,
                ttl: leftoverHoldTTL
            )
        }()
        if let chip = MatchMath.leftoverHoldNeighborChip(facesInFrame: faces.count, dist: neighborDist) {
            bits.append(chip)
        }
        if leftoverPrintSkipIds.contains(faceId), let chip = MatchMath.leftoverPrintSkipChip(skipped: true) {
            bits.append(chip)
        }
        let capped = MatchMath.overlayChipCap(bits)
        return capped.isEmpty ? nil : capped.joined(separator: " · ")
    }

    /// Ohne Mutation — SwiftUI-Body darf das lesen.
    private func leftoverSparkChipNow(faceId: UUID, yawAbs: Double? = nil) -> String? {
        let bin = MatchMath.leftoverHoldBinSigned(yaw: yawAbs ?? 0)
        let binTrail = leftoverHoldTrailBins[MatchMath.leftoverHoldKey(id: faceId, bin: bin)] ?? []
        let idTrail = leftoverHoldTrail[faceId] ?? []
        var nowChip = MatchMath.leftoverCosineSparkLabelOf(
            idTrail: idTrail,
            binTrail: binTrail,
            yawAbs: yawAbs
        )
        if nowChip == nil {
            let hash = leftoverLastHash[faceId]
            let hashTrail = hash.map {
                MatchMath.leftoverTrailLookup(
                    hash: $0,
                    table: leftoverHoldTrailByHash,
                    now: liveLastStamp,
                    ttl: leftoverHoldTTL,
                    bin: bin,
                    facesInFrame: faces.count,
                    occupied: leftoverOccupiedHashes(except: faceId)
                )
            } ?? []
            nowChip = MatchMath.leftoverCosineSparkLabel(
                MatchMath.leftoverSparkTrailOf(
                    uuidTrail: idTrail,
                    hashTrail: hashTrail,
                    yawAbs: yawAbs
                )
            )
        }
        return nowChip
    }

    private func tickLeftoverSparkChips(liveFaceIds: Set<UUID>) {
        var liveByHash: [String: UUID] = [:]
        var liveHash: Set<String> = []
        for (fid, hash) in leftoverLiveHashTick where liveFaceIds.contains(fid) && !hash.isEmpty {
            liveHash.insert(hash)
            if liveByHash[hash] == nil { liveByHash[hash] = fid }
        }
        for (fid, hash) in leftoverLastHash where liveFaceIds.contains(fid) && !hash.isEmpty {
            liveHash.insert(hash)
            if liveByHash[hash] == nil { liveByHash[hash] = fid }
        }
        var next: [UUID: (chip: String, hold: Int)] = [:]
        for (id, val) in leftoverSparkChipHeld {
            let lastH = leftoverLastHash[id] ?? leftoverLiveHashTick[id]
            guard MatchMath.leftoverSparkChipTickKeeps(
                id: id,
                live: liveFaceIds,
                hold: Set(leftoverHold.keys),
                lastHash: lastH,
                liveHash: liveHash,
                hashTable: leftoverSparkChipByHash
            ) else { continue }
            let dest = MatchMath.leftoverSparkChipTickDest(
                id: id,
                live: liveFaceIds,
                lastHash: lastH,
                liveByHash: liveByHash
            )
            if next[dest] == nil { next[dest] = val }
            leftoverSparkChipByHash = MatchMath.leftoverSparkChipHashPut(
                table: leftoverSparkChipByHash, hash: lastH, chip: val.chip
            )
        }
        leftoverSparkChipHeld = next
        for fid in liveFaceIds {
            let yaw = faces.first { $0.id == fid }.map { $0.quality.yaw }
            let nowChip = leftoverSparkChipNow(faceId: fid, yawAbs: yaw)
            let hash = leftoverLiveHashTick[fid] ?? leftoverLastHash[fid]
            let prevChip = leftoverSparkChipHeld[fid]?.chip
                ?? MatchMath.leftoverSparkChipHashGet(table: leftoverSparkChipByHash, hash: hash)
            let prevHold = leftoverSparkChipHeld[fid]?.hold ?? 0
            let held = MatchMath.leftoverSparkChipHold(prev: prevChip, now: nowChip, hold: prevHold)
            if let chip = held.chip {
                leftoverSparkChipHeld[fid] = (chip: chip, hold: held.hold)
                if let h = leftoverLastHash[fid] ?? leftoverLiveHashTick[fid] {
                    leftoverSparkChipByHash = MatchMath.leftoverSparkChipHashPut(
                        table: leftoverSparkChipByHash, hash: h, chip: chip
                    )
                }
            } else {
                leftoverSparkChipHeld.removeValue(forKey: fid)
            }
        }
    }

    func leftoverHoldNow(faceId: UUID, yawAbs: Double? = nil) -> Double? {
        MatchMath.leftoverHoldPrevOf(
            frontal: leftoverHold[faceId],
            yawAbs: yawAbs,
            bins: leftoverHoldBins,
            id: faceId,
            hash: leftoverLastHash[faceId],
            hashTable: leftoverHoldByHash,
            now: liveLastStamp,
            ttl: leftoverHoldTTL,
            facesInFrame: faces.count,
            occupied: leftoverOccupiedHashes(except: faceId)
        )
    }

    func leftoverJumpName(for faceId: UUID) -> String? {
        MatchMath.leftoverNameLockKeeps(
            until: leftoverNameLockUntil[faceId],
            now: liveLastStamp,
            name: leftoverNameLockHeld[faceId]
        )
    }

    func leftoverHasHold(faceId: UUID) -> Bool {
        MatchMath.leftoverHasHoldOf(
            hold: leftoverHold[faceId],
            bins: leftoverHoldBins,
            id: faceId,
            poseAt: livePoseAt[faceId] ?? 0,
            now: liveLastStamp,
            nameUntil: leftoverNameLockUntil[faceId] ?? 0
        )
    }

    func leftoverHoldChip(faceId: UUID, sharpness: Double? = nil, yawAbs: Double? = nil) -> String? {
        let bin = MatchMath.leftoverHoldBinSigned(yaw: yawAbs ?? 0)
        let binTrail = leftoverHoldTrailBins[MatchMath.leftoverHoldKey(id: faceId, bin: bin)] ?? []
        let base = MatchMath.leftoverHoldOverlayChipOf(
            hold: leftoverHoldNow(faceId: faceId, yawAbs: yawAbs),
            trail: leftoverHoldTrail[faceId] ?? [],
            yawAbs: yawAbs,
            sharpness: sharpness,
            compact: true,
            binTrail: binTrail
        )
        let kind = MatchMath.leftoverTrackKind(
            miss: leftoverMissFrames[faceId] ?? 0,
            coastAt: leftoverCoastAt[faceId],
            now: liveLastStamp
        )
        return MatchMath.leftoverHoldChipAppendKind(
            base,
            kind: kind,
            coastAt: leftoverCoastAt[faceId],
            now: liveLastStamp
        )
    }

    func leftoverIdentityId(of faceId: UUID) -> UUID? {
        identities.first(where: { $0.faceIds.contains(faceId) })?.id
    }

    func leftoverBlinkSeen(faceId: UUID, identityId: UUID? = nil) -> Bool {
        MatchMath.leftoverBlinkSeenOf(
            detectId: faceId,
            identityId: identityId ?? leftoverIdentityId(of: faceId),
            detectSeen: liveBlinkSeen,
            identitySeen: leftoverBlinkByIdentity
        )
    }

    func leftoverStampBlink(faceId: UUID, box: FaceBox? = nil) {
        liveBlinkSeen[faceId] = true
        if let ident = leftoverIdentityId(of: faceId) ?? liveNameLock[faceId] {
            leftoverBlinkByIdentity[ident] = true
        }
        _ = box
    }

    private func installSleepWatch() {
        guard workspaceObs.isEmpty else { return }
        let nc = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification] {
            let obs = nc.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in
                    self?.noteDidWake()
                }
            }
            workspaceObs.append(obs)
        }
    }

    func noteDidWake() {
        liveRoiSkipOnce = MatchMath.liveRoiSkipOnWake()
        livePending = nil
        guard MatchMath.liveRecoversOnWake(), liveActive else { return }
        liveDetectGen &+= 1
        liveBusy = false
        liveBusySince = 0
        liveCoastAt = 0
        liveDetectInflight = 0
        liveCapture.recoverAfterWake()
    }

    func leftoverAdoptProgress(faceId: UUID) -> String? {
        if MatchMath.leftoverWipeMutes(
            until: leftoverWipeUntil[faceId],
            now: liveLastStamp,
            histCount: (liveNameHist[faceId] ?? []).filter { !$0.isEmpty }.count
        ) {
            return leftoverPending[faceId] ?? "STUMM"
        }
        return leftoverPending[faceId]
    }

    func tapLockChip(faceId: UUID) -> String? {
        MatchMath.tapNameLockLabel(
            until: tapNameLockUntil[faceId],
            now: Date().timeIntervalSince1970
        )
    }

    func ghostFaceIds() -> Set<UUID> {
        Set(liveGhosts.map(\.face.id))
    }

    func ghostFaces() -> [FaceObservation] {
        liveGhosts.map(\.face)
    }

    func exposureLockChip(faceId: UUID) -> String? {
        MatchMath.exposureLockLabel(
            until: liveExposureUntil[faceId],
            now: Date().timeIntervalSince1970
        )
    }

    func ghostTTLChip(faceId: UUID) -> String? {
        guard let g = liveGhosts.first(where: { $0.face.id == faceId }) else { return nil }
        return MatchMath.ghostTTLLabel(until: g.until, now: Date().timeIntervalSince1970)
    }

    func tapOverlay(faceId: UUID, mediaId: UUID? = nil) {
        selectedFaceId = faceId
        if let mediaId { selectedMediaId = mediaId }
        let pinned = identities.contains { $0.faceIds.contains(faceId) }
        if MatchMath.tapOverlayLocksName(pinned: pinned) {
            tapNameLockUntil[faceId] = MatchMath.tapNameLockUntil(now: Date().timeIntervalSince1970)
        } else if MatchMath.tapGuestSuggests(pinned: pinned) {
            if tapGuestPending.contains(faceId),
               MatchMath.guestPersistWrites(tapped: true)
            {
                persistGuestTap(faceId)
            } else {
                tapGuestPending.insert(faceId)
                leftoverPending[faceId] = MatchMath.tapGuestNote()
            }
        }
    }

    /// Zweiter Overlay-Tap auf Gast: Taufe persistiert, nicht nur Chip.
    private func persistGuestTap(_ faceId: UUID) {
        guard let face = faces.first(where: { $0.id == faceId }) else { return }
        guard identities.allSatisfy({ !$0.faceIds.contains(faceId) }) else { return }
        let name = guestName(for: faceId)
        identities.append(Identity(id: UUID(), name: name, faceIds: [face.id]))
        stampEnrolled(face.id)
        let lockAt = Date().timeIntervalSince1970
        tapNameLockUntil[faceId] = MatchMath.tapNameLockUntil(now: lockAt)
        leftoverPending.removeValue(forKey: faceId)
        tapGuestPending.remove(faceId)
        persist()
        rematch()
        status = "\(name) getauft"
    }

    func stillProgress(faceId: UUID) -> Double? {
        let t = liveStillFor[faceId] ?? 0
        guard t > 0 else { return nil }
        let p = MatchMath.holdStillProgress(stillFor: t, need: MatchMath.holdStillNeedOf(dt: liveDt))
        return p < 1 ? p : nil
    }

    func stillRingWidth() -> CGFloat {
        MatchMath.holdStillRingWidth(dt: liveDt)
    }

    func printDriftSpark(faceId: UUID) -> String {
        MatchMath.printDriftSpark(livePrintDrift[faceId] ?? [])
    }

    func freezeAxisLabel(faceId: UUID) -> String? {
        freezeAxis[faceId]
    }

    func swapFlashing(now: TimeInterval = Date().timeIntervalSince1970) -> Bool {
        now < swapFlashUntil
    }

    func headCountFlashing(now: TimeInterval = Date().timeIntervalSince1970) -> Bool {
        now < headCountFlashUntil
    }

    func headCountFlashText() -> String? {
        headCountFlashing() ? lastHeadCountLabel : nil
    }

    func removeIdentity(_ id: UUID) {
        identities.removeAll { $0.id == id }
        leftoverBlinkByIdentity.removeValue(forKey: id)
        persist()
        rematch()
    }

    func renameIdentity(_ id: UUID, to raw: String) {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        guard let idx = identities.firstIndex(where: { $0.id == id }) else { return }
        guard identities[idx].name != name else { return }
        if MatchMath.renameConflict(newName: name, existing: identities.map(\.name), selfName: identities[idx].name) {
            let now = Date().timeIntervalSince1970
            if pendingRenameName != name
                || !MatchMath.renameConfirmSameId(pending: pendingRenameId, target: id)
                || MatchMath.renameConfirmExpired(since: pendingRenameAt, now: now)
            {
                pendingRenameName = name
                pendingRenameId = id
                pendingRenameAt = now
                status = "Name \(name) existiert. Nochmal Return bestätigt den Konflikt."
                return
            }
        }
        pendingRenameName = nil
        pendingRenameId = nil
        pendingRenameAt = nil
        identities[idx].name = name
        let lockAt = Date().timeIntervalSince1970
        tapNameLockUntil[id] = MatchMath.tapNameLockUntil(now: lockAt)
        for fid in identities[idx].faceIds {
            tapNameLockUntil[fid] = MatchMath.tapNameLockUntil(now: lockAt)
        }
        persist()
        status = "\(name) umbenannt"
    }

    func rejectGuess(_ identityId: UUID) {
        guard let face = selectedFace else { return }
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        let v = FaceEngine.embedding(of: face)
        guard v.count >= 32 else {
            status = "Kein Print — Ablehnen braucht Face-Print"
            return
        }
        identities[idx].rejectedVecs.append(v)
        if identities[idx].rejectedVecs.count > 8 {
            identities[idx].rejectedVecs.removeFirst(identities[idx].rejectedVecs.count - 8)
        }
        persist()
        rematch()
        status = "Nicht \(identities[idx].name) — Hard-Negativ gespeichert"
    }

    func clearReject(_ identityId: UUID) {
        guard let idx = identities.firstIndex(where: { $0.id == identityId }) else { return }
        identities[idx].rejectedVecs.removeAll()
        persist()
        rematch()
        status = "Doch \(identities[idx].name) — Hard-Negativ gelöscht"
    }

    func startLiveFromField() {
        let raw = liveURLText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parsed = sniffLiveKind(raw) else {
            status = "Keine gültige Kamera-Adresse"
            return
        }
        startLive(url: parsed.1, kind: parsed.0, name: parsed.1.host ?? "Kamera")
    }

    func startWebcam() {
        startLive(url: URL(string: "webcam://local")!, kind: .webcam, name: "Webcam")
    }

    private func startOverlayTrack() {
        overlayTrack?.invalidate()
        overlayTrack = nil
        guard MatchMath.overlayTrackBeats(live: true) else { return }
        let reduce = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let dt = MatchMath.overlayTrackDt(reduceMotion: reduce)
        let t = Timer(timeInterval: dt, repeats: true) { [weak self] _ in
            let store = self
            Task { @MainActor in
                store?.overlayBeat = CACurrentMediaTime()
            }
        }
        t.tolerance = dt * 0.25
        RunLoop.main.add(t, forMode: .common)
        overlayTrack = t
    }

    func stopLive() {
        liveDetectGen &+= 1
        livePending = nil
        liveBusy = false
        liveBusySince = 0
        liveCoastAt = 0
        liveDetectInflight = 0
        liveCapture.markFrameConsumed()
        liveRoiTick = 0
        liveRoiSkipOnce = false
        maskHoldSince.removeAll()
        lastUSlotHint = 0
        boxJumpPending.removeAll()
        liveNameHist = [:]
        liveNameLock = [:]
        liveScoreEma = [:]
        liveScoreTicks = [:]
        liveYaw = [:]
        livePitch = [:]
        liveRoll = [:]
        liveLastStamp = 0
        liveDt = 0.125
        liveDtSamples = []
        leftoverHoldSeenSlow = false
        leftoverHoldFastFor = 0
        leftoverLiveHashTick = [:]
        leftoverMissCoastTicks = 0
        leftoverNameLockUntil = [:]
        leftoverNameLockHeld = [:]
        leftoverOverlayPeakHeld = [:]
        leftoverOverlayPeakRemain = [:]
        liveNameVoteAt = [:]
        tapNameLockUntil = [:]
        liveFaceStreak = 0
        livePoseAt.removeAll()
        freezeAxis = [:]
        swapFlashUntil = 0
        headCountFlashUntil = 0
        lastLiveHeadCount = 0
        lastHeadCountLabel = nil
        livePrintTrail.removeAll()
        livePrintTrailSlot.removeAll()
        liveStillFor.removeAll()
        liveCaptureHist.removeAll()
        leftoverStreak = [:]
        leftoverStreakBox = [:]
        leftoverStreakSince = [:]
        leftoverPairLast = [:]
        leftoverPairStreak = [:]
        leftoverPairCommit = [:]
        leftoverPairCommitMiss = [:]
        leftoverPending = [:]
        tapGuestPending = []
        leftoverHold = [:]
        leftoverTracks = [:]
        leftoverHoldTrail = [:]
        leftoverHoldBins = [:]
        leftoverPrintYaw = [:]
        leftoverHoldByHash = [:]
        leftoverHoldTrailByHash = [:]
        leftoverLastHash = [:]
        leftoverSparkChipHeld = [:]
        leftoverSparkChipByHash = [:]
        leftoverJpegDelta = [:]
        leftoverLastIoU = [:]
        leftoverPrintSkipIds = []
        yawCoverageChip = "YAW —"
        enrollSMChip = "ENROLL —"
        enrollQualityChip = "Q —"
        captureSparkChip = "CQ —"
        faReplayChip = "FA —"
        faReplayMatrix = "FA —"
        faLogLastDecided = [:]
        faLogLines = 0
        overlayTrack?.invalidate()
        overlayTrack = nil
        overlayBeat = 0
        leftoverJpegAt = [:]
        leftoverJpegHash = [:]
        leftoverJpegCos = [:]
        leftoverHoldTrailBins = [:]
        leftoverEmptySince = nil
        leftoverWipeUntil = [:]
        liveSlotHold = [:]
        guestOrder = []
        guestSeenAt = [:]
        liveCapture.stop()
        liveActive = false
        if let id = liveMediaId {
            let gone = Set(faces.filter { $0.mediaId == id }.map(\.id))
            faces.removeAll { $0.mediaId == id }
            media.removeAll { $0.id == id }
            if !gone.isEmpty {
                for i in identities.indices {
                    identities[i].faceIds.removeAll { gone.contains($0) }
                }
                persist()
            }
            liveMediaId = nil
            selectedMediaId = media.first?.id
            rematch()
        }
        status = "Live beendet"
    }

    private func startLive(url: URL, kind: LiveKind, name: String) {
        if let id = liveMediaId {
            reconnectGhosts = faces.filter { $0.mediaId == id }
        }
        stopLive()
        let id = UUID()
        liveMediaId = id
        media.append(
            MediaItem(
                id: id,
                url: url,
                name: name,
                kind: .live,
                width: 1280,
                height: 720
            )
        )
        selectedMediaId = id
        liveActive = true
        startOverlayTrack()
        status = "Live · verbindet"
        liveCapture.onReady = { [weak self] in
            guard let self else { return }
            self.status = "Live"
            let uid = self.liveCapture.cameraUniqueID
            let sticky = MatchMath.cameraUniqueIDSticky(
                prevID: self.lastCameraUniqueID,
                nextID: uid,
                prevName: self.lastCameraName,
                nextName: self.liveCapture.cameraName,
                prevRole: self.lastCameraRole,
                nextRole: self.liveCapture.cameraRole
            )
            if !self.lastCameraUniqueID.isEmpty, uid != self.lastCameraUniqueID, !sticky {
                self.boxEuro.removeAll()
                self.boxKalman.removeAll()
                self.boxKalmanV.removeAll()
                self.boxKalmanWHV.removeAll()
                self.boxJumpPending.removeAll()
                self.livePrintTrail.removeAll()
                self.livePrintTrailSlot.removeAll()
                self.leftoverEmptySince = nil
                self.liveRoiTick = 0
                self.liveRoiSkipOnce = false
                self.leftoverDetectAt = 0
                self.leftoverPrintAt = 0
                self.leftoverPrintCache = []
                self.yawCoverageChip = "YAW —"
                self.liveDetectGen &+= 1
            }
            self.lastCameraUniqueID = uid
            self.lastCameraName = self.liveCapture.cameraName
            self.lastCameraRole = self.liveCapture.cameraRole
            self.cameraUniqueID = uid
            self.cameraOrient = self.liveCapture.orientOverride
        }
        liveCapture.onError = { [weak self] msg in
            self?.status = msg
            self?.liveActive = false
        }
        liveCapture.onFrame = { [weak self] image, stamp in
            if MatchMath.liveFrameTapEmitsOnCaptureQueue() {
                Task { @MainActor in
                    self?.ingestLiveFrame(image, mediaId: id, stamp: stamp)
                }
            } else {
                self?.ingestLiveFrame(image, mediaId: id, stamp: stamp)
            }
        }
        liveCapture.choice = cameraChoice
        liveCapture.mutexKillEnabled = mutexKill
        liveCapture.start(url: url, kind: kind)
    }

    private func ingestLiveFrame(_ image: CGImage, mediaId: UUID, stamp: TimeInterval) {
        let now = CACurrentMediaTime()
        if liveBusy {
            livePending = (image, mediaId, stamp)
            let busyFor = liveBusySince > 0 ? now - liveBusySince : 0
            if MatchMath.liveCoastOverlayWhileBusy(busy: true), !boxKalman.isEmpty {
                if liveCoastAt == 0 { liveCoastAt = liveBusySince > 0 ? liveBusySince : now }
                let snap: [(id: UUID, x: Double, y: Double, w: Double, h: Double)] = boxKalman.map { (id, v) in
                    (id: id, x: v.x, y: v.y, w: v.w, h: v.h)
                }
                let elapsed = MatchMath.liveCoastElapsed(now: now, origin: liveCoastAt)
                let stepped = MatchMath.liveCoastBoxes(kalman: snap, vel: boxKalmanV, dt: elapsed)
                let coast = stepped.map { row in
                    FaceObservation.coast(
                        id: row.id,
                        mediaId: mediaId,
                        box: FaceBox(x: row.x, y: row.y, width: row.w, height: row.h)
                    )
                }
                applyLiveFaces(
                    coast,
                    image: image,
                    mediaId: mediaId,
                    stamp: stamp,
                    skipDetect: true,
                    skipPrints: true
                )
            }
            if MatchMath.liveEmitHungCancel(busy: true, busyFor: busyFor) {
                if MatchMath.liveHungSpawnOk(inflight: liveDetectInflight) {
                    liveDetectGen &+= 1
                    liveBusySince = now
                    livePending = nil
                    liveCapture.markFrameConsumed()
                    runLiveDetect(image, mediaId: mediaId, stamp: stamp)
                }
            }
            return
        }
        liveBusy = true
        liveBusySince = now
        if liveCoastAt == 0 { liveCoastAt = now }
        runLiveDetect(image, mediaId: mediaId, stamp: stamp)
    }

    private func runLiveDetect(_ image: CGImage, mediaId: UUID, stamp: TimeInterval) {
        liveDetectInflight += 1
        let cont = liveCapture.isContinuity
        let dt = liveDt
        let vis = lastLiveVisMs
        let kalmanSnap: [(id: UUID, x: Double, y: Double, w: Double, h: Double)] = boxKalman.map { (id, v) in
            (id: id, x: v.x, y: v.y, w: v.w, h: v.h)
        }
        let liveIds = kalmanSnap.map(\.id)
        var skipIds = MatchMath.printBudgetSkipIds(
            ids: liveIds,
            lastIoU: leftoverLastIoU,
            yaw: liveYaw,
            printedYaw: leftoverPrintYaw,
            stillFor: liveStillFor,
            visionMs: vis,
            dt: dt,
            continuity: cont
        )
        let printCacheSet = Set(leftoverPrintCache)
        for id in liveIds {
            guard let yaw = liveYaw[id] else { continue }
            let hash = leftoverLiveHashTick[id] ?? leftoverLastHash[id]
            guard let hash, !hash.isEmpty else { continue }
            let personBins = MatchMath.leftoverPrintCacheBins(printCacheSet, hash: hash)
            if MatchMath.enrollSMSkipCapture(
                yaw: yaw,
                haveFrontal: personBins.contains(0),
                haveLeft: personBins.contains(-1),
                haveRight: personBins.contains(1),
                haveProfile: personBins.contains(-2) || personBins.contains(2)
            ) {
                skipIds.insert(id)
            }
        }
        let skipPrintCached: Set<UUID> = Set(kalmanSnap.compactMap { row in
            guard let yaw = liveYaw[row.id] else { return nil }
            let hash = leftoverLiveHashTick[row.id] ?? leftoverLastHash[row.id]
            guard MatchMath.leftoverPrintCacheHits(hash: hash, yaw: yaw, cached: printCacheSet, cam: cameraUniqueID) else {
                return nil
            }
            return row.id
        })
        var skipIdsAll = skipIds.union(skipPrintCached)
        skipIdsAll = Set(skipIdsAll.filter { !MatchMath.leftoverNeedsPrint(cosine: leftoverHold[$0]) })
        let roiKalman = MatchMath.liveRoiTracks(tracks: kalmanSnap, skipIds: skipIdsAll)
        let roiTuple = MatchMath.liveRoiBox(
            kalman: roiKalman,
            imageW: Double(image.width),
            imageH: Double(image.height)
        )
        let skipRoi = liveRoiSkipOnce || MatchMath.liveRoiPeriodicFull(tick: liveRoiTick)
        let liveIous = MatchMath.leftoverDetectSkipLiveIous(
            stored: leftoverLastIoU,
            live: kalmanSnap.map(\.id)
        )
        let skipDetectTick = MatchMath.leftoverDetectSkipTick(
            skip: MatchMath.leftoverDetectSkipAll(
                ious: liveIous,
                need: max(1, kalmanSnap.count)
            ),
            tick: liveRoiTick,
            every: 4
        )
        let stillAll = !liveIds.isEmpty && skipIds.count == liveIds.count
        let split = MatchMath.leftoverDetectPrintSplit(
            now: stamp,
            lastDetect: leftoverDetectAt,
            lastPrint: leftoverPrintAt,
            dt: dt,
            still: stillAll
        )
        let skipDetect = skipDetectTick || split.skipDetect
        liveRoiTick += 1
        liveRoiSkipOnce = false
        let skipPrints = split.skipPrint || MatchMath.printBudgetSkipAll(skipIds: skipIdsAll, liveIds: liveIds)
        if !skipDetect { leftoverDetectAt = stamp }
        if !skipPrints { leftoverPrintAt = stamp }
        let skipPrintBoxes = skipPrints ? [] : MatchMath.leftoverPrintSkipBoxes(tracks: kalmanSnap, skipIds: skipIdsAll)
        let skipPrintPalm: FaceBox? = {
            guard !skipPrints, MatchMath.cameraMutexPalmSkip(holder: liveCapture.mutexHolder, continuity: cont) else { return nil }
            return liveCapture.mutexPalmBox(imageW: Double(image.width), imageH: Double(image.height))
        }()
        let skipPrintPalms: [FaceBox] = {
            guard !skipPrints, MatchMath.cameraMutexPalmSkip(holder: liveCapture.mutexHolder, continuity: cont) else { return [] }
            return liveCapture.mutexPalmBoxes(imageW: Double(image.width), imageH: Double(image.height))
        }()
        liveDetectGen &+= 1
        let gen = liveDetectGen
        Task.detached(priority: .userInitiated) {
            let t0 = CFAbsoluteTimeGetCurrent()
            var roi = skipRoi ? nil : roiTuple.map { FaceBox(x: $0.x, y: $0.y, width: $0.w, height: $0.h) }
            var found: [FaceObservation]
            if MatchMath.leftoverDetectSkipVision(skipDetect: skipDetect) {
                var boxes = kalmanSnap.map { FaceBox(x: $0.x, y: $0.y, width: $0.w, height: $0.h) }
                if MatchMath.overlayTrackUsesVision() {
                    boxes = FaceEngine.trackBoxes(
                        in: image,
                        boxes: boxes,
                        persist: MatchMath.overlayTrackPersist(skipDetect: true)
                    )
                }
                found = zip(kalmanSnap, boxes).map { k, b in
                    FaceObservation.coast(id: k.id, mediaId: mediaId, box: b)
                }
                if MatchMath.overlayTrackForcesDetect(lost: FaceEngine.lastTrackLostCount(), live: kalmanSnap.count) {
                    found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true, skipPrints: skipPrints, roi: roi, skipPrintBoxes: skipPrintBoxes, skipPrintPalm: skipPrintPalm, skipPrintPalms: skipPrintPalms)) ?? found
                    if !found.isEmpty {
                        FaceEngine.seedTrack(boxes: found.map(\.box), image: image)
                    }
                }
            } else {
                found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true, skipPrints: skipPrints, roi: roi, skipPrintBoxes: skipPrintBoxes, skipPrintPalm: skipPrintPalm, skipPrintPalms: skipPrintPalms)) ?? []
                if MatchMath.overlayTrackPersistReset(skipDetect: false) {
                    FaceEngine.seedTrack(boxes: found.map(\.box), image: image)
                }
            }
            if !skipDetect, found.isEmpty, roi != nil, MatchMath.liveRoiMissRetries(hadROI: true, empty: true) {
                if MatchMath.liveRoiMissGoesFull(dt: dt) {
                    roi = nil
                    found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true, skipPrints: skipPrints, roi: nil, skipPrintBoxes: skipPrintBoxes, skipPrintPalm: skipPrintPalm, skipPrintPalms: skipPrintPalms)) ?? []
                } else if let raw = roiTuple {
                    let exp = MatchMath.liveRoiExpand(raw, imageW: Double(image.width), imageH: Double(image.height))
                    found = (try? FaceEngine.detect(
                        in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true,
                        skipPrints: skipPrints,
                        roi: FaceBox(x: exp.x, y: exp.y, width: exp.w, height: exp.h),
                        skipPrintBoxes: skipPrintBoxes,
                        skipPrintPalm: skipPrintPalm, skipPrintPalms: skipPrintPalms
                    )) ?? []
                    if found.isEmpty {
                        found = (try? FaceEngine.detect(in: image, mediaId: mediaId, tiles: false, continuity: cont, cheapGraph: true, live: true, skipPrints: skipPrints, roi: nil, skipPrintBoxes: skipPrintBoxes, skipPrintPalm: skipPrintPalm, skipPrintPalms: skipPrintPalms)) ?? []
                    }
                }
            }
            let visMs = (CFAbsoluteTimeGetCurrent() - t0) * 1000
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.liveDetectInflight = max(0, self.liveDetectInflight - 1)
                if MatchMath.liveHungGenDrops(resultGen: gen, liveGen: self.liveDetectGen) {
                    if self.liveDetectInflight == 0 {
                        if let pending = self.livePending {
                            self.livePending = nil
                            self.liveBusySince = CACurrentMediaTime()
                            self.runLiveDetect(pending.image, mediaId: pending.mediaId, stamp: pending.stamp)
                        } else {
                            self.liveBusy = false
                            self.liveBusySince = 0
                            self.liveCoastAt = 0
                            self.liveCapture.markFrameConsumed()
                        }
                    }
                    return
                }
                self.lastLiveVisMs = visMs
                self.liveCapture.setVisionBudget(ms: visMs)
                self.liveFormatChip = self.liveCapture.formatChip
                self.mutexChip = self.liveCapture.mutexChip
                self.leftoverPrintSkipIds = skipIdsAll
                if !self.liveActive || self.liveMediaId != mediaId {
                    self.liveBusy = false
                    self.livePending = nil
                    self.liveCoastAt = 0
                    self.liveCapture.markFrameConsumed()
                    return
                }
                if MatchMath.liveRoiSkipsForStranger(foundCount: found.count, kalmanCount: kalmanSnap.count) {
                    self.liveRoiSkipOnce = true
                }
                self.applyLiveFaces(
                    found,
                    image: image,
                    mediaId: mediaId,
                    stamp: stamp,
                    skipDetect: skipDetect,
                    skipPrints: skipPrints
                )
                self.liveCoastAt = CACurrentMediaTime()
                if let pending = self.livePending {
                    self.livePending = nil
                    self.runLiveDetect(pending.image, mediaId: pending.mediaId, stamp: pending.stamp)
                } else {
                    self.liveBusy = false
                    self.liveCoastAt = 0
                    self.liveCapture.markFrameConsumed()
                }
            }
        }
    }

    private func pinByPrint(
        _ face: FaceObservation,
        pool: [FaceObservation],
        used: Set<UUID>
    ) -> FaceObservation? {
        let v = FaceEngine.embedding(of: face)
        guard v.count >= 32 else { return nil }
        var best: FaceObservation?
        var bestC = MatchMath.pinPrintCosine
        var seen = Set<UUID>()
        for old in pool where !used.contains(old.id) && !seen.contains(old.id) {
            seen.insert(old.id)
            let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
            guard ov.count == v.count else { continue }
            let c = MatchMath.cosine(v, ov)
            if MatchMath.pinByPrint(cosine: c), c > bestC {
                bestC = c
                best = old
            }
        }
        return best
    }

    private func leftoverAdvance(
        oldId: UUID,
        box: FaceBox,
        now: TimeInterval,
        holdPrev: Double? = nil,
        boxId: UUID? = nil,
        dt: TimeInterval = 0.016,
        yawAbs: Double? = nil
    ) -> (ready: Bool, label: String?) {
        let hashed = MatchMath.leftoverStreakBoxWrite(
            kalmanX: boxKalman[boxId ?? oldId]?.x,
            kalmanY: boxKalman[boxId ?? oldId]?.y,
            kalmanW: boxKalman[boxId ?? oldId]?.w,
            kalmanH: boxKalman[boxId ?? oldId]?.h,
            fallback: box
        )
        let same: Bool
        if let prev = leftoverStreakBox[oldId] {
            same = MatchMath.leftoverSameTarget(iou: FaceEngine.iou(prev, hashed))
        } else {
            same = false
        }
        if same {
            leftoverStreakSince[oldId] = MatchMath.leftoverStreakSincePersist(
                since: leftoverStreakSince[oldId],
                now: now
            )
        } else {
            leftoverStreakSince[oldId] = now
        }
        let next = MatchMath.leftoverStreakAdvance(prev: leftoverStreak[oldId] ?? 0, sameTarget: same)
        leftoverStreak[oldId] = next
        leftoverStreakBox[oldId] = hashed
        let elapsed = now - (leftoverStreakSince[oldId] ?? now)
        let needSec = MatchMath.leftoverAdoptNeedSec(dt: dt, yawAbs: yawAbs, lockPref: adoptLockSec)
        return (
            MatchMath.leftoverAdoptReady(elapsed: elapsed, streak: next, needSec: needSec, holdPrev: holdPrev),
            MatchMath.leftoverStreakLabel(elapsed: elapsed, needSec: needSec)
        )
    }

    private func leftoverClearStreak(_ id: UUID, pair: Bool = true) {
        leftoverStreak.removeValue(forKey: id)
        leftoverStreakBox.removeValue(forKey: id)
        leftoverStreakSince.removeValue(forKey: id)
        leftoverMissFrames.removeValue(forKey: id)
        leftoverWipeUntil.removeValue(forKey: id)
        leftoverCoastPrint.removeValue(forKey: id)
        leftoverCoastPrintAt.removeValue(forKey: id)
        leftoverCoastAt.removeValue(forKey: id)
        leftoverPrintYaw.removeValue(forKey: id)
        if pair {
            leftoverPairLast.removeValue(forKey: id)
            leftoverPairStreak.removeValue(forKey: id)
            leftoverPairCommit.removeValue(forKey: id)
            leftoverPairCommitMiss.removeValue(forKey: id)
            leftoverDisagree.removeValue(forKey: id)
        }
    }

    private func leftoverMirrorPending(from: UUID, to: UUID) {
        leftoverPending = MatchMath.leftoverPendingMirror(pending: leftoverPending, from: from, to: to)
        leftoverLiveHashTick = MatchMath.leftoverLiveHashTickCopy(tick: leftoverLiveHashTick, from: from, to: to)
        leftoverLastHash = MatchMath.leftoverLiveHashTickCopy(tick: leftoverLastHash, from: from, to: to)
        leftoverPairLast = MatchMath.leftoverHoldMoveId(hold: leftoverPairLast, from: from, to: to)
        leftoverPairStreak = MatchMath.leftoverHoldMove(hold: leftoverPairStreak, from: from, to: to)
        leftoverPairCommit = MatchMath.leftoverHoldMoveId(hold: leftoverPairCommit, from: from, to: to)
        leftoverPairCommitMiss = MatchMath.leftoverHoldMove(hold: leftoverPairCommitMiss, from: from, to: to)
        leftoverDisagree = MatchMath.leftoverHoldMove(hold: leftoverDisagree, from: from, to: to)
        leftoverTracks = MatchMath.leftoverTracksMove(tracks: leftoverTracks, from: from, to: to)
        leftoverHold = MatchMath.leftoverAssignAtomic(hold: leftoverHold, from: from, to: to)
        leftoverHoldTrail = MatchMath.leftoverAssignAtomic(hold: leftoverHoldTrail, from: from, to: to)
        leftoverNameLockUntil = MatchMath.leftoverAssignAtomic(hold: leftoverNameLockUntil, from: from, to: to)
        leftoverNameLockHeld = MatchMath.leftoverAssignAtomic(hold: leftoverNameLockHeld, from: from, to: to)
        leftoverOverlayPeakHeld = MatchMath.leftoverAssignAtomic(hold: leftoverOverlayPeakHeld, from: from, to: to)
        leftoverOverlayPeakRemain = MatchMath.leftoverAssignAtomic(hold: leftoverOverlayPeakRemain, from: from, to: to)
        leftoverHoldBins = MatchMath.leftoverHoldMoveBins(hold: leftoverHoldBins, from: from, to: to)
        leftoverHoldTrailBins = MatchMath.leftoverHoldMoveBins(hold: leftoverHoldTrailBins, from: from, to: to)
        leftoverWipeUntil = MatchMath.leftoverAssignAtomic(hold: leftoverWipeUntil, from: from, to: to)
        leftoverStreak = MatchMath.leftoverAssignAtomic(hold: leftoverStreak, from: from, to: to)
        leftoverStreakSince = MatchMath.leftoverAssignAtomic(hold: leftoverStreakSince, from: from, to: to)
        leftoverStreakBox = MatchMath.leftoverAssignAtomic(hold: leftoverStreakBox, from: from, to: to)
        leftoverLastIoU = MatchMath.leftoverAssignAtomic(hold: leftoverLastIoU, from: from, to: to)
        leftoverSparkChipHeld = MatchMath.leftoverAssignAtomic(hold: leftoverSparkChipHeld, from: from, to: to)
        leftoverJpegDelta = MatchMath.leftoverAssignAtomic(hold: leftoverJpegDelta, from: from, to: to)
        leftoverJpegAt = MatchMath.leftoverAssignAtomic(hold: leftoverJpegAt, from: from, to: to)
        leftoverJpegHash = MatchMath.leftoverAssignAtomic(hold: leftoverJpegHash, from: from, to: to)
        leftoverJpegCos = MatchMath.leftoverAssignAtomic(hold: leftoverJpegCos, from: from, to: to)
        leftoverCoastPrint = MatchMath.leftoverAssignAtomic(hold: leftoverCoastPrint, from: from, to: to)
        leftoverPrintYaw = MatchMath.leftoverAssignAtomic(hold: leftoverPrintYaw, from: from, to: to)
        leftoverMissFrames = MatchMath.leftoverAssignAtomic(hold: leftoverMissFrames, from: from, to: to)
    }

    private func leftoverBlendAdopted(_ face: inout FaceObservation, oldId: UUID) {
        guard MatchMath.leftoverAdoptKeepsKalman() else { return }
        let k = boxKalman[oldId]
        let live = (x: face.box.x, y: face.box.y, w: face.box.width, h: face.box.height)
        let kal = k.map { (x: $0.x, y: $0.y, w: $0.w, h: $0.h) }
        let b = MatchMath.leftoverAdoptBlend(live: live, kalman: kal)
        face.box = FaceBox(x: b.x, y: b.y, width: b.w, height: b.h)
    }

    private func leftoverLiveHash(
        kalmanX: Double?,
        kalmanY: Double?,
        kalmanW: Double?,
        kalmanH: Double?,
        fallback: FaceBox,
        image: CGImage
    ) -> String {
        MatchMath.leftoverHoldWriteHash(
            kalmanX: kalmanX, kalmanY: kalmanY, kalmanW: kalmanW, kalmanH: kalmanH,
            fallback: fallback,
            imageW: Double(image.width),
            imageH: Double(image.height)
        )
    }

    private func leftoverRankedHash(id: UUID, fallback: String) -> String {
        MatchMath.leftoverRankedHashOf(
            tick: leftoverLiveHashTick[id],
            last: leftoverLastHash[id],
            fallback: fallback
        )
    }

    private func leftoverPredictHeld(keep: Set<UUID>, skip: Set<UUID>, miss: Int = 0) {
        let ids = keep.filter { !skip.contains($0) }
        for id in ids {
            guard let k = boxKalman[id] else { continue }
            let raw = boxKalmanV[id] ?? (vx: 0, vy: 0)
            let size = boxKalmanWHV[id] ?? (vw: 0, vh: 0)
            let held = MatchMath.leftoverFaceTrackPredictHeld(
                box: MatchMath.FaceTrackBox(x: k.x, y: k.y, w: k.w, h: k.h),
                px: raw.vx, py: raw.vy, dt: liveDt, miss: miss,
                pw: size.vw, ph: size.vh
            )
            let locked = MatchMath.leftoverGhostAspectLock(
                predX: held.box.x, predY: held.box.y,
                lastW: k.w, lastH: k.h,
                predW: held.box.w, predH: held.box.h,
                blend: 0.25
            )
            boxKalman[id] = (locked.x, locked.y, locked.w, locked.h, k.px, k.py, k.pw, k.ph)
            boxKalmanV[id] = (vx: held.px, vy: held.py)
            boxKalmanWHV[id] = (vw: held.pw, vh: held.ph)
            if let i = liveGhosts.firstIndex(where: { $0.face.id == id }) {
                var g = liveGhosts[i]
                g.face.box = FaceBox(x: locked.x, y: locked.y, width: locked.w, height: locked.h)
                liveGhosts[i] = g
            }
        }
    }

    private func leftoverDropKalmanTwins(_ found: [FaceObservation]) -> [FaceObservation] {
        let pred = boxKalman.mapValues { FaceBox(x: $0.x, y: $0.y, width: $0.w, height: $0.h) }
        guard !pred.isEmpty, found.count >= 2 else { return found }
        var best: [UUID: Double] = [:]
        for face in found {
            for (id, box) in pred {
                let o = FaceEngine.iou(face.box, box)
                best[id] = max(best[id] ?? 0, o)
            }
        }
        return found.filter { face in
            for (id, box) in pred {
                let o = FaceEngine.iou(face.box, box)
                if MatchMath.kalmanNmsDrops(iou: o, bestIou: best[id] ?? 0) { return false }
            }
            return true
        }
    }

    private func boxKalmanDrop(_ id: UUID) {
        boxKalman.removeValue(forKey: id)
        boxKalmanV.removeValue(forKey: id)
        boxKalmanWHV.removeValue(forKey: id)
    }

    private func applyLiveFaces(
        _ incoming: [FaceObservation],
        image: CGImage,
        mediaId: UUID,
        stamp: TimeInterval,
        skipDetect: Bool = false,
        skipPrints: Bool = false
    ) {
        let nowTick = stamp > 0 ? stamp : Date().timeIntervalSince1970
        leftoverHashRebasedTick = false
        if leftoverHashNeedsRebase {
            leftoverHoldByHash = MatchMath.leftoverHashHoldRebase(leftoverHoldByHash, now: nowTick, keepAt: true)
            leftoverHoldTrailByHash = MatchMath.leftoverHashTrailRebase(leftoverHoldTrailByHash, now: nowTick, keepAt: true)
            leftoverHashNeedsRebase = false
            leftoverHashRebasedTick = true
        }
        let latch = MatchMath.liveFacesLatch(
            present: !incoming.isEmpty,
            on: liveCapture.facesPresent,
            streak: liveFaceStreak
        )
        liveFaceStreak = latch.streak
        liveCapture.setFacesPresent(latch.on, streak: leftoverStreak.values.max() ?? 0)
        guard let idx = media.firstIndex(where: { $0.id == mediaId }) else { return }
        media[idx].width = image.width
        media[idx].height = image.height
        media[idx].preview = image
        let now = stamp > 0 ? stamp : Date().timeIntervalSince1970
        let found = leftoverDropKalmanTwins(incoming)
        if liveLastStamp > 0, now > liveLastStamp {
            let raw = now - liveLastStamp
            if raw > 0.02, raw < 0.40 {
                liveDtSamples.append(raw)
                if liveDtSamples.count > 8 { liveDtSamples.removeFirst(liveDtSamples.count - 8) }
            }
            liveDt = MatchMath.medianLiveDt(liveDtSamples, fallback: liveDt)
        }
        leftoverHoldSeenSlow = MatchMath.dropoutSeenSlow(
            dt: liveDt,
            samples: liveDtSamples.count,
            prev: leftoverHoldSeenSlow,
            fastFor: leftoverHoldFastFor
        )
        if liveDt < 0.08 {
            leftoverHoldFastFor += liveDt
        } else {
            leftoverHoldFastFor = 0
        }
        if !leftoverHoldSeenSlow { leftoverHoldFastFor = 0 }
        liveLastStamp = now
        let liveFrameCapture = MatchMath.leftoverPickLuma(
            frame: MatchMath.leftoverFrameCapture(image),
            capture: found.map(\.quality.capture).max()
        )
        let enrolled = Set(identities.flatMap(\.faceIds))
        let previous = faces.filter { $0.mediaId == mediaId }
        var foundIouMax = 0.0
        if !found.isEmpty, !previous.isEmpty {
            for face in found {
                for old in previous {
                    foundIouMax = max(foundIouMax, FaceEngine.iou(old.box, face.box))
                }
            }
        }
        let emptyLike = found.isEmpty
            || (!previous.isEmpty && MatchMath.leftoverEmptyIgnoresStranger(foundIouMax: foundIouMax))
        let namedTracks = Set(previous.compactMap { old -> UUID? in
            let hit = matches.first { $0.faceId == old.id }?.hits.first { $0.strategy == .aegis }
            return hit?.identityId != nil ? old.id : nil
        })
        var used = Set<UUID>()
        var leftoverTried = Set<UUID>()
        if emptyLike {
            if leftoverEmptySince == nil { leftoverEmptySince = now }
        } else {
            leftoverEmptySince = nil
        }
        let emptyFor = leftoverEmptySince.map { now - $0 } ?? 0
        let emptyLatch = emptyLike && MatchMath.leftoverLatchKeeps(emptyFor: emptyFor)
        let emptyChip = emptyLike && MatchMath.leftoverLatchChipKeeps(emptyFor: emptyFor)
        if !emptyChip && !MatchMath.leftoverEmptyKeepsOverlay(liveEmpty: emptyLike) {
            leftoverPending = [:]
        }
        var adopted: [FaceObservation] = []
        adopted.reserveCapacity(found.count)
        var printCommitted = Set<UUID>()
        for var face in found {
            let probeVec = FaceEngine.embedding(of: face)
            var best: FaceObservation?
            var bestIoU = 0.0
            var bestEnrolled = false
            for old in previous where !used.contains(old.id) {
                let o = FaceEngine.iou(old.box, face.box)
                let pin = namedTracks.contains(old.id) || enrolled.contains(old.id)
                guard MatchMath.trackPin(iou: o, enrolled: pin) else { continue }
                let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                let cosine: Double? = {
                    if probeVec.count >= 32, ov.count == probeVec.count { return MatchMath.cosine(probeVec, ov) }
                    return nil
                }()
                if pin, MatchMath.iouPrintBlocks(cosine: cosine) {
                    boxEuro.removeValue(forKey: old.id)
                    boxJumpPending.removeValue(forKey: old.id)
                    continue
                }
                if pin && !bestEnrolled {
                    best = old
                    bestIoU = o
                    bestEnrolled = true
                } else if pin == bestEnrolled, o > bestIoU {
                    best = old
                    bestIoU = o
                }
            }
            let printPin = pinByPrint(face, pool: previous + reconnectGhosts + liveGhosts.map(\.face), used: used)
            let printEnrolled = printPin.map { enrolled.contains($0.id) || namedTracks.contains($0.id) } ?? false
            var takePrint = MatchMath.boxPinTakePrint(
                iouHold: best.map { _ in MatchMath.boxHysteresisHold(iou: bestIoU) } ?? false,
                printPinDifferent: printPin.map { $0.id != best?.id } ?? false,
                printEnrolled: printEnrolled
            )
            let pinGhost = printPin.map { pin in
                reconnectGhosts.contains { $0.id == pin.id }
                    || liveGhosts.contains { $0.face.id == pin.id }
            } ?? false
            let dropPrint = MatchMath.reconnectPrefersPrint(gap: liveDt, fromGhost: pinGhost)
            if let pin = printPin, dropPrint {
                let pinVec = pin.printVec.count >= 32 ? pin.printVec : FaceEngine.embedding(of: pin)
                let pinCos: Double? = {
                    if probeVec.count >= 32, pinVec.count == probeVec.count { return MatchMath.cosine(probeVec, pinVec) }
                    return nil
                }()
                if !MatchMath.reconnectGhostNeedsBaptize(fromGhost: pinGhost, cosine: pinCos) {
                    takePrint = true
                }
            }
            // Dropout / Ghost: IoU tot — auch ohne Print keine Box-Taufe.
            if let old = best, !takePrint, !dropPrint {
                used.insert(old.id)
                face.id = old.id
                face.trackId = old.trackId ?? old.id
                face.enrolledAt = old.enrolledAt ?? face.enrolledAt
                if MatchMath.boxHysteresisHold(iou: bestIoU) {
                    if MatchMath.boxEuroResetOnHysteresis(iou: bestIoU, cosine: {
                        if probeVec.count >= 32 {
                            let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                            if ov.count == probeVec.count { return MatchMath.cosine(probeVec, ov) }
                        }
                        return nil
                    }()) {
                        boxEuro.removeValue(forKey: old.id)
                        boxJumpPending.removeValue(forKey: old.id)
                    } else if let pending = boxJumpPending[old.id],
                       MatchMath.boxHysteresisConfirm(iouToPending: FaceEngine.iou(pending, face.box))
                    {
                        boxJumpPending.removeValue(forKey: old.id)
                        boxEuro.removeValue(forKey: old.id)
                    } else {
                        boxJumpPending[old.id] = face.box
                        face.box = old.box
                        if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                            face.featurePrint = old.featurePrint
                            face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                        }
                        var spark = old.qualitySpark
                        spark.append(face.quality)
                        if spark.count > 8 { spark.removeFirst(spark.count - 8) }
                        face.qualitySpark = spark
                        adopted.append(face)
                        continue
                    }
                } else {
                    boxJumpPending.removeValue(forKey: old.id)
                }
                let t = now
                let area = face.box.width * face.box.height
                if skipDetect {
                    // Overlay-Coast: IoU ≥ 0,92 → Predict (nicht bit-gleich).
                    // Exact == snapte nach leftoverPredictHeld / async-Snap zurück.
                    let seed = boxKalman[old.id]
                    let vision = MatchMath.FaceTrackBox(
                        x: face.box.x, y: face.box.y, w: face.box.width, h: face.box.height
                    )
                    let kalmanBox = seed.map {
                        MatchMath.FaceTrackBox(x: $0.x, y: $0.y, w: $0.w, h: $0.h)
                    }
                    let iou: Double? = kalmanBox.map {
                        MatchMath.leftoverBoxIoU(
                            ax: $0.x, ay: $0.y, aw: $0.w, ah: $0.h,
                            bx: vision.x, by: vision.y, bw: vision.w, bh: vision.h
                        )
                    }
                    if MatchMath.leftoverDetectSkip(iou: iou), let k = seed {
                        let raw = boxKalmanV[old.id] ?? (vx: 0, vy: 0)
                        let size = boxKalmanWHV[old.id] ?? (vw: 0, vh: 0)
                        let pred = MatchMath.leftoverFaceTrackKalmanPredict(
                            box: MatchMath.FaceTrackBox(x: k.x, y: k.y, w: k.w, h: k.h),
                            px: raw.vx, py: raw.vy, dt: liveDt,
                            pw: size.vw, ph: size.vh
                        )
                        face.box = FaceBox(x: pred.x, y: pred.y, width: pred.w, height: pred.h)
                        boxKalman[old.id] = (pred.x, pred.y, pred.w, pred.h, k.px, k.py, k.pw, k.ph)
                    } else {
                        let vel = MatchMath.leftoverFaceTrackKalmanVel(
                            prev: kalmanBox, live: vision, dt: liveDt
                        )
                        boxKalman[old.id] = (
                            vision.x, vision.y, vision.w, vision.h,
                            seed?.px ?? 0.04, seed?.py ?? 0.04, seed?.pw ?? 0.04, seed?.ph ?? 0.04
                        )
                        boxKalmanV[old.id] = (vx: vel.px, vy: vel.py)
                        boxKalmanWHV[old.id] = (vw: vel.pw, vh: vel.ph)
                        face.box = FaceBox(x: vision.x, y: vision.y, width: vision.w, height: vision.h)
                    }
                } else if MatchMath.boxKalmanUses(dt: liveDt) {
                    let prev = boxKalman[old.id]
                    let px0 = prev?.x ?? face.box.x
                    let py0 = prev?.y ?? face.box.y
                    let pw0 = prev?.w ?? face.box.width
                    let ph0 = prev?.h ?? face.box.height
                    let jump = MatchMath.captureJumps(prev: old.quality.capture, next: face.quality.capture)
                    let q = MatchMath.boxKalmanQ(captureJump: jump)
                    let x = MatchMath.boxKalman(prev: px0, meas: face.box.x, p: prev?.px ?? 0.04, dt: liveDt, q: q)
                    let y = MatchMath.boxKalman(prev: py0, meas: face.box.y, p: prev?.py ?? 0.04, dt: liveDt, q: q)
                    let w = MatchMath.boxKalman(prev: pw0, meas: face.box.width, p: prev?.pw ?? 0.04, dt: liveDt, q: q)
                    let h = MatchMath.boxKalman(prev: ph0, meas: face.box.height, p: prev?.ph ?? 0.04, dt: liveDt, q: q)
                    face.box = FaceBox(x: x.x, y: y.x, width: w.x, height: h.x)
                    boxKalman[old.id] = (x.x, y.x, w.x, h.x, x.p, y.p, w.p, h.p)
                    let prevV = boxKalmanV[old.id]
                    let kv = MatchMath.leftoverFaceTrackKalmanVel(
                        prev: prev.map { MatchMath.FaceTrackBox(x: $0.x, y: $0.y, w: $0.w, h: $0.h) },
                        live: MatchMath.FaceTrackBox(x: x.x, y: y.x, w: w.x, h: h.x),
                        dt: liveDt
                    )
                    if kv.px == 0, kv.py == 0, kv.pw == 0, kv.ph == 0, liveDt >= 2 {
                        boxKalmanV[old.id] = (vx: 0, vy: 0)
                        boxKalmanWHV[old.id] = (vw: 0, vh: 0)
                    } else {
                        boxKalmanV[old.id] = (
                            vx: MatchMath.boxKalmanVelocity(prev: px0, next: x.x, dt: liveDt, prevV: prevV?.vx ?? 0),
                            vy: MatchMath.boxKalmanVelocity(prev: py0, next: y.x, dt: liveDt, prevV: prevV?.vy ?? 0)
                        )
                        boxKalmanWHV[old.id] = (
                            vw: MatchMath.boxKalmanVelocity(prev: pw0, next: w.x, dt: liveDt, prevV: boxKalmanWHV[old.id]?.vw ?? 0),
                            vh: MatchMath.boxKalmanVelocity(prev: ph0, next: h.x, dt: liveDt, prevV: boxKalmanWHV[old.id]?.vh ?? 0)
                        )
                    }
                } else {
                    var euro = boxEuro[old.id] ?? (
                        MatchMath.OneEuro(), MatchMath.OneEuro(), MatchMath.OneEuro(), MatchMath.OneEuro()
                    )
                    face.box = FaceBox(
                        x: euro.x.filter(face.box.x, now: t, boxArea: area),
                        y: euro.y.filter(face.box.y, now: t, boxArea: area),
                        width: euro.w.filter(face.box.width, now: t, boxArea: area),
                        height: euro.h.filter(face.box.height, now: t, boxArea: area)
                    )
                    boxEuro[old.id] = euro
                }
                let blend = MatchMath.liveBlendAlpha(continuity: liveCapture.isContinuity)
                if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec
                } else if !old.featurePrint.isEmpty, face.quality.capture + 0.04 < old.quality.capture {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if !old.featurePrint.isEmpty, !face.featurePrint.isEmpty {
                    if !old.landmarks.isEmpty, !face.landmarks.isEmpty {
                        let j = MatchMath.landmarkJitter(
                            prev: liveLandmarkPrev[old.id] ?? old.landmarks,
                            next: face.landmarks
                        )
                        let acc = MatchMath.posterJitterAccum(prev: livePosterJitter[old.id] ?? j, next: j)
                        livePosterJitter[old.id] = acc
                        livePosterStill[old.id] = MatchMath.posterStillAdvance(
                            jitter: acc,
                            streak: livePosterStill[old.id] ?? 0
                        )
                        liveLandmarkPrev[old.id] = face.landmarks
                    }
                    let closedNow = MatchMath.eyesClosed(
                        openIod: face.ratioSheet.first { $0.id == "eyeOpen_iod" }?.value
                    )
                    let lids = MatchMath.leftoverBlinkLiveness(
                        open: !closedNow,
                        openStreak: liveOpenStreak[old.id] ?? 0
                    )
                    liveOpenStreak[old.id] = lids.streak
                    if MatchMath.livenessBlink(
                        prevClosed: liveLidClosed[old.id] ?? false,
                        nowClosed: closedNow
                    ) {
                        leftoverStampBlink(faceId: old.id, box: face.box)
                    }
                    liveLidClosed[old.id] = closedNow
                    if MatchMath.captureJumps(prev: old.quality.capture, next: face.quality.capture) {
                        liveExposureUntil[old.id] = MatchMath.exposureLockUntil(
                            now: now,
                            hold: MatchMath.exposureLockHold(dt: liveDt, reconnect: pinGhost)
                        )
                    }
                    let aeLock = MatchMath.exposureLocks(now: now, until: liveExposureUntil[old.id] ?? 0)
                    let enrolledPin = enrolled.contains(old.id) || namedTracks.contains(old.id)
                    var capHist = liveCaptureHist[old.id] ?? [old.quality.capture]
                    let burst = MatchMath.captureBurstBlocksPrint(
                        history: capHist,
                        next: face.quality.capture,
                        enrolled: enrolledPin
                    )
                    capHist.append(face.quality.capture)
                    if capHist.count > MatchMath.captureBurstFrames {
                        capHist.removeFirst(capHist.count - MatchMath.captureBurstFrames)
                    }
                    liveCaptureHist[old.id] = capHist
                    if let h = leftoverLastHash[old.id] {
                        leftoverCaptureHistByHash = MatchMath.leftoverCaptureHistTablePut(
                            hash: h,
                            hist: capHist,
                            onto: leftoverCaptureHistByHash
                        )
                        leftoverCaptureHistAt = MatchMath.leftoverCaptureHistAtPut(
                            hash: h,
                            now: now,
                            onto: leftoverCaptureHistAt
                        )
                    }
                    let skip = aeLock
                        || burst
                        || MatchMath.captureJumpBlocksPrint(
                            prev: old.quality.capture,
                            next: face.quality.capture,
                            enrolled: enrolledPin
                        )
                        || MatchMath.holdStillSkip(iou: bestIoU, sharpness: face.quality.sharpness, dt: liveDt)
                        || MatchMath.skipPrint(sharpness: face.quality.sharpness, continuity: liveCapture.isContinuity, yaw: face.quality.yaw)
                        || MatchMath.leftoverPrintDiversitySkip(
                            cosine: MatchMath.leftoverCoastPrintCosine(
                                live: face.printVec.count >= 32 ? face.printVec : FaceEngine.embedding(of: face),
                                stored: leftoverCoastPrint[old.id] ?? []
                            ),
                            sameBin: MatchMath.leftoverPrintSameBin(
                                yawA: face.quality.yaw,
                                yawB: leftoverPrintYaw[old.id]
                            )
                        )
                        || MatchMath.motionBlurDrops(
                            aligned: MatchMath.cropAligns(roll: face.quality.roll),
                            sharpness: face.quality.sharpness
                        )
                    if skip {
                        liveStillFor[old.id] = 0
                    } else {
                        liveStillFor[old.id] = (liveStillFor[old.id] ?? 0) + liveDt
                    }
                    if skip || !MatchMath.holdStillReady(
                        stillFor: liveStillFor[old.id] ?? 0,
                        need: MatchMath.holdStillNeedOf(dt: liveDt)
                    ) {
                        face.featurePrint = old.featurePrint
                        face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                    } else {
                    let prev = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                    let next = FaceEngine.embedding(of: face)
                    let nextSlot = FaceEngine.poseSlot(face).rawValue
                    var trail = livePrintTrail[old.id] ?? []
                    if !MatchMath.printTrailAccepts(prevSlot: livePrintTrailSlot[old.id], nextSlot: nextSlot) {
                        trail = []
                    }
                    livePrintTrailSlot[old.id] = nextSlot
                    if MatchMath.leftoverPrintCommitOk(next: next, sharpness: face.quality.sharpness) {
                        trail = MatchMath.leftoverPrintTrailNext(trail: trail, next: next)
                        livePrintTrail[old.id] = trail
                        let median = MatchMath.leftoverPrintBlend(trail, dt: liveDt, anchor: prev)
                        face.printVec = median.isEmpty ? FaceEngine.blendEmbeddings(prev, next, alpha: blend) : median
                        leftoverPrintYaw = MatchMath.leftoverPrintYawStamp(
                            printed: leftoverPrintYaw,
                            id: old.id,
                            yaw: face.quality.yaw
                        )
                        printCommitted.insert(old.id)
                        printCommitted.insert(face.id)
                    } else {
                        livePrintTrail[old.id] = trail
                        face.featurePrint = old.featurePrint
                        face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                    }
                    }
                } else if face.printVec.isEmpty {
                    face.printVec = FaceEngine.embedding(of: face)
                }
                var spark = old.qualitySpark
                spark.append(face.quality)
                if spark.count > 8 { spark.removeFirst(spark.count - 8) }
                face.qualitySpark = spark
            } else if let old = printPin {
                used.insert(old.id)
                face.id = old.id
                face.trackId = old.trackId ?? old.id
                face.enrolledAt = old.enrolledAt ?? face.enrolledAt
                leftoverBlendAdopted(&face, oldId: old.id)
                liveExposureUntil[old.id] = MatchMath.exposureLockUntil(
                    now: now,
                    hold: MatchMath.exposureLockHold(dt: liveDt, reconnect: pinGhost)
                )
                // Ghost-Box darf nicht kleben: 1-Euro und Ampel der UUID verwerfen.
                boxEuro.removeValue(forKey: old.id)
                boxJumpPending.removeValue(forKey: old.id)
                if !MatchMath.printTrailKeepsOnGhostAdopt() {
                    livePrintTrail.removeValue(forKey: old.id)
                    livePrintTrailSlot.removeValue(forKey: old.id)
                }
                face.qualitySpark = []
                let blend = MatchMath.liveBlendAlpha(continuity: liveCapture.isContinuity)
                let enrolledPin = enrolled.contains(old.id) || namedTracks.contains(old.id)
                var hist = liveCaptureHist[old.id] ?? [old.quality.capture]
                let jump = MatchMath.captureBurstBlocksPrint(
                    history: hist,
                    next: face.quality.capture,
                    enrolled: enrolledPin
                ) || MatchMath.captureJumpBlocksPrint(
                    prev: old.quality.capture,
                    next: face.quality.capture,
                    enrolled: enrolledPin
                )
                hist.append(face.quality.capture)
                if hist.count > MatchMath.captureBurstFrames { hist.removeFirst(hist.count - MatchMath.captureBurstFrames) }
                liveCaptureHist[old.id] = hist
                if let h = leftoverLastHash[old.id] {
                    leftoverCaptureHistByHash = MatchMath.leftoverCaptureHistTablePut(
                        hash: h,
                        hist: hist,
                        onto: leftoverCaptureHistByHash
                    )
                    leftoverCaptureHistAt = MatchMath.leftoverCaptureHistAtPut(
                        hash: h,
                        now: now,
                        onto: leftoverCaptureHistAt
                    )
                }
                let blur = MatchMath.skipPrint(
                    sharpness: face.quality.sharpness,
                    continuity: liveCapture.isContinuity,
                    yaw: face.quality.yaw
                )
                if jump || blur || face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if face.featurePrint.isEmpty, !old.featurePrint.isEmpty {
                    face.featurePrint = old.featurePrint
                    face.printVec = old.printVec.isEmpty ? FaceEngine.embedding(of: old) : old.printVec
                } else if !old.printVec.isEmpty, !face.featurePrint.isEmpty {
                    face.printVec = FaceEngine.blendEmbeddings(old.printVec, FaceEngine.embedding(of: face), alpha: blend)
                }
            }
            adopted.append(face)
        }
        if adopted.count >= 2 {
            var swapped = Set<UUID>()
            func vec(_ face: FaceObservation) -> [Double] {
                face.printVec.count >= 32 ? face.printVec : FaceEngine.embedding(of: face)
            }
            for (i, j) in MatchMath.pairSwapIndices(count: adopted.count) {
                let a = adopted[i]
                let b = adopted[j]
                guard !swapped.contains(a.id), !swapped.contains(b.id) else { continue }
                guard let oldA = previous.first(where: { $0.id == a.id }),
                      let oldB = previous.first(where: { $0.id == b.id }),
                      oldA.id != oldB.id
                else { continue }
                let va = vec(a)
                let vb = vec(b)
                let oa = vec(oldA)
                let ob = vec(oldB)
                if MatchMath.identitiesCrossed(
                    keepA: MatchMath.cosine(va, oa),
                    keepB: MatchMath.cosine(vb, ob),
                    crossAB: MatchMath.cosine(va, ob),
                    crossBA: MatchMath.cosine(vb, oa)
                ) {
                    adopted[i].id = oldB.id
                    adopted[i].trackId = oldB.trackId ?? oldB.id
                    adopted[i].enrolledAt = oldB.enrolledAt ?? adopted[i].enrolledAt
                    leftoverMirrorPending(from: a.id, to: oldB.id)
                    adopted[j].id = oldA.id
                    adopted[j].trackId = oldA.trackId ?? oldA.id
                    adopted[j].enrolledAt = oldA.enrolledAt ?? adopted[j].enrolledAt
                    leftoverMirrorPending(from: b.id, to: oldA.id)
                    swapped.insert(oldA.id)
                    swapped.insert(oldB.id)
                    swapFlashUntil = now + MatchMath.swapFlashHold()
                    for id in [oldA.id, oldB.id] {
                        boxEuro.removeValue(forKey: id)
                        boxJumpPending.removeValue(forKey: id)
                        livePrintTrail.removeValue(forKey: id)
                        livePrintTrailSlot.removeValue(forKey: id)
                        liveNameHist.removeValue(forKey: id)
                        liveNameLock.removeValue(forKey: id)
                        leftoverHold.removeValue(forKey: id)
                        leftoverHoldBins = MatchMath.leftoverHoldBinDrop(bins: leftoverHoldBins, id: id)
                        liveNameVoteAt.removeValue(forKey: id)
                        liveScoreEma.removeValue(forKey: id)
                        liveScoreTicks.removeValue(forKey: id)
                        liveYaw.removeValue(forKey: id)
                        livePitch.removeValue(forKey: id)
                        liveRoll.removeValue(forKey: id)
                        livePrintDrift.removeValue(forKey: id)
                    }
                }
            }
        }
        if adopted.count >= 2 {
            let unnamedIdx = adopted.indices.filter { i in
                !namedTracks.contains(adopted[i].id) && !enrolled.contains(adopted[i].id)
            }
            let unusedNamed = previous.filter {
                MatchMath.leftoverNamedTrack(hadName: namedTracks.contains($0.id)) && !used.contains($0.id)
            }
            if unnamedIdx.count == 2, unusedNamed.count == 2 {
                let a = unusedNamed[0]
                let b = unusedNamed[1]
                let i0 = unnamedIdx[0]
                let i1 = unnamedIdx[1]
                let n0 = adopted[i0]
                let n1 = adopted[i1]
                let iouAA = FaceEngine.iou(a.box, n0.box)
                let iouBB = FaceEngine.iou(b.box, n1.box)
                let iouAB = FaceEngine.iou(a.box, n1.box)
                let iouBA = FaceEngine.iou(b.box, n0.box)
                if MatchMath.boxesCrossed(iouSameA: iouAA, iouSameB: iouBB, iouCrossAB: iouAB, iouCrossBA: iouBA) {
                    adopted[i1].id = a.id
                    adopted[i1].trackId = a.trackId ?? a.id
                    adopted[i1].enrolledAt = a.enrolledAt ?? adopted[i1].enrolledAt
                    leftoverMirrorPending(from: n1.id, to: a.id)
                    adopted[i0].id = b.id
                    adopted[i0].trackId = b.trackId ?? b.id
                    adopted[i0].enrolledAt = b.enrolledAt ?? adopted[i0].enrolledAt
                    leftoverMirrorPending(from: n0.id, to: b.id)
                    used.insert(a.id)
                    used.insert(b.id)
                    boxEuro.removeValue(forKey: a.id)
                    boxEuro.removeValue(forKey: b.id)
                    boxJumpPending.removeValue(forKey: a.id)
                    boxJumpPending.removeValue(forKey: b.id)
                }
            }
            let unnamedLeft = unnamedIdx.filter { i in
                !used.contains(adopted[i].id)
            }
            let unusedLeft = unusedNamed.filter { !used.contains($0.id) }
            if MatchMath.leftoverAssignLiveGate(
                unnamed: unnamedLeft.count,
                unused: unusedLeft.count,
                need: assignLiveGate
            ) {
                var scores: [[Double?]] = []
                scores.reserveCapacity(unusedLeft.count)
                for old in unusedLeft {
                    let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                    var row: [Double?] = []
                    row.reserveCapacity(unnamedLeft.count)
                    for i in unnamedLeft {
                        let face = adopted[i]
                        let v = face.printVec.count >= 32 ? face.printVec : FaceEngine.embedding(of: face)
                        if v.count >= 32, ov.count == v.count {
                            let c = MatchMath.cosine(v, ov)
                            row.append(MatchMath.leftoverAssignPrintCell(
                                cosine: c,
                                sharpness: face.quality.sharpness,
                                yawAbs: abs(face.quality.yaw),
                                continuity: liveCapture.isContinuity,
                                twinOtherCosine: c,
                                twinYawDelta: abs(face.quality.yaw - old.quality.yaw),
                                alreadyNamed: true,
                                blinkOk: leftoverBlinkSeen(faceId: face.id),
                                capture: MatchMath.leftoverSessionCapture(
                                    old: old.quality.capture,
                                    live: [face.quality.capture]
                                )
                            ))
                        } else {
                            row.append(nil)
                        }
                    }
                    scores.append(row)
                }
                scores = MatchMath.leftoverAssignTwinYawCull(
                    scores: scores,
                    boxes: unnamedLeft.map { (adopted[$0].box.x, adopted[$0].box.width) },
                    yaws: unnamedLeft.map { adopted[$0].quality.yaw }
                )
                let assigned = MatchMath.leftoverAssignLive(
                    scores: scores,
                    liveX: unnamedLeft.map { adopted[$0].box.x },
                    holdX: unusedLeft.map { leftoverStreakBox[$0.id]?.x ?? $0.box.x },
                    pad: fillXRescue,
                    padFill: fillXPad
                )
                var takenCols = Set<Int>()
                for (r, col) in assigned.enumerated() {
                    guard let col, r < unusedLeft.count, col < unnamedLeft.count else { continue }
                    let old = unusedLeft[r]
                    let i = unnamedLeft[col]
                    guard !used.contains(old.id), !takenCols.contains(col) else { continue }
                    takenCols.insert(col)
                    leftoverTried.insert(old.id)
                    let proposed = adopted[i].id
                    let prevLast = leftoverPairLast[old.id]
                    let committed = leftoverPairCommit[old.id]
                    let prevMiss = leftoverPairCommitMiss[old.id] ?? 0
                    let maj = MatchMath.leftoverAssignMajority(
                        committed: committed,
                        proposed: proposed,
                        lastProposed: leftoverPairLast[old.id],
                        streak: leftoverPairStreak[old.id] ?? 0,
                        locked: MatchMath.leftoverNameLockBlocks(
                            until: leftoverNameLockUntil[old.id] ?? leftoverNameLockUntil[proposed],
                            now: now
                        ),
                        commitMiss: prevMiss
                    )
                    leftoverPairCommitMiss[old.id] = MatchMath.leftoverPairCommitMissAdvance(
                        prev: prevMiss,
                        keeps: MatchMath.leftoverPairCommitKeeps(committed: committed, proposed: proposed),
                        hold: MatchMath.leftoverPairCommitHold(committed: committed, proposed: proposed, miss: prevMiss)
                    )
                    leftoverDisagree[old.id] = MatchMath.clusterSplitAdvance(
                        prev: leftoverDisagree[old.id] ?? 0,
                        changed: prevLast != nil && prevLast != proposed && maj.streak == 1
                    )
                    leftoverPairLast[old.id] = maj.last
                    leftoverPairStreak[old.id] = maj.streak
                    if MatchMath.clusterSplit(disagree: leftoverDisagree[old.id] ?? 0) {
                        leftoverPending[adopted[i].id] = MatchMath.clusterSplitNote()
                        continue
                    }
                    if let holdLabel = MatchMath.leftoverPairCommitHoldLabel(miss: leftoverPairCommitMiss[old.id] ?? 0) {
                        leftoverPending[adopted[i].id] = holdLabel
                    } else if let majLabel = MatchMath.leftoverMajorityLabel(streak: maj.streak) {
                        leftoverPending[adopted[i].id] = majLabel
                    }
                    guard maj.ready else { continue }
                    leftoverPairCommit[old.id] = maj.commit
                    leftoverPairCommitMiss[old.id] = 0
                    leftoverDisagree[old.id] = 0
                    let step = leftoverAdvance(oldId: old.id, box: adopted[i].box, now: now, boxId: adopted[i].id, dt: liveDt, yawAbs: adopted[i].quality.yaw)
                    if let label = step.label {
                        leftoverPending[adopted[i].id] = label
                    }
                    guard step.ready else { continue }
                    leftoverClearStreak(old.id, pair: MatchMath.leftoverClearDropsPair(transferred: true))
                    leftoverPending.removeValue(forKey: adopted[i].id)
                    used.insert(old.id)
                    let newId = adopted[i].id
                    adopted[i].id = old.id
                    leftoverMirrorPending(from: newId, to: old.id)
                    adopted[i].trackId = old.trackId ?? old.id
                    adopted[i].enrolledAt = old.enrolledAt ?? adopted[i].enrolledAt
                    leftoverBlendAdopted(&adopted[i], oldId: old.id)
                    boxEuro.removeValue(forKey: old.id)
                    if !MatchMath.leftoverAdoptKeepsKalman() {
                        boxKalmanDrop(old.id)
                    }
                    boxJumpPending.removeValue(forKey: old.id)
                }
                for old in unusedLeft where !leftoverTried.contains(old.id) {
                    leftoverClearStreak(old.id)
                }
            }
        }
        liveGhosts.removeAll { $0.until < now }
        let dropped = Set(MatchMath.leftoverDropped(previous: previous.map(\.id), used: used))
        for old in previous where dropped.contains(old.id) {
            liveGhosts.removeAll { $0.face.id == old.id }
            liveGhosts.append((old, now + leftoverHoldTTL))
        }
        let ghostIds = MatchMath.leftoverGhostIds(
            previous: Array(dropped),
            ghosts: liveGhosts.map(\.face.id)
        )
        let liveIds = Array(used)
        let remintLive = adopted.map { (id: $0.id, x: $0.box.x) }
        let remintStored = MatchMath.leftoverHoldRemintRows(
            streak: leftoverStreakBox.map { (id: $0.key, x: $0.value.x) },
            holdIds: Array(leftoverHold.keys),
            ghosts: liveGhosts.map { (id: $0.face.id, x: $0.face.box.x) }
        )
        let remintLiveHash = Dictionary(uniqueKeysWithValues: adopted.map { face in
            (face.id, leftoverLiveHash(
                kalmanX: boxKalman[face.id]?.x,
                kalmanY: boxKalman[face.id]?.y,
                kalmanW: boxKalman[face.id]?.w,
                kalmanH: boxKalman[face.id]?.h,
                fallback: face.box,
                image: image
            ))
        })
        let remintStoredHash = MatchMath.leftoverStoredHashMerge(last: leftoverLastHash, tick: leftoverLiveHashTick)
        let remintHashKeys = Array(leftoverHoldByHash.keys)
        let remintKeys = MatchMath.leftoverHoldRemintKeys([
            Set(leftoverHold.keys), Set(leftoverHoldTrail.keys), Set(liveSlotHold.keys),
            Set(leftoverMissFrames.keys), Set(leftoverNameLockUntil.keys), Set(leftoverNameLockHeld.keys),
            Set(leftoverPending.keys), Set(leftoverLastHash.keys), Set(leftoverLastIoU.keys),
            Set(leftoverSparkChipHeld.keys), Set(leftoverJpegDelta.keys), Set(leftoverJpegAt.keys),
            Set(leftoverJpegHash.keys), Set(leftoverJpegCos.keys), Set(leftoverLiveHashTick.keys),
            Set(leftoverWipeUntil.keys), Set(leftoverPairLast.keys), Set(leftoverPairStreak.keys),
            Set(leftoverPairCommit.keys), Set(leftoverPairCommitMiss.keys), Set(leftoverDisagree.keys),
            Set(leftoverStreak.keys), Set(leftoverStreakBox.keys), Set(leftoverStreakSince.keys),
            Set(boxKalman.keys), Set(boxKalmanV.keys), Set(boxKalmanWHV.keys), Set(freezeAxis.keys),
            Set(liveYaw.keys), Set(livePitch.keys), Set(liveRoll.keys),
            Set(livePrintTrail.keys), Set(livePrintTrailSlot.keys), Set(liveStillFor.keys),
            Set(livePrintDrift.keys), Set(liveNameHist.keys), Set(liveNameLock.keys),
            Set(liveScoreEma.keys), Set(liveScoreTicks.keys), Set(liveNameVoteAt.keys),
            Set(tapNameLockUntil.keys), Set(maskHoldSince.keys), Set(livePoseAt.keys),
            Set(liveExposureUntil.keys), Set(liveCaptureHist.keys), Set(livePosterJitter.keys),
            Set(livePosterStill.keys), Set(liveLandmarkPrev.keys), Set(liveLidClosed.keys),
            Set(liveBlinkSeen.keys), Set(liveOpenStreak.keys), Set(boxEuro.keys),
            Set(boxJumpPending.keys),
            Set(leftoverCoastPrint.keys), Set(leftoverCoastPrintAt.keys), Set(leftoverCoastAt.keys),
            Set(leftoverUnsureTicks.keys), Set(leftoverPrintYaw.keys),
            Set(leftoverOverlayPeakHeld.keys), Set(leftoverOverlayPeakRemain.keys)
        ])
        let remintPlan = MatchMath.leftoverHoldRemintMap(
            live: remintLive,
            stored: remintStored,
            holdKeys: remintKeys,
            liveHash: remintLiveHash,
            storedHash: remintStoredHash,
            hashTableKeys: remintHashKeys,
            pad: fillXPad,
            padRescue: fillXRescue
        )
        let packVel = MatchMath.leftoverFaceTrackVelFromKalman(boxKalmanV)
        leftoverTracks = MatchMath.leftoverTracksPack(
            hashes: leftoverLastHash,
            pairLast: leftoverPairLast,
            peaks: leftoverHold,
            nameLock: leftoverNameLockHeld,
            coastAt: leftoverCoastAt,
            bins: leftoverPrintYaw.mapValues { MatchMath.leftoverHoldBinSigned(yaw: $0) },
            yaw: liveYaw,
            velX: packVel.px,
            velY: packVel.py,
            blink: liveBlinkSeen
        )
        leftoverTracks = MatchMath.leftoverAssignAtomicRemint(
            tracks: leftoverTracks,
            remap: remintPlan
        )
        let unpacked = MatchMath.leftoverTracksUnpack(leftoverTracks)
        let faceMaps = MatchMath.leftoverFaceTrackRemintDropMaps(
            hold: leftoverHold,
            pending: leftoverPending,
            streak: leftoverStreak,
            lastHash: leftoverLastHash,
            lastIoU: leftoverLastIoU,
            nameHeld: leftoverNameLockHeld,
            nameUntil: leftoverNameLockUntil,
            miss: leftoverMissFrames,
            streakBox: leftoverStreakBox.mapValues { MatchMath.leftoverFaceTrackBox($0) },
            kalman: MatchMath.leftoverFaceTrackKalmanBox(boxKalman),
            pairLast: leftoverPairLast,
            pairStreak: leftoverPairStreak,
            yaw: liveYaw,
            pitch: livePitch,
            roll: liveRoll,
            stillFor: liveStillFor,
            scoreEma: liveScoreEma,
            poseAt: livePoseAt,
            blinkSeen: liveBlinkSeen,
            lidClosed: liveLidClosed,
            openStreak: liveOpenStreak,
            voteAt: liveNameVoteAt,
            px: packVel.px,
            py: packVel.py,
            coastAt: leftoverCoastAt,
            unsureTicks: leftoverUnsureTicks,
            remap: remintPlan
        )
        leftoverHold = MatchMath.leftoverMapPick(unpacked.peaks, fallback: faceMaps.hold)
        leftoverPending = faceMaps.pending
        leftoverStreak = faceMaps.streak
        leftoverLastHash = unpacked.hashes
        leftoverLastIoU = faceMaps.lastIoU
        leftoverNameLockHeld = unpacked.nameLock
        leftoverNameLockUntil = faceMaps.nameUntil
        leftoverMissFrames = faceMaps.miss
        leftoverStreakBox = faceMaps.streakBox.mapValues { MatchMath.leftoverFaceBox($0) }
        leftoverPairLast = MatchMath.leftoverPairLastPick(
            unpacked: unpacked.pairLast,
            faceMaps: faceMaps.pairLast
        )
        leftoverPairStreak = faceMaps.pairStreak
        liveYaw = MatchMath.leftoverMapPick(unpacked.yaw, fallback: faceMaps.yaw)
        livePitch = faceMaps.pitch
        liveRoll = faceMaps.roll
        liveStillFor = faceMaps.stillFor
        liveScoreEma = faceMaps.scoreEma
        livePoseAt = faceMaps.poseAt
        liveBlinkSeen = MatchMath.leftoverMapPick(unpacked.blink, fallback: faceMaps.blinkSeen)
        liveLidClosed = faceMaps.lidClosed
        liveOpenStreak = faceMaps.openStreak
        liveNameVoteAt = faceMaps.voteAt
        leftoverCoastPrint = MatchMath.leftoverHoldRemintDrop(hold: leftoverCoastPrint, remap: remintPlan)
        leftoverCoastPrintAt = MatchMath.leftoverHoldRemintDrop(hold: leftoverCoastPrintAt, remap: remintPlan)
        leftoverCoastAt = unpacked.coastAt
        leftoverUnsureTicks = faceMaps.unsureTicks.isEmpty
            ? MatchMath.leftoverHoldRemintDrop(hold: leftoverUnsureTicks, remap: remintPlan)
            : faceMaps.unsureTicks
        leftoverOverlayPeakHeld = MatchMath.leftoverHoldRemintDrop(hold: leftoverOverlayPeakHeld, remap: remintPlan)
        leftoverOverlayPeakRemain = MatchMath.leftoverHoldRemintDrop(hold: leftoverOverlayPeakRemain, remap: remintPlan)
        leftoverPrintYaw = MatchMath.leftoverHoldRemintDrop(hold: leftoverPrintYaw, remap: remintPlan)
        printCommitted = Set(
            MatchMath.leftoverHoldRemintDrop(
                hold: Dictionary(uniqueKeysWithValues: printCommitted.map { ($0, true) }),
                remap: remintPlan
            ).keys
        )
        leftoverHoldTrail = MatchMath.leftoverHoldRemintDrop(hold: leftoverHoldTrail, remap: remintPlan)
        liveSlotHold = MatchMath.leftoverHoldRemintDrop(hold: liveSlotHold, remap: remintPlan)
        leftoverSparkChipHeld = MatchMath.leftoverHoldRemintDrop(hold: leftoverSparkChipHeld, remap: remintPlan)
        leftoverJpegDelta = MatchMath.leftoverHoldRemintDrop(hold: leftoverJpegDelta, remap: remintPlan)
        leftoverJpegAt = MatchMath.leftoverHoldRemintDrop(hold: leftoverJpegAt, remap: remintPlan)
        leftoverJpegHash = MatchMath.leftoverHoldRemintDrop(hold: leftoverJpegHash, remap: remintPlan)
        leftoverJpegCos = MatchMath.leftoverHoldRemintDrop(hold: leftoverJpegCos, remap: remintPlan)
        leftoverLiveHashTick = MatchMath.leftoverHoldRemintDrop(hold: leftoverLiveHashTick, remap: remintPlan)
        leftoverWipeUntil = MatchMath.leftoverHoldRemintDrop(hold: leftoverWipeUntil, remap: remintPlan)
        leftoverHoldBins = MatchMath.leftoverHoldRemintDropBins(hold: leftoverHoldBins, remap: remintPlan)
        leftoverHoldTrailBins = MatchMath.leftoverHoldRemintDropBins(hold: leftoverHoldTrailBins, remap: remintPlan)
        leftoverPairCommit = MatchMath.leftoverHoldRemintDropId(hold: leftoverPairCommit, remap: remintPlan)
        leftoverPairCommitMiss = MatchMath.leftoverHoldRemintDrop(hold: leftoverPairCommitMiss, remap: remintPlan)
        leftoverDisagree = MatchMath.leftoverHoldRemintDrop(hold: leftoverDisagree, remap: remintPlan)
        leftoverStreakSince = MatchMath.leftoverHoldRemintDrop(hold: leftoverStreakSince, remap: remintPlan)
        freezeAxis = MatchMath.leftoverHoldRemintDrop(hold: freezeAxis, remap: remintPlan)
        livePrintTrail = MatchMath.leftoverHoldRemintDrop(hold: livePrintTrail, remap: remintPlan)
        livePrintTrailSlot = MatchMath.leftoverHoldRemintDrop(hold: livePrintTrailSlot, remap: remintPlan)
        livePrintDrift = MatchMath.leftoverHoldRemintDrop(hold: livePrintDrift, remap: remintPlan)
        liveNameHist = MatchMath.leftoverNameHistRemintTrim(
            hist: MatchMath.leftoverHoldRemintDrop(hold: liveNameHist, remap: remintPlan),
            remap: remintPlan
        )
        liveNameLock = MatchMath.leftoverHoldRemintDrop(hold: liveNameLock, remap: remintPlan)
        liveScoreTicks = MatchMath.leftoverHoldRemintDrop(hold: liveScoreTicks, remap: remintPlan)
        tapNameLockUntil = MatchMath.leftoverHoldRemintDrop(hold: tapNameLockUntil, remap: remintPlan)
        maskHoldSince = MatchMath.leftoverHoldRemintDrop(hold: maskHoldSince, remap: remintPlan)
        liveExposureUntil = MatchMath.leftoverHoldRemintDrop(hold: liveExposureUntil, remap: remintPlan)
        liveCaptureHist = MatchMath.leftoverHoldRemintDrop(hold: liveCaptureHist, remap: remintPlan)
        livePosterJitter = MatchMath.leftoverHoldRemintDrop(hold: livePosterJitter, remap: remintPlan)
        livePosterStill = MatchMath.leftoverHoldRemintDrop(hold: livePosterStill, remap: remintPlan)
        liveLandmarkPrev = MatchMath.leftoverHoldRemintDrop(hold: liveLandmarkPrev, remap: remintPlan)
        boxEuro = MatchMath.leftoverHoldRemintDrop(hold: boxEuro, remap: remintPlan)
        boxJumpPending = MatchMath.leftoverHoldRemintDrop(hold: boxJumpPending, remap: remintPlan)
        leftoverMissCoastTicks = MatchMath.leftoverHoldMissAdvance(
            prev: leftoverMissCoastTicks,
            hit: MatchMath.leftoverHoldMissHit(live: liveIds.count, adopted: adopted.count)
        )
        let missNeed = MatchMath.leftoverHoldMissNeedAuto(dt: liveDt, pref: leftoverMissNeed)
        let missCoast = MatchMath.leftoverHoldMissCoast(miss: leftoverMissCoastTicks, need: missNeed)
        let skipKalmanReset = MatchMath.leftoverHoldKalmanSkipReset(ago: leftoverKalmanRestoredAgo)
        let predictOnly = MatchMath.leftoverHoldKalmanPredictOnly(
            ago: leftoverKalmanRestoredAgo,
            liveEmpty: adopted.isEmpty,
            ghostHeld: !ghostIds.isEmpty,
            missCoast: missCoast
        )
        boxKalman = MatchMath.leftoverHoldRemintDrop(hold: boxKalman, remap: remintPlan)
        boxKalmanV = MatchMath.leftoverFaceTrackVelMerge(
            vel: MatchMath.leftoverHoldRemintDrop(hold: boxKalmanV, remap: remintPlan),
            px: MatchMath.leftoverMapPick(unpacked.velX, fallback: faceMaps.px),
            py: MatchMath.leftoverMapPick(unpacked.velY, fallback: faceMaps.py)
        )
        boxKalmanWHV = MatchMath.leftoverHoldRemintDrop(hold: boxKalmanWHV, remap: remintPlan)
        for face in adopted {
            if let k = boxKalman[face.id] {
                let kb = FaceBox(x: k.x, y: k.y, width: k.w, height: k.h)
                if !skipKalmanReset, MatchMath.leftoverHoldKalmanResets(
                    iou: FaceEngine.iou(kb, face.box),
                    jump: MatchMath.leftoverHoldKalmanJumpCam(dt: liveDt, pref: kalmanJump)
                ) {
                    boxKalmanDrop(face.id)
                }
            }
        }
        leftoverKalmanRestoredAgo = MatchMath.leftoverHoldKalmanRestoredAdvance(
            prev: leftoverKalmanRestoredAgo,
            restored: false
        )
        boxKalman = MatchMath.leftoverHoldKalmanKeep(kalman: boxKalman, live: adopted.map(\.id), missCoast: predictOnly)
        boxKalmanV = MatchMath.leftoverHoldKalmanKeep(kalman: boxKalmanV, live: adopted.map(\.id), missCoast: predictOnly)
        boxKalmanWHV = MatchMath.leftoverHoldKalmanKeep(kalman: boxKalmanWHV, live: adopted.map(\.id), missCoast: predictOnly)
        let keepIds = Set(remintLive.map(\.id)).union(Set(identities.map(\.id)))
        let holdIds = MatchMath.leftoverUUIDUUIDMapDropHold(
            hold: Set(leftoverHold.keys),
            ghosts: ghostIds,
            missKeys: missCoast ? Array(leftoverPairCommit.keys) + Array(leftoverPairLast.keys) : [],
            commitMiss: leftoverPairCommitMiss
        )
        leftoverPairLast = MatchMath.leftoverUUIDUUIDMapDropDangling(leftoverPairLast, keep: keepIds, hold: holdIds)
        leftoverPairCommit = MatchMath.leftoverUUIDUUIDMapDropDangling(leftoverPairCommit, keep: keepIds, hold: holdIds)
        leftoverHoldTrail = leftoverHoldTrail.mapValues { MatchMath.leftoverHoldTrailCap($0) }
        let holdBefore = leftoverHold.count
        let adoptLive = adopted.map {
            (id: $0.id, x: $0.box.x, y: $0.box.y, w: $0.box.width, h: $0.box.height)
        }
        let adoptStored = MatchMath.leftoverOverlayPeakStoredBoxes(
            streak: leftoverStreakBox.map {
                (id: $0.key, x: $0.value.x, y: $0.value.y, w: $0.value.width, h: $0.value.height)
            },
            kalman: boxKalman.map {
                (id: $0.key, x: $0.value.x, y: $0.value.y, w: $0.value.w, h: $0.value.h)
            }
        )
        let adoptFloor = MatchMath.leftoverOverlayPeakIoUFloorBoxes(
            live: adoptLive.map { (w: $0.w, h: $0.h) },
            dt: liveDt
        )
        let namedAdopt = MatchMath.leftoverNameLockHeldIoUAdopt(
            held: leftoverNameLockHeld,
            until: leftoverNameLockUntil,
            live: adoptLive,
            stored: adoptStored,
            floor: adoptFloor
        )
        leftoverNameLockHeld = namedAdopt.held
        leftoverNameLockUntil = namedAdopt.until
        let lockedIds = MatchMath.leftoverNameLockLive(until: leftoverNameLockUntil, now: now)
        leftoverNameLockUntil = leftoverNameLockUntil.filter { lockedIds.contains($0.key) }
        leftoverNameLockHeld = MatchMath.leftoverNameLockHeldCoast(
            held: leftoverNameLockHeld,
            live: liveIds + adopted.map(\.id),
            locked: lockedIds,
            ghosts: ghostIds
        )
        leftoverNameLockUntil = MatchMath.leftoverNameLockUntilFillHeld(
            held: leftoverNameLockHeld,
            until: leftoverNameLockUntil,
            now: now,
            arm: MatchMath.leftoverNameLockSec
        )
        do {
            let peakNeed = MatchMath.leftoverPeakHoldNeed(dt: liveDt)
            let peakBoxes = MatchMath.leftoverOverlayPeakIoUAdopt(
                held: leftoverOverlayPeakHeld,
                remain: leftoverOverlayPeakRemain,
                live: adoptLive,
                stored: adoptStored,
                floor: adoptFloor,
                need: peakNeed
            )
            leftoverOverlayPeakHeld = peakBoxes.held
            leftoverOverlayPeakRemain = peakBoxes.remain
            let peakLive = Array(Set(liveIds + adopted.map(\.id) + ghostIds))
            let guests = Dictionary(uniqueKeysWithValues: peakLive.map { ($0, leftoverOverlayGuestRaw(for: $0)) })
            let advanced = MatchMath.leftoverOverlayPeakAdvance(
                guest: guests,
                held: leftoverOverlayPeakHeld,
                remain: leftoverOverlayPeakRemain,
                live: peakLive,
                need: peakNeed
            )
            leftoverOverlayPeakHeld = advanced.held
            leftoverOverlayPeakRemain = advanced.remain
        }
        leftoverHold = MatchMath.leftoverHoldSurvive(hold: leftoverHold, ghosts: ghostIds, live: liveIds + adopted.map(\.id), emptyKeeps: MatchMath.leftoverEmptyKeepsStreak(liveEmpty: emptyLike) && emptyLatch, emptyFor: emptyFor, locked: lockedIds, missCoast: missCoast)
        leftoverHoldBins = MatchMath.leftoverHoldSurviveBins(hold: leftoverHoldBins, ghosts: ghostIds, live: liveIds + adopted.map(\.id), emptyKeeps: MatchMath.leftoverEmptyKeepsStreak(liveEmpty: emptyLike) && emptyLatch, emptyFor: emptyFor, locked: lockedIds, missCoast: missCoast)
        leftoverHoldTrail = MatchMath.leftoverHoldSurvive(hold: leftoverHoldTrail, ghosts: ghostIds, live: liveIds + adopted.map(\.id), emptyKeeps: MatchMath.leftoverEmptyKeepsStreak(liveEmpty: emptyLike) && emptyLatch, emptyFor: emptyFor, locked: lockedIds, missCoast: missCoast)
        leftoverHoldTrailBins = MatchMath.leftoverHoldSurviveBinMap(hold: leftoverHoldTrailBins, ghosts: ghostIds, live: liveIds + adopted.map(\.id), emptyKeeps: MatchMath.leftoverEmptyKeepsStreak(liveEmpty: emptyLike) && emptyLatch, emptyFor: emptyFor, locked: lockedIds, missCoast: missCoast)
        liveSlotHold = MatchMath.leftoverHoldSurvive(hold: liveSlotHold, ghosts: ghostIds, live: liveIds + adopted.map(\.id), emptyKeeps: MatchMath.leftoverEmptyKeepsStreak(liveEmpty: emptyLike) && emptyLatch, emptyFor: emptyFor, locked: lockedIds, missCoast: missCoast)
        leftoverMissFrames = MatchMath.leftoverHoldSurvive(hold: leftoverMissFrames, ghosts: ghostIds, live: liveIds + adopted.map(\.id), emptyKeeps: MatchMath.leftoverEmptyKeepsStreak(liveEmpty: emptyLike) && emptyLatch, emptyFor: emptyFor, locked: lockedIds, missCoast: missCoast)
        let keepBoxes = MatchMath.leftoverKeepBoxes(
            used: used,
            dropped: dropped,
            ghosts: ghostIds,
            hold: MatchMath.leftoverKeepHoldIds(
                hold: Array(leftoverHold.keys),
                bins: MatchMath.leftoverHoldIds(leftoverHoldBins)
            ),
            missCoast: missCoast,
            kalman: Array(boxKalman.keys),
            predictOnly: predictOnly
        )
        boxEuro = boxEuro.filter { keepBoxes.contains($0.key) }
        boxKalman = boxKalman.filter { keepBoxes.contains($0.key) }
        boxKalmanV = boxKalmanV.filter { keepBoxes.contains($0.key) }
        boxKalmanWHV = boxKalmanWHV.filter { keepBoxes.contains($0.key) }
        boxJumpPending = boxJumpPending.filter { keepBoxes.contains($0.key) }
        livePrintTrail = livePrintTrail.filter { keepBoxes.contains($0.key) }
        livePrintTrailSlot = livePrintTrailSlot.filter { keepBoxes.contains($0.key) }
        liveStillFor = liveStillFor.filter { keepBoxes.contains($0.key) }
        livePrintDrift = livePrintDrift.filter { keepBoxes.contains($0.key) }
        liveExposureUntil = liveExposureUntil.filter { keepBoxes.contains($0.key) }
        liveCaptureHist = liveCaptureHist.filter { keepBoxes.contains($0.key) }
        livePosterJitter = livePosterJitter.filter { keepBoxes.contains($0.key) }
        livePosterStill = livePosterStill.filter { keepBoxes.contains($0.key) }
        liveLandmarkPrev = liveLandmarkPrev.filter { keepBoxes.contains($0.key) }
        liveLidClosed = liveLidClosed.filter { keepBoxes.contains($0.key) }
        liveBlinkSeen = liveBlinkSeen.filter { keepBoxes.contains($0.key) }
        liveOpenStreak = liveOpenStreak.filter { keepBoxes.contains($0.key) }
        leftoverStreakBox = MatchMath.leftoverStreakBoxLive(
            boxes: leftoverStreakBox,
            live: adopted.map { (id: $0.id, box: $0.box) },
            holdIds: Set(leftoverHold.keys)
        )
        leftoverHoldByHash = MatchMath.leftoverHoldPrune(
            leftoverHoldByHash,
            now: now,
            ttl: leftoverHoldTTL,
            skip: MatchMath.leftoverHoldPruneSkips(rebased: leftoverHashRebasedTick)
        )
        leftoverHoldTrailByHash = MatchMath.leftoverTrailPrune(
            leftoverHoldTrailByHash,
            now: now,
            ttl: leftoverHoldTTL,
            skip: MatchMath.leftoverHoldPruneSkips(rebased: leftoverHashRebasedTick)
        )
        if let line = MatchMath.leftoverHoldPruneLine(
            before: holdBefore,
            after: leftoverHold.count,
            liveEmpty: liveIds.isEmpty
        ) {
            status = line
        }
        if MatchMath.leftoverPredictOnMissCoast(missCoast) || (MatchMath.leftoverPredictOnEmptyLike(emptyLike) && emptyLatch) {
            leftoverPredictHeld(keep: keepBoxes, skip: used, miss: leftoverMissCoastTicks)
        }
        if found.isEmpty {
            if MatchMath.leftoverLiveHashTickWipes(empty: true, missCoast: missCoast) {
                leftoverLiveHashTick = [:]
            }
            if MatchMath.leftoverLastHashWipes(empty: true, overlayKeep: emptyChip, missCoast: missCoast) {
                leftoverLastHash = [:]
            }
            if MatchMath.leftoverEmptyWipesOverlay(emptyChip: emptyChip, missCoast: missCoast) {
                liveHeldIds = []
                leftoverPending = [:]
            }
            if MatchMath.leftoverEmptyWipesMaps(emptyLatch: emptyLatch, missCoast: missCoast) {
                leftoverStreak = [:]
                leftoverStreakBox = [:]
                leftoverStreakSince = [:]
                leftoverMissFrames = [:]
                leftoverPairLast = [:]
                leftoverPairStreak = [:]
                leftoverPairCommit = [:]
                leftoverPairCommitMiss = [:]
                leftoverDisagree = [:]
                leftoverWipeUntil = [:]
                boxKalman = [:]
                boxKalmanV = [:]
                boxKalmanWHV = [:]
                liveStillFor = [:]
                liveExposureUntil = [:]
                livePosterJitter = [:]
                livePosterStill = [:]
                liveLandmarkPrev = [:]
                liveLidClosed = [:]
                liveBlinkSeen = [:]
                liveOpenStreak = [:]
            }
            guestOrder = guestOrder.filter {
                MatchMath.guestOrderKeeps(id: $0, live: [], lastSeen: guestSeenAt[$0], now: now)
            }
            guestSeenAt = guestSeenAt.filter { guestOrder.contains($0.key) }
            if MatchMath.leftoverEmptyWipesOverlay(emptyChip: emptyChip, missCoast: missCoast) {
                faces.removeAll { $0.mediaId == mediaId }
                if let label = MatchMath.headCountFlashLabel(prev: lastLiveHeadCount, next: 0) {
                    lastHeadCountLabel = label
                    headCountFlashUntil = now + MatchMath.headCountFlashHold
                }
                lastLiveHeadCount = 0
            }
        } else {
            let ghostFaces = liveGhosts.map(\.face).filter { $0.mediaId == mediaId }
            let leftoverPool: [FaceObservation] = {
                var seen = Set<UUID>()
                var out: [FaceObservation] = []
                for f in previous + ghostFaces where seen.insert(f.id).inserted {
                    out.append(f)
                }
                return out
            }()
            let leftoverNamed = Set(leftoverPool.compactMap { old -> UUID? in
                if namedTracks.contains(old.id) { return old.id }
                let hit = matches.first { $0.faceId == old.id }?.hits.first { $0.strategy == .aegis }
                return hit?.identityId != nil ? old.id : nil
            })
            let leftoverPinned = leftoverPool.filter {
                MatchMath.leftoverNamedTrack(hadName: leftoverNamed.contains($0.id)) && !used.contains($0.id)
            }
            var leftoverItems: [(old: FaceObservation, bestCos: Double?, cands: [(index: Int, iou: Double, cosine: Double?)])] = []
            leftoverItems.reserveCapacity(leftoverPinned.count)
            leftoverLiveHashTick = [:]
            leftoverMissCoastTicks = 0
            var rawLiveHash: [UUID: String] = [:]
            var liveXs: [UUID: Double] = [:]
            for face in adopted {
                rawLiveHash[face.id] = leftoverLiveHash(
                    kalmanX: boxKalman[face.id]?.x,
                    kalmanY: boxKalman[face.id]?.y,
                    kalmanW: boxKalman[face.id]?.w,
                    kalmanH: boxKalman[face.id]?.h,
                    fallback: face.box,
                    image: image
                )
                liveXs[face.id] = boxKalman[face.id]?.x ?? face.box.x
            }
            for face in adopted {
                let hash = rawLiveHash[face.id] ?? ""
                let rows: [(hash: String, x: Double, yaw: Double)] = rawLiveHash.compactMap { key, value in
                    if key == face.id { return nil }
                    return (
                        hash: value,
                        x: liveXs[key] ?? 0,
                        yaw: liveYaw[key] ?? adopted.first(where: { $0.id == key })?.quality.yaw ?? 0
                    )
                }
                leftoverLiveHashTick[face.id] = MatchMath.leftoverHashTwinRanked(
                    hash: hash,
                    x: liveXs[face.id] ?? 0,
                    others: rows.map { (hash: $0.hash, x: $0.x) },
                    yawAbs: liveYaw[face.id] ?? face.quality.yaw,
                    otherYaws: rows.map(\.yaw)
                )
                let ranked = leftoverLiveHashTick[face.id] ?? ""
                if !face.featurePrint.isEmpty {
                    leftoverPrintCache = MatchMath.leftoverPrintCachePut(
                        cached: leftoverPrintCache,
                        hash: ranked,
                        yaw: face.quality.yaw,
                        cam: cameraUniqueID
                    )
                    yawCoverageChip = MatchMath.printYawCoverageChip(
                        MatchMath.printYawCoverageBest(cached: Set(leftoverPrintCache))
                    )
                    let liveHashes = adopted.compactMap {
                        leftoverLiveHashTick[$0.id] ?? leftoverLastHash[$0.id]
                    }
                    var bins = MatchMath.enrollSMCacheBins(cache: Set(leftoverPrintCache), liveHashes: liveHashes)
                    for face in adopted {
                        let slots = MatchMath.leftoverEnrollSlotHave(
                            yaw: face.quality.yaw,
                            haveFrontal: bins.contains(0),
                            haveLeft: bins.contains(-1),
                            haveRight: bins.contains(1),
                            haveProfile: bins.contains(-2) || bins.contains(2)
                        )
                        if slots.frontal { bins.insert(0) }
                        if slots.left { bins.insert(-1) }
                        if slots.right { bins.insert(1) }
                        if slots.profile { bins.insert(face.quality.yaw < 0 ? -2 : 2) }
                    }
                    let blink = adopted.contains { leftoverBlinkSeen(faceId: $0.id) }
                    enrollSMChip = MatchMath.enrollSMFromBins(bins, haveBlink: blink)
                    if let pose = adopted.first {
                        enrollYawChip = MatchMath.enrollYawCompass(yaw: pose.quality.yaw)
                    }
                    let capQ = adopted.map(\.quality.capture).max() ?? 0
                    let sharpQ = adopted.map(\.quality.sharpness).max() ?? 0
                    enrollQualityChip = MatchMath.enrollQualityMeter(
                        capture: capQ,
                        sharpness: sharpQ,
                        yawCoverage: MatchMath.printYawCoverageBest(cached: Set(leftoverPrintCache))
                    )
                    captureSparkChip = MatchMath.captureQualitySpark(capQ)
                }
                let from = leftoverLastHash[face.id]
                if let from, !ranked.isEmpty, from != ranked {
                    leftoverHoldByHash = MatchMath.leftoverStringMapMove(hold: leftoverHoldByHash, from: from, to: ranked)
                    leftoverHoldTrailByHash = MatchMath.leftoverStringMapMove(hold: leftoverHoldTrailByHash, from: from, to: ranked)
                    leftoverCaptureHistByHash = MatchMath.leftoverCaptureHistTableMove(
                        table: leftoverCaptureHistByHash, from: from, to: ranked
                    )
                    leftoverCaptureHistAt = MatchMath.leftoverStringMapMove(
                        hold: leftoverCaptureHistAt, from: from, to: ranked
                    )
                }
            }
            for old in leftoverPinned {
                var cands: [(index: Int, iou: Double, cosine: Double?)] = []
                let ov = old.printVec.count >= 32 ? old.printVec : FaceEngine.embedding(of: old)
                let cachedPrintRaw = MatchMath.leftoverHoldRemintLookup(
                    hold: leftoverCoastPrint, id: old.id, remap: remintPlan
                ) ?? leftoverCoastPrint[old.id] ?? []
                let cachedStamp = MatchMath.leftoverHoldRemintLookup(
                    hold: leftoverCoastPrintAt, id: old.id, remap: remintPlan
                ) ?? leftoverCoastPrintAt[old.id]
                let cachedPrint = MatchMath.leftoverCoastPrintFresh(
                    vec: cachedPrintRaw, stamped: cachedStamp, now: now
                )
                let storedHold = MatchMath.leftoverHoldRemintLookup(
                    hold: leftoverHold, id: old.id, remap: remintPlan
                )
                let oldKal = MatchMath.leftoverHoldRemintLookup(
                    hold: boxKalman, id: old.id, remap: remintPlan
                )
                let holdViaLookup = MatchMath.leftoverHoldViaLookup(
                    hold: leftoverHold, id: old.id, remap: remintPlan
                )
                for (j, face) in adopted.enumerated() {
                    guard MatchMath.leftoverAdoptAllowed(
                        adoptedEnrolled: namedTracks.contains(face.id) || enrolled.contains(face.id)
                    ) else { continue }
                    guard !used.contains(face.id) else { continue }
                    let o = FaceEngine.iou(
                        MatchMath.leftoverStreakBoxWrite(
                            kalmanX: oldKal?.x,
                            kalmanY: oldKal?.y,
                            kalmanW: oldKal?.w,
                            kalmanH: oldKal?.h,
                            fallback: old.box
                        ),
                        MatchMath.leftoverStreakBoxWrite(
                            kalmanX: boxKalman[face.id]?.x,
                            kalmanY: boxKalman[face.id]?.y,
                            kalmanW: boxKalman[face.id]?.w,
                            kalmanH: boxKalman[face.id]?.h,
                            fallback: face.box
                        )
                    )
                    let v = FaceEngine.embedding(of: face)
                    let liveCos = MatchMath.leftoverCoastPrintSkipCosine(
                        live: v,
                        liveStored: MatchMath.leftoverCoastPrintFresh(
                            vec: leftoverCoastPrint[face.id] ?? [],
                            stamped: leftoverCoastPrintAt[face.id],
                            now: now
                        ),
                        old: ov,
                        oldStored: cachedPrint
                    )
                    let cosine = MatchMath.leftoverCoastCosineMeasured(
                        skipCosine: liveCos,
                        skipDetect: skipDetect,
                        skipPrints: skipPrints,
                        live: nil,
                        stored: storedHold,
                        livePrintEmpty: face.featurePrint.isEmpty && face.printVec.count < 32,
                        holdViaLookup: holdViaLookup
                    )
                    cands.append((j, o, cosine))
                }
                leftoverItems.append((old, cands.compactMap(\.cosine).max(), cands))
            }
            let order = MatchMath.leftoverRank(leftoverItems.map { ($0.old.id, $0.bestCos) })
            var leftoverPins = 0
            for id in order {
                guard let item = leftoverItems.first(where: { $0.old.id == id }) else { continue }
                var remaining = item.cands.filter { cand in
                    let face = adopted[cand.index]
                    return MatchMath.leftoverAdoptAllowed(
                        adoptedEnrolled: namedTracks.contains(face.id) || enrolled.contains(face.id)
                    ) && !used.contains(face.id)
                }
                let leftoverHeldName = leftoverStoreName(for: item.old.id)
                    ?? leftoverNameLockHeld[item.old.id]
                    ?? identities.first(where: { $0.faceIds.contains(item.old.id) })?.name
                var sharp: [Int: Double] = [:]
                var sameSlot: [Int: Bool] = [:]
                var yawAbs: [Int: Double] = [:]
                var aspectOk: [Int: Bool] = [:]
                var detScore: [Int: Double] = [:]
                var boxX: [Int: Double] = [:]
                let old = item.old
                if leftoverTried.contains(old.id) { continue }
                let oldRaw = FaceEngine.poseSlot(old).rawValue
                let oldHeld = liveSlotHold[old.id]
                let oldSticky = MatchMath.poseSlotSticky(prev: oldHeld?.slot ?? oldRaw, raw: oldRaw, hold: oldHeld?.n ?? 0)
                liveSlotHold[old.id] = (slot: oldSticky.slot, n: oldSticky.hold)
                for cand in remaining {
                    sharp[cand.index] = adopted[cand.index].quality.sharpness
                    yawAbs[cand.index] = adopted[cand.index].quality.yaw
                    detScore[cand.index] = adopted[cand.index].score
                    boxX[cand.index] = adopted[cand.index].box.x
                    let box = adopted[cand.index].box
                    aspectOk[cand.index] = MatchMath.boxAspectFrontal(width: box.width, height: box.height)
                    let raw = FaceEngine.poseSlot(adopted[cand.index]).rawValue
                    let held = liveSlotHold[adopted[cand.index].id]
                    let sticky = MatchMath.poseSlotSticky(prev: held?.slot ?? oldSticky.slot, raw: raw, hold: held?.n ?? 0)
                    liveSlotHold[adopted[cand.index].id] = (slot: sticky.slot, n: sticky.hold)
                    sameSlot[cand.index] = sticky.slot == oldSticky.slot
                }
                var liveIds: [Int: UUID] = [:]
                var candNames: [Int: String] = [:]
                for cand in remaining {
                    if let id = matches.first(where: { $0.faceId == adopted[cand.index].id })?
                        .hits.first(where: { $0.strategy == .aegis })?.identityId
                    {
                        liveIds[cand.index] = id
                        if let n = identities.first(where: { $0.id == id })?.name { candNames[cand.index] = n }
                    }
                    if candNames[cand.index] == nil {
                        candNames[cand.index] = leftoverStoreName(for: adopted[cand.index].id)
                            ?? leftoverNameLockHeld[adopted[cand.index].id]
                    }
                }
                let keepIdx = Set(MatchMath.twinSplitCull(
                    remaining: remaining.map { (index: $0.index, name: candNames[$0.index] ?? "") },
                    leftoverName: leftoverHeldName,
                    splits: twinSplits
                ))
                remaining = remaining.filter { keepIdx.contains($0.index) }
                let aegisHit = matches.first { $0.faceId == old.id }?.hits.first { $0.strategy == .aegis }
                let liveYaw = remaining.max(by: { $0.iou < $1.iou }).flatMap { yawAbs[$0.index] }
                let lookYaw = MatchMath.leftoverLookawayYawOf(oldYaw: old.quality.yaw, liveYaw: liveYaw)
                let lookEnrolled = namedTracks.contains(old.id) || enrolled.contains(old.id)
                if MatchMath.leftoverLookawayHolds(yawAbs: lookYaw, enrolled: lookEnrolled) {
                    leftoverPins += 1
                    let ghostUntil = liveGhosts.first(where: { $0.face.id == old.id })?.until
                    let weg = MatchMath.leftoverLookawayLabel(until: ghostUntil, now: now)
                    if let pinJ = MatchMath.leftoverLookawayPin(candidates: remaining) {
                        leftoverPending[adopted[pinJ].id] = weg
                        if MatchMath.leftoverTriedInserts(unsure: false, lookaway: true) {
                            leftoverTried.insert(old.id)
                        }
                    } else if let best = remaining.max(by: { $0.iou < $1.iou }),
                              !MatchMath.leftoverLookawayPinsStranger(iou: best.iou)
                    {
                        leftoverPending[adopted[best.index].id] = weg
                        if MatchMath.leftoverTriedInserts(unsure: false, lookaway: true) {
                            leftoverTried.insert(old.id)
                        }
                    }
                    // leftoverHoldSkipLookaway: EMA nicht mit Profil überschreiben. continue hält den Wert.
                    // leftoverHold[id] ist Frontal. ¾-Lookup nicht in die unbinned EMA.
                    if leftoverHold[old.id] == nil,
                       MatchMath.leftoverHoldBin(yawAbs: lookYaw ?? old.quality.yaw) == 0,
                       !MatchMath.leftoverHoldSkipLookaway(enrolled: lookEnrolled, yawAbs: lookYaw)
                    {
                        leftoverHold[old.id] = MatchMath.leftoverHoldLookupYaw(
                            hash: leftoverRankedHash(
                                id: old.id,
                                fallback: leftoverLiveHash(
                                    kalmanX: boxKalman[old.id]?.x,
                                    kalmanY: boxKalman[old.id]?.y,
                                    kalmanW: boxKalman[old.id]?.w,
                                    kalmanH: boxKalman[old.id]?.h,
                                    fallback: old.box,
                                    image: image
                                )
                            ),
                            table: leftoverHoldByHash,
                            now: now,
                            ttl: leftoverHoldTTL,
                            yawAbs: lookYaw ?? old.quality.yaw,
                            facesInFrame: adopted.count,
                            occupied: leftoverOccupiedHashes(except: old.id)
                        )
                    }
                    continue
                }
                let skipCosineBest = remaining.compactMap(\.cosine).max()
                let holdUnsure = MatchMath.leftoverHoldLookupUnsure(
                    skipCosine: skipCosineBest, holdViaLookup: holdViaLookup
                )
                let iouOnly = MatchMath.leftoverDetectSkipIoUOnly(
                    skipCosine: skipCosineBest,
                    skipDetect: skipDetect,
                    skipPrints: skipPrints,
                    holdViaLookup: holdViaLookup
                )
                guard let bestJ = MatchMath.leftoverPick(
                    candidates: remaining,
                    sharpness: sharp,
                    sameSlot: sameSlot,
                    yawAbs: yawAbs,
                    aspectOk: aspectOk,
                    twinPair: {
                        if adopted.count >= 2 {
                            let vecs: [[Double]] = adopted.compactMap { f in
                                let v = MatchMath.leftoverCoastPrintVecOf(
                                    live: f.printVec,
                                    stored: leftoverCoastPrint[f.id] ?? []
                                )
                                return v.count >= 32 ? v : nil
                            }
                            if vecs.count >= 2 {
                                var best: Double?
                                for i in vecs.indices {
                                    for j in vecs.indices where j > i {
                                        if let c = MatchMath.leftoverCoastPrintCosine(live: vecs[i], stored: vecs[j]) {
                                            best = max(best ?? c, c)
                                        }
                                    }
                                }
                                if let best { return best }
                            }
                        }
                        return aegisHit?.pairCosine
                    }(),
                    holdPrev: storedHold,
                    liveIds: liveIds,
                    leftoverId: old.id,
                    printId: aegisHit?.identityId,
                    geoMix: aegisHit?.geoMix,
                    dt: liveDt,
                    lookawayEnrolled: namedTracks.contains(old.id) || enrolled.contains(old.id),
                    lookawayYaw: lookYaw,
                    facesInFrame: adopted.count,
                    detScore: detScore,
                    boxX: boxX,
                    leftoverX: old.box.x,
                    otherX: adopted.filter { $0.id != old.id }.map { $0.box.x },
                    sessionCapture: MatchMath.leftoverSessionCapture(
                        old: old.quality.capture,
                        live: remaining.map { adopted[$0.index].quality.capture }
                    ),
                    capture: Dictionary(uniqueKeysWithValues: remaining.map {
                        ($0.index, adopted[$0.index].quality.capture)
                    }),
                    imageW: Double(image.width),
                    captureHist: liveCaptureHist[old.id] ?? [],
                    captureBoxHist: Dictionary(uniqueKeysWithValues: remaining.map {
                        ($0.index, liveCaptureHist[adopted[$0.index].id] ?? [])
                    }),
                    holdBins: leftoverHoldBins,
                    holdHash: leftoverRankedHash(
                        id: old.id,
                        fallback: leftoverLiveHash(
                            kalmanX: boxKalman[old.id]?.x,
                            kalmanY: boxKalman[old.id]?.y,
                            kalmanW: boxKalman[old.id]?.w,
                            kalmanH: boxKalman[old.id]?.h,
                            fallback: old.box,
                            image: image
                        )
                    ),
                    holdHashTable: leftoverHoldByHash,
                    holdAt: now,
                    holdTTL: leftoverHoldTTL,
                    frameCapture: liveFrameCapture,
                    holdOccupied: leftoverOccupiedHashes(except: old.id),
                    holdOnlyUnsure: holdUnsure,
                    gallery: identities.count,
                    iouOnly: iouOnly,
                    holdTrail: leftoverHoldTrail[old.id] ?? [],
                    holdBinTrail: leftoverHoldTrailBins[MatchMath.leftoverHoldKey(
                        id: old.id,
                        bin: MatchMath.leftoverHoldBinSigned(yaw: old.quality.yaw)
                    )] ?? [],
                    probeMasked: FaceEngine.lowerFaceOccluded(old),
                    refMasked: Dictionary(uniqueKeysWithValues: remaining.map {
                        ($0.index, FaceEngine.lowerFaceOccluded(adopted[$0.index]))
                    }),
                    twinSplits: twinSplits,
                    leftoverName: leftoverHeldName,
                    candNames: candNames
                ) else {
                    let openUnsure = MatchMath.leftoverOpenSetUnsure(
                        scores: remaining.compactMap(\.cosine)
                    )
                    if holdUnsure || openUnsure {
                        if holdUnsure, let best = remaining.max(by: { $0.iou < $1.iou }) {
                            leftoverPending[adopted[best.index].id] = MatchMath.leftoverHoldLookupUnsureNote()
                        }
                        let ticks = MatchMath.leftoverUnsureStreakAdvance(
                            prev: MatchMath.leftoverHoldRemintLookup(
                                hold: leftoverUnsureTicks, id: old.id, remap: remintPlan
                            ) ?? leftoverUnsureTicks[old.id] ?? 0,
                            unsure: true
                        )
                        leftoverUnsureTicks[old.id] = ticks
                        if let live = remintPlan[old.id], live != old.id {
                            leftoverUnsureTicks[live] = ticks
                        }
                        if MatchMath.leftoverTriedInserts(unsure: true) {
                            leftoverTried.insert(old.id)
                        }
                        if MatchMath.leftoverPinCounts(unsure: true) {
                            leftoverPins += 1
                        }
                        if MatchMath.leftoverUnsureStreakClears(ticks: ticks) {
                            leftoverClearStreak(old.id)
                            if let live = remintPlan[old.id], live != old.id {
                                leftoverClearStreak(live)
                            }
                            leftoverUnsureTicks[old.id] = 0
                            if let live = remintPlan[old.id] { leftoverUnsureTicks[live] = 0 }
                        }
                        continue
                    }
                    let twin = aegisHit?.pairCosine
                    if let twinLabel = MatchMath.leftoverTwinPairLabel(pairCosine: twin) {
                        for cand in remaining {
                            leftoverPending[adopted[cand.index].id] = twinLabel
                        }
                        if !MatchMath.leftoverTwinKeepsStreak(pairCosine: twin) {
                            leftoverClearStreak(old.id)
                        }
                    } else if remaining.contains(where: { MatchMath.leftoverUnknownKeepsStreak(cosine: $0.cosine) }) {
                        for cand in remaining where MatchMath.leftoverUnknownHard(cosine: cand.cosine) {
                            leftoverPending[adopted[cand.index].id] = MatchMath.leftoverUnknownNote()
                        }
                        leftoverPins += 1
                    } else {
                        let miss = MatchMath.leftoverMissAdvance(prev: leftoverMissFrames[old.id] ?? 0, hit: false)
                        leftoverMissFrames[old.id] = miss
                        leftoverCoastAt[old.id] = MatchMath.leftoverCoastAtStamp(
                            prev: MatchMath.leftoverHoldRemintLookup(
                                hold: leftoverCoastAt, id: old.id, remap: remintPlan
                            ) ?? leftoverCoastAt[old.id],
                            miss: miss,
                            now: liveLastStamp
                        )
                        if MatchMath.conflictTickAgrees(
                            boxId: nil,
                            printId: aegisHit?.identityId,
                            geoId: nil,
                            lockId: liveIds.values.first,
                            geoMix: aegisHit?.geoMix
                        ) == false {
                            for cand in remaining {
                                guard !MatchMath.leftoverYieldsToLive(liveId: liveIds[cand.index], leftoverId: old.id) else {
                                    continue
                                }
                                leftoverPending[adopted[cand.index].id] = MatchMath.conflictTickNote()
                            }
                        }
                        if MatchMath.leftoverMissClears(
                            miss: miss,
                            coastAt: leftoverCoastAt[old.id],
                            now: liveLastStamp
                        ) {
                            leftoverClearStreak(old.id)
                        }
                    }
                    continue
                }
                leftoverTried.insert(old.id)
                leftoverUnsureTicks[old.id] = 0
                if let live = remintPlan[old.id] { leftoverUnsureTicks[live] = 0 }
                leftoverMissFrames[old.id] = MatchMath.leftoverMissAdvance(prev: leftoverMissFrames[old.id] ?? 0, hit: true)
                leftoverCoastAt[old.id] = MatchMath.leftoverCoastAtStamp(
                    prev: leftoverCoastAt[old.id],
                    miss: leftoverMissFrames[old.id] ?? 0,
                    now: liveLastStamp
                )
                let boxHash = leftoverLiveHash(
                    kalmanX: boxKalman[adopted[bestJ].id]?.x,
                    kalmanY: boxKalman[adopted[bestJ].id]?.y,
                    kalmanW: boxKalman[adopted[bestJ].id]?.w,
                    kalmanH: boxKalman[adopted[bestJ].id]?.h,
                    fallback: adopted[bestJ].box,
                    image: image
                )
                let holdHash = leftoverRankedHash(
                    id: adopted[bestJ].id,
                    fallback: leftoverRankedHash(id: old.id, fallback: boxHash)
                )
                let holdPrev = MatchMath.leftoverHoldPrevOf(
                    frontal: storedHold,
                    yawAbs: adopted[bestJ].quality.yaw,
                    bins: leftoverHoldBins,
                    id: old.id,
                    hash: holdHash,
                    hashTable: leftoverHoldByHash,
                    now: now,
                    ttl: leftoverHoldTTL,
                    facesInFrame: adopted.count,
                    occupied: leftoverOccupiedHashes(except: old.id)
                )
                let step = leftoverAdvance(oldId: old.id, box: adopted[bestJ].box, now: now, holdPrev: holdPrev, boxId: adopted[bestJ].id, dt: liveDt, yawAbs: adopted[bestJ].quality.yaw)
                if let label = step.label {
                    leftoverPending[adopted[bestJ].id] = label
                }
                guard step.ready else { continue }
                if let cos = remaining.first(where: { $0.index == bestJ })?.cosine {
                    leftoverLastHash[adopted[bestJ].id] = MatchMath.leftoverLastHashKeeps(
                        prev: leftoverLastHash[adopted[bestJ].id] ?? leftoverLastHash[old.id],
                        next: holdHash
                    )
                    leftoverLastHash[old.id] = leftoverLastHash[adopted[bestJ].id]
                    if liveCaptureHist[adopted[bestJ].id] == nil,
                       let kept = MatchMath.leftoverCaptureHistLookup(
                        hash: holdHash,
                        fallback: boxHash,
                        table: leftoverCaptureHistByHash
                       )
                    {
                        liveCaptureHist[adopted[bestJ].id] = kept
                    }
                    let yawNow = adopted[bestJ].quality.yaw
                    let bin = MatchMath.leftoverHoldBinSigned(yaw: yawNow)
                    var trail = MatchMath.leftoverTrailNowOf(
                        idTrail: leftoverHoldTrail[old.id] ?? [],
                        binTrail: MatchMath.leftoverTrailLookup(
                            hash: holdHash,
                            table: leftoverHoldTrailByHash,
                            now: now,
                            ttl: leftoverHoldTTL,
                            bin: bin,
                            facesInFrame: adopted.count,
                            occupied: leftoverOccupiedHashes(except: old.id)
                        ),
                        yawAbs: yawNow
                    )
                    if MatchMath.leftoverTrailWriteOk(
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: yawNow
                    ) {
                        leftoverHoldTrailByHash = MatchMath.leftoverTrailPut(
                            hash: holdHash,
                            sample: cos,
                            onto: leftoverHoldTrailByHash,
                            now: now,
                            sharpness: adopted[bestJ].quality.sharpness,
                            yawAbs: yawNow,
                            bin: bin,
                            ttl: leftoverHoldTTL
                        )
                        if bin == 0 {
                            trail = MatchMath.leftoverHoldTrailEMA(leftoverHoldTrail[old.id] ?? trail, sample: cos)
                            leftoverHoldTrail[old.id] = trail
                        } else {
                            let key = MatchMath.leftoverHoldKey(id: old.id, bin: bin)
                            leftoverHoldTrailBins[key] = MatchMath.leftoverHoldTrailEMA(
                                leftoverHoldTrailBins[key] ?? [], sample: cos
                            )
                            trail = leftoverHoldTrailBins[key] ?? MatchMath.leftoverTrailLookup(
                                hash: holdHash,
                                table: leftoverHoldTrailByHash,
                                now: now,
                                ttl: leftoverHoldTTL,
                                bin: bin,
                                facesInFrame: adopted.count,
                                occupied: leftoverOccupiedHashes(except: old.id)
                            )
                        }
                    }
                    if MatchMath.printMADBlocks(trail) {
                        leftoverPending[adopted[bestJ].id] = MatchMath.printMADNote()
                        continue
                    }
                    if let med = MatchMath.printCommitMedian(trail),
                       MatchMath.unknownCentroid(bestCosine: med)
                    {
                        leftoverPending[adopted[bestJ].id] = "MED"
                        continue
                    }
                }
                if MatchMath.posterFaceReject(
                    jitter: livePosterJitter[old.id] ?? 1,
                    frames: livePosterStill[old.id] ?? 0
                ) {
                    leftoverPending[adopted[bestJ].id] = "POSTER"
                    continue
                }
                if MatchMath.posterNeedsBlink(
                    stillFrames: livePosterStill[old.id] ?? 0,
                    blinked: liveBlinkSeen[old.id] ?? false
                ) {
                    leftoverPending[adopted[bestJ].id] = MatchMath.posterBlinkNote()
                    continue
                }
                leftoverPending.removeValue(forKey: adopted[bestJ].id)
                let pinCos = remaining.first(where: { $0.index == bestJ })?.cosine ?? item.bestCos
                let holdNow = MatchMath.leftoverHoldPrevOf(
                    frontal: storedHold,
                    yawAbs: adopted[bestJ].quality.yaw,
                    bins: leftoverHoldBins,
                    id: old.id,
                    hash: holdHash,
                    hashTable: leftoverHoldByHash,
                    now: now,
                    ttl: leftoverHoldTTL,
                    facesInFrame: adopted.count,
                    occupied: leftoverOccupiedHashes(except: old.id)
                )
                let trailNow = MatchMath.leftoverTrailNowOf(
                    idTrail: leftoverHoldTrail[old.id] ?? [],
                    binTrail: MatchMath.leftoverTrailLookup(
                        hash: holdHash,
                        table: leftoverHoldTrailByHash,
                        now: now,
                        ttl: leftoverHoldTTL,
                        bin: MatchMath.leftoverHoldBinSigned(yaw: adopted[bestJ].quality.yaw),
                        facesInFrame: adopted.count,
                        occupied: leftoverOccupiedHashes(except: old.id)
                    ),
                    yawAbs: adopted[bestJ].quality.yaw
                )
                let tapUntil = tapNameLockUntil[old.id] ?? tapNameLockUntil[adopted[bestJ].id]
                if let tap = MatchMath.tapNameLockLabel(until: tapUntil, now: now) {
                    leftoverPending[adopted[bestJ].id] = tap
                }
                let stillFor = liveStillFor[old.id] ?? liveStillFor[adopted[bestJ].id] ?? 0
                let blinkBlocked = (liveOpenStreak[old.id] ?? liveOpenStreak[adopted[bestJ].id] ?? 0) < 2
                let boxIoU = FaceEngine.iou(old.box, adopted[bestJ].box)
                leftoverLastIoU[adopted[bestJ].id] = boxIoU
                let jumpCam = MatchMath.leftoverHoldKalmanJumpCam(dt: liveDt, pref: kalmanJump)
                leftoverNameLockUntil[old.id] = MatchMath.leftoverNameLockArm(
                    jump: MatchMath.leftoverIoUJumpBlocks(boxIoU, jump: jumpCam),
                    now: now,
                    prev: leftoverNameLockUntil[old.id] ?? leftoverNameLockUntil[adopted[bestJ].id],
                    sec: nameLockSec
                )
                leftoverNameLockUntil[adopted[bestJ].id] = leftoverNameLockUntil[old.id]
                if MatchMath.leftoverNameLockBlocks(until: leftoverNameLockUntil[old.id], now: now) {
                    let held = leftoverNameLockHeld[old.id]
                        ?? leftoverNameLockHeld[adopted[bestJ].id]
                        ?? identities.first(where: { $0.id == liveNameLock[old.id] })?.name
                        ?? identities.first(where: { $0.faceIds.contains(old.id) })?.name
                    if let held {
                        leftoverNameLockHeld[adopted[bestJ].id] = held
                        leftoverNameLockHeld[old.id] = held
                    }
                    if liveNameLock[adopted[bestJ].id] == nil {
                        liveNameLock[adopted[bestJ].id] = liveNameLock[old.id]
                    }
                }
                let nameLock = leftoverNameLockUntil[old.id]
                var jpegDelta: Double?
                let printReady = !adopted[bestJ].featurePrint.isEmpty
                let namedAlready = leftoverIdentityId(of: old.id) != nil
                    || leftoverIdentityId(of: adopted[bestJ].id) != nil
                    || leftoverPending[old.id] != nil
                    || leftoverPending[adopted[bestJ].id] != nil
                    || leftoverNameLockHeld[old.id] != nil
                let blinkOk = leftoverBlinkSeen(
                    faceId: adopted[bestJ].id,
                    identityId: leftoverIdentityId(of: old.id) ?? leftoverIdentityId(of: adopted[bestJ].id)
                )
                if MatchMath.leftoverAssignBlinkOk(
                    printOk: MatchMath.leftoverBaptize(cosine: pinCos, continuity: liveCapture.isContinuity) && printReady,
                    blinkOk: blinkOk,
                    alreadyNamed: namedAlready
                ) {
                    let probeId = adopted[bestJ].id
                    let boxHash = leftoverLastHash[probeId] ?? leftoverLastHash[old.id]
                    if let boxHash,
                       let hit = MatchMath.leftoverJpegProbeLookupBin(
                        table: leftoverJpegByHash,
                        hash: boxHash,
                        yaw: adopted[bestJ].quality.yaw
                       ),
                       MatchMath.leftoverJpegProbeReuse(
                        now: now,
                        last: hit.at,
                        ttl: jpegProbeTTL,
                        hash: boxHash,
                        cachedHash: boxHash,
                        cosine: pinCos,
                        cachedCosine: hit.cosine
                       )
                    {
                        jpegDelta = MatchMath.leftoverJpegProbeGet(hit.delta)
                    } else if MatchMath.leftoverJpegProbeReuse(
                        now: now,
                        last: leftoverJpegAt[probeId] ?? leftoverJpegAt[old.id],
                        ttl: jpegProbeTTL,
                        hash: boxHash,
                        cachedHash: leftoverJpegHash[probeId] ?? leftoverJpegHash[old.id],
                        cosine: pinCos,
                        cachedCosine: leftoverJpegCos[probeId] ?? leftoverJpegCos[old.id]
                    ) {
                        jpegDelta = MatchMath.leftoverJpegProbeGet(leftoverJpegDelta[probeId] ?? leftoverJpegDelta[old.id])
                    } else {
                        jpegDelta = FaceEngine.jpegProbeDelta(
                            print: adopted[bestJ].featurePrint,
                            image: image,
                            box: adopted[bestJ].box
                        )
                        leftoverJpegDelta[probeId] = MatchMath.leftoverJpegProbePut(jpegDelta)
                        leftoverJpegAt[probeId] = now
                        if let boxHash {
                            leftoverJpegHash[probeId] = boxHash
                            leftoverJpegByHash = MatchMath.leftoverJpegProbeStoreBin(
                                table: leftoverJpegByHash,
                                hash: boxHash,
                                yaw: adopted[bestJ].quality.yaw,
                                delta: jpegDelta,
                                at: now,
                                cosine: pinCos
                            )
                        }
                        if let pinCos { leftoverJpegCos[probeId] = pinCos }
                    }
                }
                let transfer = MatchMath.leftoverTransfersId(
                    cosine: pinCos,
                    holdPrev: holdNow,
                    trail: trailNow,
                    tapUntil: tapUntil,
                    now: now,
                    stillFor: stillFor,
                    sharpness: adopted[bestJ].quality.sharpness,
                    yawAbs: adopted[bestJ].quality.yaw,
                    blink: blinkBlocked,
                    jpegDelta: jpegDelta,
                    iou: boxIoU,
                    jpegRequired: printReady,
                    nameLockUntil: nameLock,
                    jump: jumpCam,
                    continuity: liveCapture.isContinuity,
                    capture: MatchMath.leftoverSessionCapture(
                        old: old.quality.capture,
                        live: [adopted[bestJ].quality.capture]
                    )
                )
                if MatchMath.leftoverHoldsTrack(
                    cosine: pinCos,
                    holdPrev: holdNow,
                    trail: trailNow,
                    tapUntil: tapUntil,
                    now: now,
                    stillFor: stillFor,
                    sharpness: adopted[bestJ].quality.sharpness,
                    yawAbs: adopted[bestJ].quality.yaw,
                    blink: blinkBlocked,
                    jpegDelta: jpegDelta,
                    iou: boxIoU,
                    jpegRequired: printReady,
                    nameLockUntil: nameLock,
                    jump: jumpCam,
                    continuity: liveCapture.isContinuity,
                    capture: MatchMath.leftoverSessionCapture(
                        old: old.quality.capture,
                        live: [adopted[bestJ].quality.capture]
                    )
                ) {
                    leftoverPending[adopted[bestJ].id] = MatchMath.leftoverHoldLabel(
                        cosine: pinCos,
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: adopted[bestJ].quality.yaw,
                        smooth: holdNow
                    )
                        ?? leftoverPending[adopted[bestJ].id]
                    leftoverPins += 1
                    if let cos = pinCos, MatchMath.leftoverHoldWriteOk(
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: abs(adopted[bestJ].quality.yaw)
                    ) {
                        leftoverHoldByHash = MatchMath.leftoverHoldPut(
                            hash: holdHash,
                            cosine: cos,
                            onto: leftoverHoldByHash,
                            now: now,
                            bin: MatchMath.leftoverHoldBinSigned(yaw: adopted[bestJ].quality.yaw),
                            ttl: leftoverHoldTTL
                        )
                        leftoverHold[old.id] = MatchMath.leftoverHoldEMA(
                            prev: leftoverHold[old.id] ?? holdNow,
                            next: cos,
                            alpha: MatchMath.leftoverHoldAlpha(
                                dt: liveDt,
                                captureJump: MatchMath.leftoverCaptureJump(
                                    prev: old.quality.capture,
                                    next: adopted[bestJ].quality.capture
                                )
                            )
                        )
                    }
                    if let cos = pinCos, MatchMath.leftoverHoldBinWriteOk(
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: abs(adopted[bestJ].quality.yaw)
                    ) {
                        leftoverHoldBins = MatchMath.leftoverHoldBinPut(
                            bins: leftoverHoldBins,
                            id: old.id,
                            yawAbs: adopted[bestJ].quality.yaw,
                            next: cos,
                            prev: MatchMath.leftoverHoldPrevOf(
                                frontal: leftoverHold[old.id] ?? holdNow,
                                yawAbs: adopted[bestJ].quality.yaw,
                                bins: leftoverHoldBins,
                                id: old.id
                            ),
                            dt: liveDt,
                            captureJump: MatchMath.leftoverCaptureJump(
                                prev: old.quality.capture,
                                next: adopted[bestJ].quality.capture
                            )
                        )
                        leftoverHoldByHash = MatchMath.leftoverHoldPut(
                            hash: holdHash,
                            cosine: cos,
                            onto: leftoverHoldByHash,
                            now: now,
                            bin: MatchMath.leftoverHoldBinSigned(yaw: adopted[bestJ].quality.yaw),
                            ttl: leftoverHoldTTL
                        )
                    }
                    continue
                }
                if !MatchMath.leftoverStreakKeepsLive(transferred: transfer) {
                    leftoverClearStreak(old.id)
                }
                used.insert(old.id)
                if transfer {
                    let newId = adopted[bestJ].id
                    adopted[bestJ].id = old.id
                    leftoverMirrorPending(from: newId, to: old.id)
                    adopted[bestJ].trackId = old.trackId ?? old.id
                    adopted[bestJ].enrolledAt = old.enrolledAt ?? adopted[bestJ].enrolledAt
                    if adopted[bestJ].featurePrint.isEmpty {
                        adopted[bestJ].featurePrint = old.featurePrint
                    }
                    if adopted[bestJ].printVec.isEmpty, !old.printVec.isEmpty {
                        adopted[bestJ].printVec = old.printVec
                    }
                    leftoverBlendAdopted(&adopted[bestJ], oldId: old.id)
                    liveExposureUntil[old.id] = MatchMath.exposureLockUntil(
                        now: now,
                        hold: MatchMath.exposureLockHold(dt: liveDt, reconnect: true)
                    )
                } else {
                    guestOrder = MatchMath.guestOrderAppend(id: adopted[bestJ].id, onto: guestOrder)
                    guestSeenAt[adopted[bestJ].id] = now
                }
                let putHash = holdHash
                boxEuro.removeValue(forKey: old.id)
                if !MatchMath.leftoverAdoptKeepsKalman() {
                    boxKalmanDrop(old.id)
                }
                boxJumpPending.removeValue(forKey: old.id)
                leftoverPins += 1
                if let cos = pinCos {
                    let spike = MatchMath.leftoverBaptizeSpike(raw: cos, prev: holdPrev)
                    if !spike, MatchMath.leftoverHoldWriteOk(
                        sharpness: adopted[bestJ].quality.sharpness,
                        yawAbs: abs(adopted[bestJ].quality.yaw)
                    ) {
                        leftoverHoldByHash = MatchMath.leftoverHoldPut(
                            hash: putHash,
                            cosine: cos,
                            onto: leftoverHoldByHash,
                            now: now,
                            bin: MatchMath.leftoverHoldBinSigned(yaw: adopted[bestJ].quality.yaw),
                            ttl: leftoverHoldTTL
                        )
                    }
                    if MatchMath.leftoverWipeHist(cosine: cos, continuity: liveCapture.isContinuity) {
                        leftoverHold[adopted[bestJ].id] = MatchMath.leftoverHoldEMA(
                            prev: leftoverHold[adopted[bestJ].id] ?? leftoverHold[old.id],
                            next: cos,
                            alpha: MatchMath.leftoverHoldAlpha(
                                dt: liveDt,
                                captureJump: MatchMath.leftoverCaptureJump(
                                    prev: old.quality.capture,
                                    next: adopted[bestJ].quality.capture
                                )
                            )
                        )
                        if MatchMath.leftoverHoldBinWriteOk(
                            sharpness: adopted[bestJ].quality.sharpness,
                            yawAbs: abs(adopted[bestJ].quality.yaw)
                        ) {
                            leftoverHoldBins = MatchMath.leftoverHoldBinPut(
                                bins: leftoverHoldBins,
                                id: adopted[bestJ].id,
                                yawAbs: adopted[bestJ].quality.yaw,
                                next: cos,
                                prev: MatchMath.leftoverHoldPrevOf(
                                    frontal: leftoverHold[adopted[bestJ].id] ?? leftoverHold[old.id],
                                    yawAbs: adopted[bestJ].quality.yaw,
                                    bins: leftoverHoldBins,
                                    id: adopted[bestJ].id
                                ),
                                dt: liveDt,
                                captureJump: MatchMath.leftoverCaptureJump(
                                    prev: old.quality.capture,
                                    next: adopted[bestJ].quality.capture
                                )
                            )
                            leftoverHoldByHash = MatchMath.leftoverHoldPut(
                                hash: putHash,
                                cosine: cos,
                                onto: leftoverHoldByHash,
                                now: now,
                                bin: MatchMath.leftoverHoldBinSigned(yaw: adopted[bestJ].quality.yaw),
                                ttl: leftoverHoldTTL
                            )
                        }
                        leftoverWipeUntil[adopted[bestJ].id] = MatchMath.leftoverWipeMuteUntil(now: now)
                        if transfer {
                            liveNameHist.removeValue(forKey: old.id)
                            liveNameLock.removeValue(forKey: old.id)
                            liveNameVoteAt.removeValue(forKey: old.id)
                            liveScoreEma.removeValue(forKey: old.id)
                            liveScoreTicks.removeValue(forKey: old.id)
                            livePrintDrift.removeValue(forKey: old.id)
                        }
                    } else {
                        leftoverHold.removeValue(forKey: adopted[bestJ].id)
                        leftoverHoldBins = MatchMath.leftoverHoldBinDrop(bins: leftoverHoldBins, id: adopted[bestJ].id)
                    }
                }
            }
            let liveIds = Set(adopted.map(\.id))
            let leftoverIds = Set(leftoverPinned.map(\.id))
            leftoverPrintYaw = MatchMath.leftoverPrintYawMerge(
                printed: leftoverPrintYaw,
                live: Dictionary(uniqueKeysWithValues: adopted.map { ($0.id, $0.quality.yaw) }),
                skipPrints: skipPrints,
                printedIds: printCommitted
            )
            let livePrints = Dictionary(uniqueKeysWithValues: adopted.map {
                ($0.id, $0.printVec.count >= 32 ? $0.printVec : FaceEngine.embedding(of: $0))
            })
            let prevCoast = leftoverCoastPrint
            leftoverCoastPrint = MatchMath.leftoverCoastPrintMerge(
                stored: leftoverCoastPrint,
                live: livePrints,
                skipPrints: skipPrints,
                commitIds: printCommitted
            )
            leftoverCoastPrintAt = MatchMath.leftoverCoastPrintStampMerge(
                stamped: leftoverCoastPrintAt,
                live: livePrints,
                skipPrints: skipPrints,
                now: now,
                stored: prevCoast,
                commitIds: printCommitted
            )
            leftoverCoastPrint = MatchMath.leftoverCoastPrintWipe(
                stored: leftoverCoastPrint,
                stamped: leftoverCoastPrintAt,
                liveIds: liveIds,
                now: now,
                skipPrints: skipPrints
            )
            leftoverCoastPrintAt = leftoverCoastPrintAt.filter { leftoverCoastPrint[$0.key] != nil }
            leftoverCoastAt = leftoverCoastAt.filter { liveIds.contains($0.key) || leftoverIds.contains($0.key) }
            leftoverUnsureTicks = leftoverUnsureTicks.filter { liveIds.contains($0.key) || leftoverIds.contains($0.key) }
            leftoverPrintYaw = leftoverPrintYaw.filter {
                liveIds.contains($0.key) || leftoverIds.contains($0.key) || leftoverCoastPrint[$0.key] != nil
            }
            leftoverHold = leftoverHold.filter { liveIds.contains($0.key) || leftoverIds.contains($0.key) }
            leftoverHoldBins = leftoverHoldBins.filter { row in
                MatchMath.leftoverHoldId(from: row.key).map { liveIds.contains($0) || leftoverIds.contains($0) } ?? false
            }
            leftoverHoldByHash = MatchMath.leftoverHoldPrune(
                leftoverHoldByHash,
                now: now,
                ttl: leftoverHoldTTL,
                skip: MatchMath.leftoverHoldPruneSkips(rebased: leftoverHashRebasedTick)
            )
            leftoverHoldTrailByHash = MatchMath.leftoverTrailPrune(
                leftoverHoldTrailByHash,
                now: now,
                ttl: leftoverHoldTTL,
                skip: MatchMath.leftoverHoldPruneSkips(rebased: leftoverHashRebasedTick)
            )
            leftoverHashRebasedTick = false
            leftoverPending = leftoverPending.filter { liveIds.contains($0.key) }
            tapGuestPending = tapGuestPending.filter { liveIds.contains($0) }
            for id in tapGuestPending {
                if leftoverPending[id] == nil {
                    leftoverPending[id] = MatchMath.tapGuestNote()
                }
            }
            let liveList = Array(liveIds)
            guestOrder = guestOrder.filter {
                MatchMath.guestOrderKeeps(id: $0, live: liveList, lastSeen: guestSeenAt[$0], now: now)
            }
            for id in liveIds where guestOrder.contains(id) {
                guestSeenAt[id] = now
            }
            guestSeenAt = guestSeenAt.filter { guestOrder.contains($0.key) || liveIds.contains($0.key) }
            leftoverStreak = leftoverStreak.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverStreakBox = leftoverStreakBox.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverStreakSince = leftoverStreakSince.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverLastHash = leftoverLastHash.filter {
                liveIds.contains($0.key)
                    || leftoverCoastPrint[$0.key] != nil
                    || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverJpegDelta = leftoverJpegDelta.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverLastIoU = leftoverLastIoU.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverJpegAt = leftoverJpegAt.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverJpegHash = leftoverJpegHash.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverJpegCos = leftoverJpegCos.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverSparkChipHeld = leftoverSparkChipHeld.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverPairLast = leftoverPairLast.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverPairStreak = leftoverPairStreak.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverPairCommit = leftoverPairCommit.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverPairCommitMiss = leftoverPairCommitMiss.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverDisagree = leftoverDisagree.filter { leftoverIds.contains($0.key) && !used.contains($0.key) }
            leftoverHoldTrail = leftoverHoldTrail.filter {
                liveIds.contains($0.key) || (leftoverIds.contains($0.key) && !used.contains($0.key))
            }
            leftoverHoldTrailBins = leftoverHoldTrailBins.filter { row in
                MatchMath.leftoverHoldId(from: row.key).map {
                    liveIds.contains($0) || (leftoverIds.contains($0) && !used.contains($0))
                } ?? false
            }
            leftoverWipeUntil = leftoverWipeUntil.filter { liveIds.contains($0.key) || leftoverIds.contains($0.key) }
            liveSlotHold = liveSlotHold.filter { liveIds.contains($0.key) || leftoverIds.contains($0.key) }
            if leftoverPins > 0, let line = MatchMath.leftoverPinStatus(
                count: leftoverPins,
                cosine: leftoverHold.values.max()
            ) {
                status = "Live · \(line)"
            } else if let pending = leftoverPending.values.sorted().last {
                status = "Live · leftover \(pending)"
            } else if status.hasPrefix("Live · Leftover") || status.hasPrefix("Live · leftover") {
                status = "Live"
            }
            liveHeldIds = Set(adopted.compactMap { namedTracks.contains($0.id) ? $0.id : nil })
            faces.removeAll { $0.mediaId == mediaId }
            faces.append(contentsOf: adopted)
            let n = adopted.count
            if let label = MatchMath.headCountFlashLabel(prev: lastLiveHeadCount, next: n) {
                lastHeadCountLabel = label
                headCountFlashUntil = now + MatchMath.headCountFlashHold
            }
            lastLiveHeadCount = n
        }
        if selectedMediaId == mediaId {
            if found.isEmpty {
                if MatchMath.leftoverEmptyWipesOverlay(emptyChip: emptyChip, missCoast: missCoast) {
                    selectedFaceId = nil
                }
            } else if let cur = selectedFaceId, adopted.contains(where: { $0.id == cur }) {
                // Auswahl halten, solange der Track da ist.
            } else {
                selectedFaceId = adopted.first?.id
            }
        }
        reconnectGhosts.removeAll { used.contains($0.id) }
        nmsDropped = FaceEngine.lastNMSDropped
        rematchLive()
        suggestUSlotIfHeld(adopted, now: now)
        leftoverHashRebasedTick = false
    }

    /// 1,2 s Maske im Track → Vorschlag, nie still schreiben.
    private func suggestUSlotIfHeld(_ adopted: [FaceObservation], now: TimeInterval) {
        let liveIds = Set(adopted.map(\.id))
        maskHoldSince = maskHoldSince.filter { liveIds.contains($0.key) }
        for face in adopted {
            let masked = FaceEngine.lowerFaceOccluded(face)
            if masked {
                if maskHoldSince[face.id] == nil { maskHoldSince[face.id] = now }
            } else {
                maskHoldSince.removeValue(forKey: face.id)
            }
            guard let since = maskHoldSince[face.id], now - since >= 1.2 else { continue }
            guard now - lastUSlotHint >= 4 else { continue }
            let owner = identities.first { $0.faceIds.contains(face.id) }
                ?? (identities.count == 1 ? identities.first : nil)
            guard let owner else { continue }
            let refs = faces.filter { owner.faceIds.contains($0.id) }
            let hasU = refs.contains { $0.forcedPartial || FaceEngine.lowerFaceOccluded($0) }
            if hasU { continue }
            lastUSlotHint = now
            status = "Maske 1,2 s · U für Teil-Print von \(owner.name) — nie still geschrieben"
        }
    }

    func exportCSV() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "aegis-matches.csv"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        var lines = [MatchMath.labCSVHeader()]
        let idNames = Dictionary(uniqueKeysWithValues: identities.map { ($0.id, $0.name) })
        for row in matches {
            for hit in row.hits {
                let name = hit.identityId.flatMap { idNames[$0] } ?? ""
                lines.append(MatchMath.labCSVRow(
                    face: row.faceId.uuidString,
                    strategy: hit.strategy.label,
                    identity: name,
                    percent: hit.percent,
                    note: hit.note
                ))
            }
        }
        try? lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    private func csvField(_ raw: String) -> String {
        if raw.contains(",") || raw.contains("\"") || raw.contains("\n") || raw.contains("\r") {
            return "\"" + raw.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return raw
    }

    func exportLab() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "aegis-labor.txt"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let faces = self.faces
        let identities = self.identities
        let media = self.media
        let enabled = self.enabled
        let threshold = self.threshold
        let cameraOrient = self.cameraOrient
        busy = true
        status = "Laborbericht"
        Task {
            let text = await Task.detached {
                LabReport.text(
                    faces: faces,
                    identities: identities,
                    media: media,
                    enabled: enabled,
                    threshold: threshold,
                    cameraOrient: cameraOrient
                )
            }.value
            try? text.write(to: url, atomically: true, encoding: .utf8)
            busy = false
            status = "Laborbericht gespeichert"
        }
    }

    func fetchBenchData(thenStart: Bool = false) {
        scanGeneration += 1
        let gen = scanGeneration
        busy = true
        status = "Testdaten · starte Download"
        Task {
            do {
                let ident20 = try await BenchFetch.install { msg in
                    Task { @MainActor in
                        if gen == self.scanGeneration { self.status = msg }
                    }
                }
                if gen != self.scanGeneration {
                    self.busy = false
                    return
                }
                self.status = "Testdaten in \(ident20.deletingLastPathComponent().path)"
                self.busy = false
                if thenStart {
                    self.runBenchmark(root: ident20)
                }
            } catch {
                self.busy = false
                self.status = "Testdaten: \(error.localizedDescription)"
            }
        }
    }

    func startDefaultBenchmark() {
        if BenchFetch.ident20Ready() {
            retainAccess([BenchFetch.root()])
            runBenchmark(root: BenchFetch.ident20URL())
            return
        }
        fetchBenchData(thenStart: true)
    }

    func pickBenchmark() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Testmodus"
        panel.message = "Ordner mit Personen-Unterordnern. Empfohlen: ~/Downloads/AegisBench/ident20 nach ./bench/fetch.sh"
        let home = benchHome
        if FileManager.default.fileExists(atPath: home.path) {
            panel.directoryURL = home
        } else {
            status = "Kein ~/Downloads/AegisBench. In der App: Testdaten holen."
        }
        guard panel.runModal() == .OK, let root = panel.url else { return }
        retainAccess([root])
        runBenchmark(root: root)
    }

    private func runBenchmark(root: URL) {
        scanGeneration += 1
        scanFlag.reset()
        let gen = scanGeneration
        let flag = scanFlag
        let threshold = self.threshold
        let enabled = self.enabled
        let cameraOrient = self.cameraOrient
        let savedMedia = media
        let savedFaces = faces
        let savedIdentities = identities
        let savedMatches = matches
        let savedSelectedMedia = selectedMediaId
        let savedSelectedFace = selectedFaceId
        busy = true
        status = "Testmodus · Ordner lesen"
        Task {
            var parts: [String] = [Benchmark.header(root: root, mode: "Verifikation + Identifikation")]
            let pairsURL = BenchProtocol.findPairsFile(root: root)
                ?? Bundle.main.url(forResource: "pairs", withExtension: "txt")
            let pairsText = pairsURL.flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? ""
            let pairs = BenchProtocol.parsePairs(pairsText)
            let people = BenchProtocol.personFolders(root: root)
            let picked = BenchProtocol.selectPeople(people, cap: Benchmark.identifyPeopleCap)
            let large = people.count > picked.urls.count

            if !pairs.isEmpty {
                self.status = "Testmodus · Verifikation 0/\(pairs.count)"
                let verifyRoot = root
                let tick = BenchProgress()
                let verifyTask = Task.detached {
                    defer { tick.finish() }
                    return Benchmark.verify(
                        root: verifyRoot,
                        pairs: pairs,
                        threshold: threshold,
                        shouldContinue: { flag.alive },
                        progress: { n, total in tick.set(n, total) }
                    )
                }
                while !tick.isFinished {
                    if gen != self.scanGeneration {
                        flag.stop()
                        break
                    }
                    self.status = tick.label
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
                let report = await verifyTask.value
                parts.append("")
                parts.append(report)
            } else {
                parts.append("")
                parts.append("Kein pairs.txt — nur Identifikation. Testdaten holen legt die LFW-Paare nach Downloads/AegisBench.")
            }

            if gen != self.scanGeneration || !flag.alive {
                self.restoreGallery(savedMedia, savedFaces, savedIdentities, savedMatches, savedSelectedMedia, savedSelectedFace)
                self.busy = false
                self.status = "Testmodus abgebrochen"
                return
            }

            let subset = picked.urls
            var urls: [URL] = []
            for person in subset {
                urls.append(contentsOf: BenchProtocol.images(in: person, limit: Benchmark.photosPerPerson))
            }
            if !urls.isEmpty {
                self.media = []
                self.faces = []
                self.identities = []
                self.matches = []
                self.status = "Testmodus · Identifikation \(urls.count) Fotos, \(subset.count) Personen"
                await self.ingestAndScan(urls: urls, generation: gen)
                self.busy = true
                if gen != self.scanGeneration {
                    self.restoreGallery(savedMedia, savedFaces, savedIdentities, savedMatches, savedSelectedMedia, savedSelectedFace)
                    self.busy = false
                    self.status = "Testmodus abgebrochen"
                    return
                }
                self.identities = Benchmark.identitiesFromFolders(media: self.media, faces: self.faces)
                self.rematch()
                let idFaces = self.faces
                let idIdentities = self.identities
                let idMedia = self.media
                let lab = await Task.detached {
                    LabReport.text(
                        faces: idFaces,
                        identities: idIdentities,
                        media: idMedia,
                        enabled: enabled,
                        threshold: threshold,
                        cameraOrient: cameraOrient
                    )
                }.value
                parts.append("")
                parts.append("Identifikation (Leave-one-out, ≥\(picked.minPhotos) Fotos, max \(Benchmark.identifyPeopleCap) Personen × \(Benchmark.photosPerPerson) Fotos)")
                if large {
                    parts.append("Galerie gekappt: \(people.count) Ordner → \(subset.count) Personen (min \(picked.minPhotos) Bilder). ident10/ident20 sind die vorbereiteten Sätze.")
                }
                parts.append(lab)
            }

            self.restoreGallery(savedMedia, savedFaces, savedIdentities, savedMatches, savedSelectedMedia, savedSelectedFace)
            let text = parts.joined(separator: "\n")
            let save = NSSavePanel()
            save.allowedContentTypes = [.plainText]
            save.nameFieldStringValue = "aegis-testmodus.txt"
            save.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("AegisBench")
            self.busy = false
            if save.runModal() == .OK, let url = save.url {
                try? text.write(to: url, atomically: true, encoding: .utf8)
                self.status = "Testmodus gespeichert · \(url.lastPathComponent)"
            } else {
                self.status = "Testmodus fertig — Speichern verworfen"
            }
        }
    }

    private func restoreGallery(
        _ media: [MediaItem],
        _ faces: [FaceObservation],
        _ identities: [Identity],
        _ matches: [MatchResult],
        _ selectedMediaId: UUID?,
        _ selectedFaceId: UUID?
    ) {
        self.media = media
        self.faces = faces
        self.identities = identities
        self.matches = matches
        self.selectedMediaId = selectedMediaId
        self.selectedFaceId = selectedFaceId
    }

    private func appendFalseAcceptLog(hash: String, identity: String, cosine: Double, decided: String) {
        guard MatchMath.falseAcceptJSONLShouldLog(
            prevDecided: faLogLastDecided[hash], decided: decided
        ) else { return }
        faLogLastDecided[hash] = decided
        let line = MatchMath.falseAcceptJSONLLine(
            ts: Date().timeIntervalSince1970,
            hash: hash,
            identity: identity,
            cosine: cosine,
            decided: decided
        ) + "\n"
        let url = GalleryFile.falseAcceptURL
        guard let data = line.data(using: .utf8) else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            if let handle = try? FileHandle(forWritingTo: url) {
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            }
        } else {
            try? data.write(to: url)
        }
        faLogLines += 1
        let cap = MatchMath.falseAcceptJSONLCap()
        if faLogLines > cap, let text = try? String(contentsOf: url, encoding: .utf8) {
            let trimmed = MatchMath.falseAcceptJSONLTrim(text, cap: cap)
            if let blob = trimmed.data(using: .utf8) {
                try? blob.write(to: url)
            }
            faLogLines = cap
        }
    }

    func replayFalseAccept() {
        let url = GalleryFile.falseAcceptURL
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            faReplayChip = "FA —"
            faReplayMatrix = "FA —"
            status = "Kein False-Accept-Log"
            return
        }
        let lines = text.split(whereSeparator: \.isNewline).suffix(20)
        var hits = 0
        var pairs: [(expected: String, decided: String)] = []
        for line in lines {
            guard let row = MatchMath.falseAcceptJSONLParse(String(line)) else { continue }
            if MatchMath.falseAcceptJSONLHits(
                cosine: row.cosine, floor: 0.80, decided: row.decided, expected: row.identity
            ) {
                hits += 1
                pairs.append((expected: row.identity, decided: row.decided))
            }
        }
        let heat = MatchMath.falseAcceptPairHeatmap(pairs)
        if hits > 0 {
            if let split = MatchMath.twinAutoSplit(heat: heat) {
                faReplayChip = MatchMath.twinAutoSplitChip(kept: split.kept, split: split.split)
                twinSplits = MatchMath.twinSplitInsert(kept: split.kept, split: split.split, splits: twinSplits)
                UserDefaults.standard.set(
                    MatchMath.twinSplitEncode(twinSplits),
                    forKey: MatchMath.twinSplitStoreKey()
                )
            } else {
                faReplayChip = MatchMath.falseAcceptPairChip(heat)
            }
            faReplayMatrix = MatchMath.falseAcceptPairMatrix(heat)
            let top = heat.prefix(3).map { "\($0.pair)×\($0.n)" }.joined(separator: " · ")
            status = "False-Accept Replay · \(hits) Treffer · \(top)"
        } else {
            faReplayChip = "FA —"
            faReplayMatrix = "FA —"
            status = "Match-Log \(lines.count) Zeilen"
        }
    }

    func seedFromPeopleAlbum() {
        let now = Date().timeIntervalSince1970
        guard MatchMath.photoKitDebounceAllows(last: peopleAlbumSeedAt, now: now) else {
            status = "People-Album · warte"
            return
        }
        peopleAlbumSeedAt = now
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] auth in
            Task { @MainActor in
                guard let self else { return }
                guard MatchMath.peopleAlbumAuthOk(Int(auth.rawValue)) else {
                    self.status = "Fotos-Zugriff fehlt — People-Album"
                    return
                }
                let limited = MatchMath.peopleAlbumLimitedOnly(Int(auth.rawValue))
                let subtype: PHAssetCollectionSubtype
                if MatchMath.peopleAlbumFetchAny(limited: limited) {
                    subtype = .any
                } else {
                    subtype = PHAssetCollectionSubtype(rawValue: UInt(MatchMath.peopleAlbumSubtypeRaw)) ?? .albumSyncedFaces
                }
                let cols = PHAssetCollection.fetchAssetCollections(with: .album, subtype: subtype, options: nil)
                var seeded = 0
                var stillCount = 0
                let cap = MatchMath.peopleAlbumStillCap()
                let scan = MatchMath.peopleAlbumScanCap()
                cols.enumerateObjects { col, _, stop in
                    if seeded >= 8 { stop.pointee = true; return }
                    let nameBase = col.localizedTitle ?? ""
                    if MatchMath.peopleAlbumSkipEmpty(nameBase) { return }
                    if MatchMath.peopleAlbumSkipHidden(
                        title: nameBase,
                        subtypeRaw: Int(col.assetCollectionSubtype.rawValue),
                        isHidden: false
                    ) { return }
                    let assets = PHAsset.fetchAssets(in: col, options: nil)
                    var picked: [PHAsset] = []
                    assets.enumerateObjects { asset, _, halt in
                        if picked.count >= scan { halt.pointee = true; return }
                        if asset.mediaType == .image { picked.append(asset) }
                    }
                    guard MatchMath.peopleAlbumEnrollOk(stills: picked.count, need: MatchMath.peopleAlbumSeedNeed()) else { return }
                    let images = self.peopleAlbumLoadStills(picked)
                    var detected: [(cg: CGImage, face: FaceObservation)] = []
                    for cg in images {
                        let mid = UUID()
                        let found = (try? FaceEngine.detect(in: cg, mediaId: mid, tiles: false, live: false)) ?? []
                        guard let face = found.max(by: { $0.box.width * $0.box.height < $1.box.width * $1.box.height }) else { continue }
                        if MatchMath.printCaptureQualitySkip(face.quality.capture) { continue }
                        if detected.contains(where: {
                            MatchMath.peopleAlbumStillDup(
                                yawA: $0.face.quality.yaw, yawB: face.quality.yaw,
                                captureA: $0.face.quality.capture, captureB: face.quality.capture
                            )
                        }) { continue }
                        var copy = face
                        copy.enrolledAt = Date()
                        detected.append((cg: cg, face: copy))
                    }
                    let bins = detected.map { MatchMath.peopleAlbumYawBin($0.face.quality.yaw) }
                    let keep = MatchMath.peopleAlbumYawPick(bins: bins, cap: cap)
                    let keepBins = keep.map { bins[$0] }
                    if MatchMath.peopleAlbumSMBlocksSeed(bins: keepBins) { return }
                    let name = MatchMath.displayNameSuffix(
                        base: nameBase, taken: self.identities.map(\.name)
                    )
                    if let i = keep.first {
                        let probe = detected[i].face
                        if let hit = FaceEngine.duplicateOf(
                            face: probe,
                            identities: self.identities,
                            faces: self.faces
                        ), MatchMath.peopleAlbumDuplicate(cosine: hit.1) {
                            self.mergeUndoAt = Date().timeIntervalSince1970
                            self.mergeHint = MatchMath.mergeUndoChip(kept: hit.0.name, skipped: name)
                            return
                        }
                    }
                    var faceIds: [UUID] = []
                    for i in keep {
                        let row = detected[i]
                        let cg = row.cg
                        let copy = row.face
                        let mid = copy.mediaId
                        if !self.faces.contains(where: { $0.id == copy.id }) {
                            self.faces.append(copy)
                        }
                        if !self.media.contains(where: { $0.id == mid }) {
                            self.media.append(MediaItem(
                                id: mid,
                                url: URL(fileURLWithPath: "/tmp/aegis-people-\(mid.uuidString)"),
                                name: name,
                                kind: .photo,
                                width: cg.width,
                                height: cg.height,
                                duration: nil,
                                parentId: nil,
                                timeSec: nil,
                                preview: cg
                            ))
                        }
                        faceIds.append(copy.id)
                    }
                    guard !faceIds.isEmpty else { return }
                    self.identities.append(Identity(id: UUID(), name: name, faceIds: faceIds))
                    seeded += 1
                    stillCount += faceIds.count
                }
                if seeded > 0 {
                    self.compactLowQualityPrints()
                    self.persist()
                }
                self.status = seeded > 0
                    ? (limited
                        ? "People-Album (eingeschränkt) · \(seeded) Personen · \(stillCount) Stills"
                        : "People-Album · \(seeded) Personen · \(stillCount) Stills")
                    : MatchMath.peopleAlbumLimitedStatus(seeded: 0, limited: limited)
            }
        }
    }

    /// Capture < 0,35 Gift im Centroid. Nur droppen wenn die Person noch andere Stills hat.
    func compactLowQualityPrints() {
        var drop: Set<UUID> = []
        for idn in identities {
            let owned = faces.filter { idn.faceIds.contains($0.id) }
            let remain = owned.filter { !MatchMath.printCaptureQualitySkip($0.quality.capture) }.count
            for f in owned where MatchMath.galleryCompactDrops(capture: f.quality.capture, remaining: remain + (MatchMath.printCaptureQualitySkip(f.quality.capture) ? 1 : 0)) {
                if remain >= 1 { drop.insert(f.id) }
            }
        }
        guard !drop.isEmpty else { return }
        faces.removeAll { drop.contains($0.id) }
        identities = identities.map { idn in
            var n = idn
            n.faceIds.removeAll { drop.contains($0) }
            return n
        }
    }

    private func peopleAlbumLoadStills(_ assets: [PHAsset]) -> [CGImage] {
        let opts = PHImageRequestOptions()
        opts.isSynchronous = true
        opts.deliveryMode = .highQualityFormat
        opts.resizeMode = .fast
        opts.isNetworkAccessAllowed = false
        var out: [CGImage] = []
        let mgr = PHImageManager.default()
        for asset in assets {
            mgr.requestImage(
                for: asset,
                targetSize: CGSize(width: 720, height: 720),
                contentMode: .aspectFill,
                options: opts
            ) { img, _ in
                if let cg = img?.cgImage { out.append(cg) }
            }
        }
        return out
    }
}
