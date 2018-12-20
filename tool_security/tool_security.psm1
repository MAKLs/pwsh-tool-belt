$public = Get-ChildItem -Path (Join-Path $PSScriptRoot "public") -Recurse -Filter *.ps1
$private = Get-ChildItem -Path (Join-Path $PSScriptRoot "private") -Recurse -Filter *.ps1
$module = Split-Path $PSScriptRoot -Leaf

#Load public functions
foreach ($import in $public)
{
   try {. $import.FullName}
   catch {Write-Error ("Failed to import public function {0} from module {1}" -f $import.BaseName, $module)}
}

#Load private functions
foreach ($import in $private)
{
   try {. $import.FullName}
   catch {Write-Error ("Failed to import private function {0} from module {1}" -f $import.BaseName, $module)}
}

#Export only public functions
Export-ModuleMember -Function $public.BaseName