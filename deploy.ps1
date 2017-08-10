param (
  $msDeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy",
  $port = "8172",
  [Parameter(Mandatory=$true)]
  [string]$appName,
  [Parameter(Mandatory=$true)]
  [string]$packageSource,
  [Parameter(Mandatory=$true)]
  [string]$server,
  [Parameter(Mandatory=$true)]
  [string]$deployUser,
  [Parameter(Mandatory=$true)]
  [string]$deployPass
)

function Fail ([string]$message) {
  Write-Error $message
  [System.Environment]::Exit(1)
}

function Deploy {
  if(-Not (Test-Path -Path "$msDeploy.exe")) {
    throw throw [System.InvalidOperationException] "MS Deploy V3 is not installed."
  }

  $serverUrl = "https://$server" + ":$port/MsDeploy.axd"

  [string[]]$arguments = @(
    "-source:package='$packageSource'",
    "-dest:auto,computerName=$serverUrl,userName=$deployUser,password=$deployPass,authtype=basic,includeAcls=False",
    "-verb:sync",
    "-allowUntrusted",
    "-setParam:name='IIS Web Application Name',value=$appName"
  )

  Write-Host "Deploying to $serverUrl"
  Write-Host "With arguments: $arguments"

  Start-Process $msDeploy -NoNewWindow -ArgumentList $arguments
}

Try {
  Deploy
} Catch {
  Fail $_.Exception
}
