#requires -Version 7

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition -Parent)

$sourceModelPath = "$currentPath\Model - A.bim"

Write-Host "Loading Module Assemblies"

$nugets = @(
    @{
        name = "Microsoft.AnalysisServices.NetCore.retail.amd64"
        ;
        version = "19.64.0"
        ;
        path = @("lib\netcoreapp3.0\Microsoft.AnalysisServices.Tabular.dll"
        , "lib\netcoreapp3.0\Microsoft.AnalysisServices.Tabular.Json.dll"
        )
    }       
)

foreach ($nuget in $nugets)
{
    Write-Host "Installing nuget: $($nuget.name)"

    if (!(Test-Path "$currentPath\Nuget\$($nuget.name).$($nuget.Version)*" -PathType Container)) {
        Install-Package -Name $nuget.name -ProviderName NuGet -Destination "$currentPath\Nuget" -RequiredVersion $nuget.Version -SkipDependencies -AllowPrereleaseVersions -Scope CurrentUser  -Force
    }
    
    foreach ($nugetPath in $nuget.path)
    {
        $path = Resolve-Path (Join-Path "$currentPath\Nuget\$($nuget.name).$($nuget.Version)" $nugetPath)
        Add-Type -Path $path -Verbose | Out-Null
    }
   
}

$sourceModel = [Microsoft.AnalysisServices.Tabular.JsonSerializer]::DeserializeDatabase([System.IO.File]::ReadAllText($sourceModelPath))

$targetModel = [Microsoft.AnalysisServices.Tabular.JsonSerializer]::DeserializeDatabase([System.IO.File]::ReadAllText($sourceModelPath))

$sourceModel.CopyTo($targetModel) | Out-Null

$outputStr = [Microsoft.AnalysisServices.Tabular.JsonSerializer]::SerializeDatabase($targetModel)

$outputStr | Out-File "$currentPath\output.bim"
