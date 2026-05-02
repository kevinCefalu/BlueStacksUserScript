function Copy-BluestacksSnippetAt {
  <#
  .SYNOPSIS
    Returns a copy of a snippet's events with timestamps rebased to BaseTimestamp.

  .DESCRIPTION
    Loads the named snippet and returns a new array of event objects whose
    Timestamp values are shifted forward by BaseTimestamp, so the snippet
    can be placed at any position in a compiled sequence.

  .PARAMETER Name
    The base name (without extension) of the snippet JSON file.

  .PARAMETER BaseTimestamp
    Millisecond offset at which the snippet should start.

  .PARAMETER SnippetDir
    Directory that contains snippet JSON files.
    Defaults to the module-owned 'snippets' sub-folder.

  .OUTPUTS
    PSCustomObject[]
  #>
  [CmdletBinding()]
  [OutputType([PSCustomObject[]])]
  param(
    [Parameter(Mandatory)]
    [string] $Name,

    [Parameter(Mandatory)]
    [long] $BaseTimestamp,

    [string] $SnippetDir = (Get-BluestacksSnippetDirectory)
  )

  return @(
    Get-BluestacksSnippet -Name $Name -SnippetDir $SnippetDir | ForEach-Object {
      [PSCustomObject]@{
        Delta     = $_.Delta
        EventType = $_.EventType
        Timestamp = $BaseTimestamp + $_.Timestamp
        X         = $_.X
        Y         = $_.Y
      }
    }
  )
}
