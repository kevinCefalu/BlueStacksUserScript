@{
  Severity     = @('Error', 'Warning', 'Information')
  ExcludeRules = @(
    # Write-Host is intentional in Preview/timing output paths
    'PSAvoidUsingWriteHost'
  )
  Rules        = @{
    PSUseCompatibleSyntax    = @{
      Enable         = $true
      TargetVersions = @('7.2', '7.4')
    }
    PSReviewUnusedParameter  = @{ Enable = $true }
    PSUseConsistentIndentation = @{
      Enable              = $true
      IndentationSize     = 2
      PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
      Kind                = 'Space'
    }
    PSUseConsistentWhitespace = @{
      Enable                                  = $true
      CheckInnerBrace                         = $true
      CheckOpenBrace                          = $true
      CheckOpenParen                          = $true
      CheckOperator                           = $true
      CheckPipe                               = $true
      CheckPipeForRedundantWhitespace         = $true
      CheckSeparator                          = $true
      CheckParameter                          = $false
    }
    PSAlignAssignmentStatement = @{
      Enable         = $true
      CheckHashtable = $true
    }
  }
}
