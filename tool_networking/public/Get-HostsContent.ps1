function Get-HostsContent
{
   param
   (
      [Parameter(ValueFromPipeline=$true)]
      [Alias("comp","mach","mn")]
      [string]$ComputerName="localhost",
   
      [PSCredential]$Credential,
   
      [Parameter(ParameterSetName="remote_session")]
      [Alias("sess","rem")]
      [System.Management.Automation.Runspaces.PSSession]$PSSession
   )

   Begin
   {
      $ParseHosts = 
      {
         $hostsPath = Join-Path $env:windir "System32\drivers\etc\hosts"
         [array]$entries = @()
         $_sep = ";"
         (Get-Content $hostsPath) | % {
            if (Test-IPAddress -ip $_)
            {
               $ip = $Matches[1]
               $hosts = ($Matches[2].trim() -replace '\s{1,}',$_sep).split($_sep)
               $entries += ,(New-Object psobject -Property @{IP=$ip;Hosts=$hosts})
            }
         }
         return $entries
      }
      $results = @()
   }

   Process
   {
      #Decide whether to run script block locally or remotely and execute
      if (($ComputerName -eq "localhost") -or ($ComputerName -match "^$env:COMPUTERNAME") -or (Get-NetIPAddress | ? {$ComputerName -match $_.IPAddress}))
      {
         #Run locally
         Write-Verbose "Running command locally on $env:COMPUTERNAME..."
         $results += &$ParseHosts
      }
      else
      {
         try
         {
            if (!$PSSession -or $PSSession.State -ne "Opened")
            {
               Write-Verbose "No open PSSession for $ComputerName! Establishing one now..."
               if ($Credential) {$PSSession = New-PSSession -ComputerName $ComputerName -Credential $Credential}
               else {$PSSession = New-PSSession -ComputerName $ComputerName}
            }
         }
         catch [System.Management.Automation.Remoting.PSRemotingTransportException]
         {
            switch ($Error[0].Exception.ErrorCode)
            {
               "5"            {Write-Warning "Access denied to $ComputerName! Try specifying the -Credential parameter with a PSCredential object."}
               "-2144108103"  {Write-Warning "$ComputerName could not be resolved! Make sure the name is correct and that it is available on the network to connect."}
            }
         }
         finally
         {
            if ($PSSession)
            {
               #Run remotely
               Write-Verbose "Running command remotely on $ComputerName..."
               $results += Invoke-Command -Session $PSSession -ScriptBlock $ParseHosts
               Remove-PSSession -Session $PSSession
               Clear-Variable PSSession
            }
         }
      }
   }

   End
   {
      return $results
   }
}