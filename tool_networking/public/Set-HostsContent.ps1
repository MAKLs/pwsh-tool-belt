function Set-HostsContent
{
   param
   (
      [Parameter(Mandatory=$true)]
      [Alias('ip')]
      [string]$IPAddress,

      [Parameter(Mandatory=$false)]
      [Alias('hosts')]
      [array]$HostsList,

      [Parameter(Mandatory=$false)]
      [switch]$Remove,

      [Parameter(Mandatory=$false,ParameterSetName="remote")]
      [Alias('comp','mach', 'mn')]
      [string]$ComputerName = "localhost",

      [Parameter(Mandatory=$false,ParameterSetName="remote")]
      [PSCredential]$Credential

   )

   #Script block to set content
   $SetHosts = 
   {
      param
      (
         [string]$_ip,
         
         [AllowEmptyString()]
         [array]$_hosts,

         [bool]$_remove
      )

      #We haven't matched an IP yet
      $_ip = $_ip -replace "\*","\d+"
      $_path = Join-Path $env:windir "System32\drivers\etc\hosts"
      $_ipMatched = $false
      $_newContent = @()
      $_bakExt = ".bak"
      $_bakFormat = "{0}_{1:dd-MMM-yyyy_HH-mm-ss}$_bakExt"
      $_sep = ";"

      #Grab the content of the hosts file
      $_content = Get-Content -Path $_path

      foreach ($_entry in $_content)
      {
         #Parse entry to get its IP address and current hosts
         if ($_entry -match "^(?!#)(.*)$")
         {
            $_pEntry = ($_entry -replace "\s{1,}",$_sep).Split($_sep)
            $_currIP = $_pEntry[0]
            $_currHosts = $_pEntry[1..($_pEntry.Length-1)]
         }
         else
         {
            #We hit a commented entry so just add it to the new content and skip
            #to the next entry
            $_newContent += ,$_entry
            continue
         }

         #Check if entry's IP matches the input IP
         if ($_currIP -match "^$_ip$")
         {
            #We matched an IP address
            $_ipMatched = $true

            #If no hosts list was passed discard the entry and skip to the next
            if ($_hosts -eq $null)
            {
               $_entry = "" #not required but clearer
               continue
            }

            foreach ($_name in $_hosts)
            {
               $_name = ([string]$_name).Trim().Replace("*",".*")
               #Check the new hosts against the current hosts
               if (($_currHosts -notcontains $_name) -and !$_remove)
               {
                  #We're adding this host to this IP entry
                  $_currHosts += ,$_name
               }
               elseif ($_remove)
               {
                  #We're removing this host from this IP entry
                  $_currHosts = $_currHosts | ? {$_ -notmatch "^$_name$"}
               }
            }
            #Rebuild the entry with the new hosts list; if no hosts are left, discard the entry
            $_entry = if ($_currHosts) {"{0}`t`t{1}" -f $_currIP,($_currHosts -join " ")} else {""}
         }

         #Add the entry to the edited content that will be written to the hosts file
         if ($_entry) {$_newContent += ,$_entry}
      }

      #If our IP address didn't match any entry and we're not removing entries, we
      #have a new row... add it to the end
      if (!$_ipMatched -and !$_remove -and $_hosts)
      {
         $_newContent += ,("{0}`t`t{1}" -f $_ip,($_hosts -join " "))
      }

      #Finally, make a backup of the current hosts file and write the new content
      #to the hosts file
      try
      {
         #1. Backup
         $_bakTime = (Get-Date)
         Copy-Item $_path -Destination ($_bakFormat -f $_path,$_bakTime) -Force

         #2. Write
         $_newContent
         Set-Content $_path -Value $_newContent -Force

         #3. Remove old backups
         $_oldBaks = (Get-ChildItem (Split-Path $_path -Parent) -Filter "*$_bakExt") | ? {$_.CreationTime -lt $_bakTime}
         $_oldBaks | % {Remove-Item -Path $_oldBaks.FullName -Force}

         #Return good
      }
      catch
      {
         throw
         #Return bad
      }
   }

   #Validate IP address and hostname formats. Only necessary if we're adding
   #because we should always be able to remove invalid entries
   if (!$Remove)
   {
      $IPWarnings = @()
      $HostWarnings = @()
      #IP warnings
      if (!(Test-IPAddress -IPAddress $IPAddress))
      {
         $IPWarnings += ,"$IPAddress is an invalid IP address"
      }
      #Hosts warnings
      foreach ($name in $HostsList)
      {
         $name = [string]$name
         if ($name -notmatch "^[0-9A-Za-z]{1}([0-9A-Za-z\-]*\.*){1,}[0-9A-Za-z]$")
         {
            $HostWarnings += ,"`n`t`t* Hostnames must only contain characters A-Z (case-insensitive), digits 0-9, '-' and '.' and must start and end with a letter or digit."
         }
         if ($name.Length -gt 253)
         {
            $HostWarnings += ,"`n`t`t* Hostnames cannot be longer than 253 characters!"
         }
         if ($null -ne ($name.Split('.') | ? {($_.Length -lt 1) -or ($_.Length -gt 63)}))
         {
            $HostWarnings += ,"`n`t`t* Each label (delimited by '.') must be 1-63 characters long!"
         }
         if ($HostWarnings.Count -ge 1)
         {
            $HostWarnings = ("$name is an invalid hostname:") + $HostWarnings
         }
      }
      #Print warnings and quit
      $allWarnings = $IPWarnings + $HostWarnings
      if ($allWarnings)
      {
         Write-Warning "`n$($allWarnings -join "`n`n")"
         return 0
      }
   }

   #Decide whether to run script block locally or remotely and execute (should also check if IP is local
   if (($ComputerName -eq "localhost") -or ($ComputerName -match "^$env:COMPUTERNAME") -or (Get-NetIPAddress | ? {$ComputerName -match $_.IPAddress}))
   {
      #Run locally
      $results = $SetHosts.InvokeReturnAsIs($IPAddress,$HostsList,$Remove.IsPresent)
   }
   else
   {
      #Run remotely
      try
      {
         $session = New-PSSession -ComputerName $ComputerName
      }
      catch [System.Management.Automation.Remoting.PSRemotingTransportException]
      {
         switch ($Error[0].Exception.ErrorCode)
         {
            "5"            {Write-Warning "Access denied to $ComputerName. Try specifying the -Credential parameter with a PSCredential object."}
            "-2144108103"  {Write-Warning "$ComputerName could not be resolved! Make sure the name is correct and that it is available on the network to connect."}
         }
      }
      finally
      {
         if ($session)
         {
            $results = Invoke-Command -Session $session -ScriptBlock $SetHosts -ArgumentList ($IPAddress,$HostsList,$Remove.IsPresent)
            Remove-PSSession -Session $session
         }
      }
   }

   return $results
}