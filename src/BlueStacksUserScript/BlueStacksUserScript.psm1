Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

# -- Single snippet cache instance -------------------------------------------------
# Declared here so it survives across all dot-sourced function files.
$script:snippetCache = @{};

$privateFunctions = $PSScriptRoot | Join-Path -ChildPath 'Private'
  | Get-ChildItem -Filter '*.ps1' -ErrorAction:SilentlyContinue;

$publicFunctions = $PSScriptRoot | Join-Path -ChildPath 'Public'
  | Get-ChildItem -Filter '*.ps1' -ErrorAction:SilentlyContinue;

# -- Auto-load Private, then Public functions -------------------------------------
foreach ($file in $privateFunctions) {
  . $file.FullName;
}

foreach ($file in $publicFunctions) {
  . $file.FullName;
}

Set-Alias -Name 'Delay' -Value 'ConvertTo-Milliseconds'
Set-Alias -Name 'Time' -Value 'ConvertTo-Milliseconds'

Export-ModuleMember -Function $publicFunctions.BaseName -Alias 'Delay', 'Time';
