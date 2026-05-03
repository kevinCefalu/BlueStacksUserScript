Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force

BeforeAll {
  $script:snippetDir = Join-Path $TestDrive 'snippets'
  New-Item -ItemType Directory -Path $script:snippetDir | Out-Null

  $json = [PSCustomObject]@{
    Events = @(
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseDown'; Timestamp = 0;  X = 10.0; Y = 20.0 }
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseUp';   Timestamp = 50; X = 10.0; Y = 20.0 }
    )
  } | ConvertTo-Json -Depth 5
  Set-Content -Path (Join-Path $script:snippetDir 'tap.json') -Value $json
}

Describe 'Copy-BluestacksSnippetAt (private)' {
  InModuleScope BlueStacksUserScript {
    It 'returns the same number of events as the source snippet' {
      $snippetDir = Join-Path $TestDrive 'snippets'
      $result = Copy-BluestacksSnippetAt -Name 'tap' -BaseTimestamp 1000 -SnippetDir $snippetDir
      $result.Count | Should -Be 2
    }

    It 'shifts all timestamps by BaseTimestamp' {
      $snippetDir = Join-Path $TestDrive 'snippets'
      $result = Copy-BluestacksSnippetAt -Name 'tap' -BaseTimestamp 500 -SnippetDir $snippetDir
      $result[0].Timestamp | Should -Be 500
      $result[1].Timestamp | Should -Be 550
    }

    It 'preserves X and Y values' {
      $snippetDir = Join-Path $TestDrive 'snippets'
      $result = Copy-BluestacksSnippetAt -Name 'tap' -BaseTimestamp 0 -SnippetDir $snippetDir
      $result[0].X | Should -Be 10.0
      $result[0].Y | Should -Be 20.0
    }
  }
}
