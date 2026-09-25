# 🛡️ Wazuh SOC & Vulnerability Management Lab

![Wazuh](https://img.shields.io/badge/Wazuh-4.14.7-blue?style=flat-square)
![Windows](https://img.shields.io/badge/Windows_11-Agent_002-0078D6?style=flat-square)
![Kali](https://img.shields.io/badge/Kali_Linux-Agent_004-557C94?style=flat-square)
![Sysmon](https://img.shields.io/badge/Sysmon-15.21-important?style=flat-square)
![MITRE](https://img.shields.io/badge/MITRE_ATT%26CK-Mapped-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)
![CVEs](https://img.shields.io/badge/CVEs_Remediated-128+-critical?style=flat-square)
![IRs](https://img.shields.io/badge/Incident_Reports-5-orange?style=flat-square)
![MITRE Detections](https://img.shields.io/badge/MITRE_Detections-7-red?style=flat-square)
![Custom Rules](https://img.shields.io/badge/Custom_Rules-4-blueviolet?style=flat-square)

> End-to-end SOC simulation lab built on Wazuh — covering real-time endpoint monitoring, FIM, vulnerability management, CIS benchmarking, Sysmon telemetry, MITRE ATT&CK-mapped attack simulations across Windows 11 and Kali Linux endpoints, custom detection rules, threat hunting, and structured incident response documentation.

---

## 📌 Objective

Build a simulated Security Operations environment capable of:

- Real-time endpoint monitoring and alerting across Windows and Linux (4,600+ events captured)
- File Integrity Monitoring with MITRE-mapped registry coverage
- Security Configuration Assessment against CIS benchmarks (Windows 11 + Linux)
- Vulnerability discovery, prioritization, and remediation (131 → ~0 CVEs)
- Attack simulation across 7 MITRE techniques with live detection validation
- Custom Wazuh detection rules mapped to MITRE ATT&CK (4 rules, 100001–100004)
- Proactive threat hunting with documented hypotheses (6 total, 3 confirmed)
- Incident investigation and structured response documentation (5 IRs)

---

## 🏗️ Architecture

```
┌─────────────────────────────────┐    ┌─────────────────────────────────┐
│      Windows 11 — Khonshu       │    │      Kali Linux — kali          │
│                                  │    │                                  │
│  ┌──────────────────────────┐   │    │  ┌──────────────────────────┐   │
│  │      Sysmon v15.21       │   │    │  │   auditd 4.1.2           │   │
│  │  SwiftOnSecurity config  │   │    │  │   rsyslog + auth.log     │   │
│  │  Process / Net / Reg     │   │    │  │   SSH daemon             │   │
│  └────────────┬─────────────┘   │    │  └────────────┬─────────────┘   │
│               │                  │    │               │                  │
│  ┌────────────▼─────────────┐   │    │  ┌────────────▼─────────────┐   │
│  │   Wazuh Agent v4.14.7    │   │    │  │   Wazuh Agent v4.14.8    │   │
│  │   Agent ID: 002          │   │    │  │   Agent ID: 004          │   │
│  └────────────┬─────────────┘   │    │  └────────────┬─────────────┘   │
└───────────────┼─────────────────┘    └───────────────┼─────────────────┘
                │ TCP :1514 AES                         │ TCP :1514 AES
                └───────────────────┬───────────────────┘
                        ┌───────────▼─────────────┐
                        │    Wazuh Server OVA      │
                        │    v4.14.7 — VirtualBox  │
                        │    10.249.232.133         │
                        │                           │
                        │  wazuh-manager  :55000    │
                        │  wazuh-indexer  :9200     │
                        │  wazuh-dashboard :443     │
                        └───────────────────────────┘
```

---

## ⚙️ Lab Components

| Component | Detail |
|---|---|
| **Wazuh Server** | OVA v4.14.7 on Oracle VirtualBox |
| **Server IP** | 10.249.232.133 (bridged adapter) |
| **Windows Endpoint** | Windows 11 Home — Hostname: `Khonshu` (Agent 002) |
| **Linux Endpoint** | Kali Linux — Hostname: `kali` (Agent 004, IP: 10.249.232.161) |
| **Communication** | TCP :1514, AES encrypted |
| **Sysmon** | v15.21 — SwiftOnSecurity config schema 4.91 |
| **auditd** | v4.1.2 — custom rules for privilege escalation, passwd, sshd config |
| **SCA Policies** | CIS Windows 11 Enterprise + CIS Distribution Independent Linux |
| **Custom Rules** | 4 rules (100001–100004), all MITRE-mapped |

---

## 🚀 Deployment — Real Challenges Documented

| # | Issue | Root Cause | Fix |
|---|---|---|---|
| 1 | Agent "Never Connected" | Windows Firewall blocking TCP :1514 | Added outbound firewall rule |
| 2 | `agent-auth.exe` not found | Agent installed to x86 path not x64 | Used `C:\Program Files (x86)\ossec-agent\agent-auth.exe` |
| 3 | Incomplete MSI (5.9MB) | Broken download in TEMP | Re-downloaded via winget |
| 4 | IP changes on every reboot | DHCP lease renewal | SSH to current IP each session |
| 5 | `systemctl` Access Denied | Running as `wazuh-user` not root | `sudo su -` before any service commands |
| 6 | Sysmon binary not in PATH | winget installed launcher only | Direct download from sysinternals.com |
| 7 | EventID 4625 not generated | Windows audit policy disabled by default | `auditpol /set /subcategory:"Logon" /failure:enable` |
| 8 | Dashboard API auth error | wazuh-manager not fully started | `systemctl restart wazuh-manager` + 60s wait |
| 9 | Disk 100% full on reboot | `queue/vd` (11G) + `queue/vd_updater` (7.9G) filled `/dev/sda1` | Cleared queues; set `feed-update-interval` 60m → 24h; daily cleanup cron |
| 10 | Kali agent stuck Pending | GPG key import failed without sudo; `sqv` incompatibility | Used `--dearmor` method; wiped stale client.keys; re-enrolled |
| 11 | ossec.conf corrupted | `sed` inserted literal `\n` breaking XML structure | Rewrote config from scratch using Python |
| 12 | Kali no IPv4 (network unreachable) | Adapter set to plain NAT instead of Bridged | Changed to Bridged Adapter (MediaTek Wi-Fi 6 MT7921) |
| 13 | auth.log missing on Kali | Kali uses journald only — no rsyslog by default | Installed rsyslog; created /etc/rsyslog.d/50-auth.conf |

### Session Startup Checklist

```bash
# SSH to Wazuh server (every session — DHCP may change IP)
ssh wazuh-user@10.249.232.133
sudo systemctl start wazuh-indexer wazuh-manager wazuh-dashboard
sudo systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard

# Verify agents
sudo /var/ossec/bin/agent_control -l
```

```powershell
# Admin PowerShell on Khonshu (every session)
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

---

## 🔒 Module 2 — Security Configuration Assessment (SCA)

| Endpoint | Policy | Hits | Status |
|---|---|---|---|
| Khonshu (Windows) | CIS Windows 11 Enterprise | — | ✅ Active |
| kali (Linux) | CIS Distribution Independent Linux | **392** | ✅ Active |

> Full CIS pass/fail breakdown: [`docs/sca-report.md`](docs/sca-report.md)

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
| Status | ✅ Running — events confirmed flowing to Wazuh |

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

| # | Technique | ID | Agent | Simulated | Detected | Rule | Level | Status |
|---|---|---|---|---|---|---|---|---|
| 1 | Brute Force (Windows) | T1110 | Khonshu | ✅ | ✅ | 60204 | 10 | ✅ **CONFIRMED** |
| 2 | PowerShell Execution | T1059.001 | Khonshu | ✅ | ✅ | 100002 | 12 | ✅ **CONFIRMED** |
| 3 | Scheduled Task | T1053.005 | Khonshu | ✅ | ✅ | 100001 | 12 | ✅ **CONFIRMED** |
| 4 | Startup Persistence | T1547.001 | Khonshu | ✅ | ✅ | 100003 | 12 | ✅ **CONFIRMED** |
| 5 | Registry Modification | T1112 | Khonshu | ✅ | ✅ | 750 | 5 | ✅ **CONFIRMED** |
| 6 | File Integrity | T1565 | Khonshu | ✅ | ✅ | 550 | 7 | ✅ **CONFIRMED** |
| 7 | SSH Brute Force (Linux) | T1110 | kali | ✅ | ✅ | **100004** | 12 | ✅ **CONFIRMED** |
| 8 | Credential Dumping | T1003 | Khonshu | ⬜ | ⬜ | TBD | High | ⬜ Phase 4 |
| 9 | C2 Beacon | T1071.001 | Both | ⬜ | ⬜ | TBD | High | ⬜ Phase 4 |

**Confirmed: 7/9 techniques detected**

### Simulation Tools Used

| Tool | Target | Technique | Agent |
|---|---|---|---|
| `net use \\localhost\IPC$` | Windows logon | T1110 | Khonshu |
| PowerShell `-EncodedCommand` | Script block logging | T1059.001 | Khonshu |
| `schtasks /create /ru SYSTEM` | Task scheduler | T1053.005 | Khonshu |
| Startup folder + Run key | Boot persistence | T1547.001 | Khonshu |
| Hydra v9.6 + rockyou.txt | SSH service | T1110 | kali |

---

## 🔧 Module 6 — Custom Detection Rules

File: [`config/local_rules.xml`](config/local_rules.xml)

| Rule ID | Technique | Description | Level | Agent |
|---|---|---|---|---|
| 100001 | T1053.005 | Scheduled Task created via schtasks.exe | 12 | Khonshu |
| 100002 | T1059.001 | Suspicious PowerShell script block execution | 12 | Khonshu |
| 100003 | T1547.001 | Registry Run Key persistence detected | 12 | Khonshu |
| 100004 | T1110 | SSH Brute Force on Linux endpoint | 12 | kali |

All rules confirmed firing in Wazuh Threat Hunting dashboard.

---

## 🔍 Module 7 — Threat Hunting

File: [`docs/threat-hunting.md`](docs/threat-hunting.md)

| # | Hypothesis | Technique | Agent | Status |
|---|---|---|---|---|
| 1 | LOLBin abuse | T1218 | Khonshu | No hits — baseline established |
| 2 | Registry autorun persistence | T1547.001 | Khonshu | ✅ Confirmed (IR-004) |
| 3 | LSASS credential dump | T1003.001 | Khonshu | Planned — Phase 4 |
| 4 | C2 outbound beacon | T1071.001 | Both | Planned — Phase 4 |
| 5 | Execution from Temp dirs | T1059 | Khonshu | ✅ Confirmed (IR-002) |
| 6 | SSH brute force | T1110 | kali | ✅ Confirmed (IR-005) |

---

## 📋 Incident Reports

| ID | Date | Technique | MITRE ID | Agent | Rules Fired | Status |
|---|---|---|---|---|---|---|
| [IR-001](incidents/IR-2026-09-12-001.md) | 2026-09-12 | Brute Force | T1110 | Khonshu | 60122, 60204 | ✅ Closed |
| [IR-002](incidents/IR-2026-09-13-002.md) | 2026-09-13 | PowerShell Execution | T1059.001 | Khonshu | EID4104, Sysmon EID1 | ✅ Closed |
| [IR-003](incidents/IR-2026-09-19-003.md) | 2026-09-19 | Scheduled Task | T1053.005 | Khonshu | Sysmon EID1, FIM 750, EID4698 | ✅ Closed |
| [IR-004](incidents/IR-2026-09-19-004.md) | 2026-09-19 | Startup Persistence | T1547.001 | Khonshu | FIM 550, FIM 750, Sysmon EID11/13 | ✅ Closed |
| [IR-005](incidents/IR-2026-09-24-005.md) | 2026-09-24 | SSH Brute Force | T1110 | kali | 5760, 5557, 2502, **100004** | ✅ Closed |

---

## 📁 Repository Structure

```
wazuh-soc-lab/
│
├── README.md                          ← This file
├── future.md                          ← Planned phases and expansion roadmap
│
├── config/
│   ├── ossec.conf                     ← Hardened agent config (Khonshu)
│   ├── local_rules.xml                ← Custom MITRE rules 100001–100004
│   └── sysmon-config.xml              ← SwiftOnSecurity ruleset v4.91
│
├── docs/
│   ├── deployment.md                  ← Full reproduction guide + troubleshooting
│   ├── vuln-management.md             ← CVE remediation summary
│   ├── sca-report.md                  ← CIS Win11 benchmark results
│   ├── threat-hunting.md              ← 6 threat hunting hypotheses (3 confirmed)
│   └── github-setup.md                ← Git workflow and commit strategy
│
├── reports/
│   └── vulnerability-management/
│       ├── initial-assessment.md
│       ├── critical-findings.md
│       ├── remediation-log.md
│       ├── verification-results.md
│       └── final-assessment.md
│
├── scripts/
│   ├── sim-bruteforce.ps1             ← T1110 simulation (Windows)
│   ├── sim-powershell.ps1             ← T1059.001 simulation
│   ├── sim-persistence.ps1            ← T1053.005 simulation
│   └── sim-startup.ps1                ← T1547.001 simulation
│
└── incidents/
    ├── IR-TEMPLATE.md
    ├── IR-2026-09-12-001.md           ← T1110 Brute Force (Windows) ✅
    ├── IR-2026-09-13-002.md           ← T1059.001 PowerShell ✅
    ├── IR-2026-09-19-003.md           ← T1053.005 Scheduled Task ✅
    ├── IR-2026-09-19-004.md           ← T1547.001 Startup Persistence ✅
    └── IR-2026-09-24-005.md           ← T1110 SSH Brute Force (Linux) ✅
```

---

## 📊 Lab Metrics

| Metric | Value |
|---|---|
| Total alerts captured (24h) | **4,654+** |
| High-level alerts (Level 12+) | **32+** |
| MITRE techniques simulated | **7** |
| MITRE techniques confirmed | **7** |
| Custom detection rules | **4** (100001–100004) |
| Incident reports written | **5** |
| CVEs discovered | **131** |
| CVEs remediated | **128 (98.5%)** |
| FIM realtime paths | **8** |
| Registry keys monitored | **20+** |
| Sysmon event types active | **10** |
| Threat hunting hypotheses | **6 (3 confirmed)** |
| Agents enrolled | **2** (Khonshu + kali) |
| SCA hits (Linux CIS) | **392** |

---

## 🗺️ Roadmap

### ✅ Phase 0 — Foundation
- [x] Wazuh OVA deployment and agent enrollment
- [x] Agent-server communication (TCP :1514, AES)
- [x] Real deployment challenges documented

### ✅ Phase 1 — Monitoring Configuration
- [x] FIM hardened — 8 realtime paths, 5-min scans
- [x] MITRE-mapped registry monitoring (20+ keys)
- [x] Extended telemetry (PowerShell, Defender, TaskScheduler)
- [x] SCA running — CIS Win11 Enterprise
- [x] Sysmon 15.21 with SwiftOnSecurity config

### ✅ Phase 2 — Vulnerability Management
- [x] 131 CVEs discovered and baselined
- [x] Django 5.2.17 — 128 CVEs cleared
- [x] VLC 3.0.23 — CVE-2023-47359 CVSS 9.8 cleared
- [x] Full vuln lifecycle report written (5 documents)
- [ ] WinRAR 7.x upgrade pending
- [ ] Python 3.11.9 + 3.13.1 upgrades pending

### ✅ Phase 3 — Linux Endpoint + Custom Rules
- [x] Kali Linux enrolled as second agent (ID 004)
- [x] auditd configured with MITRE-mapped rules
- [x] rsyslog + auth.log capturing SSH failures
- [x] SSH brute force simulated (Hydra v9.6, rockyou.txt)
- [x] 644 alerts generated — rules 5557, 5760, 2502 confirmed
- [x] Custom rule 100004 (T1110, Level 12) — 7 hits confirmed
- [x] SCA auto-ran on Kali — 392 CIS Linux benchmark hits
- [x] IR-005 written and pushed
- [x] Custom rules 100001–100004 documented in local_rules.xml
- [x] Threat hunting doc — 6 hypotheses, 3 confirmed

### ⬜ Phase 4 — Advanced Detections
- [ ] Wazuh Active Response — auto-block IPs on brute force
- [ ] Metasploit C2 simulation — T1071.001 beacon detection
- [ ] LSASS dump simulation — T1003.001 (Mimikatz on Khonshu)
- [ ] Alert tuning and false positive reduction
- [ ] Sigma rule engineering

### ⬜ Phase 5 — Enterprise Expansion
- [ ] Third agent — Ubuntu server
- [ ] Network IDS integration (Suricata)
- [ ] Log forwarding pipeline (Filebeat)
- [ ] Wazuh API automation scripts

---

## 📚 References

- [Wazuh Documentation](https://documentation.wazuh.com)
- [MITRE ATT&CK for Enterprise](https://attack.mitre.org/matrices/enterprise/)
- [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [NVD — National Vulnerability Database](https://nvd.nist.gov/)
- [Hydra — THC](https://github.com/vanhauser-thc/thc-hydra)

---

## 👤 Author

**Pratik** — Offensive Security Researcher & Bug Bounty Hunter
HackerOne: `on3_r4gn4r` | Bugcrowd: `r4gn4r`

> *"Built this lab to understand how defenders see the attacks I research — the same techniques from both sides of the scope."*

---

*Last updated: 2026-09-24 | Active Development*
