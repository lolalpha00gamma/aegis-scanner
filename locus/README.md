# Locus — Standortverlauf (eigenes Produkt)

**Nicht Aegis.** Face-Scanner bleibt unter `macos/`. Locus liegt nur hier unter `locus/`.

macOS-App: liest in einstellbarem Intervall den lokalen Find-My-Cache (`~/Library/Caches/com.apple.findmy.fmipcore/`) plus optional den eigenen Mac per CoreLocation, speichert Snapshots als Verlauf und zeigt sie auf einer MapKit-Karte (Zoom, Zeiten, Geräteliste, Polyline).

## Datenquellen

1. **Find-My-Cache (eigene Geräte/Items/Personen auf diesem Mac)**  
   `Items.data`, `Devices.data`, `People.data`. Wenn die Datei noch JSON ist, wird der letzte Fix übernommen. Ab macOS 14.4 ist der Cache oft verschlüsselt — Locus markiert das und sammelt dann nur noch ab dem Moment, in dem wieder lesbare Fixes ankommen, plus eigenen Mac-Standort.
2. **Dieser Mac (CoreLocation)** nach Systemdialog.
3. **Import** JSON (Array von `{id,name,kind,lat,lon,timestamp}`).

Kein privates Apple-Report-API, kein Keychain-Key-Grab. Verlauf entsteht durch regelmässiges Snapshotten.

## Bauen / Signieren (lokal, nicht GitHub Actions)

```bash
cd locus
./build-locus.sh          # Locus.app + Locus.dmg (adhoc falls kein Cert)
./build-locus.sh sign     # nutzt ../macos/ci-sign.sh + Locus.entitlements
```

CI-Workflow `release-dmg.yml` bleibt **Aegis-only**. Locus nicht in die Matrix hängen.
