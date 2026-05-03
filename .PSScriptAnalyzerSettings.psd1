@{
  Severity = @('Error', 'Warning');
  ExcludeRules = @(
    # Write-Host is intentional in Preview/timing output paths
    'PSAvoidUsingWriteHost',
    # New-* functions here are pure in-memory builders and do not mutate external state
    'PSUseShouldProcessForStateChangingFunctions',
    # Stable public API names intentionally use plural nouns for collection-returning commands
    'PSUseSingularNouns'
  );
  Rules = @{
    PSUseCompatibleSyntax = @{
      Enable = $true;
      TargetVersions = @('7.2', '7.4');
    };
    PSReviewUnusedParameter = @{
      Enable = $true;
    };
    PSUseConsistentIndentation = @{
      Enable = $false;
      IndentationSize = 2;
      Kind = 'Space';
    };
    PSAlignAssignmentStatement = @{
      Enable = $false;
    };
  };
};
