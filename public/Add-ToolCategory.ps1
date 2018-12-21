function Add-ToolCategory
{
   param
   (
      [Parameter(Mandatory=$true)]
      [string]$ToolCategoryName
   )

   #Clean tool category name
   $catName = "tool_{0}" -f ($ToolCategoryName -replace "\s+","_").toLower()

   #Set our tool category location
   $catParent = Split-Path $PSScriptRoot -Parent
   $catDir = Join-Path $catParent $catName

   #Set all components in tool category
   $catComponents = @(
      @{Path=$catParent; Name=$catName; ItemType="Directory"},
      @{Path=$catDir; Name="public"; ItemType="Directory"},
      @{Path=$catDir; Name="private"; ItemType="Directory"},
      @{Path=$catDir; Name="$catName.psd1"; ItemType="File"},
      @{Path=$catDir; Name="$catName.psm1"; ItemType="File"}
   )

   try
   {
      #Create tool category components
      foreach ($comp in $catComponents)
      {
         $null = New-Item @comp
      }

      #Update manifest with new tool category module
      Update-ToolBeltManifest
   }

   catch
   {
      Write-Warning $_.Exception.Message
   }
}