# 🛡️ Wazuh SOC & Vulnerability Management Lab

![Wazuh](https://img.shields.io/badge/Wazuh-4.14.7-blue?style=flat-square)
![Windows](https://img.shields.io/badge/Windows_11-Agent_002-0078D6?style=flat-square)
![Kali](https://img.shields.io/badge/Kali_Linux-Agent_005-557C94?style=flat-square)
![Sysmon](https://img.shields.io/badge/Sysmon-15.21-important?style=flat-square)
![MITRE](https://img.shields.io/badge/MITRE_ATT%26CK-Mapped-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)
![CVEs](https://img.shields.io/badge/CVEs_Remediated-131-critical?style=flat-square)
![IRs](https://img.shields.io/badge/Incident_Reports-8-orange?style=flat-square)
![MITRE Detections](https://img.shields.io/badge/MITRE_Detections-8-red?style=flat-square)
![Custom Rules](https://img.shields.io/badge/Custom_Rules-5-blueviolet?style=flat-square)
![Active Response](https://img.shields.io/badge/Active_Response-Enabled-brightgreen?style=flat-square)

> End-to-end SOC simulation lab built on Wazuh — covering real-time endpoint monitoring, FIM, vulnerability management, CIS benchmarking, Sysmon telemetry, MITRE ATT&CK-mapped attack simulations across Windows 11 and Kali Linux endpoints, custom detection rules, threat hunting, automated active response, and structured incident response documentation.

---

## 📌 Objective

Build a simulated Security Operations environment capable of:

- Real-time endpoint monitoring and alerting across Windows and Linux (4,600+ events captured)
- File Integrity Monitoring with MITRE-mapped registry coverage
- Security Configuration Assessment against CIS benchmarks (Windows 11 + Linux)
- Vulnerability discovery, prioritization, and remediation (131 CVEs → 100% remediated)
- Attack simulation across 8 MITRE techniques with live detection validation
- Custom Wazuh detection rules mapped to MITRE ATT&CK (5 rules, 100001–100005)
- Automated Active Response — `firewall-drop` auto-blocking attacker IPs on rule trigger
- Proactive threat hunting with documented hypotheses (6 total, 4 confirmed)
- Incident investigation and structured response documentation (8 IRs)

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
│  │   Wazuh Agent v4.14.7    │   │    │  │   Wazuh Agent v4.14.7    │   │
│  │   Agent ID: 002          │   │    │  │   Agent ID: 005          │   │
│  └────────────┬─────────────┘   │    │  └────────────┬─────────────┘   │
└───────────────┼─────────────────┘    └───────────────┼─────────────────┘
                │ TCP :1514 AES                         │ TCP :1514 AES
                └───────────────────┬───────────────────┘
                        ┌───────────▼─────────────┐
                        │    Wazuh Server OVA      │
                        │    v4.14.7 — VirtualBox  │
                        │    IP: dynamic (DHCP)*   │
                        │                           │
                        │  wazuh-manager  :55000    │
                        │  wazuh-indexer  :9200     │
                        │  wazuh-dashboard :443     │
                        └───────────────────────────┘
```

> *Server IP is assigned dynamically per session by the home router (subnet varies). Static config is set via `/etc/systemd/network/20-eth0.network` and updated each session. See Session Startup Checklist below.

---

## ⚙️ Lab Components

| Component | Detail |
|---|---|
| **Wazuh Server** | OVA v4.14.7 on Oracle VirtualBox |
| **Server IP** | Dynamic (DHCP — updated each session via systemd-networkd) |
| **Windows Endpoint** | Windows 11 Home — Hostname: `Khonshu` (Agent 002) |
| **Linux Endpoint** | Kali Linux — Hostname: `kali` (Agent 005) |
| **Communication** | TCP :1514, AES encrypted |
| **Sysmon** | v15.21 — SwiftOnSecurity config (schema 4.50) |
| **auditd** | v4.1.2 — custom rules for privilege escalation, passwd, sshd config |
| **SCA Policies** | CIS Windows 11 Enterprise + CIS Distribution Independent Linux |
| **Custom Rules** | 5 rules (100001–100005), all MITRE-mapped |

---

## 🚀 Deployment — Real Challenges Documented

| # | Issue | Root Cause | Fix |
|---|---|---|---|
| 1 | Agent "Never Connected" | Windows Firewall blocking TCP :1514 | Added outbound firewall rule |
| 2 | `agent-auth.exe` not found | Agent installed to x86 path not x64 | Used `C:\Program Files (x86)\ossec-agent\agent-auth.exe` |
| 3 | Incomplete MSI (5.9MB) | Broken download in TEMP | Re-downloaded via winget |
| 4 | IP changes each session | Home router assigns different subnet per session | Update systemd-networkd config + agent ossec.conf each session |
| 5 | `systemctl` Access Denied | Running as `wazuh-user` not root | `sudo su -` before any service commands |
| 6 | Sysmon binary not in PATH | winget installed launcher only | Direct download from sysinternals.com |
| 7 | EventID 4625 not generated | Windows audit policy disabled by default | `auditpol /set /subcategory:"Logon" /failure:enable` |
| 8 | Dashboard API auth error | wazuh-manager not fully started | `systemctl restart wazuh-manager` + 60s wait |
| 9 | Disk 100% full on reboot | `queue/vd` (11G) + `queue/vd_updater` (7.9G) filled `/dev/sda1` | Cleared queues; set `feed-update-interval` 60m → 24h; daily cleanup cron |
| 10 | Kali agent stuck Pending | GPG key import failed without sudo; `sqv` incompatibility | Used `--dearmor` method; wiped stale client.keys; re-enrolled |
| 11 | ossec.conf corrupted | `sed` inserted literal `\n` breaking XML structure | Rewrote config from scratch using Python |
| 12 | Kali no IPv4 (network unreachable) | Adapter set to plain NAT instead of Bridged | Changed to Bridged Adapter (MediaTek Wi-Fi 6 MT7921) |
| 13 | auth.log missing on Kali | Kali uses journald only — no rsyslog by default | Installed rsyslog; created `/etc/rsyslog.d/50-auth.conf` |
| 14 | Sysmon EID 3 not shipping to Wazuh | Agent bookmark advances past EID 3 during service restarts on private subnet | Avoid WazuhSvc restarts during active monitoring; documented in IR-008 |

### Session Startup Checklist

```powershell
# Step 1 — Find current subnet on Windows host
(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127*"}).IPAddress
# Note the subnet (e.g. 10.71.19.x) — server will be .133, Kali will be .161
```

```bash
# Step 2 — Update server static IP in systemd-networkd
sudo nano /etc/systemd/network/20-eth0.network
# Change Address= and Gateway= to current subnet
sudo systemctl restart systemd-networkd

# Step 3 — Start Wazuh services
sudo systemctl start wazuh-indexer wazuh-manager wazuh-dashboard
sudo systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard
sudo /var/ossec/bin/agent_control -l
```

```powershell
# Step 4 — Update Khonshu agent manager IP
(Get-Content "C:\Program Files (x86)\ossec-agent\ossec.conf") `
  -replace '<address>.*</address>', '<address>CURRENT_SERVER_IP</address>' | `
  Set-Content "C:\Program Files (x86)\ossec-agent\ossec.conf"
Stop-Service WazuhSvc -Force; Start-Service WazuhSvc
```

```bash
# Step 5 — Update Kali agent manager IP and static IP
sudo nmcli con mod "Wired connection 1" ipv4.addresses "SUBNET.161/24" ipv4.gateway "SUBNET.1"
sudo nmcli con up "Wired connection 1"
sudo sed -i 's|<address>.*</address>|<address>CURRENT_SERVER_IP</address>|' /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-agent
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
Total:   131                    Total:     0
━━━━━━━━━━━━━━━━━━━━━━━         ━━━━━━━━━━━━━━━━━━━
                    Remediation Rate: 100% (131/131)
```

### Package Remediation

| Package | Before | After | CVEs Fixed |
|---|---|---|---|
| Django | old | **5.2.17** | 28 (incl. CVSS 9.1 SQLi) ✅ |
| VLC | 3.0.10 | **3.0.23** | CVE-2023-47359 CVSS 9.8 RCE ✅ |
| WinRAR 5.40 beta | — | **7.x** | 11 CVEs incl. CVE-2023-38831 ✅ |
| Python 3.11.9 | — | **patched** | 15 CVEs ✅ |
| Python 3.13.1 | — | **patched** | 13 CVEs ✅ |
| pip | — | **patched** | 10 CVEs ✅ |

### Critical CVEs Patched

| CVE | CVSS | Package | Type | Status |
|---|---|---|---|---|
| CVE-2023-47359 | **9.8** | VLC 3.0.10 | Heap overflow RCE | ✅ Fixed |
| CVE-2025-64459 | **9.1** | Django | SQL injection | ✅ Fixed |
| CVE-2026-4277 | Critical | Django | Auth bypass (PoC public) | ✅ Fixed |
| CVE-2023-38831 | **7.8** | WinRAR 5.40 | Arbitrary code execution | ✅ Fixed |

---

## 📡 Module 4 — Sysmon Integration

| Item | Detail |
|---|---|
| Version | 15.21 |
| Config | SwiftOnSecurity (schema 4.50) |
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
| 6 | SSH Brute Force (Linux) | T1110 | kali | ✅ | ✅ | 100004 | 12 | ✅ **CONFIRMED** |
| 7 | LSASS Credential Dump | T1003.001 | Khonshu | ✅ | 🛡️ | — | — | 🛡️ **BLOCKED** |
| 8 | C2 Beacon (Meterpreter) | T1071.001 | Both | ✅ | ✅ | 92213, 92052, 92031 | **15** | ✅ **CONFIRMED** |

**Confirmed: 7/8 techniques detected | 1/8 attempted — blocked by OS defenses**

> **Note on T1003.001:** Five LSASS dump methods attempted (comsvcs MiniDump, Task Manager, procdump64, createdump, SYSTEM-level schtasks). All blocked by PPL, Microsoft Defender, and WDAC. Sysmon EID 10 was not generated — OS terminated OpenProcess() before Sysmon could hook it. See [IR-007](incidents/IR-2026-09-26-007.md).

> **Note on T1071.001:** Built-in rule 92213 (Level 15) fired on payload drop before C2 connection established. Full kill chain detected including payload staging, abnormal process execution, and post-exploitation discovery. Custom rule 100005 validated via wazuh-logtest. Sysmon EID 3 shipping gap documented — see [IR-008](incidents/IR-2026-09-27-008.md).

### Simulation Tools Used

| Tool | Target | Technique | Agent |
|---|---|---|---|
| `net use \\localhost\IPC$` | Windows logon | T1110 | Khonshu |
| PowerShell `-EncodedCommand` | Script block logging | T1059.001 | Khonshu |
| `schtasks /create /ru SYSTEM` | Task scheduler | T1053.005 | Khonshu |
| Startup folder + Run key | Boot persistence | T1547.001 | Khonshu |
| Hydra v9.6 + rockyou.txt | SSH service | T1110 | kali |
| comsvcs MiniDump, procdump64, createdump | LSASS memory | T1003.001 | Khonshu |
| msfvenom + Metasploit multi/handler | Reverse TCP C2 | T1071.001 | Khonshu ← kali |

---

## 🔧 Module 6 — Custom Detection Rules

File: [`config/local_rules.xml`](config/local_rules.xml)

| Rule ID | Technique | Description | Level | Agent |
|---|---|---|---|---|
| 100001 | T1053.005 | Scheduled Task created via schtasks.exe | 12 | Khonshu |
| 100002 | T1059.001 | Suspicious PowerShell script block execution | 12 | Khonshu |
| 100003 | T1547.001 | Registry Run Key persistence detected | 12 | Khonshu |
| 100004 | T1110 | SSH Brute Force on Linux endpoint | 12 | kali |
| 100005 | T1071.001 | Suspected C2 outbound connection on port 4444 | 14 | Khonshu |

All rules confirmed via Wazuh Threat Hunting dashboard or wazuh-logtest.

---

## 🔍 Module 7 — Threat Hunting

File: [`docs/threat-hunting.md`](docs/threat-hunting.md)

| # | Hypothesis | Technique | Agent | Status |
|---|---|---|---|---|
| 1 | LOLBin abuse | T1218 | Khonshu | No hits — baseline established |
| 2 | Registry autorun persistence | T1547.001 | Khonshu | ✅ Confirmed (IR-004) |
| 3 | LSASS credential dump | T1003.001 | Khonshu | 🛡️ Attempted — all methods blocked by OS defenses (IR-007) |
| 4 | C2 outbound beacon | T1071.001 | Both | ✅ Confirmed (IR-008) |
| 5 | Execution from Temp dirs | T1059 | Khonshu | ✅ Confirmed (IR-002) |
| 6 | SSH brute force | T1110 | kali | ✅ Confirmed (IR-005) |

---

## 🤖 Module 8 — Active Response

Wazuh Active Response automatically executes countermeasures when specific rules fire — no manual intervention required.

| Parameter | Value |
|---|---|
| Command | `firewall-drop` |
| Trigger Rule | 100004 (T1110 SSH Brute Force) |
| Location | Local (executes on the agent) |
| Timeout | 300 seconds (auto-unblock) |
| Script | `/var/ossec/active-response/bin/firewall-drop` |

### Confirmed Detection-to-Containment Chain

```
Hydra SSH brute force (attacker IP)
  → /var/log/auth.log — PAM failures logged
    → Wazuh agent (005/kali) — logcollector ships to manager
      → Rule 5760 (Level 5)  — sshd: authentication failed
      → Rule 5557 (Level 5)  — unix_chkpwd: password check failed
      → Rule 2502 (Level 10) — user missed password repeatedly
        → Rule 100004 (Level 12) — T1110 SSH Brute Force [CUSTOM]
          → Active Response: firewall-drop TRIGGERED
            → iptables DROP — attacker blocked ✅
```

**Time from first failure to auto-block: ~1 second**

> See [`incidents/IR-2026-09-25-006.md`](incidents/IR-2026-09-25-006.md) for full evidence and timeline.

---

## 📋 Incident Reports

| ID | Date | Technique | MITRE ID | Agent | Rules Fired | Status |
|---|---|---|---|---|---|---|
| [IR-001](incidents/IR-2026-09-12-001.md) | 2026-09-12 | Brute Force | T1110 | Khonshu | 60122, 60204 | ✅ Closed |
| [IR-002](incidents/IR-2026-09-13-002.md) | 2026-09-13 | PowerShell Execution | T1059.001 | Khonshu | EID4104, Sysmon EID1 | ✅ Closed |
| [IR-003](incidents/IR-2026-09-19-003.md) | 2026-09-19 | Scheduled Task | T1053.005 | Khonshu | Sysmon EID1, FIM 750, EID4698 | ✅ Closed |
| [IR-004](incidents/IR-2026-09-19-004.md) | 2026-09-19 | Startup Persistence | T1547.001 | Khonshu | FIM 550, FIM 750, Sysmon EID11/13 | ✅ Closed |
| [IR-005](incidents/IR-2026-09-24-005.md) | 2026-09-24 | SSH Brute Force | T1110 | kali | 5760, 5557, 2502, 100004 | ✅ Closed |
| [IR-006](incidents/IR-2026-09-25-006.md) | 2026-09-25 | Active Response Auto-Block | T1110 | kali | 100004 → firewall-drop | ✅ Closed |
| [IR-007](incidents/IR-2026-09-26-007.md) | 2026-09-26 | LSASS Dump — Blocked | T1003.001 | Khonshu | All methods blocked by PPL/Defender/WDAC | ✅ Closed |
| [IR-008](incidents/IR-2026-09-27-008.md) | 2026-09-27 | Meterpreter C2 Beacon | T1071.001 | Khonshu/kali | 92213 (L15), 92052, 92031, FIM 550 | ✅ Closed |

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
│   ├── local_rules.xml                ← Custom MITRE rules 100001–100005
│   └── sysmon-config.xml              ← SwiftOnSecurity ruleset (schema 4.50)
│
├── docs/
│   ├── deployment.md                  ← Full reproduction guide + troubleshooting
│   ├── vuln-management.md             ← CVE remediation summary (131 → 0)
│   ├── sca-report.md                  ← CIS benchmark results
│   ├── threat-hunting.md              ← 6 threat hunting hypotheses (4 confirmed)
│   └── github-setup.md                ← Git workflow and commit strategy
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
    ├── IR-2026-09-24-005.md           ← T1110 SSH Brute Force (Linux) ✅
    ├── IR-2026-09-25-006.md           ← Active Response auto-block confirmed ✅
    ├── IR-2026-09-26-007.md           ← T1003.001 LSASS — all methods blocked ✅
    └── IR-2026-09-27-008.md           ← T1071.001 Meterpreter C2 — Level 15 detected ✅
```

---

## 📊 Lab Metrics

| Metric | Value |
|---|---|
| Total alerts captured (24h) | **4,654+** |
| High-level alerts (Level 12+) | **32+** |
| Max alert level reached | **Level 15** (C2 payload staging — rule 92213) |
| MITRE techniques simulated | **8** |
| MITRE techniques confirmed | **7 detected + 1 blocked by OS defenses** |
| Custom detection rules | **5** (100001–100005) |
| Incident reports written | **8** |
| Active Response rules | **1** (firewall-drop on rule 100004) |
| Auto-block time (detection to block) | **~1 second** |
| CVEs discovered | **131** |
| CVEs remediated | **131 (100%)** |
| FIM realtime paths | **8** |
| Registry keys monitored | **20+** |
| Sysmon event types active | **10** |
| Threat hunting hypotheses | **6 (4 confirmed, 1 blocked)** |
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
- [x] Django 5.2.17 — 28 CVEs cleared
- [x] VLC 3.0.23 — CVE-2023-47359 CVSS 9.8 cleared
- [x] WinRAR 7.x — 11 CVEs cleared
- [x] Python 3.11.9 + 3.13.1 + pip — 38 CVEs cleared
- [x] 131/131 CVEs remediated (100%)

### ✅ Phase 3 — Linux Endpoint + Custom Rules
- [x] Kali Linux enrolled as second agent (ID 005)
- [x] auditd configured with MITRE-mapped rules
- [x] rsyslog + auth.log capturing SSH failures
- [x] SSH brute force simulated (Hydra v9.6, rockyou.txt)
- [x] 644 alerts generated — rules 5557, 5760, 2502 confirmed
- [x] Custom rule 100004 (T1110, Level 12) — confirmed
- [x] SCA auto-ran on Kali — 392 CIS Linux benchmark hits
- [x] Custom rules 100001–100004 documented in local_rules.xml
- [x] Threat hunting doc — 6 hypotheses, 3 confirmed
- [x] IR-003, IR-004, IR-005 written and pushed

### ✅ Phase 4 — Active Response + Advanced Simulations
- [x] Wazuh Active Response — `firewall-drop` auto-block on rule 100004 confirmed
- [x] IR-006 — Active Response auto-block documented
- [x] T1003.001 LSASS dump — 5 methods attempted, all blocked by PPL/Defender/WDAC
- [x] IR-007 — LSASS attempt and OS defense coverage documented

### ✅ Phase 5 — C2 Simulation + Detection Engineering
- [x] Metasploit Meterpreter payload generated (windows/x64/meterpreter/reverse_tcp)
- [x] Payload delivered via HTTP and executed on Khonshu — reverse shell established
- [x] Full kill chain detected: payload staging (L15), abnormal execution, discovery activity
- [x] Post-exploitation: discovery commands (net user, ipconfig) detected via EID 1
- [x] Custom rule 100005 (T1071.001, Level 14) written and validated via wazuh-logtest
- [x] Sysmon EID 3 shipping gap identified and documented as detection finding
- [x] IR-008 — Meterpreter C2 full kill chain documented

### ⬜ Phase 6 — Detection Maturity
- [ ] Sigma rules for 100001–100005 (portable detection logic)
- [ ] Alert tuning and false positive reduction
- [ ] Host-Only VirtualBox adapter — permanent IP fix (192.168.56.x)
- [ ] Third agent — Ubuntu server
- [ ] Network IDS integration (Suricata)

---

## 📚 References

- [Wazuh Documentation](https://documentation.wazuh.com)
- [MITRE ATT&CK for Enterprise](https://attack.mitre.org/matrices/enterprise/)
- [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [NVD — National Vulnerability Database](https://nvd.nist.gov/)
- [Hydra — THC](https://github.com/vanhauser-thc/thc-hydra)
- [Metasploit Framework](https://github.com/rapid7/metasploit-framework)

---

## 👤 Author

**Pratik** — Offensive Security Researcher & Bug Bounty Hunter
HackerOne: `on3_r4gn4r` | Bugcrowd: `r4gn4r`

> *"Built this lab to understand how defenders see the attacks I research — the same techniques from both sides of the scope."*

---

*Last updated: 2026-09-27 | Active Development*
