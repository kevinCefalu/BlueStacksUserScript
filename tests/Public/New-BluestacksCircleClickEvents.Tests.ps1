BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force
}

Describe 'New-BluestacksCircleClickEvents' {
  It 'returns ClickCount * 2 events' {
    $result = New-BluestacksCircleClickEvents -ClickCount 4 -BaseTimestamp 0
    $result.Count | Should -Be 8
  }

  It 'alternates MouseDown and MouseUp for each click' {
    $result = New-BluestacksCircleClickEvents -ClickCount 2 -BaseTimestamp 0
    $result[0].EventType | Should -Be 'MouseDown'
    $result[1].EventType | Should -Be 'MouseUp'
    $result[2].EventType | Should -Be 'MouseDown'
    $result[3].EventType | Should -Be 'MouseUp'
  }

  It 'first MouseDown starts at BaseTimestamp' {
    $result = New-BluestacksCircleClickEvents -ClickCount 1 -BaseTimestamp 500
    $result[0].Timestamp | Should -Be 500
  }

  It 'MouseUp timestamp equals MouseDown + HoldMs' {
    $result = New-BluestacksCircleClickEvents -ClickCount 1 -BaseTimestamp 0 -HoldMs 25
    $result[1].Timestamp | Should -Be 25
  }

  It 'second click starts at BaseTimestamp + HoldMs + IntervalMs' {
    $result = New-BluestacksCircleClickEvents -ClickCount 2 -BaseTimestamp 0 -HoldMs 20 -IntervalMs 10
    $result[2].Timestamp | Should -Be 30
  }

  It 'first click is at angle 0 (rightmost point of circle)' {
    $result = New-BluestacksCircleClickEvents -CenterX 50 -CenterY 50 -Radius 10 -ClickCount 1 -BaseTimestamp 0
    # cos(0) = 1, sin(0) = 0 -> X = 60, Y = 50
    [math]::Abs($result[0].X - 60) | Should -BeLessOrEqual 0.0001 -Because 'cos(0) = 1'
    [math]::Abs($result[0].Y - 50) | Should -BeLessOrEqual 0.0001 -Because 'sin(0) = 0'
  }

  It 'throws when ClickCount is 0' {
    { New-BluestacksCircleClickEvents -ClickCount 0 } | Should -Throw
  }

  It 'throws when ClickCount is negative' {
    { New-BluestacksCircleClickEvents -ClickCount -1 } | Should -Throw
  }

  It 'throws when Radius is 0' {
    { New-BluestacksCircleClickEvents -Radius 0 } | Should -Throw
  }

  It 'throws when Radius is negative' {
    { New-BluestacksCircleClickEvents -Radius -5 } | Should -Throw
  }
}
