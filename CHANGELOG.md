# Changelog

## 1.0.0 — 2026-07-30

- Added native macOS installation through `scripts/setup.sh`.
- Rebuilt the Windows installer with reliable native-command exit handling.
- Migrated Pi installation to `@earendil-works/pi-coding-agent`.
- Pinned Pi, vault tools, and Obsidian plugin versions for reproducible builds.
- Added strict Obsidian vault validation and isolated temporary build directories.
- Made GitHub backup opt-in, private-first, previewed, and confirmation-gated.
- Added a cross-platform compatibility patch for the upstream Obsidian Pi plugin.
- Replaced outdated API-key instructions with Pi’s current `/login` flow.
- Removed unsupported `/plan`, `/loop`, `/swarm`, and unverified cost claims.
- Added Windows/macOS validation in GitHub Actions.
