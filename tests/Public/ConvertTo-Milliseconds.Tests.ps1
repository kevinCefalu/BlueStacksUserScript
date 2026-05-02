BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force
}

Describe 'ConvertTo-Milliseconds' {
  It 'returns 0 with no parameters' {
    ConvertTo-Milliseconds | Should -Be 0
  }

  It 'converts seconds' {
    ConvertTo-Milliseconds -S 1 | Should -Be 1000
  }

  It 'converts fractional seconds' {
    ConvertTo-Milliseconds -S 2.5 | Should -Be 2500
  }

  It 'converts minutes' {
    ConvertTo-Milliseconds -M 1 | Should -Be 60000
  }

  It 'converts hours' {
    ConvertTo-Milliseconds -H 1 | Should -Be 3600000
  }

  It 'accumulates all units' {
    ConvertTo-Milliseconds -H 1 -M 1 -S 1 -Ms 1 | Should -Be 3661001
  }

  It 'is reachable via the Delay alias' {
    Delay -S 2 | Should -Be 2000
  }

  It 'is reachable via the Time alias' {
    Time -M 0.5 | Should -Be 30000
  }
}
