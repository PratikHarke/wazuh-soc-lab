# =============================================================
# Simulation: Scheduled Task Persistence (T1053.005)
# Lab:        Wazuh SOC Lab â€” Khonshu (Windows 11)
# Author:     Pratik (on3_r4gn4r)
# MITRE:      T1053.005 â€” Scheduled Task/Job: Scheduled Task
# Expected:   TaskScheduler EID4698 | Sysmon EID1 | FIM Registry
# =============================================================
# DISCLAIMER: Run only in your own lab. Never on unauthorized systems.
# =============================================================

Write-Host "[*] Starting Scheduled Task Persistence Simulation (T1053.005)" -ForegroundColor Cyan
Write-Host "[*] Task name: 'WindowsUpdateHelper' (disguised as legit)" -ForegroundColor Cyan
Write-Host "[*] Trigger: OnLogon | Context: SYSTEM" -ForegroundColor Cyan
Write-Host ""

$taskName = "WindowsUpdateHelper"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "[+] Creating task at: $timestamp" -ForegroundColor Yellow

# Create the scheduled task
schtasks /create `
  /tn $taskName `
  /tr "powershell.exe -WindowStyle Hidden -Command Write-Host 'lab-test-payload'" `
  /sc onlogon `
  /ru SYSTEM `
  /f 2>&1

Write-Host "[+] Task created â€” waiting 10 seconds for detection..." -ForegroundColor Green
Write-Host "    TaskScheduler should log EID4698 (Task Created)" -ForegroundColor DarkGray
Write-Host "    FIM should alert on HKLM\...\TaskCache\Tasks registry change" -ForegroundColor DarkGray
Write-Host "    Sysmon EID1 should capture schtasks.exe execution" -ForegroundColor DarkGray

Start-Sleep -Seconds 10

# Clean up
Write-Host ""
Write-Host "[*] Cleaning up â€” deleting task..." -ForegroundColor Yellow
schtasks /delete /tn $taskName /f 2>&1
Write-Host "[+] Task deleted â€” TaskScheduler should log EID4699 (Task Deleted)" -ForegroundColor Green

$endtime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host ""
Write-Host "[+] Simulation complete: $endtime" -ForegroundColor Green
Write-Host ""
Write-Host "[!] Check Wazuh Dashboard:" -ForegroundColor Magenta
Write-Host "    Endpoint Security â†’ File Integrity Monitoring" -ForegroundColor White
Write-Host "    Filter: syscheck.path:*TaskCache*" -ForegroundColor White
Write-Host "    Threat Hunting â†’ Events" -ForegroundColor White
Write-Host "    Filter: data.win.system.eventID:4698" -ForegroundColor White
Write-Host "    Filter: data.win.eventdata.taskName:*WindowsUpdateHelper*" -ForegroundColor White
Write-Host ""
Write-Host "[!] Document in MITRE matrix: T1053.005 â€” Scheduled Task" -ForegroundColor Magenta
