param (
  [string]$apiUrl = "https://ci.appveyor.com/api",
  [string]$accountName="hemantksingh",
  [Parameter(mandatory=$true)]
  [string]$projectSlug,
  [Parameter(mandatory=$true)]
  [string]$destination,
  [Parameter(mandatory=$true)]
  [string]$apiToken
)

$headers = @{
  "Authorization" = "Bearer $apiToken"
  "Content-type" = "application/json"
}

# get project with last build details
$project = Invoke-RestMethod -Method Get -Uri "$apiUrl/projects/$accountName/$projectSlug" -Headers $headers

Write-Host "project: $project"
# we assume here that build has a single job
# get this job id
$jobId = $project.build.jobs[0].jobId

# get job artifacts (just to see what we've got)
$artifacts = Invoke-RestMethod -Method Get -Uri "$apiUrl/buildjobs/$jobId/artifacts" -Headers $headers

# here we just take the first artifact, but you could specify its file name
# $artifactFileName = 'MyWebApp.zip'
$artifactFileName = $artifacts[1].fileName

Write-Host "Artifact: $artifactFileName"

# download artifact
# -OutFile - is local file name where artifact will be downloaded into
# the Headers in this call should only contain the bearer token, and no Content-type, otherwise it will fail!
Write-Host "Downloading '$artifactFileName' to '$destination' ..."
Invoke-RestMethod -Method Get -Uri "$apiUrl/buildjobs/$jobId/artifacts/$artifactFileName" `
-OutFile $destination -Headers @{ "Authorization" = "Bearer $apiToken" }
Write-Host "Download completed ..."
