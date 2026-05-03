function Get-BluestacksSnippet {
  <#
  .SYNOPSIS
    Loads and caches a named BlueStacks input-event snippet from disk.

  .DESCRIPTION
    Reads the JSON file <Name>.json from the snippet directory, normalises
    every event's Timestamp so that the earliest event starts at zero, and
    returns the resulting event array.

    Subsequent calls with the same Name and directory combination are served
    from an in-memory cache without re-reading the file, making it safe to
    call this function repeatedly inside a sequence loop.

  .PARAMETER Name
    The base name (without extension) of the snippet JSON file.

  .PARAMETER SnippetDir
    Directory that contains snippet JSON files.
    Defaults to the module-owned 'snippets' sub-folder.

  .OUTPUTS
    PSCustomObject[]  - each object has Delta, EventType, Timestamp, X, Y.

  .EXAMPLE
    Get-BluestacksSnippet -Name 'collect-gem'

  .EXAMPLE
    Get-BluestacksSnippet -Name 'swipe-down' -SnippetDir '.\my-snippets'
  #>
  [CmdletBinding()]
  [OutputType([PSCustomObject[]])]
  param(
    [Parameter(Mandatory)]
    [string] $Name,

    [string] $SnippetDir = (Get-BluestacksSnippetDirectory)
  )

  $resolvedDir = Get-BluestacksSnippetDirectory -SnippetDir $SnippetDir
  $cacheKey    = '{0}|{1}' -f $resolvedDir, $Name

  if (-not $script:snippetCache.ContainsKey($cacheKey)) {
    $path = Join-Path $resolvedDir "$Name.json"
    if (-not (Test-Path $path)) {
      throw "Snippet '$Name' not found. Expected path: $path"
    }

    $rawEvents = @((Get-Content $path -Raw | ConvertFrom-Json).Events)
    if ($rawEvents.Count -eq 0) {
      throw "Snippet '$Name' does not contain any events."
    }

    $minTimestamp = ($rawEvents | Measure-Object -Property Timestamp -Minimum).Minimum
    $script:snippetCache[$cacheKey] = @(
      $rawEvents | ForEach-Object {
        [PSCustomObject]@{
          Delta     = [int]$_.Delta
          EventType = [string]$_.EventType
          Timestamp = [long]($_.Timestamp - $minTimestamp)
          X         = [double]$_.X
          Y         = [double]$_.Y
        }
      }
    )
  }

  return $script:snippetCache[$cacheKey]
}
