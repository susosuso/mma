param(
    [parameter(Mandatory=$true)] $workspaceKey, 
    [parameter(Mandatory=$true)] $workspaceId
)

$MMADownloadPath = "https://github.com/susosuso/mma/raw/master/MMASetup-AMD64.exe"
$mmaDir = "C:\MMA"
$MMAexe = ".\MMASetup-AMD64.exe"
$logfile = "C:\mma-install.log"
Write-Output "$(Get-Date)"
Write-Output "workspaceId is $workspaceId" >> $logfile

Write-Output "Downloading MMA from $MMADownloadPath as $MMAexe..." >> $logfile
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest -Uri $MMADownloadPath -OutFile $MMAexe -UseBasicParsing

Write-Output "Running $MMAexe ..." >> $logfile
& $MMAexe /c /t:$mmaDir

Start-Sleep -Seconds 3

Set-Location $mmaDir
dir *>> $logfile 
Write-Output "Runnig setup.exe ..." *>> $logfile
& .\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID="$workspaceId" OPINSIGHTS_WORKSPACE_KEY="$workspaceKey" AcceptEndUserLicenseAgreement=1

if($LASTEXITCODE -eq 0)
{
    write-output "setup.exe returns 0" >> $logfile
}
else{
    write-output "setup.exe returns non zero" >> $logfile
}

Write-Output "Done." >> $logfile
