function Get-WindowsGroups
{
   param
   (
      [Parameter(ParameterSetName="current_user")]
      [switch]$CurrentUser,
      
      [Parameter(ParameterSetName="specified_user")]
      [string]$WindowsUser
   )
   
   $groups = @()
   
   if ($CurrentUser)
   {
      $userObj = [System.Security.Principal.WindowsIdentity]::GetCurrent()
   }
   else
   {
      $userObj = New-Object System.Security.Principal.WindowsIdentity($WindowsUser)
   }
   
   foreach ($groupSID in $userObj.Groups)
   {
      $sidObj = New-Object System.Security.Principal.SecurityIdentifier("$($groupSID.Value)")
      $groups += [PSCustomObject]@{NTAccount=($sidObj.Translate([System.Security.Principal.NTAccount])).Value; SID=$groupSID}
   }
   
   return $groups
}   
