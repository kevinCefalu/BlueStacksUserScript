function ConvertTo-Milliseconds {
  <#
  .SYNOPSIS
    Converts a human-readable duration into a total number of milliseconds.

  .DESCRIPTION
    Accepts any combination of hours, minutes, seconds, and milliseconds and
    returns the total as an integer number of milliseconds.  The function is
    aliased as both 'Delay' and 'Time' for concise use inside sequence
    definitions.

  .PARAMETER Hours
    Number of hours to include in the total.  Accepts fractional values.

  .PARAMETER Minutes
    Number of minutes to include in the total.  Accepts fractional values.

  .PARAMETER Seconds
    Number of seconds to include in the total.  Accepts fractional values.

  .PARAMETER Milliseconds
    Whole milliseconds to add on top of the other units.

  .OUTPUTS
    System.Double

  .EXAMPLE
    ConvertTo-Milliseconds -S 2.5
    # Returns 2500

  .EXAMPLE
    Delay -M 1 -S 30
    # Returns 90000

  .EXAMPLE
    Time -H 1 -M 30
    # Returns 5400000
  #>
  [Alias('Delay', 'Time')]
  [OutputType([double])]
  param(
    [Alias('H')] [double] $Hours        = 0.0,
    [Alias('M')] [double] $Minutes      = 0.0,
    [Alias('S')] [double] $Seconds      = 0.0,
    [Alias('Ms')] [int]   $Milliseconds = 0
  )

  return (($Hours * 3600) + ($Minutes * 60) + $Seconds) * 1000 + $Milliseconds
}
