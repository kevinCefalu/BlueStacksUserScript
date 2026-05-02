BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force

  # Create a minimal macro JSON for analysis
  $script:macroDir = Join-Path $TestDrive 'macros'
  New-Item -ItemType Directory -Path $script:macroDir | Out-Null

  $script:macroPath = Join-Path $script:macroDir 'test-macro.json'
  $script:emptyPath = Join-Path $script:macroDir 'empty-macro.json'

  $macroJson = [PSCustomObject]@{
    Events = @(
      # A click pair at (26, 40)
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseDown'; Timestamp = 100;  X = 26.0; Y = 40.0 }
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseUp';   Timestamp = 150;  X = 26.0; Y = 40.0 }
      # A swipe
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseDown'; Timestamp = 500;  X = 10.0; Y = 50.0 }
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseMove'; Timestamp = 510;  X = 20.0; Y = 50.0 }
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseUp';   Timestamp = 520;  X = 30.0; Y = 50.0 }
    )
  } | ConvertTo-Json -Depth 5
  Set-Content -Path $script:macroPath -Value $macroJson

  $emptyJson = [PSCustomObject]@{ Events = @() } | ConvertTo-Json -Depth 5
  Set-Content -Path $script:emptyPath -Value $emptyJson
}

Describe 'Invoke-BluestacksEventAnalysis' {
  It 'throws when the path does not exist' {
    { Invoke-BluestacksEventAnalysis -Path (Join-Path $TestDrive 'missing.json') } | Should -Throw
  }

  It 'returns a PSCustomObject' {
    $result = Invoke-BluestacksEventAnalysis -Path $script:macroPath
    $result | Should -BeOfType [PSCustomObject]
  }

  It 'returns TotalEvents equal to the event count in the file' {
    $result = Invoke-BluestacksEventAnalysis -Path $script:macroPath
    $result.TotalEvents | Should -Be 5
  }

  It 'returns TypeCounts with entries for each EventType' {
    $result = Invoke-BluestacksEventAnalysis -Path $script:macroPath
    $result.TypeCounts | Should -Not -BeNullOrEmpty
    $result.TypeCounts.EventType | Should -Contain 'MouseDown'
  }

  It 'detects click pairs in ClickBuckets' {
    $result = Invoke-BluestacksEventAnalysis -Path $script:macroPath
    $result.ClickBuckets | Should -Not -BeNullOrEmpty
  }

  It 'detects swipes' {
    $result = Invoke-BluestacksEventAnalysis -Path $script:macroPath
    $result.Swipes | Should -Not -BeNullOrEmpty
  }

  It 'returns Path property matching the input' {
    $result = Invoke-BluestacksEventAnalysis -Path $script:macroPath
    $result.Path | Should -Be $script:macroPath
  }

  It 'handles empty event array gracefully' {
    $result = Invoke-BluestacksEventAnalysis -Path $script:emptyPath
    $result.TotalEvents | Should -Be 0
    $result.ClickBuckets.Count | Should -Be 0
    $result.Swipes.Count | Should -Be 0
  }
}
