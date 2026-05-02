<#
.SYNOPSIS
  Entry point for local builds.

.DESCRIPTION
  Thin wrapper that invokes Invoke-Build with the task file .build.ps1.
  Requires the InvokeBuild module: Install-Module InvokeBuild -Scope CurrentUser

.PARAMETER Task
  One or more task names to run.  Defaults to 'Default' (Lint + Test + Build).

.EXAMPLE
  ./build.ps1

.EXAMPLE
  ./build.ps1 -Task Test

.EXAMPLE
  ./build.ps1 -Task Lint, Test
#>
#Requires -Modules @{ ModuleName = 'InvokeBuild'; ModuleVersion = '5.0' }

param(
  [string[]] $Task = 'Default'
)

Invoke-Build -Task $Task -File "$PSScriptRoot/.build.ps1"
