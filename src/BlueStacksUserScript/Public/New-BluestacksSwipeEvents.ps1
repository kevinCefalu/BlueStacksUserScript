function New-BluestacksSwipeEvents {
  <#
  .SYNOPSIS
    Generates a drag-gesture event array between two coordinates.

  .DESCRIPTION
    Returns an array of BlueStacks input events that represents a swipe from
    (StartX, StartY) to (EndX, EndY).  The gesture is made up of:

      - One MouseDown at StartX/StartY
      - MoveCount evenly-spaced MouseMove events along the path
      - One MouseUp at EndX/EndY

    Coordinates are expressed as percentages of the screen dimensions (0–100).

  .PARAMETER StartX
    Horizontal start coordinate (0–100).

  .PARAMETER StartY
    Vertical start coordinate (0–100).

  .PARAMETER EndX
    Horizontal end coordinate (0–100).

  .PARAMETER EndY
    Vertical end coordinate (0–100).

  .PARAMETER BaseTimestamp
    Millisecond timestamp at which the gesture begins.

  .PARAMETER MoveCount
    Number of intermediate MouseMove events.  Defaults to 23.

  .PARAMETER MoveIntervalMs
    Milliseconds between consecutive move events.  Must be at least 1.
    Defaults to 5.

  .OUTPUTS
    PSCustomObject[]

  .EXAMPLE
    New-BluestacksSwipeEvents -StartX 50 -StartY 80 -EndX 50 -EndY 20 -BaseTimestamp 0

  .EXAMPLE
    New-BluestacksSwipeEvents -StartX 10 -StartY 50 -EndX 90 -EndY 50 `
        -BaseTimestamp 1000 -MoveCount 10 -MoveIntervalMs 10
  #>
  [CmdletBinding()]
  [OutputType([PSCustomObject[]])]
  param(
    [Parameter(Mandatory)]
    [double] $StartX,

    [Parameter(Mandatory)]
    [double] $StartY,

    [Parameter(Mandatory)]
    [double] $EndX,

    [Parameter(Mandatory)]
    [double] $EndY,

    [Parameter(Mandatory)]
    [long] $BaseTimestamp,

    [int] $MoveCount      = 23,
    [int] $MoveIntervalMs = 5
  )

  if ($MoveCount -lt 0) {
    throw 'MoveCount must be zero or greater.'
  }

  if ($MoveIntervalMs -lt 1) {
    throw 'MoveIntervalMs must be at least 1.'
  }

  $events = [System.Collections.Generic.List[PSCustomObject]]::new()
  $events.Add([PSCustomObject]@{ Delta = 0; EventType = 'MouseDown'; Timestamp = $BaseTimestamp; X = $StartX; Y = $StartY })

  for ($i = 1; $i -le $MoveCount; $i++) {
    $progress = $i / ($MoveCount + 1)
    $events.Add([PSCustomObject]@{
      Delta     = 0
      EventType = 'MouseMove'
      Timestamp = $BaseTimestamp + ($i * $MoveIntervalMs)
      X         = $StartX + (($EndX - $StartX) * $progress)
      Y         = $StartY + (($EndY - $StartY) * $progress)
    })
  }

  $events.Add([PSCustomObject]@{
    Delta     = 0
    EventType = 'MouseUp'
    Timestamp = $BaseTimestamp + (($MoveCount + 1) * $MoveIntervalMs)
    X         = $EndX
    Y         = $EndY
  })

  return $events.ToArray()
}
