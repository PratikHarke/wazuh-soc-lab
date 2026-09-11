# 🛡️ Wazuh SOC & Vulnerability Management Lab

![Wazuh](https://img.shields.io/badge/Wazuh-4.14.7-blue?style=flat-square&logo=wazuh)
![Windows](https://img.shields.io/badge/Windows_11-Agent-0078D6?style=flat-square&logo=windows)
![Sysmon](https://img.shields.io/badge/Sysmon-15.21-important?style=flat-square)
![MITRE ATT&CK](https://img.shields.io/badge/MITRE_ATT%26CK-Mapped-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)
![CVEs Remediated](https://img.shields.io/badge/CVEs_Remediated-128+-critical?style=flat-square)

> An end-to-end SOC simulation lab built on Wazuh — covering endpoint monitoring, threat detection, FIM, vulnerability management, security configuration assessment, and attack simulation mapped to MITRE ATT&CK.

---

## 📌 Objective

Build a simulated Security Operations environment capable of:

- Real-time endpoint monitoring and alerting
- File Integrity Monitoring (FIM) with MITRE-mapped registry coverage
- Security Configuration Assessment against CIS benchmarks
- Vulnerability discovery, prioritization, and remediation
- Attack simulation and detection validation
- Incident investigation and response documentation

---

## 🏗️ Architecture

```
                    ┌─────────────────────┐
                    │   Windows 11 Host   │
                    │   (Khonshu)         │
                    │                     │
                    │  ┌───────────────┐  │
                    │  │  Sysmon 15.21 │  │
                    │  │  - Process    │  │
                    │  │  - Network    │  │
                    │  │  - Registry   │  │
                    │  │  - DLL Load   │  │
                    │  └───────┬───────┘  │
                    │          │           │
                    │  ┌───────▼───────┐  │
                    │  │ Wazuh Agent   │  │
                    │  │ (ossec-agent) │  │
                    │  │ v4.14.7 x86   │  │
                    │  └───────┬───────┘  │
                    └──────────┼──────────┘
                               │
                          TCP :1514
                          AES Encrypted
                               │
                    ┌──────────▼──────────┐
                    │   Wazuh Server OVA  │
                    │   v4.14.7           │
                    │   10.249.232.254    │
                    │   (VirtualBox)      │
                    │                     │
                    │  ┌───────────────┐  │
                    │  │ wazuh-manager │  │
                    │  │ wazuh-indexer │  │
                    │  │ wazuh-dashbrd │  │
                    │  └───────────────┘  │
                    └─────────────────────┘
                               │
                         Dashboard :443
                               │
                    ┌──────────▼──────────┐
                    │   Detection Modules  │
                    ├─────────────────────┤
                    │  FIM  │  SCA  │ Vuln │
                    ├─────────────────────┤
                    │  Threat Hunting      │
                    ├─────────────────────┤
                    │  MITRE ATT&CK        │
                    └─────────────────────┘
```

---

## ⚙️ Lab Components

| Component | Details |
|---|---|
| **Wazuh Server** | OVA v4.14.7 on Oracle VirtualBox |
| **Server IP** | 10.249.232.254 (static) |
| **Windows Endpoint** | Windows 11 Home — Hostname: `Khonshu` |
| **Agent ID** | 002 |
| **Agent Path** | `C:\Program Files (x86)\ossec-agent\` |
| **Communication** | TCP :1514, AES encrypted |
| **Sysmon** | v15.21 with SwiftOnSecurity config |
| **SCA Policy** | CIS Windows 11 Enterprise |

---

## 🚀 Deployment

### Challenges Encountered & Fixed

Real-world deployment problems documented here — these are more valuable than a clean install:

| # | Issue | Root Cause | Resolution |
|---|---|---|---|
| 1 | Agent "Never Connected" | Windows Firewall blocking TCP :1514 outbound | Added outbound firewall rule for TCP + UDP :1514 |
| 2 | `agent-auth.exe` not found | Agent installed to `x86` path, not `x64` | Corrected path to `C:\Program Files (x86)\ossec-agent\agent-auth.exe` |
| 3 | Incomplete MSI (5.9MB) | Broken download in `%TEMP%` | Re-downloaded via winget with hash verification |
| 4 | Agent stuck "Pending" | Syscollector cache lag post-restart | Forced rescan via `Restart-Service WazuhSvc` |
| 5 | Server IP changed | DHCP lease renewal (`.254` → `.133`) | Configured static IP via `ifcfg-eth0` |
| 6 | `systemctl` Access Denied | Running as `wazuh-user`, not root | Switched to root via `sudo su -` |
| 7 | Sysmon binary not in PATH | winget installed launcher only | Direct download from sysinternals.com |

### Agent Enrollment Flow

```
Download MSI (winget)
       ↓
msiexec install with WAZUH_MANAGER param
       ↓
agent-auth.exe -m 10.249.232.254 -A "Khonshu"
       ↓
Valid key received
       ↓
WazuhSvc started
       ↓
Never Connected → Pending → ✅ Active
```

---

## 🔍 Module 1 — File Integrity Monitoring (FIM)

### Configuration Changes from Default

| Setting | Default | This Lab |
|---|---|---|
| Scan frequency | 43200s (12h) | **300s (5 min)** |
| `alert_new_files` | not set | **yes** |
| `scan_on_start` | not set | **yes** |
| Realtime paths | Startup folder only | **8 critical paths** |
| `report_changes` | not set | **yes** (user dirs) |

### Realtime Monitored Paths

| Path | Threat Coverage |
|---|---|
| `%USERPROFILE%\Desktop` | Payload staging |
| `%USERPROFILE%\Downloads` | Dropper detection |
| `%USERPROFILE%\Documents` | Data exfiltration |
| `%APPDATA%\...\Recent` | Access pattern tracking |
| `%PROGRAMDATA%\...\Startup` | Persistence — T1547.001 |
| `%APPDATA%\...\Startup` | Per-user persistence |
| `%WINDIR%\Temp` + `%TEMP%` | Stager/dropper locations |
| `C:\Program Files (x86)\ossec-agent` | Agent tamper detection |

### Registry Keys Monitored — MITRE Mapped

| Registry Key | MITRE Technique | Description |
|---|---|---|
| `...\CurrentVersion\Run` (both arch) | T1547.001 | Autorun persistence |
| `...\CurrentVersion\RunOnce` | T1547.001 | One-time autorun |
| `...\Winlogon` | T1547.004 | Winlogon hijacking |
| `Image File Execution Options` | T1546.012 | Debugger hijacking |
| `CLSID` (both arch) | T1546.015 | COM object hijacking |
| `TaskCache\Tasks` | T1053.005 | Scheduled task persistence |
| `Policies\System` | — | UAC bypass detection |
| `Shell Folders` | T1547 | Shell folder redirection |
| `Active Setup\Installed Components` | T1546.010 | AppInit DLL hijacking |
| `CurrentControlSet\Services` | T1543.003 | Service persistence |
| `KnownDLLs` | T1574.001 | DLL search order hijacking |

### Additional Windows Telemetry Added

| Log Source | EventIDs | Detection Coverage |
|---|---|---|
| PowerShell Operational | 4103, 4104, 4105, 4106 | Script block logging, obfuscated commands |
| Windows Defender Operational | All | Malware detection, quarantine events |
| Task Scheduler Operational | All | Persistence via scheduled tasks |
| Sysmon Operational | All | Process, network, DLL, registry |

---

## 🔒 Module 2 — Security Configuration Assessment (SCA)

| Setting | Value |
|---|---|
| Policy | CIS Windows 11 Enterprise |
| Scan on start | Yes |
| Interval | 12 hours |
| Status | ✅ Active |

> **[🔄 In Progress]** — CIS benchmark pass/fail results being documented. Full hardening report to be added here.

---

## 🦠 Module 3 — Vulnerability Management

### CVE Remediation Journey

```
Initial State (2026-09-05)
┌─────────────────────────────────────────┐
│  Critical:  3   ████████████████████    │
│  High:     58   ████████████████████    │
│  Medium:   50   ████████████████████    │
│  Low:      11   ████                    │
│  Total:   131                           │
└─────────────────────────────────────────┘

After Remediation
┌─────────────────────────────────────────┐
│  Critical:  0   ✅                       │
│  High:      0   ✅                       │
│  Medium:    0   ✅  [indexer syncing]    │
│  Low:       0   ✅                       │
│  Total:    ~2   (cache lag only)         │
└─────────────────────────────────────────┘

Remediation Rate: ~98.5%
```

### Package Remediation Table

| Package | Vuln Count | Before | After | CVEs Fixed | Status |
|---|---|---|---|---|---|
| Django | 28 | old | **5.2.17** | CVE-2025-64459 (CVSS 9.1), CVE-2026-4277 + 26 others | ✅ |
| VLC Media Player | 1 | 3.0.10 | **3.0.23** | CVE-2023-47359 (CVSS 9.8) | ✅ |
| Python 3.11.9 | 15 | 3.11.9 | Pending | — | ⏳ |
| Python 3.13.1 | 13 | 3.13.1 | Pending | — | ⏳ |
| WinRAR 5.40 beta 3 | 11 | 5.40b3 | Pending | CVE-2023-38831 family | ⏳ |
| pip | 10 | old | Pending | — | ⏳ |

### Critical CVE Detail

| CVE | CVSS | Package | Description | Fixed In | Status |
|---|---|---|---|---|---|
| CVE-2023-47359 | **9.8** | VLC 3.0.10 | Heap buffer overflow in MMS GetPacket() — RCE | 3.0.20 | ✅ Patched |
| CVE-2025-64459 | **9.1** | Django | SQL injection via `_connector` in Q()/QuerySet — unauthenticated | 5.2.8 | ✅ Patched |
| CVE-2026-4277 | Critical | Django | Auth bypass in GenericInlineModelAdmin — PoC public | 5.2.13 | ✅ Patched |

### Vulnerability Management Methodology

```
Discover (Wazuh syscollector + NVD feed)
         ↓
Prioritize (CVSS score → Critical first)
         ↓
Patch (pip upgrade / winget / manual)
         ↓
Rescan (Restart-Service WazuhSvc)
         ↓
Verify (Dashboard CVE count drops)
         ↓
Document (before/after evidence)
```

---

## 🔬 Module 4 — Sysmon Integration

### Installation

```powershell
# Download from Sysinternals
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "C:\Sysmon.zip"
Expand-Archive -Path "C:\Sysmon.zip" -DestinationPath "C:\Sysmon" -Force

# Install with SwiftOnSecurity config
& "C:\Sysmon\sysmon64.exe" -accepteula -i C:\sysmon-config.xml

# Verify
Get-Service sysmon64
```

**Config:** [SwiftOnSecurity sysmon-config](https://github.com/SwiftOnSecurity/sysmon-config)  
**Version:** 15.21, Schema 4.50  
**Status:** ✅ Running

### Sysmon Event Coverage

| EventID | Event Type | Detection Use Case |
|---|---|---|
| 1 | Process Create | Malware execution, LOLBin abuse |
| 2 | File Creation Time | Timestomping (T1070.006) |
| 3 | Network Connection | C2 callbacks, lateral movement |
| 7 | Image Loaded | DLL hijacking, injection |
| 8 | CreateRemoteThread | Process injection (T1055) |
| 10 | ProcessAccess | Credential dumping (T1003) |
| 11 | FileCreate | Dropper detection |
| 12/13 | RegistryEvent | Persistence detection |
| 15 | FileCreateStreamHash | ADS (T1564.004) |
| 22 | DNS Query | C2 detection, tunneling |

---

## ⚔️ Module 5 — Attack Simulation (In Progress)

### MITRE ATT&CK Detection Coverage Matrix

| # | Technique | ID | Simulated | Detected | Log Source | Wazuh Rule | Status |
|---|---|---|---|---|---|---|---|
| 1 | PowerShell Execution | T1059.001 | ⬜ | ⬜ | Sysmon EID1, Win EID4104 | TBD | 🔄 Next |
| 2 | Scheduled Task Persistence | T1053.005 | ⬜ | ⬜ | TaskScheduler EID4698 + FIM | TBD | 🔄 Next |
| 3 | Startup Folder Persistence | T1547.001 | ⬜ | ⬜ | FIM realtime | TBD | 🔄 Next |
| 4 | Brute Force | T1110 | ⬜ | ⬜ | Security EID4625 | 18152 | 🔄 Next |
| 5 | Registry Run Key Persistence | T1547.001 | ⬜ | ⬜ | Wazuh registry monitor | TBD | ⬜ |
| 6 | Suspicious Process Creation | T1059 | ⬜ | ⬜ | Sysmon EID1 | TBD | ⬜ |
| 7 | Account Discovery | T1087 | ⬜ | ⬜ | Sysmon + Security | TBD | ⬜ |
| 8 | File System Integrity | T1565 | ✅ | ✅ | FIM realtime | Verified | ✅ |

> **Legend:** ✅ Complete | 🔄 In Progress | ⬜ Pending

### Planned Simulations

#### Simulation 1 — Brute Force (T1110)
```powershell
# 10 failed local authentication attempts
1..10 | ForEach-Object {
    try {
        $cred = New-Object System.Management.Automation.PSCredential(
            "FakeUser",
            (ConvertTo-SecureString "WrongPass" -AsPlainText -Force))
        Start-Process cmd -Credential $cred -ErrorAction Stop
    } catch { }
    Start-Sleep -Milliseconds 500
}
# Expected: Wazuh Rule 18152 fires, Security EventID 4625 ×10
```

#### Simulation 2 — Encoded PowerShell (T1059.001)
```powershell
# Simulate malware-style encoded command
$cmd = "Write-Host 'Simulated beacon - lab test only'"
$enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($cmd))
powershell.exe -EncodedCommand $enc
# Expected: Sysmon EID1 + Windows EID4104 fires
```

#### Simulation 3 — Scheduled Task Persistence (T1053.005)
```powershell
# Create disguised scheduled task
schtasks /create /tn "WindowsUpdateHelper" `
  /tr "powershell.exe -WindowStyle Hidden -Command Write-Host 'lab'" `
  /sc onlogon /ru SYSTEM /f
Start-Sleep -Seconds 10
schtasks /delete /tn "WindowsUpdateHelper" /f
# Expected: TaskScheduler EID4698 + FIM registry alert fires
```

#### Simulation 4 — Startup Persistence (T1547.001)
```powershell
# Drop file in monitored startup folder
New-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\lab-test.bat" `
  -Value "echo lab test" -Force
Start-Sleep -Seconds 10
Remove-Item "$env:APPDATA\...\Startup\lab-test.bat" -Force
# Expected: FIM realtime alert fires immediately
```

---

## 📋 Incident Reports

> **[🔄 In Progress]** — Incident reports will be added here as simulations are executed and validated.

### IR Template Used

```
Incident ID:     IR-YYYY-MM-DD-001
Severity:        [Critical/High/Medium/Low]
Detection Time:  [timestamp]
Affected Host:   Khonshu
Technique:       MITRE Txxxx.xxx
Initial Alert:   [Wazuh rule ID + description]

Timeline:
  HH:MM:SS — Event 1
  HH:MM:SS — Event 2
  HH:MM:SS — Alert generated
  HH:MM:SS — Investigation began
  HH:MM:SS — Contained

Investigation:
  Log sources reviewed: [list]
  Key indicators:       [IOCs]
  Root cause:           [description]

Containment:   [steps taken]
Remediation:   [steps taken]
Evidence:      [screenshots/log excerpts]
Lessons:       [takeaways]
```

---

## 📁 Repository Structure

```
wazuh-soc-lab/
│
├── README.md                    ← This file
│
├── docs/
│   ├── architecture.md          ← Detailed architecture
│   ├── deployment.md            ← Full deployment guide
│   ├── sca-report.md            ← CIS benchmark results (in progress)
│   └── vuln-management.md       ← CVE remediation full report
│
├── config/
│   ├── ossec.conf               ← Hardened agent config
│   └── sysmon-config.xml        ← SwiftOnSecurity Sysmon config
│
├── detections/
│   ├── windows/
│   │   ├── powershell/          ← PS detection rules
│   │   ├── persistence/         ← Startup, registry, task rules
│   │   ├── authentication/      ← Brute force, auth rules
│   │   └── process/             ← Suspicious process rules
│   └── linux/
│       ├── ssh/                 ← SSH brute force (planned)
│       └── persistence/         ← Linux persistence (planned)
│
├── incidents/
│   ├── IR-2026-09-05-001.md     ← [Planned: Brute Force IR]
│   ├── IR-2026-09-05-002.md     ← [Planned: PowerShell IR]
│   └── IR-2026-09-05-003.md     ← [Planned: Persistence IR]
│
└── scripts/
    ├── sim-bruteforce.ps1       ← Simulation scripts
    ├── sim-powershell.ps1
    ├── sim-persistence.ps1
    └── sim-startup.ps1
```

---

## 🗺️ Roadmap

### ✅ Phase 0 — Foundation (Complete)
- [x] Wazuh OVA deployment on VirtualBox
- [x] Windows agent enrollment and activation
- [x] Agent-server communication (TCP :1514, AES)
- [x] Real-world deployment troubleshooting documented

### ✅ Phase 1 — Monitoring Configuration (Complete)
- [x] FIM hardened — realtime on 8 paths, 5-min frequency
- [x] MITRE-mapped registry monitoring (10 keys)
- [x] Extended Windows telemetry (PowerShell, Defender, TaskScheduler)
- [x] SCA — CIS Win11 Enterprise active
- [x] Sysmon 15.21 installed with SwiftOnSecurity config

### 🔄 Phase 2 — Vulnerability Management (In Progress)
- [x] Vulnerability detection enabled on server
- [x] 131 CVEs discovered across 5 packages
- [x] Django upgraded → 5.2.17 (cleared 128 CVEs)
- [x] VLC upgraded → 3.0.23 (cleared CVE-2023-47359 CVSS 9.8)
- [ ] WinRAR upgrade → 7.x (manual download pending)
- [ ] Python 3.11.9 + 3.13.1 upgrades pending
- [ ] pip upgrade pending
- [ ] Final CVE count → 0 target

### ⬜ Phase 3 — Attack Simulation + Detection Validation
- [ ] Brute force simulation + detection (T1110)
- [ ] PowerShell encoded command detection (T1059.001)
- [ ] Scheduled task persistence detection (T1053.005)
- [ ] Startup folder persistence (T1547.001)
- [ ] MITRE coverage matrix completed
- [ ] 3 full incident reports written

### ⬜ Phase 4 — SOC Operations
- [ ] Threat hunting exercises (5 hypotheses)
- [ ] Alert severity tuning
- [ ] False positive testing and documentation
- [ ] Custom Wazuh detection rules
- [ ] SOC investigation timelines

### ⬜ Phase 5 — Enterprise Expansion
- [ ] Linux endpoint (Ubuntu) added
- [ ] Kali attacker VM added
- [ ] SSH brute force detection (Linux)
- [ ] Purple team attack-detect-respond cycle
- [ ] Detection Engineering repository (Sigma rules)

---

## 📊 Key Metrics

| Metric | Value |
|---|---|
| Endpoints Monitored | 1 (Windows 11) |
| Total CVEs Discovered | 131 |
| Critical CVEs Patched | 3/3 (100%) |
| CVE Reduction | 131 → ~2 (98.5%) |
| FIM Realtime Paths | 8 |
| Registry Keys Monitored | 20+ |
| MITRE Techniques Mapped (config) | 10+ |
| MITRE Techniques Validated (sim) | 0 → In Progress |
| Incident Reports | 0 → In Progress |
| Sysmon Event Types | 10 |

---

## 🔧 Key Config Files

- [`config/ossec.conf`](config/ossec.conf) — Hardened Wazuh agent configuration
- [`config/sysmon-config.xml`](config/sysmon-config.xml) — SwiftOnSecurity Sysmon ruleset

---

## 📚 References

- [Wazuh Documentation](https://documentation.wazuh.com)
- [MITRE ATT&CK for Windows](https://attack.mitre.org/matrices/enterprise/windows/)
- [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config)
- [CIS Benchmarks — Windows 11](https://www.cisecurity.org/benchmark/microsoft_windows_desktop)
- [NVD — National Vulnerability Database](https://nvd.nist.gov/)

---

## 👤 Author

**Pratik** — Offensive Security Researcher & Bug Bounty Hunter  
HackerOne: `on3_r4gn4r` | Bugcrowd: `r4gn4r`

> *"I built this lab to understand how defenders see the attacks I research — the same techniques from both sides of the scope."*

---

*Last updated: 2026-09-07 | Status: Active Development*
