function New-BluestacksCircleClickEvents {
  <#
  .SYNOPSIS
    Generates evenly-spaced taps around the circumference of a circle.

  .DESCRIPTION
    Computes ClickCount positions distributed uniformly around a circle
    defined by CenterX, CenterY, and Radius (all as percentages of the
    screen dimensions) and emits a MouseDown / MouseUp pair at each position.

  .PARAMETER CenterX
    Horizontal centre of the circle (0–100).  Defaults to 50.

  .PARAMETER CenterY
    Vertical centre of the circle (0–100).  Defaults to 25.5.

  .PARAMETER Radius
    Circle radius as a percentage of screen width.  Must be greater than 0.
    Defaults to 12.5.

  .PARAMETER ClickCount
    Number of tap positions around the circle.  Must be at least 1.
    Defaults to 90.

  .PARAMETER BaseTimestamp
    Millisecond timestamp at which the first tap begins.  Defaults to 100.

  .PARAMETER HoldMs
    Duration in milliseconds of each tap.  Defaults to 15.

  .PARAMETER IntervalMs
    Milliseconds between the end of one tap and the start of the next.
    Defaults to 15.

  .OUTPUTS
    PSCustomObject[]

  .EXAMPLE
    New-BluestacksCircleClickEvents -CenterX 50 -CenterY 25.5 -Radius 12.5 `
        -ClickCount 180 -BaseTimestamp 100 -HoldMs 15 -IntervalMs 15

  .EXAMPLE
    $params = @{ CenterX=50; CenterY=25.5; Radius=12.5; ClickCount=90 }
    New-BluestacksCircleClickEvents @params
  #>
  [CmdletBinding()]
  [OutputType([PSCustomObject[]])]
  param(
    [double] $CenterX      = 50,
    [double] $CenterY      = 25.5,
    [double] $Radius       = 12.5,
    [int]    $ClickCount   = 90,
    [long]   $BaseTimestamp = 100,
    [int]    $HoldMs       = 15,
    [int]    $IntervalMs   = 15
  )

  if ($ClickCount -lt 1) {
    throw 'ClickCount must be at least 1.'
  }

  if ($Radius -le 0) {
    throw 'Radius must be greater than 0.'
  }

  $events    = [System.Collections.Generic.List[PSCustomObject]]::new()
  $angleStep = 360.0 / $ClickCount
  $ts        = $BaseTimestamp

  for ($i = 0; $i -lt $ClickCount; $i++) {
    $radians = ($i * $angleStep) * ([math]::PI / 180)
    $clickX  = $CenterX + $Radius * [math]::Cos($radians)
    $clickY  = $CenterY + $Radius * [math]::Sin($radians)

    $events.Add([PSCustomObject]@{ Delta = 0; EventType = 'MouseDown'; Timestamp = $ts;           X = $clickX; Y = $clickY })
    $events.Add([PSCustomObject]@{ Delta = 0; EventType = 'MouseUp';   Timestamp = $ts + $HoldMs; X = $clickX; Y = $clickY })

    $ts += $HoldMs + $IntervalMs
  }

  return $events.ToArray()
}
