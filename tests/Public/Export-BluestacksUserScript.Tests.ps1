BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force
}

Describe 'Export-BluestacksUserScript' {
  Context 'File output' {
    It 'writes a JSON file' {
      $out    = Join-Path $TestDrive 'output.json'
      $result = Export-BluestacksUserScript -Sequence @(@{ Click = @(10, 10) }) -OutputFile $out
      Test-Path $out | Should -BeTrue
    }

    It 'written JSON has an Events array' {
      $out = Join-Path $TestDrive 'events.json'
      Export-BluestacksUserScript -Sequence @(@{ Click = @(10, 10) }) -OutputFile $out | Out-Null
      $json = Get-Content $out -Raw | ConvertFrom-Json
      $json.Events | Should -Not -BeNullOrEmpty
    }

    It 'returns a build result object' {
      $out    = Join-Path $TestDrive 'result.json'
      $result = Export-BluestacksUserScript -Sequence @(@{ Click = @(10, 10) }) -OutputFile $out
      $result.EventCount | Should -BeGreaterThan 0
    }

    It 'creates parent directory if it does not exist' {
      $out = Join-Path $TestDrive 'newdir' 'nested.json'
      Export-BluestacksUserScript -Sequence @(@{ Click = @(10, 10) }) -OutputFile $out | Out-Null
      Test-Path $out | Should -BeTrue
    }
  }

  Context '-WhatIf' {
    It 'does not write a file under -WhatIf' {
      $out = Join-Path $TestDrive 'whatif.json'
      Export-BluestacksUserScript -Sequence @(@{ Click = @(10, 10) }) -OutputFile $out -WhatIf | Out-Null
      Test-Path $out | Should -BeFalse
    }

    It 'returns a build result under -WhatIf' {
      $out    = Join-Path $TestDrive 'whatif2.json'
      $result = Export-BluestacksUserScript -Sequence @(@{ Click = @(10, 10) }) -OutputFile $out -WhatIf
      $result | Should -Not -BeNullOrEmpty
    }
  }

  Context '-Preview' {
    It 'does not write a file under -Preview' {
      $out = Join-Path $TestDrive 'preview.json'
      Export-BluestacksUserScript -Sequence @(@{ Click = @(10, 10) }) -OutputFile $out -Preview | Out-Null
      Test-Path $out | Should -BeFalse
    }
  }
}
