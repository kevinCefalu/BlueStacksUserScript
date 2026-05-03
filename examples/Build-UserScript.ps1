<#
.SYNOPSIS
  Builds the configured BlueStacks UserScript JSON.

.DESCRIPTION
  Keeps the macro sequence definition in this file, while delegating snippet
  management, event analysis, sequence compilation, and JSON export to the
  BlueStacksUserScript module under src\.

  STEP TYPES
    Snippet  - load a named .json file from the module-owned snippets directory
    Click    - inline tap defined as @(X, Y) -> emits MouseDown + MouseUp
    Swipe    - emit a drag gesture from a start point to an end point
    CircleClick - emit taps evenly around a circle from inline parameters
    Wait     - silent pause (ms), no events emitted

  COMMON KEYS (apply to Snippet, Click, Swipe, and CircleClick)
    Repeat          - emit the action N times              (default 1)
    RepeatInterval  - ms gap between successive emissions  (default 100)
    HoldMs          - tap duration for Click steps         (default 50)
    DelayAfter      - ms of silence after the step/repeats (default 100)

.PARAMETER OutputFile
  Path to write the assembled JSON.

.PARAMETER StartOffset
  Milliseconds before the very first event.

.PARAMETER WhatIf
  Print a step-by-step timing summary without writing any file.
#>

[CmdletBinding(SupportsShouldProcess)]

param(
  [Parameter(Mandatory)]
  [string] $OutputFile,

  [Parameter()]
  [int] $StartOffset = 100
);

Set-StrictMode -Version 'Latest';
$ErrorActionPreference = 'Stop';

Import-Module ($PSScriptRoot | Join-Path -ChildPath '..\src\BlueStacksUserScript\BlueStacksUserScript.psd1') -Force;

$AdGemBtn = @(26, 40);
$ForFloatingGem = @{
  CenterX = 50; CenterY = 25.5;
  Radius = 12.5; ClickCount = 180;
  IntervalMs = 15;
};

$Sequence = @(
  <# Ad Gem #> @{ Click = $AdGemBtn; }
  <# Floating Gem #> @{
    CircleClick = $ForFloatingGem;
    DelayAfter = (Delay -S 15);
  };
);

$exportParams = @{
  Sequence = $Sequence;
  OutputFile = $OutputFile;
  StartOffset = $StartOffset;
  Preview = $WhatIfPreference;
};

$build = Export-BluestacksUserScript @exportParams;

$build;
