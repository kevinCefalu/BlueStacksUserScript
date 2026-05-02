BeforeAll {
  Import-Module "$PSScriptRoot/../../src/BlueStacksUserScript/BlueStacksUserScript.psd1" -Force
}

Describe 'New-BluestacksUserScript' {
  Context 'Click step' {
    It 'emits MouseDown then MouseUp' {
      $result = New-BluestacksUserScript -Sequence @(@{ Click = @(50.0, 50.0) }) -StartOffset 0
      $result.Events[0].EventType | Should -Be 'MouseDown'
      $result.Events[1].EventType | Should -Be 'MouseUp'
    }

    It 'emits 2 events for a single click' {
      $result = New-BluestacksUserScript -Sequence @(@{ Click = @(10.0, 10.0) }) -StartOffset 0
      $result.EventCount | Should -Be 2
    }

    It 'honours the Repeat key' {
      $result = New-BluestacksUserScript -Sequence @(@{ Click = @(10.0, 10.0); Repeat = 3 }) -StartOffset 0
      $result.EventCount | Should -Be 6
    }

    It 'uses StartOffset as the first timestamp' {
      $result = New-BluestacksUserScript -Sequence @(@{ Click = @(10.0, 10.0) }) -StartOffset 500
      $result.Events[0].Timestamp | Should -Be 500
    }
  }

  Context 'Wait step' {
    It 'emits no events' {
      $result = New-BluestacksUserScript -Sequence @(@{ Wait = 500 }) -StartOffset 0
      $result.EventCount | Should -Be 0
    }

    It 'advances the duration by the Wait value' {
      $result = New-BluestacksUserScript -Sequence @(@{ Wait = 1000 }) -StartOffset 0
      $result.DurationMs | Should -BeGreaterOrEqual 1000
    }
  }

  Context 'Swipe step' {
    It 'emits at least 2 events (Down and Up)' {
      $swipe  = @{ StartX = 0; StartY = 0; EndX = 100; EndY = 100; MoveCount = 0 }
      $result = New-BluestacksUserScript -Sequence @(@{ Swipe = $swipe }) -StartOffset 0
      $result.EventCount | Should -BeGreaterOrEqual 2
    }

    It 'accepts Start/End array shorthand' {
      $swipe  = @{ Start = @(0, 0); End = @(100, 100); MoveCount = 0 }
      $result = New-BluestacksUserScript -Sequence @(@{ Swipe = $swipe }) -StartOffset 0
      $result.EventCount | Should -BeGreaterOrEqual 2
    }
  }

  Context 'CircleClick step' {
    It 'emits ClickCount * 2 events' {
      $circle = @{ CenterX = 50; CenterY = 50; Radius = 10; ClickCount = 5 }
      $result = New-BluestacksUserScript -Sequence @(@{ CircleClick = $circle }) -StartOffset 0
      $result.EventCount | Should -Be 10
    }
  }

  Context 'Return value' {
    It 'returns an object with Events, EventCount, DurationMs, DurationLabel' {
      $result = New-BluestacksUserScript -Sequence @(@{ Click = @(10, 10) }) -StartOffset 0
      $result.PSObject.Properties.Name | Should -Contain 'Events'
      $result.PSObject.Properties.Name | Should -Contain 'EventCount'
      $result.PSObject.Properties.Name | Should -Contain 'DurationMs'
      $result.PSObject.Properties.Name | Should -Contain 'DurationLabel'
    }
  }

  Context 'Unknown step key' {
    It 'writes a warning for an unrecognised step' {
      $result = New-BluestacksUserScript -Sequence @(@{ UnknownKey = 1 }) -WarningVariable w
      $w | Should -Not -BeNullOrEmpty
    }
  }
}
