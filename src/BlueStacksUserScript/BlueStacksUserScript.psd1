@{
  RootModule        = 'BlueStacksUserScript.psm1'
  ModuleVersion     = '1.0.0'
  GUID              = '945f948a-88cc-4c27-bff9-09be267d5e7a'
  Author            = 'Kevin Cefalu'
  CompanyName       = 'Psibit Engineering'
  Copyright         = '(c) Psibit Engineering. MIT License.'
  Description       = 'Build and analyse BlueStacks InputMapper macro JSON files from composable snippets and inline gestures.'
  PowerShellVersion = '7.2'
  FunctionsToExport = @(
    'ConvertTo-Milliseconds',
    'Export-BluestacksUserScript',
    'Get-BluestacksSnippet',
    'Get-BluestacksSnippetDirectory',
    'Invoke-BluestacksEventAnalysis',
    'New-BluestacksCircleClickEvents',
    'New-BluestacksSwipeEvents',
    'New-BluestacksUserScript'
  )
  CmdletsToExport   = @()
  VariablesToExport = @()
  AliasesToExport   = @('Delay', 'Time')
  PrivateData       = @{
    PSData = @{
      Tags         = @('BlueStacks', 'Macro', 'InputMapper', 'Automation', 'Gaming', 'Android', 'Emulator')
      LicenseUri   = 'https://github.com/kevinCefalu/BlueStacksUserScript/blob/main/LICENSE'
      ProjectUri   = 'https://github.com/kevinCefalu/BlueStacksUserScript'
      ReleaseNotes = 'Initial public release.'
    }
  }
}
