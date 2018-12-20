function Remove-ToolCategory
{
   [cmdletBinding()]
   param()

   dynamicparam
   {
      $paramName = "ToolCategoryName"
      $paramAttr = New-Object System.Management.Automation.ParameterAttribute
      $paramAttr.Mandatory = $true
      $validSet = Get-ChildItem -Path (Split-Path $PSScriptRoot -Parent) -Filter "tool_*" -Directory
      $validateSetAttr = New-Object System.Management.Automation.ValidateSetAttribute($validSet)

      $attrCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
      $attrCollection.Add($paramAttr)
      $attrCollection.Add($validateSetAttr)

      $param = New-Object System.Management.Automation.RuntimeDefinedParameter($paramName, [string], $attrCollection)

      $paramDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
      $paramDict.add($paramName, $param)
      return $paramDict
   }

   begin
   {
      $ToolCategoryName = $PSBoundParameters[$paramName]

      try
      {
         #Remove tool category directory from disk
         $catParent = Split-Path $PSScriptRoot -Parent
         Remove-Item -Path (Join-Path $catParent $ToolCategoryName) -Recurse -Force

         #Update tool belt manifest
         Update-ToolBeltManifest
      }
      catch
      {
         Write-Warning $_.Exception.Message
      }
   }
}