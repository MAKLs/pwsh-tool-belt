function New-AdminShell
{
   <#
   Must revise
   ------------
   Should add functionality to copy entire environment (user defined funs and vars)
   to new shell.

   Experimentation with creating a new [powershell] host and passing synchronized hashtable
   to its runspace seems promising, but still not sure how to open new console from this host
   or how to elevate user token to admin.
   #>
   switch -Exact ($PSEdition) {
      "Desktop" {
         Start-Process powershell -Verb runas
      }

      "Core" {
         Start-Process pwsh -Verb runas
      }

      default {
         Write-Error -Message "No process defined for PowerShell Edition: $($_)" -Category NotImplemented
      }
   }
}