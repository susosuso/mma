param(
    [parameter(Mandatory=$true)] $workspaceKey, 
    [parameter(Mandatory=$true)] $workspaceId,
    [parameter(Mandatory=$false)] [switch] $unsign,
    [parameter(Mandatory=$false)] $foo
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

$retry = 0
while (!(Test-Path ".\Setup.exe") -and ($retry -lt 5)) {
    Write-Output ".\Setup.exe is not in $mmaDir. Wait for 5 sec. Attempt $retry" >> $logfile
    $retry++;
    Start-Sleep -Seconds 5
}

if (Test-Path ".\Setup.exe") {
    Write-Output ".\Setup.exe is in $mmaDir :)" >> $logfile
}
else {
    Write-Output ".\Setup.exe is NOT in $mmaDir after $retry retries. Abort." >> $logfile
    exit
}

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

if ($unsign) {
    Start-Sleep -Seconds 10
    $retry = 0;
    $maxRetry = 20;
    $regPath = "HkLM:\SOFTWARE\Microsoft\HybridRunbookWorker"
    while (!(test-path $regPath) -and $retry -lt 20) {
        $waitTime = ($maxRetry - $retry) * 4;
        Write-Output "$regPath does not exist. Wait for $waitTime sec. Attempt $retry" >> $logfile
        $retry++;
        Start-Sleep -Seconds $waitTime
    }

    if (test-path $regPath) {
        Write-Output "Setting 'EnableSignatureValidation' to 'False'" >> $logfile
        Set-Location $($(dir $regPath).Name -replace 'HKEY_LOCAL_MACHINE','HKLM:')
        Set-ItemProperty -Path . -Name 'EnableSignatureValidation' -Value 'False'
    }
    else {
        Write-Output "$regPath does not exist after $retry retries. Abort." >> $logfile
        exit
    }
}

Write-Output "Done." >> $logfile
