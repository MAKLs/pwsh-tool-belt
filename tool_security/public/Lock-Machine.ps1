function Lock-Machine
{
   #Lock Local machine
   $signature = @"  
   [DllImport("user32.dll", SetLastError = true)]  
   public static extern bool LockWorkStation();  
"@  
   $LockWorkStation = Add-Type -MemberDefinition $signature -Name "Win32LockWorkStation" -Namespace Win32Functions -PassThru  
   $LockWorkStation::LockWorkStation() | Out-Null
}