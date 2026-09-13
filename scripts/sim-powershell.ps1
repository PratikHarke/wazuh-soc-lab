# =============================================================
# Simulation: Malicious PowerShell Execution (T1059.001)
# Lab:        Wazuh SOC Lab — Khonshu (Windows 11)
# Author:     Pratik (on3_r4gn4r)
# MITRE:      T1059.001 — Command and Scripting: PowerShell
# Expected:   Sysmon EID1 | Windows EID4104 (Script Block Logging)
# =============================================================
# DISCLAIMER: Run only in your own lab. Never on unauthorized systems.
# =============================================================

Write-Host "[*] Starting PowerShell Encoded Command Simulation (T1059.001)" -ForegroundColor Cyan
Write-Host ""

# --- Simulation 1: EncodedCommand flag (most common malware pattern) ---
Write-Host "[*] Sim 1: Encoded command execution" -ForegroundColor Yellow
$command = "Write-Host 'Simulated C2 beacon — lab test only — $(Get-Date)'"
$encoded = [Convert]::ToBase64String(
    [System.Text.Encoding]::Unicode.GetBytes($command)
)
Write-Host "  [+] Encoded payload: $encoded" -ForegroundColor DarkGray
powershell.exe -EncodedCommand $encoded
Write-Host "  [+] Sysmon EID1 and Windows EID4104 should fire" -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 2

# --- Simulation 2: Suspicious flags (NoProfile, Bypass, Hidden) ---
Write-Host "[*] Sim 2: Suspicious execution flags" -ForegroundColor Yellow
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden `
    -Command "Write-Host 'Simulated download cradle pattern — lab test only'"
Write-Host "  [+] Sysmon EID1 should capture -ExecutionPolicy Bypass flag" -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 2

# --- Simulation 3: IEX-style execution (common in payloads) ---
Write-Host "[*] Sim 3: IEX pattern simulation" -ForegroundColor Yellow
$fakePayload = "Write-Host 'Simulated IEX stager — lab test only'"
Invoke-Expression $fakePayload
Write-Host "  [+] EID4104 script block logging should capture Invoke-Expression" -ForegroundColor Green
Write-Host ""

Write-Host "[!] Check Wazuh Dashboard:" -ForegroundColor Magenta
Write-Host "    Threat Hunting → Events" -ForegroundColor White
Write-Host "    Filter: data.win.system.channel:Microsoft-Windows-Sysmon/Operational" -ForegroundColor White
Write-Host "    Filter: data.win.eventdata.commandLine:*EncodedCommand*" -ForegroundColor White
Write-Host "    Filter: data.win.system.eventID:4104" -ForegroundColor White
Write-Host ""
Write-Host "[!] Document in MITRE matrix: T1059.001 — PowerShell" -ForegroundColor Magenta
