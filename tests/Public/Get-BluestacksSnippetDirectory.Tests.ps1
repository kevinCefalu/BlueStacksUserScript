BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force
}

Describe 'Get-BluestacksSnippetDirectory' {
  It 'returns a string' {
    Get-BluestacksSnippetDirectory | Should -BeOfType [string]
  }

  It 'returns the module snippets folder when no argument is supplied' {
    $result = Get-BluestacksSnippetDirectory
    $result | Should -Match 'snippets'
  }

  It 'resolves a relative path to an absolute path' {
    $result = Get-BluestacksSnippetDirectory -SnippetDir '.'
    [System.IO.Path]::IsPathRooted($result) | Should -BeTrue
  }

  It 'returns the resolved absolute path for a custom directory' {
    $result = Get-BluestacksSnippetDirectory -SnippetDir $TestDrive
    $result | Should -Be $TestDrive
  }
}
