function Update-ToolBeltManifest
{
   $root = Split-Path $PSScriptRoot -Parent
   $manifest = (Get-ChildItem -Path $root -Filter "*.psd1").FullName
   [array]$fileList = @()
   [array]$moduleList = @()
   $extensionFilter = "ps.?1|xml|md|dll"
   $updateFields = @(
      @{Name="FileList"; Value={$fileList}},
      @{Name="ModuleList"; Value={$moduleList}}
   )
   $failureMessage = "Failed to update module manifest. Please inspect manually.`n`n{0}"

   #Get all files to include in the module and all nested modules
   foreach ($file in (Get-ChildItem -Path $root -Recurse -File))
   {
      $relativePath = $file.FullName -replace "$($root -replace "\\","\\")\\?",".\"
      if ($file.Extension -match $extensionFilter)
      {
         $fileList += ,$relativePath
      }
   }
   $moduleList = $fileList | ? {$_ -match ".*\\?.*.psm1"}

   #Update the fields in the manifest with the current files
   #Update-ModuleManifest could be used here, but it does not function well
   #when a file specified in the manifest's' filelist is removed from disk
   try
   {
      $originalContent = $content = [System.IO.File]::ReadAllText($manifest)
   }
   catch [System.IO.IOException]
   {
      #Failed to read manifest file
      throw $_
   }

   #Update fields in memory
   foreach ($field in $updateFields)
   {
      $valStr = "@(`"$((&$field.Value) -join '","')`")"
      $content = $content -replace "(?<=((?<!#\s*)$($field.Name)\s*=\s*))@\(.*\)", $valStr
   }

   #Commit changes to disk
   try
   {
      [System.IO.File]::WriteAllText($manifest, $content)
   }
   catch [System.IO.IOException]
   {
      #Failed to commit changes to disk
      throw $_
   }
   
   #Test module to verify that all is good
   try
   {
      $null = Test-ModuleManifest -Path $manifest
   }
   catch [System.Management.Automation.CmdletInvocationException]
   {
      #Module manifest is malformed... revert to original content
      Write-Warning "Module manifest is malformed... reverting to original manifest state"
      
      try
      {
         [System.IO.File]::WriteAllText($manifest, $originalContent)
      }

      catch [System.IO.IOException]
      {
         #Failed to commit changes to disk
         throw $_
      }
   }
}