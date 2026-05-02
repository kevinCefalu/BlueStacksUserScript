<#
  Invoke-Build task file for BlueStacksUserScript.
  Run with: ./build.ps1  (or  Invoke-Build in this directory)
#>

$ModuleName   = 'BlueStacksUserScript'
$SrcRoot      = "$BuildRoot/src/$ModuleName"
$OutputRoot   = "$BuildRoot/output/$ModuleName"
$TestsRoot    = "$BuildRoot/tests"
$ManifestPath = "$SrcRoot/$ModuleName.psd1"

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
  $results  = Invoke-ScriptAnalyzer -Path $SrcRoot -Recurse -Settings $settings

  if ($results) {
    $results | Format-Table -AutoSize
    throw "PSScriptAnalyzer found $($results.Count) issue(s)."
  }
  Write-Build Green 'Lint passed.'
}

# ── Test ──────────────────────────────────────────────────────────────────────
task Test {
  $config = New-PesterConfiguration
  $config.Run.Path              = $TestsRoot
  $config.Output.Verbosity      = 'Normal'
  $config.CodeCoverage.Enabled  = $true
  $config.CodeCoverage.Path     = "$SrcRoot/**/*.ps1"
  $config.CodeCoverage.OutputPath          = "$BuildRoot/output/coverage.xml"
  $config.CodeCoverage.OutputFormat        = 'JaCoCo'
  $config.TestResult.Enabled               = $true
  $config.TestResult.OutputPath            = "$BuildRoot/output/testResults.xml"
  $config.TestResult.OutputFormat          = 'NUnitXml'
  $config.CodeCoverage.CoveragePercentTarget = 80

  $result = Invoke-Pester -Configuration $config

  if ($result.FailedCount -gt 0) {
    throw "$($result.FailedCount) Pester test(s) failed."
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
