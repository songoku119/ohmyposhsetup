# Define variables
$taskName = "Update-TerminalSettings"
$taskDescription = "Updates terminal settings using the Update-TerminalSettings.ps1 script."
$scriptPath = "C:\Temp\ohmyposhsetup\Update-TerminalSettings.ps1"
$taskUser = "NT AUTHORITY\INTERACTIVE"  # Runs for all users logged in

# Prepare the command to run the PowerShell script
$action = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Create the XML configuration for the task
$taskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>$taskDescription</Description>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <StartBoundary>$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")</StartBoundary>
      <Delay>PT1M</Delay>
      <Enabled>true</Enabled>
      <Repetition>
        <Interval>PT30M</Interval>
        <Duration>PT24H</Duration>
      </Repetition>
    </LogonTrigger>
  </Triggers>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT24H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>$action</Command>
    </Exec>
  </Actions>
</Task>
"@

# Save the XML to a temporary file
$tempTaskFile = [System.IO.Path]::GetTempFileName() + ".xml"
$taskXml | Out-File -FilePath $tempTaskFile -Encoding UTF8

# Register the task using SCHTASKS
schtasks /Create /TN $taskName /XML $tempTaskFile /RU "SYSTEM" /F

# Clean up temporary file
Remove-Item $tempTaskFile

Write-Host "Scheduled task '$taskName' has been created successfully."