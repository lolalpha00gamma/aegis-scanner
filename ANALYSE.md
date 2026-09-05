# Helios + Aegis — Analyse 2026-09-05 (2.1.89)

Helios **1.5.73** (Build 93). Aegis **2.1.89 alpha** (Build 115). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` (2.1.15) hinter main, nichts nachziehen.

## Warum Namen nach 2.1.88 noch sprangen / tot wirkten

2.1.88 hält Live-Tag über Ghost, ¾ kein Hold-EMA, Print-Floor roh, Nacht-Climb kein Spike, FaceEngine Capture. Drei Löcher blieben:

1. **Session-Capture = min(alle Live).** Gast im Schatten 0,18 + Anna 0,70 → Floor 0,60. Twin 0,61 tauft Anna. per-Box fehlte.
2. **unknownCentroid ohne Yaw.** `min(Genuine 0,62, session)` macht Profil-Floor 0,70 zunichte. 0,65 im ¾ ist „bekannt“. Twin im Profil.
3. **Hold-EMA α ignoriert AE-Sprung.** Capture 0,70→0,18, α 0,35 schreibt den Hold in einem Tick um. Nächster Frontal spike-blockt oder tauft falsch.

## Was 2.1.89 wirklich ändert

1. **`leftoverSessionCaptureBox`.** Box behält ihren Capture. leftoverPick `capture: [Int: Double]`.
2. **`unknownCentroid(yawAbs:)`.** Profil-Floor 0,70 bleibt. FaceEngine reicht Yaw.
3. **`leftoverHoldAlpha(captureJump:)`.** Sprung ≥ 0,20 → α 0,08.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.89 (Build 115).

2.1.88 bleibt: Live-Tag schlägt Ghost, Print-Floor roh, Nacht-Climb, FaceEngine Capture.

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, Yaw-binned Print-Bank, Blink-Liveness, Iris-Twin-Veto.

Helios 1.5.73: Fill tot bei Still, Y-Vel × Höhe, Screen-px Vel, Kalman-Q aus MAD. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
