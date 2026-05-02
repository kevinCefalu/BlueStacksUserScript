function Export-BluestacksUserScript {
  <#
  .SYNOPSIS
    Builds a BlueStacks macro sequence and writes it to a JSON file.

  .DESCRIPTION
    Calls New-BluestacksUserScript to compile the sequence, then serialises
    the resulting event array to a BlueStacks InputMapper-compatible JSON file
    at OutputFile.

    Supports -WhatIf: when specified, a timing preview is printed but no file
    is written.

  .PARAMETER Sequence
    Array of step hashtables defining the macro.  See New-BluestacksUserScript
    for the supported step types and keys.

  .PARAMETER OutputFile
    Path of the JSON file to create or overwrite.

  .PARAMETER SnippetDir
    Directory that contains snippet JSON files.
    Defaults to the module-owned 'snippets' sub-folder.

  .PARAMETER StartOffset
    Milliseconds before the very first event.  Defaults to 100.

  .PARAMETER Preview
    When specified, prints a human-readable timing summary and returns the
    build result without writing any file.  Equivalent to -WhatIf for
    display purposes but can be combined with it.

  .OUTPUTS
    PSCustomObject  — the same build result returned by New-BluestacksUserScript.

  .EXAMPLE
    Export-BluestacksUserScript -Sequence $sequence -OutputFile '.\macro.json'

  .EXAMPLE
    Export-BluestacksUserScript -Sequence $sequence -OutputFile '.\macro.json' -WhatIf
  #>
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory)]
    [object[]] $Sequence,

    [Parameter(Mandatory)]
    [string] $OutputFile,

    [string] $SnippetDir  = (Get-BluestacksSnippetDirectory),
    [int]    $StartOffset = 100,
    [switch] $Preview
  )

  $build = New-BluestacksUserScript -Sequence $Sequence -SnippetDir $SnippetDir `
             -StartOffset $StartOffset -Preview:$Preview

  if ($Preview -or $WhatIfPreference) {
    Write-Host ''
    Write-Host ('Total: {0} events  |  duration: {1}  |  final cursor: {2} ms' -f
      $build.EventCount, $build.DurationLabel, $build.FinalCursor)
    Write-Host '(WhatIf: no file written)'
    return $build
  }

  $outputDir = Split-Path $OutputFile -Parent
  if ($outputDir -and -not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
  }

  if ($PSCmdlet.ShouldProcess($OutputFile, 'Write BlueStacks user script JSON')) {
    $payload = [PSCustomObject]@{ Events = $build.Events } | ConvertTo-Json -Depth 5
    Set-Content -Path $OutputFile -Value $payload -Encoding UTF8
    Write-Host ("Wrote {0} events to '{1}'  (duration: {2})" -f $build.EventCount, $OutputFile, $build.DurationLabel)
  }

  return $build
}
