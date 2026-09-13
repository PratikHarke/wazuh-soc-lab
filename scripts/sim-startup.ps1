# =============================================================
# Simulation: Startup Folder Persistence (T1547.001)
# Lab:        Wazuh SOC Lab — Khonshu (Windows 11)
# Author:     Pratik (on3_r4gn4r)
# MITRE:      T1547.001 — Boot or Logon Autostart: Registry Run Keys / Startup Folder
# Expected:   FIM realtime alert (immediate) | Sysmon EID11 (FileCreate)
# =============================================================
# DISCLAIMER: Run only in your own lab. Never on unauthorized systems.
# =============================================================

Write-Host "[*] Starting Startup Folder Persistence Simulation (T1547.001)" -ForegroundColor Cyan
Write-Host "[*] Method 1: User startup folder (per-user persistence)" -ForegroundColor Cyan
Write-Host "[*] Method 2: Registry Run key (system-wide persistence)" -ForegroundColor Cyan
Write-Host ""

# --- Method 1: Startup Folder Drop ---
Write-Host "[*] Method 1: Dropping file in monitored Startup folder..." -ForegroundColor Yellow

$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$testFile    = "$startupPath\WindowsDefenderHelper.bat"
$timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "  [+] Target path: $startupPath" -ForegroundColor DarkGray
Write-Host "  [+] File: WindowsDefenderHelper.bat (disguised)" -ForegroundColor DarkGray
Write-Host "  [+] Creating at: $timestamp" -ForegroundColor DarkGray

New-Item -Path $testFile -ItemType File `
  -Value "@echo off`r`necho lab-test-payload`r`n" -Force | Out-Null

Write-Host "  [+] File created — FIM realtime alert should fire within seconds" -ForegroundColor Green
Write-Host "  [+] Sysmon EID11 (FileCreate) should fire too" -ForegroundColor Green
Write-Host ""
Write-Host "  [*] Waiting 15 seconds for detection capture..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Clean up Method 1
Remove-Item $testFile -Force -ErrorAction SilentlyContinue
Write-Host "  [+] File removed — FIM delete alert should fire" -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 3

# --- Method 2: Registry Run Key ---
Write-Host "[*] Method 2: Adding Registry Run key (T1547.001)..." -ForegroundColor Yellow

$regPath  = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName  = "WindowsDefenderUpdate"
$regValue = "powershell.exe -WindowStyle Hidden -Command Write-Host 'lab-test'"

Write-Host "  [+] Key: $regPath\$regName" -ForegroundColor DarkGray

New-ItemProperty -Path $regPath -Name $regName -Value $regValue `
  -PropertyType String -Force | Out-Null

Write-Host "  [+] Registry key added — Wazuh registry monitor should alert" -ForegroundColor Green
Write-Host "  [*] Waiting 10 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Clean up Method 2
Remove-ItemProperty -Path $regPath -Name $regName -Force -ErrorAction SilentlyContinue
Write-Host "  [+] Registry key removed" -ForegroundColor Green
Write-Host ""

$endtime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "[+] Simulation complete: $endtime" -ForegroundColor Green
Write-Host ""
Write-Host "[!] Check Wazuh Dashboard:" -ForegroundColor Magenta
Write-Host "    Endpoint Security → File Integrity Monitoring" -ForegroundColor White
Write-Host "    Filter: syscheck.path:*Startup*" -ForegroundColor White
Write-Host "    Filter: syscheck.path:*CurrentVersion\Run*" -ForegroundColor White
Write-Host "    Threat Hunting → Events" -ForegroundColor White
Write-Host "    Filter: data.win.system.channel:Microsoft-Windows-Sysmon/Operational AND data.win.system.eventID:11" -ForegroundColor White
Write-Host ""
Write-Host "[!] Document in MITRE matrix: T1547.001 — Startup Persistence" -ForegroundColor Magenta
