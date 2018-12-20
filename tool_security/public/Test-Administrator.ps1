function Test-Administrator
{
   $curUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
   $userObj = (New-Object System.Security.Principal.WindowsPrincipal $curUser)
   $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
   return [bool]$userObj.IsInRole($adminRole)
}