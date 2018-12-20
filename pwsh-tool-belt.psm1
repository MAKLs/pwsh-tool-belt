$public = Get-ChildItem -Path (Join-Path $PSScriptRoot "public") -Recurse -Filter *.ps1
$private = Get-ChildItem -Path (Join-Path $PSScriptRoot "private") -Recurse -Filter *.ps1
$currentModule = "^$($MyInvocation.MyCommand -replace "\.","\.")"
$packagedModules = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter *.psm1 | ? {!($_.Name -match $currentModule)}

#Load public functions
foreach ($import in $public)
{
   try {. $import.FullName}
   catch {Write-Error ("Failed to import public function {0}" -f $import.BaseName)}
}

#Load private functions
foreach ($import in $private)
{
   try {. $import.FullName}
   catch {Write-Error ("Failed to import private function {0}" -f $import.BaseName)}
}

#Import all tool belt modules into the global scope
foreach ($module in $packagedModules)
{
   Import-Module $module.FullName -Scope Global
}

#Export only public functions
Export-ModuleMember -Function $public.BaseName