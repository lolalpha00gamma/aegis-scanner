# Helios + Aegis — Analyse 2026-09-04 (2.1.68)

Helios **1.5.52** (Build 72). Aegis **2.1.68 alpha** (Build 94). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.67 noch sprangen

2.1.67 hat Ghost-Pool, Größen-Hash, Twin-Steal und Trail-über-Dropout wirklich verdrahtet. Fünf Löcher blieben — plus Dropout-Wipe, das Hold wieder tot machte:

1. **Slot hart tot.** `leftoverPick` gab `nil` sobald sameSlot alle false. Kopfdrehen F→¾→P: Streak weg, Overlay Gast, dann Sprung. Hold 0,64 lag in der Tabelle und niemand las sie, weil Pick nie kam.
2. **Hold ohne Transfer machte Gast.** `leftoverTransfersId` verweigerte Steal unter 0,80 — und der else-Zweig schrieb `guestOrder` plus `used.insert(old.id)`. Anna wurde verbraucht, Live wurde Gast. Genau der Sprung, den 2.1.67 verhindern sollte.
3. **`holdPrev != nil` skippte 1,2 s auch bei 0,00.** Müll-Hold war Adopt.
4. **Kleine Kiste sprang 2 Bins.** ±1 reichte nicht, wenn width-Bin 0/1 ist. Hash-Hold tot nach einem Schritt nach vorn.
5. **`centroidWeight` war tot.** `meanPrintVector` hatte die Formel inline, nicht die Math. `printWeights` ebenfalls.
6. **Leerer Frame wischte UUID-Hold.** Hash-TTL blieb, `leftoverHold = [:]`, `leftoverHoldTrail = [:]`, `liveSlotHold = [:]`. Kopfdrehen + Dropout: Hash verfehlt die Kiste, holdPrev nil, 1,2 s Gast-Fenster.

## Was 2.1.68 wirklich ändert

1. **`leftoverAllowsCrossSlot`.** sameSlot fehlt: Print ≥ 0,64 darf picken. 0,50 bleibt tot. Same-Slot gewinnt weiter gegen 0,01.
2. **`leftoverHoldsTrack`.** 0,64–0,79: Overlay „gehalten“, UUID bleibt, Live wird nicht Gast, leftover bleibt im Pool. Streak wird erst bei Transfer/Gast gelöscht.
3. **`leftoverAdoptReady`.** Skip nur bei `leftoverPrintOk(holdPrev)`, nicht bei jedem non-nil.
4. **Kleine-Box-Radius 2.** w/h-Bin ≤ 1: Nachbarn ±2 in Position und Größe.
5. **`centroidWeight` in `meanPrintVector` / Partial / `printWeights`.** Eine Formel.
6. **`leftoverHoldSurvive`.** Dropout: UUID-Hold, Trail und Slot-Hold am Ghost, nicht Wipe. Hash allein reicht nicht nach Kopfdrehen.
7. leftoverHold / Slot-Hold überleben, solange leftoverPinned die UUID kennt.
8. VERSION = Models = MARKETING_VERSION 2.1.68 (Build 94).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge.

Helios 1.5.52: Pinch-Open, Tasche (auch dunkel), destClamp im Display-Link, Relativ-Span, Pointer-Pool. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
