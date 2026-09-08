# Aegis Vorschläge — 2026-09-08 (Pass 2, 2.1.203)

Stand 2.1.203 alpha Build 228. Ergänzung, keine Kopie von 2.1.188–202.

## Gelandet in 2.1.203

Solo-Rescue `facesInFrame` (Solo + Rescue-Produktion), Occupied GhostDrop in LibraryStore, `FaceTrack` Struct, `leftoverAssignAtomicAll`. Engine schreibt die 20 Maps noch — Atomic ist der Einstieg, nicht der Riss.

## Erweiterung (neu)

17. **FaceTrack = einzige Map.** Hold/Peak/PairLast/NameLock/Hash/Bin Felder einer Struct. P0. Struct existiert, Store noch 20 Dicts.
18. **Assign atomar verdrahten** in LibraryStore — Funktion ist da, Call-Sites nicht.
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
29. **gallery.json.bak Rotate 3** + printRevision je Identity.
30. **Licht-Eimer** frontal / ¾ / Profil getrennte Prototypen.
31. **Match-Log JSONL** Replay gegen eine Twin-Restart-Fixture.
32. **Drop-in `.mlmodel`** FaceEmbedder-Protokoll.
33. **Stereo Built-in + Continuity** Disparität als Yaw-Prior.
34. **LiveCapture nicht @MainActor.** Detect outputQueue. Slider isolieren.
35. **Enroll-SM** Front → ¾L → ¾R → Blink als Pflichtpfad, kein Burst 0,98.
36. **Hung-Detect Cancel** nach 1 s, FrameTap drop-oldest bleibt.
37. **FaceTrack.id** über uniqueID-Reconnect via Print+Yaw-Bin.
38. **Print auf Metal** statt JPEG-Roundtrip.
39. **Twin-Lock** cosine > 0,90: keine Taufe bis Yaw 15° divergiert.
40. **Gallery HDBSCAN** statt pruneCosine 0,98.
41. **420f vs 420v** Color-Space-Mismatch Continuity/Built-in → Cosine-Drop.
42. **Time-to-identity HUD** ms seit letztem stabilen Namen.
43. **Negative Gallery** „nicht Ada“-Prints für harte Twins.
44. **Tests: eine Fixture Restart+Twin+AssignLive.** Orakel auf 40 Bools stoppen.
45. **leftoverAssignAtomicAll** in HoldMove/TickCopy/AssignLive — nicht nur MatchMath.
46. **Print-Yaw als Occupied-Prior** statt Hamming wenn |yaw| > 25°.

Kein 2.1.204-Flag ohne 17 verdrahtet oder 24.
