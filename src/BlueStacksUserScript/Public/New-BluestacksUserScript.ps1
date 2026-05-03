function New-BluestacksUserScript {
  <#
  .SYNOPSIS
    Compiles a sequence of gesture steps into a BlueStacks event array.

  .DESCRIPTION
    Iterates over a sequence of step hashtables and builds a flat array of
    BlueStacks input events.  Each step advances an internal timestamp cursor
    so events are laid out contiguously in time.

    Supported step types:

      Snippet     - embed a pre-recorded snippet from the snippet directory
      Click       - inline tap: @(X, Y)
      Swipe       - drag gesture with Start/End coordinates
      CircleClick - evenly-spaced taps around a circle
      Wait        - silent pause; no events emitted

    Common keys accepted by all action steps:

      Repeat         - repeat the action N times           (default 1)
      RepeatInterval - ms gap between repetitions          (default 20)
      HoldMs         - tap-hold duration for Click steps   (default 20)
      DelayAfter     - ms of silence after the step        (default 20)

  .PARAMETER Sequence
    Array of step hashtables defining the macro.

  .PARAMETER SnippetDir
    Directory that contains snippet JSON files.
    Defaults to the module-owned 'snippets' sub-folder.

  .PARAMETER StartOffset
    Milliseconds before the very first event.  Defaults to 100.

  .PARAMETER Preview
    When specified, writes a human-readable timing summary to the host
    without modifying any files.

  .OUTPUTS
    PSCustomObject  with properties: Events, EventCount, StartOffset,
                    FinalCursor, DurationMs, DurationLabel, SnippetDirectory.

  .EXAMPLE
    $result = New-BluestacksUserScript -Sequence @(
        @{ Click = @(26, 40) }
        @{ Wait  = 2000 }
        @{ Click = @(50, 50); Repeat = 3; RepeatInterval = 500 }
    )
    $result.DurationLabel

  .EXAMPLE
    New-BluestacksUserScript -Sequence $sequence -Preview
  #>
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory)]
    [object[]] $Sequence,

    [string] $SnippetDir = (Get-BluestacksSnippetDirectory),
    [int]    $StartOffset = 100,
    [switch] $Preview
  )

  $resolvedSnippetDir = Get-BluestacksSnippetDirectory -SnippetDir $SnippetDir
  $events = [System.Collections.Generic.List[PSCustomObject]]::new()
  [long] $cursor = $StartOffset

  foreach ($step in $Sequence) {
    $repeat = $step.ContainsKey('Repeat') ? [int]$step.Repeat : 1
    $repeatInterval = $step.ContainsKey('RepeatInterval') ? [int]$step.RepeatInterval : 20
    $delayAfter = $step.ContainsKey('DelayAfter') ? [int]$step.DelayAfter : 20
    $holdMs = $step.ContainsKey('HoldMs') ? [int]$step.HoldMs : 20

    # -- Wait ------------------------------------------------------------------------
    if ($step.ContainsKey('Wait')) {
      $waitMs = [long]$step.Wait
      if ($Preview) {
        Write-Host ('  [cursor {0,9} ms]  WAIT  {1} ms  ->  cursor {2} ms' -f $cursor, $waitMs, ($cursor + $waitMs))
      }
      $cursor += $waitMs
      continue
    }

    # -- Snippet ---------------------------------------------------------------------
    if ($step.ContainsKey('Snippet')) {
      $name = [string]$step.Snippet
      $duration = Get-BluestacksSnippetDuration -Name $name -SnippetDir $resolvedSnippetDir

      if ($Preview) {
        Write-Host ("  [cursor {0,9} ms]  SNIPPET  '{1}'  x{2}  (dur {3} ms, +{4} ms interval, +{5} ms after)" -f
          $cursor, $name, $repeat, $duration, $repeatInterval, $delayAfter)
      }

      for ($i = 0; $i -lt $repeat; $i++) {
        $events.AddRange([PSCustomObject[]](Copy-BluestacksSnippetAt -Name $name -BaseTimestamp $cursor -SnippetDir $resolvedSnippetDir))
        $cursor += $duration
        if ($i -lt ($repeat - 1)) {
          $cursor += $repeatInterval
        }
      }

      $cursor += $delayAfter
      continue
    }

    # -- Click -----------------------------------------------------------------------
    if ($step.ContainsKey('Click')) {
      $x = [double]$step.Click[0]
      $y = [double]$step.Click[1]

      if ($Preview) {
        Write-Host ('  [cursor {0,9} ms]  CLICK  ({1}, {2})  x{3}  (hold {4} ms, +{5} ms interval, +{6} ms after)' -f
          $cursor, $x, $y, $repeat, $holdMs, $repeatInterval, $delayAfter)
      }

      for ($i = 0; $i -lt $repeat; $i++) {
        $events.AddRange([PSCustomObject[]](New-BluestacksClickEvents -X $x -Y $y -BaseTimestamp $cursor -HoldMs $holdMs))
        $cursor += $holdMs
        if ($i -lt ($repeat - 1)) {
          $cursor += $repeatInterval
        }
      }

      $cursor += $delayAfter
      continue
    }

    # -- Swipe -----------------------------------------------------------------------
    if ($step.ContainsKey('Swipe')) {
      $swipe = $step.Swipe

      $startX = $swipe.ContainsKey('Start') ? [double]$swipe.Start[0] : [double]$swipe.StartX
      $startY = $swipe.ContainsKey('Start') ? [double]$swipe.Start[1] : [double]$swipe.StartY

      $endX = $swipe.ContainsKey('End') ? [double]$swipe.End[0] : [double]$swipe.EndX
      $endY = $swipe.ContainsKey('End') ? [double]$swipe.End[1] : [double]$swipe.EndY

      $moveCount = $swipe.ContainsKey('MoveCount') ? [int]$swipe.MoveCount : 23
      $moveIntervalMs = $swipe.ContainsKey('MoveIntervalMs') ? [int]$swipe.MoveIntervalMs : 5
      $duration = ($moveCount + 1) * $moveIntervalMs

      if ($Preview) {
        Write-Host ('  [cursor {0,9} ms]  SWIPE  ({1},{2})->({3},{4})  x{5}  (moves {6}, every {7} ms, +{8} ms interval, +{9} ms after)' -f
          $cursor, $startX, $startY, $endX, $endY, $repeat, $moveCount, $moveIntervalMs, $repeatInterval, $delayAfter)
      }

      for ($i = 0; $i -lt $repeat; $i++) {
        $events.AddRange([PSCustomObject[]](New-BluestacksSwipeEvents -StartX $startX -StartY $startY -EndX $endX -EndY $endY `
              -BaseTimestamp $cursor -MoveCount $moveCount -MoveIntervalMs $moveIntervalMs))
        $cursor += $duration
        if ($i -lt ($repeat - 1)) {
          $cursor += $repeatInterval
        }
      }

      $cursor += $delayAfter
      continue
    }

    # -- CircleClick -------------------------------------------------------------------
    if ($step.ContainsKey('CircleClick')) {
      $circle = $step.CircleClick
      $centerX = [double]$circle.CenterX
      $centerY = [double]$circle.CenterY
      $radius = [double]$circle.Radius
      $clickCount = [int]$circle.ClickCount
      $intervalMs = $circle.ContainsKey('IntervalMs') ? [int]$circle.IntervalMs : $repeatInterval
      $duration = ($holdMs * $clickCount) + ($intervalMs * ($clickCount - 1))

      if ($Preview) {
        Write-Host ('  [cursor {0,9} ms]  CIRCLECLICK  center=({1},{2}) radius={3} clicks={4}  x{5}  (hold {6} ms, +{7} ms point interval, +{8} ms repeat interval, +{9} ms after)' -f
          $cursor, $centerX, $centerY, $radius, $clickCount, $repeat, $holdMs, $intervalMs, $repeatInterval, $delayAfter)
      }

      for ($i = 0; $i -lt $repeat; $i++) {
        $events.AddRange([PSCustomObject[]](New-BluestacksCircleClickEvents -CenterX $centerX -CenterY $centerY -Radius $radius `
              -ClickCount $clickCount -BaseTimestamp $cursor -HoldMs $holdMs -IntervalMs $intervalMs))
        $cursor += $duration
        if ($i -lt ($repeat - 1)) {
          $cursor += $repeatInterval
        }
      }

      $cursor += $delayAfter
      continue
    }

    Write-Warning "Step has no recognised action key (Snippet / Click / Swipe / CircleClick / Wait). Keys found: $($step.Keys -join ', ')"
  }

  $durationMs = $cursor - $StartOffset
  $minutes = [math]::Floor($durationMs / 60000)
  $seconds = [math]::Round(($durationMs % 60000) / 1000, 1)

  return [PSCustomObject]@{
    Events = $events.ToArray()
    EventCount = $events.Count
    StartOffset = $StartOffset
    FinalCursor = $cursor
    DurationMs = $durationMs
    DurationLabel = '{0}m {1}s' -f $minutes, $seconds
    SnippetDirectory = $resolvedSnippetDir
  }
}
