function Invoke-BluestacksEventAnalysis {
  <#
  .SYNOPSIS
    Analyses a raw BlueStacks macro JSON file and returns structured statistics.

  .DESCRIPTION
    Reads a BlueStacks InputMapper JSON file and returns a PSCustomObject
    containing:

      TypeCounts   — ordered array of EventType / Count pairs
      ClickBuckets — top coordinate-grouped click pairs with hold-time stats
      Swipes       — detected drag gestures with start/end coordinates

    Human-readable output is written to the Verbose stream so the function
    remains fully testable without stream redirection.

  .PARAMETER Path
    Path to the BlueStacks macro JSON file to analyse.

  .OUTPUTS
    PSCustomObject  with properties: Path, TotalEvents, TypeCounts, ClickBuckets, Swipes.

  .EXAMPLE
    Invoke-BluestacksEventAnalysis -Path '.\wave-14.json' | Select-Object -ExpandProperty ClickBuckets

  .EXAMPLE
    Invoke-BluestacksEventAnalysis -Path '.\wave-14.json' -Verbose
  #>
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory)]
    [string] $Path
  )

  if (-not (Test-Path $Path)) {
    throw "Path not found: $Path"
  }

  $events = @((Get-Content $Path -Raw | ConvertFrom-Json).Events)
  if ($events.Count -eq 0) {
    Write-Verbose "No events found in '$Path'."
    return [PSCustomObject]@{
      Path        = $Path
      TotalEvents = 0
      TypeCounts  = @()
      ClickBuckets = @()
      Swipes      = @()
    }
  }

  Write-Verbose "=== Event Analysis: $Path ==="
  Write-Verbose "Total events: $($events.Count)"

  # ── EventType distribution ──────────────────────────────────────────────────
  $typeCounts = @(
    $events |
      Group-Object -Property EventType |
      Sort-Object -Property Count -Descending |
      ForEach-Object { [PSCustomObject]@{ EventType = $_.Name; Count = $_.Count } }
  )

  Write-Verbose 'EventType distribution:'
  foreach ($tc in $typeCounts) {
    Write-Verbose ('  {0,-10} {1,6}' -f $tc.EventType, $tc.Count)
  }

  # ── Click pairs ─────────────────────────────────────────────────────────────
  $clickPairs = [System.Collections.Generic.List[PSCustomObject]]::new()
  for ($i = 0; $i -lt ($events.Count - 1); $i++) {
    $cur  = $events[$i]
    $nxt  = $events[$i + 1]
    if ($cur.EventType -eq 'MouseDown' -and $nxt.EventType -eq 'MouseUp' -and
        [double]$cur.X -eq [double]$nxt.X -and [double]$cur.Y -eq [double]$nxt.Y) {
      $clickPairs.Add([PSCustomObject]@{
        X              = [double]$cur.X
        Y              = [double]$cur.Y
        HoldMs         = [long]$nxt.Timestamp - [long]$cur.Timestamp
        StartTimestamp = [long]$cur.Timestamp
      })
      $i++  # skip the MouseUp we just consumed
    }
  }

  $clickBuckets = @(
    $clickPairs |
      Group-Object -Property { '{0:0.##},{1:0.##}' -f $_.X, $_.Y } |
      Sort-Object -Property Count -Descending |
      ForEach-Object {
        $holds      = $_.Group.HoldMs
        $avgHold    = [math]::Round((($holds | Measure-Object -Average).Average), 1)
        [PSCustomObject]@{
          Coordinate  = $_.Name
          Count       = $_.Count
          AvgHoldMs   = $avgHold
        }
      }
  )

  Write-Verbose 'Top click buckets (snippet candidates):'
  foreach ($bucket in $clickBuckets | Select-Object -First 12) {
    Write-Verbose ('  ({0,-12})  count={1,4}  avgHoldMs={2,6}' -f $bucket.Coordinate, $bucket.Count, $bucket.AvgHoldMs)
  }

  # ── Swipes ──────────────────────────────────────────────────────────────────
  $swipes = [System.Collections.Generic.List[PSCustomObject]]::new()
  $index  = 0
  while ($index -lt $events.Count) {
    $evt = $events[$index]
    if ($evt.EventType -ne 'MouseDown') { $index++; continue }

    $startEvt  = $evt
    $cursor    = $index + 1
    $moveCount = 0

    while ($cursor -lt $events.Count) {
      $nextEvt = $events[$cursor]
      if ($nextEvt.EventType -eq 'MouseMove') { $moveCount++; $cursor++; continue }

      if ($nextEvt.EventType -eq 'MouseUp') {
        if ($moveCount -gt 0) {
          $swipes.Add([PSCustomObject]@{
            StartX     = [double]$startEvt.X
            StartY     = [double]$startEvt.Y
            EndX       = [double]$nextEvt.X
            EndY       = [double]$nextEvt.Y
            MoveCount  = $moveCount
            DurationMs = [long]$nextEvt.Timestamp - [long]$startEvt.Timestamp
          })
        }
        $index = $cursor + 1
        break
      }
      break
    }

    if ($cursor -ge $events.Count) { $index++ }
  }

  Write-Verbose 'Swipe/drag gestures:'
  foreach ($swipe in $swipes | Select-Object -First 10) {
    Write-Verbose ('  ({0},{1}) -> ({2},{3})  moves={4,3}  durationMs={5,5}' -f
      $swipe.StartX, $swipe.StartY, $swipe.EndX, $swipe.EndY, $swipe.MoveCount, $swipe.DurationMs)
  }

  return [PSCustomObject]@{
    Path         = $Path
    TotalEvents  = $events.Count
    TypeCounts   = $typeCounts
    ClickBuckets = $clickBuckets
    Swipes       = $swipes.ToArray()
  }
}
