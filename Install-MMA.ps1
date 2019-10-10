param(
    [parameter(Mandatory=$true)] $workspaceKey, 
    [parameter(Mandatory=$true)] $workspaceId
)


$MMADownloadPath = "https://github.com/susosuso/mma/raw/master/MMASetup-AMD64.exe"
$mmaDir = "C:\Users\$env:USERNAME\MMA"
$MMAexe = "MMASetup-AMD64.exe"
$logfile = "C:\Users\$env:USERNAME\mma-install.log"

Write-Output "Downloading MMA from $MMADownloadPath as $MMAexe..." >> $logfile
Invoke-WebRequest -Uri $MMADownloadPath -OutFile $MMAexe

Write-Output "Running $MMAexe ..." >> $logfile
& $MMAexe /c /t:$mmaDir

Set-Location $mmaDir
Write-Output "Runnig setup.exe ..." >> $logfile
& ./setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID="$workspaceId" OPINSIGHTS_WORKSPACE_KEY="$workspaceKey" AcceptEndUserLicenseAgreement=1  >> $logfile

Write-Output "Done." >> $logfile
