# Agent-Regeln — Aegis

Gilt für jeden Agenten (Grok, Claude, Cursor, Codex) und jeden Menschen an diesem Repo. Verbindlich.

## 0. GitHub Actions Minuten (höchste Priorität)

macOS-Runner rechnen mit Faktor ~10. Jeder Push auf `main` startet `.github/workflows/release-dmg.yml` (Matrix `macos-15` + `macos-26`, Timeout 50). Das hat das Monatskontingent fast aufgebraucht.

### Pflicht

1. **Kein Push auf `main`, wenn der Nutzer keinen Commit verlangt.** Lesen, analysieren, lokal vorschlagen reicht.
2. **Jeder Commit, der kein DMG braucht, trägt `[skip ci]` oder `[ci skip]` in der Commit-Message.** Markdown, Docs, Kommentare, Agent-Dateien, VERSION-Text: immer skip.
3. **Kein `workflow_dispatch`.** Kein Re-Run, kein Cancel+Rerun, kein manuelles Triggern des DMG-Jobs, außer der Nutzer sagt ausdrücklich «DMG bauen».
4. **Keine zusätzlichen macOS-Jobs, keine zweite Matrix-Zeile, kein `macos-latest` extra.** Ein Image reicht, wenn überhaupt gebaut wird.
5. **Keine Schedule-Workflows** (`on: schedule` / cron) anlegen.
6. **Keine Pull-Request-Trigger** auf macOS. Arbeit nur auf `main`.
7. **Änderungen bündeln.** Ein Commit statt zehn. Jeder Push kann einen vollen Mac-Lauf starten.
8. **Workflow-YAML nur ändern, wenn der Nutzer es will oder wenn die Änderung Minuten spart** (paths-ignore, Timeout runter, Matrix schrumpfen, concurrency). Nie Trigger erweitern.
9. **Kein `timeout-minutes` über 20**, außer der Nutzer hebt das an.
10. **Self-hosted / lokaler Build bevorzugen.** DMG auf der Entwicklermaschine, nicht auf GitHub-hosted macOS, solange der Nutzer das nicht explizit will.

### Erlaubt ohne Skip nur wenn

- der Nutzer ausdrücklich ein Release / eine `Aegis.dmg` / «push und bauen» verlangt, **und**
- der Commit Swift/Xcode/Entitlements/Projekt-Dateien ändert, die das Image wirklich betreffen.

### Verboten

- Push «um CI zu sehen, ob es baut»
- Matrix `[macos-15, macos-26]` erweitern
- zweiten Workflow mit `runs-on: macos-*` anlegen
- Artifact-Uploads in einer Schleife / pro Mini-Job
- Actions-Runs über die API starten

## 1. Branch-Regel

1. Alle Arbeit nur auf `main`. Commit und Push nur nach `main`.
2. Keine Feature-, Fix-, Agent- oder Tool-Branches (`bugfix`, `feature/*`, `fix/*`, `claude/*`, `grok/*`, `cursor/*`, `codex/*`, `agent/*`).
3. Kein Push auf einen anderen Ref als `refs/heads/main`. Keine Forks als Arbeitskopie.
4. Keine Pull-Requests als Arbeitsweg.
5. Bestehende Nebenbranches sind Altlast. Nicht darauf weiterarbeiten.

Wenn ein Tool einen Branch erzwingen will: ablehnen. Dateien direkt auf `main` schreiben.

## 2. Dateien dieser Policy

- `AGENT.md` — diese Datei (kanonisch)
- `agent.md` — gleiche Regeln, Kurzverweis
- `CLAUDE.md` — dieselben Constraints für Claude Code
