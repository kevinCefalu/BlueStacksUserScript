BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force

  $script:snippetDir = Join-Path $TestDrive 'snippets'
  New-Item -ItemType Directory -Path $script:snippetDir | Out-Null

  $json = [PSCustomObject]@{
    Events = @(
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseDown'; Timestamp = 0;   X = 10.0; Y = 20.0 }
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseUp';   Timestamp = 100; X = 10.0; Y = 20.0 }
    )
  } | ConvertTo-Json -Depth 5
  Set-Content -Path (Join-Path $script:snippetDir 'tap100.json') -Value $json
}

Describe 'Get-BluestacksSnippetDuration (private)' {
  InModuleScope BlueStacksUserScript {
    It 'returns the maximum Timestamp of the snippet' {
      $snippetDir = Join-Path $TestDrive 'snippets'
      $duration = Get-BluestacksSnippetDuration -Name 'tap100' -SnippetDir $snippetDir
      $duration | Should -Be 100
    }

    It 'returns a long integer' {
      $snippetDir = Join-Path $TestDrive 'snippets'
      $duration = Get-BluestacksSnippetDuration -Name 'tap100' -SnippetDir $snippetDir
      $duration | Should -BeOfType [long]
    }
  }
}
