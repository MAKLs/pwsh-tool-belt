function Format-ConsoleText
{
   [cmdletBinding()]
   param
   (
      [Parameter(Mandatory=$true)]
      [string]$Text,
     
      [ValidateCount(3, 3)]
      [Alias('fc')]
      [array]$ForegroundColor,

      [ValidateCount(3, 3)]
      [Alias('bc')]
      [array]$BackgroundColor,

      [Alias('b')]
      [switch]$Bold,

      [Alias('u')]
      [switch]$Underline,

      [Alias('top')]
      [switch]$ToTop
   )

   if (!$Host.UI.SupportsVirtualTerminal)
   {
      #Host doesn't support VT escape sequences
      #We can't color the text
      return $Text
   }

   $e = [char]27
   $eStr = ""
   $argSep = "~"
   switch -Regex ($PSBoundParameters.Keys -join $argSep)
   {
      "${argSep}?ToTop${argSep}?"            {$eStr += "$e[0;0H"}
      "${argSep}?Underline${argSep}?"        {$eStr += "$e[4m"}
      "${argSep}?Bold${argSep}?"             {$eStr += "$e[1m"}
      "${argSep}?\w+Color${argSep}?"         {$eStr += "$e["}
      "${argSep}?ForegroundColor${argSep}?"  {$eStr += "38;2;{0};" -f ($ForegroundColor -join ";")}
      "${argSep}?BackgroundColor${argSep}?"  {$eStr += "48;2;{0};" -f ($BackgroundColor -join ";"); break}
      default                                {return $Text}
   }
   
   if ($eStr.EndsWith(";"))
   {
      $eStr = $eStr.Substring(0, $eStr.Length - 1)
   }

   if (!($eStr.EndsWith("m"))) {$eStr += "m"}

   return ($eStr + $Text + "$e[0m")
}