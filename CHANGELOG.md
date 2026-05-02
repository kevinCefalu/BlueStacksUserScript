# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-05-02

### Added
- Initial public release.
- `ConvertTo-Milliseconds` — human-friendly duration helper with `Delay`/`Time` aliases.
- `Get-BluestacksSnippetDirectory` — resolves the snippet search path.
- `Get-BluestacksSnippet` — loads and caches named input-event snippets from disk.
- `Invoke-BluestacksEventAnalysis` — analyses a raw macro JSON file and returns structured statistics.
- `New-BluestacksUserScript` — compiles a sequence of steps (Click, Swipe, CircleClick, Snippet, Wait) into an event array.
- `Export-BluestacksUserScript` — builds and writes a BlueStacks InputMapper JSON file.
- `New-BluestacksSwipeEvents` — generates a drag-gesture event array.
- `New-BluestacksCircleClickEvents` — generates evenly-spaced taps around a circle.
- Pester v5 test suite with ≥ 80 % line coverage.
- Invoke-Build task file for local development.
- GitHub Actions CI (lint + test) and publish (PS Gallery on version tag) workflows.
