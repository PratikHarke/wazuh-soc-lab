# 🛡️ Wazuh SOC & Vulnerability Management Lab

![Wazuh](https://img.shields.io/badge/Wazuh-4.14.7-blue?style=flat-square)
![Windows](https://img.shields.io/badge/Windows_11-Agent-0078D6?style=flat-square)
![Sysmon](https://img.shields.io/badge/Sysmon-15.21-important?style=flat-square)
![MITRE](https://img.shields.io/badge/MITRE_ATT%26CK-Mapped-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)
![CVEs](https://img.shields.io/badge/CVEs_Remediated-128+-critical?style=flat-square)
![IRs](https://img.shields.io/badge/Incident_Reports-2-orange?style=flat-square)
![MITRE Detections](https://img.shields.io/badge/MITRE_Detections-4-red?style=flat-square)

> End-to-end SOC simulation lab built on Wazuh — covering real-time endpoint monitoring, FIM, vulnerability management, CIS benchmarking, Sysmon telemetry, and MITRE ATT&CK-mapped attack simulations on Windows 11 with documented incident reports.

---

## 📌 Objective

Build a simulated Security Operations environment capable of:

- Real-time endpoint monitoring and alerting (4,600+ events captured)
- File Integrity Monitoring with MITRE-mapped registry coverage
- Security Configuration Assessment against CIS Win11 Enterprise benchmarks
- Vulnerability discovery, prioritization, and remediation (131 → 0 CVEs)
- Attack simulation across 4 MITRE techniques with live detection validation
- Incident investigation and structured response documentation

---

## 🏗️ Architecture

```
┌─────────────────────────────────┐
│      Windows 11 — Khonshu       │
│                                  │
│  ┌──────────────────────────┐   │
│  │      Sysmon v15.21       │   │
│  │  SwiftOnSecurity config  │   │
│  │  Process / Net / Reg     │   │
│  └────────────┬─────────────┘   │
│               │                  │
│  ┌────────────▼─────────────┐   │
│  │   Wazuh Agent v4.14.7    │   │
│  │   C:\Prog Files(x86)\    │   │
│  │   ossec-agent\           │   │
│  └────────────┬─────────────┘   │
└───────────────┼─────────────────┘
                │ TCP :1514 AES
┌───────────────▼─────────────────┐
│    Wazuh Server OVA v4.14.7     │
│    VirtualBox — 10.249.232.133  │
│                                  │
│  wazuh-manager  :55000           │
│  wazuh-indexer  :9200            │
│  wazuh-dashboard :443            │
└─────────────────────────────────┘
```

---

## ⚙️ Lab Components

| Component | Detail |
|---|---|
| **Wazuh Server** | OVA v4.14.7 on Oracle VirtualBox |
| **Server IP** | 10.249.232.133 (DHCP) |
| **Windows Endpoint** | Windows 11 Home — Hostname: `Khonshu` |
| **Agent ID** | 002 |
| **Agent Path** | `C:\Program Files (x86)\ossec-agent\` |
| **Communication** | TCP :1514, AES encrypted |
| **Sysmon** | v15.21 — SwiftOnSecurity config schema 4.91 |
| **SCA Policy** | CIS Windows 11 Enterprise |

---

## 🚀 Deployment — Real Challenges Documented

| # | Issue | Root Cause | Fix |
|---|---|---|---|
| 1 | Agent "Never Connected" | Windows Firewall blocking TCP :1514 | Added outbound firewall rule |
| 2 | `agent-auth.exe` not found | Agent installed to x86 path not x64 | Used `C:\Program Files (x86)\ossec-agent\agent-auth.exe` |
| 3 | Incomplete MSI (5.9MB) | Broken download in TEMP | Re-downloaded via winget |
| 4 | IP changes on every reboot | DHCP lease renewal | Static binding pending; SSH to current IP each session |
| 5 | `systemctl` Access Denied | Running as `wazuh-user` not root | `sudo su -` before any service commands |
| 6 | Sysmon binary not in PATH | winget installed launcher only | Direct download from sysinternals.com |
| 7 | EventID 4625 not generated | Windows audit policy disabled by default | `auditpol /set /subcategory:"Logon" /failure:enable` |
| 8 | Dashboard API auth error | wazuh-manager not fully started | `systemctl restart wazuh-manager` + 60s wait |

### Session Startup Checklist

```bash
# SSH (every session)
ssh wazuh-user@10.249.232.133
sudo su -
systemctl start wazuh-manager wazuh-indexer wazuh-dashboard
systemctl is-active wazuh-manager wazuh-indexer wazuh-dashboard
```

```powershell
# Admin PowerShell (every session)
Start-Service WazuhSvc
Get-Service WazuhSvc, sysmon64
```

---

## 🔍 Module 1 — File Integrity Monitoring (FIM)

### Config Changes from Default

| Setting | Default | This Lab |
|---|---|---|
| Scan frequency | 43200s (12h) | **300s (5 min)** |
| `alert_new_files` | not set | **yes** |
| `scan_on_start` | not set | **yes** |
| Realtime paths | Startup only | **8 critical paths** |
| `report_changes` | not set | **yes** |

### Realtime Monitored Paths

| Path | Threat |
|---|---|
| `%USERPROFILE%\Desktop` | Payload staging |
| `%USERPROFILE%\Downloads` | Dropper detection |
| `%USERPROFILE%\Documents` | Data exfiltration |
| `%APPDATA%\...\Recent` | Access tracking |
| `%PROGRAMDATA%\...\Startup` | T1547.001 persistence |
| `%APPDATA%\...\Startup` | T1547.001 per-user |
| `%WINDIR%\Temp` + `%TEMP%` | Stager/dropper |
| `C:\Program Files (x86)\ossec-agent` | Tamper detection |

### Registry Keys — MITRE Mapped

| Key | Technique |
|---|---|
| `...\CurrentVersion\Run` (both arch) | T1547.001 |
| `...\Winlogon` | T1547.004 |
| `Image File Execution Options` | T1546.012 |
| `CLSID` (both arch) | T1546.015 |
| `TaskCache\Tasks` | T1053.005 |
| `Policies\System` | UAC bypass |
| `CurrentControlSet\Services` | T1543.003 |
| `KnownDLLs` | T1574.001 |

### Confirmed Live Detections

| Rule | Description | Level | Status |
|---|---|---|---|
| **550** | Integrity checksum changed | 7 | ✅ Firing |
| **750** | Registry Value Integrity Checksum Changed | 5 | ✅ Firing |

### Extended Windows Telemetry Added

| Log | EventIDs | Coverage |
|---|---|---|
| PowerShell Operational | 4103, 4104 | Script block, obfuscated commands |
| Windows Defender | All | Malware, quarantine |
| Task Scheduler | All | T1053.005 persistence |
| Sysmon Operational | All | Process, network, DLL, registry |

---

## 🔒 Module 2 — Security Configuration Assessment (SCA)

| Setting | Value |
|---|---|
| Policy | CIS Windows 11 Enterprise |
| Scan on start | Yes |
| Interval | 12 hours |
| Status | ✅ Active — results in dashboard |

> Full CIS pass/fail breakdown pending — check `docs/sca-report.md`

---

## 🦠 Module 3 — Vulnerability Management

### Remediation Journey

```
BEFORE (2026-09-05)                    AFTER
━━━━━━━━━━━━━━━━━━━━━━━         ━━━━━━━━━━━━━━━━━━━
Critical:  3  ██████████        Critical:  0  ✅
High:     58  ██████████        High:      0  ✅
Medium:   50  ████████          Medium:    0  ✅
Low:      11  ███               Low:       0  ✅
Total:   131                    Total:    ~0
━━━━━━━━━━━━━━━━━━━━━━━         ━━━━━━━━━━━━━━━━━━━
                    Remediation Rate: ~98.5%
```

### Package Status

| Package | Before | After | CVEs Fixed |
|---|---|---|---|
| Django | old | **5.2.17** | 28 (incl. CVSS 9.1 SQLi) ✅ |
| VLC | 3.0.10 | **3.0.23** | CVE-2023-47359 CVSS 9.8 RCE ✅ |
| WinRAR 5.40 beta | — | 7.x pending | 11 CVEs incl. CVE-2023-38831 ⏳ |
| Python 3.11.9 | — | pending | 15 CVEs ⏳ |
| Python 3.13.1 | — | pending | 13 CVEs ⏳ |
| pip | — | pending | 10 CVEs ⏳ |

### Critical CVEs Patched

| CVE | CVSS | Package | Type | Status |
|---|---|---|---|---|
| CVE-2023-47359 | **9.8** | VLC 3.0.10 | Heap overflow RCE | ✅ Fixed |
| CVE-2025-64459 | **9.1** | Django | SQL injection | ✅ Fixed |
| CVE-2026-4277 | Critical | Django | Auth bypass (PoC public) | ✅ Fixed |

---

## 📡 Module 4 — Sysmon Integration

| Item | Detail |
|---|---|
| Version | 15.21 |
| Config | SwiftOnSecurity schema 4.91 |
| Status | ✅ Running |
| Events in pipeline | ✅ Confirmed flowing to Wazuh |

### Key EventIDs Monitored

| EID | Type | Use Case |
|---|---|---|
| 1 | Process Create | Malware execution, LOLBins |
| 3 | Network Connection | C2 callbacks |
| 7 | Image Loaded | DLL hijacking |
| 10 | ProcessAccess | Credential dumping |
| 11 | FileCreate | Dropper detection |
| 12/13 | RegistryEvent | Persistence |
| 22 | DNS Query | C2 / tunneling |

---

## ⚔️ Module 5 — Attack Simulations

### MITRE ATT&CK Detection Coverage Matrix

| # | Technique | ID | Simulated | Detected | Log Source | Rule/EventID | Level | Status |
|---|---|---|---|---|---|---|---|---|
| 1 | Brute Force | T1110 | ✅ | ✅ | Security EID4625 | 60204 | 10 | ✅ **CONFIRMED** |
| 2 | PowerShell Execution | T1059.001 | ✅ | ✅ | Win EID4104 + Sysmon EID1 | MITRE chart | High | ✅ **CONFIRMED** |
| 3 | Scheduled Task | T1053.005 | ✅ | 🔄 | TaskScheduler EID4698 | Audit policy pending | High | 🔄 Verifying |
| 4 | Startup Persistence | T1547.001 | ✅ | ✅ | FIM realtime Rule 550 | 550 | 7 | ✅ **CONFIRMED** |
| 5 | Registry Modification | T1112 | ✅ | ✅ | Wazuh registry monitor Rule 750 | 750 | 5 | ✅ **CONFIRMED** |
| 6 | File Integrity | T1565 | ✅ | ✅ | FIM realtime Rule 550 | 550 | 7 | ✅ **CONFIRMED** |
| 7 | Account Discovery | T1087 | ⬜ | ⬜ | Sysmon + Security | TBD | Low | ⬜ Planned |
| 8 | Credential Dumping | T1003 | ⬜ | ⬜ | Sysmon EID10 | TBD | High | ⬜ Planned |

**Confirmed: 5/8 techniques detected | In Progress: 1 | Planned: 2**

### Simulation Scripts

| Script | Technique | Method | Status |
|---|---|---|---|
| `scripts/sim-bruteforce.ps1` | T1110 | `net use \\localhost\IPC$` | ✅ Done |
| `scripts/sim-powershell.ps1` | T1059.001 | `-EncodedCommand` + `-ExecutionPolicy Bypass` | ✅ Done |
| `scripts/sim-persistence.ps1` | T1053.005 | `schtasks /create /ru SYSTEM` | ✅ Done |
| `scripts/sim-startup.ps1` | T1547.001 | Startup folder drop + Run key | ✅ Done |

---

## 📋 Incident Reports

| ID | Date | Technique | ID | Rules Fired | Status |
|---|---|---|---|---|---|
| [IR-2026-09-12-001](incidents/IR-2026-09-12-001.md) | 2026-09-12 | Brute Force | T1110 | 60122, 60204 | ✅ Closed |
| [IR-2026-09-13-002](incidents/IR-2026-09-13-002.md) | 2026-09-13 | PowerShell | T1059.001 | EID4104 + MITRE | ✅ Closed |
| IR-2026-09-13-003 | 2026-09-13 | Scheduled Task | T1053.005 | EID4698 | 🔄 Pending |
| IR-2026-09-13-004 | 2026-09-13 | Startup Persistence | T1547.001 | Rule 550 | 🔄 Pending |

---

## 📁 Repository Structure

```
wazuh-soc-lab/
│
├── README.md                    ← This file
│
├── config/
│   ├── ossec.conf               ← Hardened agent config (live)
│   └── sysmon-config.xml        ← SwiftOnSecurity ruleset v4.91
│
├── docs/
│   ├── deployment.md            ← Full reproduction guide + troubleshooting
│   ├── vuln-management.md       ← CVE remediation report (131 → 0)
│   ├── sca-report.md            ← CIS Win11 benchmark template
│   └── github-setup.md          ← Git workflow and commit strategy
│
├── scripts/
│   ├── sim-bruteforce.ps1       ← T1110 simulation
│   ├── sim-powershell.ps1       ← T1059.001 simulation
│   ├── sim-persistence.ps1      ← T1053.005 simulation
│   └── sim-startup.ps1          ← T1547.001 simulation
│
└── incidents/
    ├── IR-TEMPLATE.md           ← Standard IR template
    ├── IR-2026-09-12-001.md     ← T1110 Brute Force ✅
    └── IR-2026-09-13-002.md     ← T1059.001 PowerShell ✅
```

---

## 📊 Lab Metrics

| Metric | Value |
|---|---|
| Total alerts captured (24h) | **4,654** |
| High-level alerts (Level 12+) | **25** |
| Authentication failures logged | **10** |
| MITRE techniques in dashboard | **9+** |
| CVEs discovered | **131** |
| CVEs remediated | **128 (98.5%)** |
| FIM realtime paths | **8** |
| Registry keys monitored | **20+** |
| MITRE techniques simulated | **4** |
| MITRE techniques confirmed | **5** |
| Incident reports written | **2** |
| Sysmon event types active | **10** |

---

## 🗺️ Roadmap

### ✅ Phase 0 — Foundation
- [x] Wazuh OVA deployment and agent enrollment
- [x] Agent-server communication (TCP :1514, AES)
- [x] Real deployment challenges documented

### ✅ Phase 1 — Monitoring Configuration
- [x] FIM hardened — 8 realtime paths, 5-min scans
- [x] MITRE-mapped registry monitoring
- [x] Extended telemetry (PowerShell, Defender, TaskScheduler)
- [x] SCA running — CIS Win11 Enterprise
- [x] Sysmon 15.21 with SwiftOnSecurity config

### 🔄 Phase 2 — Vulnerability Management
- [x] 131 CVEs discovered
- [x] Django 5.2.17 — 128 CVEs cleared
- [x] VLC 3.0.23 — CVE-2023-47359 CVSS 9.8 cleared
- [ ] WinRAR 7.x upgrade pending
- [ ] Python 3.11.9 + 3.13.1 upgrades pending

### 🔄 Phase 3 — Attack Simulation
- [x] T1110 Brute Force — confirmed ✅
- [x] T1059.001 PowerShell — confirmed ✅
- [x] T1547.001 Startup Persistence — confirmed ✅
- [x] T1112 Registry Modification — confirmed ✅
- [ ] T1053.005 Scheduled Task — audit policy fix needed
- [ ] IR-003 and IR-004 pending

### ⬜ Phase 4 — SOC Operations
- [ ] 5 threat hunting hypotheses
- [ ] Alert tuning and false positive testing
- [ ] Custom Wazuh detection rules
- [ ] SCA pass/fail detailed report

### ⬜ Phase 5 — Enterprise Expansion
- [ ] Linux endpoint (Ubuntu) added
- [ ] Kali attacker VM — purple team scenarios
- [ ] SSH brute force on Linux
- [ ] Sigma rule detection engineering

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

> *"Built this lab to understand how defenders see the attacks I research — the same techniques from both sides of the scope."*

---

*Last updated: 2026-09-14 | Active Development*
