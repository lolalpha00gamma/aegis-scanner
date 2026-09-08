# Aegis Vorschläge — 2026-09-08

Stand 2.1.202 alpha Build 227. Ergänzung, keine Kopie von 2.1.188–202.

## Erweiterung (neu)

17. **FaceTrack = einzige Map.** Hold/Peak/PairLast/NameLock/Hash/Bin Felder einer Struct. P0.
18. **Assign atomar** eine Funktion, ein Write. Kein HoldMove-dann-TickCopy.
19. **Print-Index** Pose-Bin × Name vor Cosine. Gallery nicht linear.
20. **Gemeinsamer CVPixelBuffer** Detect+Print, JPEG nur Export.
21. **Temperature Cosine** statt hart 0,80. Calibration auf eigenen Prints.
22. **VNTrackObjectRequest** Box halten zwischen Detect-Ticks (8 fps).
23. **Overlay CAMetalLayer 60 Hz**, Detect 8–24, Lerp 2.1.202 reicht nicht ohne Layer.
24. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
25. **HeliosAegisKit** Mutex v2 + PTS + SlotKind.
26. **RTSP 420f** Backoff, Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
27. **P-Slot Maske/Schal**, Brille Twin-Veto.
28. **ReID-Graph** Hold-Trail, nicht nur Last-Print.
29. **gallery.json.bak Rotate 3** + printRevision je Identity (Funktion existiert, Store prüfen).
30. **Licht-Eimer** frontal / ¾ / Profil getrennte Prototypen.
31. **Match-Log JSONL** Replay gegen eine Twin-Restart-Fixture.
32. **Drop-in `.mlmodel`** FaceEmbedder-Protokoll.
33. **Stereo Built-in + Continuity** Disparität als Yaw-Prior.
34. **LiveCapture nicht @MainActor.** Detect outputQueue. Slider isolieren.
35. **Enroll-SM** Front → ¾L → ¾R → Blink als Pflichtpfad, kein Burst 0,98.
36. **Solo-Rescue nur wenn holdIDs.count==1 UND tableKeys.count==1.** Fremder Hash nie stehlen.
37. **Occupied nur Live-Hashes**, Ghost nach Coast-TTL.
38. **Baptize gegen denselben Buffer** wie Detect, Qualität vor Cosine.
39. **Hung-Detect Cancel** nach 1 s, FrameTap drop-oldest bleibt.
40. **Tests: eine Fixture Restart+Twin+AssignLive.** Orakel auf 40 Bools stoppen.

Kein 2.1.203-Flag ohne 17 oder 24.
