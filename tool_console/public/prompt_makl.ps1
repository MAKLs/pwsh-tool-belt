function prompt_makl
{
   $format = @(
      @{Text="["; fc=@(255,42,0)},
      @{Text=("{0:HH:mm:ss}" -f (Get-Date)); fc=@(255,255,25)},
      @{Text="]"; fc=@(255,42,0)},
      @{Text=":"; fc=@(255,255,255)},
      @{Text=(Split-Path $PWD.Path -Leaf); fc=@(79,131,222)},
      @{Text=">"; fc=@(255,42,0)}
   )
   
   foreach ($e in $format)
   {
      Write-Host (Format-ConsoleText @e) -NoNewline
   }

   return [char]0
}