BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force
}

Describe 'New-BluestacksSwipeEvents' {
  It 'returns an array' {
    $result = New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 100 -EndY 100 -BaseTimestamp 0
    $result | Should -Not -BeNullOrEmpty
  }

  It 'first event is MouseDown' {
    $result = New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 100 -EndY 100 -BaseTimestamp 0
    $result[0].EventType | Should -Be 'MouseDown'
  }

  It 'last event is MouseUp' {
    $result = New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 100 -EndY 100 -BaseTimestamp 0
    $result[-1].EventType | Should -Be 'MouseUp'
  }

  It 'total event count equals MoveCount + 2' {
    $result = New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 50 -EndY 50 -BaseTimestamp 0 -MoveCount 5
    $result.Count | Should -Be 7
  }

  It 'emits only Down and Up when MoveCount is 0' {
    $result = New-BluestacksSwipeEvents -StartX 10 -StartY 10 -EndX 90 -EndY 90 -BaseTimestamp 0 -MoveCount 0
    $result.Count | Should -Be 2
  }

  It 'respects BaseTimestamp on MouseDown' {
    $result = New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 10 -EndY 10 -BaseTimestamp 5000 -MoveCount 0
    $result[0].Timestamp | Should -Be 5000
  }

  It 'MouseUp timestamp equals BaseTimestamp + (MoveCount+1)*MoveIntervalMs' {
    $result = New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 10 -EndY 10 `
                -BaseTimestamp 1000 -MoveCount 3 -MoveIntervalMs 10
    # (3+1)*10 = 40 ms after base
    $result[-1].Timestamp | Should -Be 1040
  }

  It 'MouseDown X/Y matches StartX/StartY' {
    $result = New-BluestacksSwipeEvents -StartX 25 -StartY 75 -EndX 80 -EndY 20 -BaseTimestamp 0
    $result[0].X | Should -Be 25
    $result[0].Y | Should -Be 75
  }

  It 'MouseUp X/Y matches EndX/EndY' {
    $result = New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 80 -EndY 60 -BaseTimestamp 0
    $result[-1].X | Should -Be 80
    $result[-1].Y | Should -Be 60
  }

  It 'intermediate events are of type MouseMove' {
    $result = New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 100 -EndY 100 -BaseTimestamp 0 -MoveCount 3
    $result[1].EventType | Should -Be 'MouseMove'
    $result[2].EventType | Should -Be 'MouseMove'
    $result[3].EventType | Should -Be 'MouseMove'
  }

  It 'throws when MoveCount is negative' {
    { New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 10 -EndY 10 -BaseTimestamp 0 -MoveCount -1 } |
      Should -Throw
  }

  It 'throws when MoveIntervalMs is less than 1' {
    { New-BluestacksSwipeEvents -StartX 0 -StartY 0 -EndX 10 -EndY 10 -BaseTimestamp 0 -MoveIntervalMs 0 } |
      Should -Throw
  }
}
