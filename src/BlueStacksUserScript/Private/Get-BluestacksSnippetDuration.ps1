function Get-BluestacksSnippetDuration {
  <#
  .SYNOPSIS
    Returns the total duration in milliseconds of a named snippet.

  .DESCRIPTION
    Loads the snippet via Get-BluestacksSnippet and returns the maximum
    Timestamp value, which equals the snippet's duration when timestamps
    are normalised to start at zero.

  .PARAMETER Name
    The base name (without extension) of the snippet JSON file.

  .PARAMETER SnippetDir
    Directory that contains snippet JSON files.
    Defaults to the module-owned 'snippets' sub-folder.

  .OUTPUTS
    System.Int64
  #>
  [CmdletBinding()]
  [OutputType([long])]
  param(
    [Parameter(Mandatory)]
    [string] $Name,

    [string] $SnippetDir = (Get-BluestacksSnippetDirectory)
  )

  return [long](
    Get-BluestacksSnippet -Name $Name -SnippetDir $SnippetDir |
      Measure-Object -Property Timestamp -Maximum
  ).Maximum
}
