# Nachtrag Grok 2026-09-07 — Architektur, warum es hakt, Erweiterung

Quelle: Review Helios 1.5.188 (Build 207) und Aegis 2.1.187 alpha (Build 212).
Kein Binary-Lauf in dieser Session (Linux-Sandbox). Keine Schwellen in MatchMath/CoordMath gedreht.

## Diagnose — warum Live tot / zitternd / falsch wirkt

1. Kamera-Schiedsrichter ist eine Textdatei. Helios und Aegis locken dieselbe Continuity-Kamera über flock + 5 Felder (owner, pid, stamp, gen, pts). Das ist kein Broker. Hung-live führt zu SIGTERM/SIGKILL. 8 fps zwingt Overlay, Print und Fill in Sonderregeln.
2. Zustand ist ein Friedhof aus Nachträgen. leftover* (Aegis) und palm*/obsFill*/destEdge* (Helios) sind jeweils ein volles Produkt. Ein Detect-Loch 400 ms triggert Remint, Coast, Ghost, NameLock, Peak-IoU, Fill-Gap-Rebase — oft gegeneinander.
3. Identität hängt an UUID, nicht an der Person. Apple Face-Print + Maße + Yaw. Remint mintet eine neue UUID, fünfzehn Dictionaries müssen mit. Overlay-Ada ist nicht Store-Ada.
4. Hot Path kopiert Bilder. CGImage je Frame, Vision auf Main-nahen Queues, Store wieder auf MainActor.
5. Dritte Hand existiert nicht. Gitarre ist eine Zahl 0,29. Solange Prop kein Slot-Typ ist, bleibt Bind ein Wettrennen.
6. Zwei Parser, ein Protokoll. Drift im Mutex-Format (4 vs 5 Felder) sieht aus wie Aegis tot.

Das ist die Ursache für funktioniert schlecht, nicht fehlende Gesten.

## Offen nach 2.1.187 (nicht noch ein Slider)

P0 CameraBroker: ein Capture-Prozess, zwei Subscriber.
P0 FaceTrack = einzige Store-Map. Ende Remint-Geister.
P0 Slot-Typ hand | prop | ghost in Helios; Aegis kennt Ghost analog als Coast-Klasse.
P1 Eine Motion-Clock = Sample-PTS für Fill, Lerp, Print.
P1 CVPixelBuffer bis Detect.
P1 LiveCapture nicht @MainActor.
P2 MatchMath split (Mutex, Print, leftover, Live).
P2 Mutex v2 mit Versionsbyte.
P2 Print-Qualität ungleich Skip-Gate, damit 3/4-Enroll bleibt.
P2 Golden-Frames 8 fps + PTS.

## Erweiterung

1. Broker-Socket statt Datei. Unix-Socket, Frames als IOSurface. Mutex-Datei nur Heartbeat.
2. Continuity-Profil fest: Helios=Continuity XOR Aegis=Built-in. Auto-Yield nur wenn der Nutzer Continuity in Aegis erzwingt.
3. Gallery-Row-ID überlebt Detect. Overlay zeigt Row-Name, nie UUID-Tail.
4. Prop-Kalib 10 s legt Scale- und Span-Band fest statt global 0,28.
5. IOHID für Cursor optional, CGWarp Fallback.
6. Overlay-Metal: ein Quad, Knochen Line-Strip, Ghost Opacity-Uniform.
7. Enroll-Coach als State Machine: Front, 3/4 L, 3/4 R, Blink. Kein Print-Burst 0,98.
8. Shared Package HeliosAegisKit: Mutex, PTS, Slot-Typen, Broker-Client.
9. Replay-Datei 20 s Continuity + PTS + Observations. Jeder Fix eine Replay-Regression.
10. Watchdog ohne Kill: Session-Pause 2 s, dann Built-in. SIGKILL nur nach Pref.
11. Gaze-Idle ungleich keine Hand. Live-Hand hält wach.
12. Aegis Hunt/Lock-fps darf Helios-Gain nicht drosseln.

## Bugfix-Skill

Pass 1: Befunde oben. Keine ungetesteten Math-Edits.
Pass 2–3 Compile auf diesem Host nicht möglich. Loop nicht als grün behauptet.
