BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force
}

Describe 'New-BluestacksClickEvents (private)' {
  InModuleScope BlueStacksUserScript {
    It 'returns exactly 2 events' {
      $result = New-BluestacksClickEvents -X 25 -Y 50 -BaseTimestamp 100
      $result.Count | Should -Be 2
    }

    It 'first event is MouseDown' {
      $result = New-BluestacksClickEvents -X 10 -Y 10 -BaseTimestamp 0
      $result[0].EventType | Should -Be 'MouseDown'
    }

    It 'second event is MouseUp' {
      $result = New-BluestacksClickEvents -X 10 -Y 10 -BaseTimestamp 0
      $result[1].EventType | Should -Be 'MouseUp'
    }

    It 'MouseDown timestamp equals BaseTimestamp' {
      $result = New-BluestacksClickEvents -X 10 -Y 10 -BaseTimestamp 1000
      $result[0].Timestamp | Should -Be 1000
    }

    It 'MouseUp timestamp equals BaseTimestamp + HoldMs' {
      $result = New-BluestacksClickEvents -X 10 -Y 10 -BaseTimestamp 1000 -HoldMs 75
      $result[1].Timestamp | Should -Be 1075
    }

    It 'both events share the same X and Y' {
      $result = New-BluestacksClickEvents -X 33.5 -Y 66.5 -BaseTimestamp 0
      $result[0].X | Should -Be 33.5
      $result[0].Y | Should -Be 66.5
      $result[1].X | Should -Be 33.5
      $result[1].Y | Should -Be 66.5
    }
  }
}
