# Nachtrag Grok 2026-09-07 — 2.1.188 / 1.5.189 (Bugfix-Pass 1 auf main)

Quelle: Review Helios 1.5.189 (Build 208) und Aegis 2.1.188 alpha (Build 213).
Kein Binary-Lauf in dieser Session (Linux-Sandbox). Kein Merge von `bugfix`.

## Diagnose

1. Kamera-Schiedsrichter ist eine Textdatei + SIGKILL. Beide Default Auto.
2. Mutex-Format driftete (3 vs 5 Felder). PTS-Cap 80 ms nutzlos bei 8 fps.
3. leftoverHashTwinLeft x-Tie ohne Yaw → beide tot.
4. Identität hängt an UUID. Remint mintet, 15 Dictionaries müssen mit.
5. LiveCapture @MainActor. CGImage je Frame.
6. Prop/Ghost in Helios war Scale/Bool, kein Slot-Typ.

## In 2.1.188 / 1.5.189 gelandet (Bugfix-Pass 1)

1. Mutex v2.
2. PTS-Skew 220 ms.
3. Twin tieKey ohne Yaw.
4. Kamera-Paar Built-in / Continuity. Auto einmal migriert.
5. SIGKILL Default aus.
6. Helios SlotKind.
7. Tests. Nur `main`.

## Offen

P0 CameraBroker. FaceTrack-only Store.
P1 CVPixelBuffer, LiveCapture off MainActor.
P2 MatchMath split. Print-Qualität ≠ Skip-Gate. Golden-Frames.

## Erweiterung

Siehe `VORSCHLAEGE-NEU.md` (FaceTrack-Map, Enroll-Coach, Temperature-Cosine, PhotoKit, Stereo, HeliosAegisKit, Licht-Eimer, Match-Log, Drop-in .mlmodel).

## Bugfix-Skill

Pass 1: oben, auf `main`. Kein `bugfix`-Branch.
Pass 2–3 ohne Xcode hier nicht schließbar.
