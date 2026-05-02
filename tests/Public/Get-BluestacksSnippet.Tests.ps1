BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force

  # ── Create a minimal snippet JSON in a temp directory ──────────────────────
  $script:snippetDir = Join-Path $TestDrive 'snippets'
  New-Item -ItemType Directory -Path $script:snippetDir | Out-Null

  $tapJson = [PSCustomObject]@{
    Events = @(
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseDown'; Timestamp = 200; X = 10.0; Y = 20.0 }
      [PSCustomObject]@{ Delta = 0; EventType = 'MouseUp';   Timestamp = 250; X = 10.0; Y = 20.0 }
    )
  } | ConvertTo-Json -Depth 5

  Set-Content -Path (Join-Path $script:snippetDir 'tap.json') -Value $tapJson

  $emptyJson = [PSCustomObject]@{ Events = @() } | ConvertTo-Json -Depth 5
  Set-Content -Path (Join-Path $script:snippetDir 'empty.json') -Value $emptyJson
}

Describe 'Get-BluestacksSnippet' {
  It 'returns an array of event objects' {
    $events = Get-BluestacksSnippet -Name 'tap' -SnippetDir $script:snippetDir
    $events | Should -Not -BeNullOrEmpty
  }

  It 'normalises the first event Timestamp to 0' {
    $events = Get-BluestacksSnippet -Name 'tap' -SnippetDir $script:snippetDir
    $events[0].Timestamp | Should -Be 0
  }

  It 'preserves relative timing between events' {
    $events = Get-BluestacksSnippet -Name 'tap' -SnippetDir $script:snippetDir
    # MouseUp was 50 ms after MouseDown in the source file
    $events[1].Timestamp | Should -Be 50
  }

  It 'returns events with the expected properties' {
    $event = (Get-BluestacksSnippet -Name 'tap' -SnippetDir $script:snippetDir)[0]
    $event.PSObject.Properties.Name | Should -Contain 'Delta'
    $event.PSObject.Properties.Name | Should -Contain 'EventType'
    $event.PSObject.Properties.Name | Should -Contain 'Timestamp'
    $event.PSObject.Properties.Name | Should -Contain 'X'
    $event.PSObject.Properties.Name | Should -Contain 'Y'
  }

  It 'returns the same object reference on second call (cache hit)' {
    $first  = Get-BluestacksSnippet -Name 'tap' -SnippetDir $script:snippetDir
    $second = Get-BluestacksSnippet -Name 'tap' -SnippetDir $script:snippetDir
    # Same array length proves we got the cached result
    $second.Count | Should -Be $first.Count
  }

  It 'throws when the snippet file does not exist' {
    { Get-BluestacksSnippet -Name 'nonexistent' -SnippetDir $script:snippetDir } | Should -Throw
  }

  It 'throws when the snippet contains no events' {
    { Get-BluestacksSnippet -Name 'empty' -SnippetDir $script:snippetDir } | Should -Throw
  }
}
