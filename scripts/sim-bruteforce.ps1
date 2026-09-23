# =============================================================
# Simulation: Brute Force Authentication (T1110)
# Lab:        Wazuh SOC Lab â€” Khonshu (Windows 11)
# Author:     Pratik (on3_r4gn4r)
# Date:       2026-09-05
# MITRE:      T1110 â€” Brute Force
# Expected:   Wazuh Rule 18152 | Security EventID 4625
# =============================================================
# DISCLAIMER: Run only in your own lab. Never on unauthorized systems.
# =============================================================

Write-Host "[*] Starting Brute Force Simulation (T1110)" -ForegroundColor Cyan
Write-Host "[*] Target: Local account 'FakeUser'" -ForegroundColor Cyan
Write-Host "[*] Attempts: 10 failed logins" -ForegroundColor Cyan
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "[+] Simulation start: $timestamp" -ForegroundColor Yellow

$attempts = 0
1..10 | ForEach-Object {
    try {
        $cred = New-Object System.Management.Automation.PSCredential(
            "FakeUser",
            (ConvertTo-SecureString "WrongPassword$_!" -AsPlainText -Force)
        )
        Start-Process -FilePath "cmd.exe" -Credential $cred -ErrorAction Stop -WindowStyle Hidden
    } catch {
        $attempts++
        Write-Host "  [-] Attempt $_ failed (expected)" -ForegroundColor DarkGray
    }
    Start-Sleep -Milliseconds 500
}

$endtime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host ""
Write-Host "[+] Simulation complete: $endtime" -ForegroundColor Green
Write-Host "[+] Failed attempts generated: $attempts" -ForegroundColor Green
Write-Host ""
Write-Host "[!] Check Wazuh Dashboard:" -ForegroundColor Magenta
Write-Host "    Threat Hunting â†’ Events" -ForegroundColor White
Write-Host "    Filter: rule.id:18152" -ForegroundColor White
Write-Host "    Filter: data.win.system.eventID:4625" -ForegroundColor White
Write-Host ""
Write-Host "[!] Document in MITRE matrix: T1110 â€” Brute Force" -ForegroundColor Magenta
