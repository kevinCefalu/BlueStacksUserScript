function Get-BluestacksSnippetDirectory {
  <#
  .SYNOPSIS
    Resolves the directory used to look up BlueStacks snippet JSON files.

  .DESCRIPTION
    When SnippetDir is omitted or blank, returns the 'snippets' sub-folder
    that ships with this module.  Otherwise resolves the supplied path to a
    fully-qualified provider path so that relative paths work correctly
    regardless of the caller's current location.

  .PARAMETER SnippetDir
    Optional path to a custom snippet directory.  Relative paths are resolved
    against the PowerShell session's current location.

  .OUTPUTS
    System.String

  .EXAMPLE
    Get-BluestacksSnippetDirectory
    # Returns '<module-root>\snippets'

  .EXAMPLE
    Get-BluestacksSnippetDirectory -SnippetDir '.\my-snippets'
    # Returns the fully-qualified path to .\my-snippets
  #>
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [string] $SnippetDir
  )

  if ([string]::IsNullOrWhiteSpace($SnippetDir)) {
    return (Join-Path $PSScriptRoot '..\snippets')
  }

  return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($SnippetDir)
}
