# CLAUDE.md — Aegis

Lies zuerst `AGENT.md`. Die Regeln dort sind bindend.

## Actions-Minuten — für Claude zwingend

Dieses private Repo verbraucht GitHub Actions Minuten vor allem durch Agent-Pushes auf `main`. Der Workflow `Aegis.dmg` läuft auf **jedem** Push nach `main` auf **zwei** macOS-Runnern (`macos-15` und `macos-26`). Eine echte Minute kostet ~10 Abrechnungsminuten.

Du (Claude) darfst:

- Dateien lesen, analysieren, Diffs vorschlagen
- nur dann committen/pushen, wenn der Nutzer das ausdrücklich will
- bei jedem nicht-DMG-Commit `[skip ci]` in die Message schreiben
- Markdown, Docs, `CLAUDE.md`, `AGENT.md` immer mit `[skip ci]` pushen

Du darfst nicht:

- `workflow_dispatch` oder Re-Runs auslösen
- neue macOS-Jobs oder Matrix-Zeilen anlegen
- `on: schedule` setzen
- PRs oder Nebenbranches anlegen
- «mal eben pushen, damit CI baut»
- Timeout über 20 Minuten setzen
- mehrere Mini-Pushes statt eines gebündelten Commits

DMG auf GitHub-hosted macOS nur, wenn der Nutzer wörtlich ein Image / Release verlangt.

Default-Branch: nur `main`.
