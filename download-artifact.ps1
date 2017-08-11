param (
  [string]$apiUrl = "https://ci.appveyor.com/api",
  [string]$accountName="hemantksingh",
  [Parameter(mandatory=$true)]
  [string]$projectSlug,
  [Parameter(mandatory=$true)]
  [string]$artifactName,
  [Parameter(mandatory=$true)]
  [string]$destinationDir,
  [Parameter(mandatory=$true)]
  [string]$apiToken
)

$headers = @{
  "Authorization" = "Bearer $apiToken"
  "Content-type" = "application/json"
}

# get project with last build details
$project = Invoke-RestMethod -Method Get `
  -Uri "$apiUrl/projects/$accountName/$projectSlug" `
  -Headers $headers

$destination = "$destinationDir\$artifactName"

if(-Not (Test-Path -Path $destination)) {
  $dir = Split-Path -Path $destination
  Write-Warning "Directory '$dir' does not exist. Creating it"
  md -Force $dir
}
# we assume here that build has a single job
# get this job id
$jobId = $project.build.jobs[0].jobId

Write-Host "Downloading '$artifactName' to '$destination' ..."
Invoke-RestMethod -Method Get `
  -Uri "$apiUrl/buildjobs/$jobId/artifacts/$artifactName" `
  -OutFile $destination -Headers @{ "Authorization" = "Bearer $apiToken" }
Write-Host "Download completed!"
