winget settings export | Out-File -FilePath $PSScriptRoot/settings.json
winget export -o $PSScriptRoot/packages.json