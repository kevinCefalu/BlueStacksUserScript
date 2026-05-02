# BlueStacksUserScript

[![CI](https://github.com/you/BlueStacksUserScript/actions/workflows/ci.yml/badge.svg)](https://github.com/you/BlueStacksUserScript/actions/workflows/ci.yml)
[![PS Gallery](https://img.shields.io/powershellgallery/v/BlueStacksUserScript)](https://www.powershellgallery.com/packages/BlueStacksUserScript)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A PowerShell module for building and analysing **BlueStacks InputMapper** macro JSON files from composable snippets and inline gestures.

---

## Installation

```powershell
Install-Module BlueStacksUserScript -Scope CurrentUser
```

## Quick start

```powershell
Import-Module BlueStacksUserScript

$sequence = @(
    @{ Click = @(26, 40) }
    @{ CircleClick = @{ CenterX=50; CenterY=25.5; Radius=12.5; ClickCount=180; IntervalMs=15 }; DelayAfter = (Delay -S 15) }
)

Export-BluestacksUserScript -Sequence $sequence -OutputFile '.\my-macro.json'
```

## Snippet authoring

1. Record a macro in BlueStacks and save the raw JSON.
2. Place the file in `src\BlueStacksUserScript\snippets\<name>.json`.
3. Reference it in a sequence step: `@{ Snippet = '<name>' }`.

The snippet loader normalises all event timestamps to start at zero and caches the result for the module session.

## Step types

| Key | Description |
|---|---|
| `Snippet` | Load a named `.json` snippet file |
| `Click` | Inline tap: `@(X, Y)` |
| `Swipe` | Drag from Start to End |
| `CircleClick` | Evenly-spaced taps around a circle |
| `Wait` | Silent pause in milliseconds |

### Common keys (all action steps)

| Key | Default | Description |
|---|---|---|
| `Repeat` | 1 | Repeat the action N times |
| `RepeatInterval` | 20 | Milliseconds between repetitions |
| `HoldMs` | 20 | Tap-hold duration for Click steps |
| `DelayAfter` | 20 | Milliseconds of silence after the step |

## Function reference

| Function | Description |
|---|---|
| `ConvertTo-Milliseconds` | Convert hours/minutes/seconds/ms to a total millisecond integer |
| `Get-BluestacksSnippetDirectory` | Resolve the snippet search path |
| `Get-BluestacksSnippet` | Load and cache a named snippet |
| `Invoke-BluestacksEventAnalysis` | Return structured statistics about a raw macro JSON |
| `New-BluestacksUserScript` | Compile a sequence into an event array |
| `Export-BluestacksUserScript` | Build and write the macro JSON file |
| `New-BluestacksSwipeEvents` | Generate a drag-gesture event array |
| `New-BluestacksCircleClickEvents` | Generate evenly-spaced taps around a circle |

Run `Get-Help <FunctionName> -Full` for detailed parameter documentation and examples.

## Local development

```powershell
# Install build tools once
Install-Module InvokeBuild      -Scope CurrentUser
Install-Module Pester           -Scope CurrentUser -MinimumVersion 5.0
Install-Module PSScriptAnalyzer -Scope CurrentUser

# Lint + test + build
./build.ps1

# Tests only
./build.ps1 -Task Test
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
