<#
  Invoke-Build task file for BlueStacksUserScript.
  Run with: ./build.ps1  (or  Invoke-Build in this directory)
#>

param(
  [string] $Version
)

$ModuleName = 'BlueStacksUserScript'
$SrcRoot = "$BuildRoot/src/$ModuleName"
$OutputRoot = "$BuildRoot/output/$ModuleName"
$TestsRoot = "$BuildRoot/tests"
$ManifestPath = "$SrcRoot/$ModuleName.psd1"

# ── Stamp Version ────────────────────────────────────────────────────────────
task StampVersion {
  if ([string]::IsNullOrWhiteSpace($Version)) {
    throw 'Version parameter is required for StampVersion task.'
  }
  (Get-Content $ManifestPath -Raw) -replace "ModuleVersion\s*=\s*'[^']*'", "ModuleVersion = '$Version'" |
    Set-Content $ManifestPath
  Write-Build Green "Stamped version $Version into $ManifestPath"
}

# ── Clean ─────────────────────────────────────────────────────────────────────
task Clean {
  if (Test-Path $OutputRoot) {
    Remove-Item $OutputRoot -Recurse -Force
    Write-Build Green "Cleaned $OutputRoot"
  }
}

# ── Lint ──────────────────────────────────────────────────────────────────────
task Lint {
  $settings = "$BuildRoot/.PSScriptAnalyzerSettings.psd1"
  $results = Invoke-ScriptAnalyzer -Path $SrcRoot -Recurse -Settings $settings

  if ($results) {
    $results | Format-Table -AutoSize
    throw "PSScriptAnalyzer found $($results.Count) issue(s)."
  }
  Write-Build Green 'Lint passed.'
}

# ── Test ──────────────────────────────────────────────────────────────────────
task Test {
  $config = New-PesterConfiguration
  $config.Run.Path = $TestsRoot
  $config.Output.Verbosity = 'Normal'
  $config.Run.PassThru = $true
  $config.CodeCoverage.Enabled = $true
  $config.CodeCoverage.Path = "$SrcRoot/**/*.ps1"
  $config.CodeCoverage.OutputPath = "$BuildRoot/output/coverage.xml"
  $config.CodeCoverage.OutputFormat = 'JaCoCo'
  $config.TestResult.Enabled = $true
  $config.TestResult.OutputPath = "$BuildRoot/output/testResults.xml"
  $config.TestResult.OutputFormat = 'NUnitXml'
  $config.CodeCoverage.CoveragePercentTarget = 80

  $result = Invoke-Pester -Configuration $config

  if ($null -eq $result) {
    throw 'Pester did not return a test result object. Failing Test task to avoid false positives.'
  }

  $failedCount = ($result.PSObject.Properties.Name -contains 'FailedCount') ? [int]$result.FailedCount : 0
  $failedBlocksCount = ($result.PSObject.Properties.Name -contains 'FailedBlocksCount') ? [int]$result.FailedBlocksCount : 0
  $totalCount = ($result.PSObject.Properties.Name -contains 'TotalCount') ? [int]$result.TotalCount : -1
  $status = ($result.PSObject.Properties.Name -contains 'Result') ? [string]$result.Result : 'Unknown'

  if ($totalCount -eq 0) {
    throw 'Pester discovered zero tests. Failing Test task to avoid false positives.'
  }

  if ($failedCount -gt 0 -or $failedBlocksCount -gt 0 -or $status -ne 'Passed') {
    throw "Pester run failed. Status=$status; FailedCount=$failedCount; FailedBlocksCount=$failedBlocksCount; TotalCount=$totalCount"
  }

  Write-Build Green "All $($result.PassedCount) tests passed."
}

# ── Build ─────────────────────────────────────────────────────────────────────
task Build Clean, {
  $null = New-Item $OutputRoot -ItemType Directory -Force
  Copy-Item $SrcRoot -Destination (Split-Path $OutputRoot) -Recurse -Force
  Write-Build Green "Module staged to $OutputRoot"
}

# ── Publish ───────────────────────────────────────────────────────────────────
task Publish {
  $apiKey = $env:PSGALLERY_API_KEY
  if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw 'PSGALLERY_API_KEY environment variable is not set.'
  }
  Publish-Module -Path $OutputRoot -NuGetApiKey $apiKey -Repository PSGallery -Verbose
  Write-Build Green "Published $ModuleName to PSGallery."
}

# ── Default ───────────────────────────────────────────────────────────────────
task Default Lint, Test, Build
