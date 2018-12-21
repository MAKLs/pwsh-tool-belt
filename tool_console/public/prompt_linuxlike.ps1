function prompt_linuxlike
{
   $currDir = if ($PWD.Path -eq $env:USERPROFILE) {"~"} else {Split-Path $PWD.Path -Leaf}
   $format = @(
      @{Text="$env:USERNAME@$env:COMPUTERNAME"; fc=@(144,226,76)},
      @{Text=": "; fc=@(255,255,255)},
      @{Text=$currDir; fc=@(125,157,197)},
      @{Text=" $"; fc=@(125,157,197)}
   )
   
   foreach ($e in $format)
   {
      Write-Host (Format-ConsoleText @e) -NoNewline
   }

   return [char]0
}