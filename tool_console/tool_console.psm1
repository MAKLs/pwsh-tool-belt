$public = Get-ChildItem -Path (Join-Path $PSScriptRoot "public") -Recurse -Filter *.ps1
$private = Get-ChildItem -Path (Join-Path $PSScriptRoot "private") -Recurse -Filter *.ps1

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

#Export only public functions
Export-ModuleMember -Function $public.BaseName