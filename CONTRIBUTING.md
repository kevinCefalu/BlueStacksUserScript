# Contributing

Thank you for your interest in contributing!

## Development setup

1. Fork and clone the repository.
2. Install build tools:
   ```powershell
   Install-Module InvokeBuild      -Scope CurrentUser
   Install-Module Pester           -Scope CurrentUser -MinimumVersion 5.0
   Install-Module PSScriptAnalyzer -Scope CurrentUser
   ```
3. Run `./build.ps1` to lint, test, and build locally.

## Guidelines

- One function per file under `src/BlueStacksUserScript/Public/` or `Private/`.
- Every public function must have complete comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.OUTPUTS`, `.EXAMPLE`).
- New public functions must be accompanied by a corresponding Pester test file under `tests/Public/`.
- All `Invoke-ScriptAnalyzer` warnings must be resolved before submitting a PR.
- Pester code coverage must remain at or above 80 %.

## Pull requests

- Target the `main` branch.
- Summarise your changes in `CHANGELOG.md` under `[Unreleased]`.
- CI must be green before merge.
