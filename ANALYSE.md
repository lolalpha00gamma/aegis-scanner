# Helios + Aegis — Analyse 2026-09-04

Beide Repos sind keine leeren Scanner. Helios ist Gestensteuerung (1.5.46, Build 66). Aegis ist Live-ReID (2.1.61 alpha, Build 88). Sie wirken „schlecht“, weil die **Wahrnehmung ungleichmäßig** ist und der **Zustand zu viele Uhren** hat.

## Helios — warum der Cursor lügt

| Schicht | Was schiefgeht | Symptom |
|---|---|---|
| Kamera | Continuity 8 fps, Built-in 24 fps, Desk-View ungespiegelt vs Front | Pinch-Need 90 vs 180 ms, erster Frame nach Lock klickt |
| Vision | 21 2D-Joints, Confidence 0,12–0,18, Ghost 0,60 s | Faust-Scharf am Knie, Peace-Screenshot aus toter Pose |
| Map | Eine Homographie, ein Dest-Rect, kein Blend beim Screen-Wechsel | Warp an Monitorgrenze, Kalib „fertig“ bei RMS 70 px |
| AX | Probe-TTL, Traffic-Walk, SwiftUI kann AXPosition nicht | Klick in Fenstermitte, Helios selbst ungreifbar |
| Engine | 40+ Gatter (Need, Travel, Clutch, Latch, Skip-AX, Dead-Man, Lid) | Ein Tick blockt den nächsten; Changelog ist eine Kette von Selbstfixes |

1.5.38–1.5.46 sind fast nur **Folgeschäden** der vorigen Version. `predictPalm` wurde gelöscht und die App kompilierte nicht. `lidClosed` war Math ohne IOKit. Trackpad 6 px stahl den Zeiger während Palm-Gain.

Das ist kein fehlendes Feature. Das ist ein **zu dünnes Modell der Hand** (2D-Ratio statt 3D-Tip-Z) plus **zu viele Schwellen**, die denselben Tick lesen.

Was wirklich Masse bringen würde, in dieser Reihenfolge:

1. Eine State-Machine mit wenigen Phasen (`idle / armed / pinch / drag / scale`) und **einem** Clock (`lastTickT`). Alle Need-Uhren davon ableiten.
2. Homographie **pro Display** + 120 ms Blend.
3. Shared Frame-Pump mit Aegis.
4. Vision Revision 2 (3D) für Pinch.
5. Haptik + 8 ms Klick-Sound — ohne Feedback wirkt jede korrekte Aktion tot.

`bugfix`-Loop auf GestureEngine ohne macos-26-Runner nicht. Drei Clean-Passes auf 64 kB Engine ohne Gerät erzeugen die nächste 1.5.47-Regression.

## Aegis — warum Namen springen

Matching ist nicht „Cosine > 0,78“. Live-ReID ist:

```
Box → NMS → Print (manchmal skip) → Geo → leftover-Assign
    → Majority 3 → Name-Lock 8 s → Ghost-TTL → Open-Set Floor
```

Widersprechen sich zwei Stufen, tauft die dritte trotzdem. Deshalb Twin 0,91 still als Anna, Ghost 0,64 stiehlt UUID, Poster ohne Blink.

`MatchMath` ist inzwischen ein Katalog von Pflastern (`leftoverPickAspect`, `twoPersonAnd`, `posterNeedsBlink`, `boxKalman`, …). Tests sind grün. Das Overlay folgt oft **eine Version später**.

Was Masse bringen würde:

1. **Konflikt-Tick:** BOX/PRINT/GEO/LOCK müssen einig sein, sonst keine Taufe.
2. Per-Kamera-Centroid.
3. Enrollment-Burst, schärfstes Ref.
4. Live-FAR sichtbar.
5. Guest als persistente Klasse, nicht „nächste Anna“.
6. Helios-Bridge.

## Was diese Session nicht tut

Kein weiterer Math-only-Bump auf 1.5.47 / 2.1.62. Die Listen in `VORSCHLAEGE.md` sind um die strukturellen Punkte und neue Ideen ergänzt. Code-Änderungen an Engine/Store ohne Xcode 26 wären genau das Muster, das die Repos „schlecht“ macht.
