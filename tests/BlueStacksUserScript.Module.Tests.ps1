BeforeAll {
  $manifestPath = "$PSScriptRoot/../src/BlueStacksUserScript/BlueStacksUserScript.psd1"
  Import-Module $manifestPath -Force
}

Describe 'Module manifest' {
  BeforeAll {
    $script:manifest = Test-ModuleManifest "$PSScriptRoot/../src/BlueStacksUserScript/BlueStacksUserScript.psd1"
  }

  It 'passes Test-ModuleManifest' {
    $script:manifest | Should -Not -BeNullOrEmpty
  }

  It 'has a parseable semantic version' {
    { [System.Management.Automation.SemanticVersion]$script:manifest.Version } | Should -Not -Throw
  }

  It 'exports ConvertTo-Milliseconds' {
    $script:manifest.ExportedFunctions.Keys | Should -Contain 'ConvertTo-Milliseconds'
  }

  It 'exports Export-BluestacksUserScript' {
    $script:manifest.ExportedFunctions.Keys | Should -Contain 'Export-BluestacksUserScript'
  }

  It 'exports Get-BluestacksSnippet' {
    $script:manifest.ExportedFunctions.Keys | Should -Contain 'Get-BluestacksSnippet'
  }

  It 'exports New-BluestacksUserScript' {
    $script:manifest.ExportedFunctions.Keys | Should -Contain 'New-BluestacksUserScript'
  }

  It 'exports the Delay alias' {
    $script:manifest.ExportedAliases.Keys | Should -Contain 'Delay'
  }

  It 'exports the Time alias' {
    $script:manifest.ExportedAliases.Keys | Should -Contain 'Time'
  }
}

Describe 'Module import' {
  It 'imports without error' {
    Get-Module BlueStacksUserScript | Should -Not -BeNullOrEmpty
  }

  It 'does not expose private function New-BluestacksClickEvents' {
    Get-Command -Module BlueStacksUserScript -Name 'New-BluestacksClickEvents' -ErrorAction SilentlyContinue |
      Should -BeNullOrEmpty
  }

  It 'does not expose private function Copy-BluestacksSnippetAt' {
    Get-Command -Module BlueStacksUserScript -Name 'Copy-BluestacksSnippetAt' -ErrorAction SilentlyContinue |
      Should -BeNullOrEmpty
  }

  It 'does not expose private function Get-BluestacksSnippetDuration' {
    Get-Command -Module BlueStacksUserScript -Name 'Get-BluestacksSnippetDuration' -ErrorAction SilentlyContinue |
      Should -BeNullOrEmpty
  }
}
