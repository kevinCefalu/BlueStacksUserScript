function New-BluestacksClickEvents {
  <#
  .SYNOPSIS
    Emits a MouseDown / MouseUp event pair at a given coordinate.

  .DESCRIPTION
    Returns exactly two PSCustomObjects representing a tap: a MouseDown event
    at BaseTimestamp and a MouseUp event at BaseTimestamp + HoldMs.

  .PARAMETER X
    Horizontal screen coordinate (percentage of screen width).

  .PARAMETER Y
    Vertical screen coordinate (percentage of screen height).

  .PARAMETER BaseTimestamp
    Millisecond timestamp at which the tap begins.

  .PARAMETER HoldMs
    Duration in milliseconds between MouseDown and MouseUp.
    Defaults to 50.

  .OUTPUTS
    PSCustomObject[]
  #>
  [CmdletBinding()]
  [OutputType([PSCustomObject[]])]
  param(
    [Parameter(Mandatory)]
    [double] $X,

    [Parameter(Mandatory)]
    [double] $Y,

    [Parameter(Mandatory)]
    [long] $BaseTimestamp,

    [int] $HoldMs = 50
  )

  return @(
    [PSCustomObject]@{ Delta = 0; EventType = 'MouseDown'; Timestamp = $BaseTimestamp;           X = $X; Y = $Y }
    [PSCustomObject]@{ Delta = 0; EventType = 'MouseUp';   Timestamp = $BaseTimestamp + $HoldMs; X = $X; Y = $Y }
  )
}
