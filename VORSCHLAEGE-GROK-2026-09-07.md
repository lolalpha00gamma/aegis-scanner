# Nachtrag Grok 2026-09-07 — 2.1.189 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.189 (Build 214) auf 2.1.188 (Mutex v2, Kamera-Paar). Helios 1.5.190.
Kein Binary-Lauf. `bugfix` #3 nicht gemergt.

## Warum Live nach 2.1.188 weiter riss

1. skipPrint nutzte printQuality(yaw) als Gate — ¾ (Bin 1) kam nicht in die Bank. FaceEngine übergab kein Yaw.
2. leftoverFaceTrackRemint hielt Source-UUID. Overlay-Ada ≠ Store-Ada.
3. leftover miss war eine Zahl, kein live|coast|ghost.
4. Helios Kalman stahl S1. Fill-Gap tot.

## In 2.1.189 / 1.5.190 gelandet

- skipPrint ¾. FaceEngine Yaw. Profil bleibt Skip.
- FaceTrack Remint = Drop. Source tot.
- TrackKind + leftoverMissClears.
- Helios Kalman-Klemme, Fill-Gap displayTick, SlotKind Joints.

## Offen

P0 CameraBroker. FaceTrack einzige Map.
P1 CVPixelBuffer bis Detect. LiveCapture nicht MainActor.
P2 Golden-Frames 8 fps. TrackKind-TTL. HeliosAegisKit.

## Erweiterung (neu)

1. Broker IOSurface. Mutex nur Heartbeat.
2. Gallery-Row-ID überlebt Detect.
3. Enroll-Coach State Machine.
4. Overlay-Metal 90 Hz.
5. Replay 20 s Continuity + PTS.
6. Watchdog Pause → Built-in.
7. AVCaptureSessionWasInterrupted.
8. VNTrackObjectRequest.
9. livePending drop-oldest.
10. Continuity 720p Format-Lock.

## Bugfix-Skill

Pass 1: Diagnose. Pass 2: 2.1.189 auf main. Pass 3: CI hart.
