# Aegis Vorschläge — 2026-09-08 (Pass 7, 2.1.206)

Stand 2.1.206 alpha Build 231. Ergänzung, keine Kopie von 2.1.188–205.

## Gelandet in 2.1.206 (dieser Pass)

leftoverTracksUnpack als Identität (Hold/Hash/Name/Coast). leftoverTracksMove in MirrorPending. Print-Index Call-Site in FaceEngine. Twin-Lock in leftoverAssignPrintCell.

## Erweiterung (neu, nicht in der 2.1.205-Liste)

57. **leftoverTracks auch Live-Skalare** Yaw/Kalman/Blink — FaceTrackMaps aus Unpack. P0 Rest.
58. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
59. **gallery ANN** HNSW statt linear, Print-Index ist der Einstieg.
60. **Identity-Merge-Wizard** Cosine 0,89–0,94 mit Pairwise-Heatmap.
61. **Watch-Folder PhotoKit** + Export `.aegis` verschlüsselt.
62. **P-Slot Maske/Schal**, Brille Twin-Veto.
63. **ReID-Graph** Hold-Trail, nicht nur Last-Print.
64. **Stereo Built-in + Continuity** Disparität als Yaw-Prior.
65. **FaceTrack.id uniqueID-Reconnect** via Print+Yaw-Bin.
66. **Overlay CAMetalLayer 60 Hz**, Detect 8–24.
67. **Gemeinsamer CVPixelBuffer** Detect+Print, JPEG nur Export.
68. **VNTrackObjectRequest** Box halten zwischen Detect-Ticks.
69. **Hung-Detect Cancel** nach 1 s, FrameTap drop-oldest bleibt.
70. **LiveCapture nicht @MainActor.** Detect outputQueue.
71. **420f vs 420v** Color-Space-Mismatch Continuity/Built-in.
72. **Tests: eine Fixture Restart+Twin+AssignLive.** Orakel auf 40 Bools stoppen.

Kein 2.1.207-Flag ohne CameraBroker oder leftoverTracks als einzige Map für Live-Skalare.
