$Patterns = Get-ChildItem -Path "$PSScriptRoot\patterns" -Filter *.ps1 -Depth 2

foreach ($file in $Patterns) {
    try {
        . $file.FullName
    }
    catch {
        Write-Error "Error loading $($file.Name): $($file.Exception)"
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\patterns" -Filter *.ps1 -Depth 2 | ForEach-Object { $_.BaseName })
