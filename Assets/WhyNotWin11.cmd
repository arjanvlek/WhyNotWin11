@echo off
setlocal EnableDelayedExpansion

fltmc >nul 2>&1
if errorlevel 1 (
    echo This script needs admin rights.
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

set "0=%~f0" &powershell -nop -c $f=[IO.File]::ReadAllText($env:0) -split ':shellpower\:.*';iex($f[1])
exit /b

:shellpower:
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "      WhyNotWin11 - Upgrade to Windows 11"     -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

function Start-Appraiser {
	$TaskName = "Microsoft Compatibility Appraiser"
	$TaskPath = "\Microsoft\Windows\Application Experience\"

	Write-Host "`nRunning Compatibility Appraiser..."
	$null = Enable-ScheduledTask $TaskName $TaskPath
	Start-ScheduledTask $TaskName $TaskPath
	while ((Get-ScheduledTask $TaskName $TaskPath).State.value__ -eq 4) {Start-Sleep -Seconds 1}
	Write-Host "Task finished." -ForegroundColor Green

    Write-Host "`nOpening Windows Update..."
    Start-Process "ms-settings:windowsupdate"

    Write-Host "Attempting automatic 'Check for updates'..."
    try {
        cmd /c UsoClient.exe StartBypassScan
    } catch {}
}

Start-Appraiser

Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
:shellpower:
