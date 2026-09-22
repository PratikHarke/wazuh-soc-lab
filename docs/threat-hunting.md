# Threat Hunting Hypotheses — Khonshu (Agent 002)

**Analyst:** Pratik  
**Endpoint:** Windows 11 — Khonshu  
**Tooling:** Wazuh Threat Hunting, Sysmon telemetry, FIM, Windows Event Logs  
**Framework:** MITRE ATT&CK for Enterprise

---

## What is Threat Hunting?

Threat hunting is proactive, human-led search for attacker activity that has not yet triggered an automated alert. Unlike reactive detection (wait for a rule to fire), hunting starts with a hypothesis about attacker behaviour and uses available telemetry to confirm or deny it.

**Hypothesis format used here:**

```
IF [attacker behaviour]
THEN [observable evidence in telemetry]
SEARCH [specific query / data source]
RESULT [confirmed / not found / inconclusive]
```

---

## Hypothesis 1 — Living-off-the-Land Binary (LOLBin) Spawning a Shell

**MITRE:** T1059.001, T1218  
**Rationale:** Attackers commonly abuse legitimate Windows binaries (mshta.exe, wscript.exe, certutil.exe, regsvr32.exe) to spawn PowerShell or cmd.exe, bypassing application allowlisting. These parent-child process chains are rarely seen in normal operations.

**Hypothesis:**
> IF an attacker is using a LOLBin to execute code,  
> THEN we will see mshta.exe / wscript.exe / certutil.exe / regsvr32.exe as a **parent process** of powershell.exe or cmd.exe in Sysmon EID 1 logs.

**Hunt Query (Wazuh Events DQL):**
```
rule.groups:sysmon AND data.win.eventdata.parentImage:(*mshta* OR *wscript* OR *certutil* OR *regsvr32*) AND data.win.eventdata.image:(*powershell* OR *cmd.exe*)
```

**Data Sources:**
- Sysmon EventID 1 (Process Create) — `ParentImage` + `Image` fields
- Wazuh group: `sysmon_event1`

**Indicators of Compromise:**
- `wscript.exe → powershell.exe`
- `mshta.exe → cmd.exe`
- `certutil.exe → any child process` (certutil has no legitimate reason for child processes)

**Baseline:** In normal Khonshu operation, none of these parent-child chains should appear. Any hit = high-confidence attacker activity.

**Result:** ⬜ Not yet hunted — scheduled

---

## Hypothesis 2 — Persistence via Non-Standard Registry Run Key Path

**MITRE:** T1547.001, T1112  
**Rationale:** T1547.001 hunting typically focuses on `HKCU\...\Run` and `HKLM\...\Run`. Sophisticated attackers use lesser-known autorun locations: `RunOnce`, `RunServices`, `Policies\Explorer\Run`, or `HKCU\Environment\UserInitMprLogonScript` — paths that are less frequently monitored and may bypass standard detection.

**Hypothesis:**
> IF an attacker has established persistence via a non-standard registry autorun key,  
> THEN we will see FIM Rule 750 fire on registry paths outside the standard Run key paths we monitor,  
> OR we will see a process writing to one of these alternative paths via Sysmon EID 13.

**Hunt Query (Wazuh Events DQL):**
```
rule.id:750 AND data.win.eventdata.targetObject:(*RunOnce* OR *RunServices* OR *Policies\\Explorer\\Run* OR *UserInitMprLogonScript* OR *BootExecute*)
```

**Alternative Run Key Paths to Check:**
```
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices
HKLM\SOFTWARE\Policies\Microsoft\Windows\System\Scripts
HKCU\Environment\UserInitMprLogonScript
HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\BootExecute
```

**Data Sources:**
- Wazuh FIM Rule 750 (registry monitoring)
- Sysmon EID 13 (RegistryValue Set)

**Baseline Check:**
```powershell
# Run on Khonshu to enumerate all current autorun locations
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
```

**Result:** ⬜ Not yet hunted — scheduled

---

## Hypothesis 3 — Credential Access via LSASS Memory Read

**MITRE:** T1003.001  
**Rationale:** Credential dumping from LSASS (Local Security Authority Subsystem Service) is one of the most common post-exploitation techniques. Tools like Mimikatz, ProcDump, and Task Manager (legitimately) all read LSASS memory. Sysmon EID 10 (ProcessAccess) captures any process opening a handle to lsass.exe with read permissions.

**Hypothesis:**
> IF an attacker has attempted credential dumping,  
> THEN we will see Sysmon EID 10 with `lsass.exe` as the **TargetImage** and a non-standard **SourceImage** (not werfault.exe, not the Windows Error Reporting process).

**Hunt Query (Wazuh Events DQL):**
```
rule.groups:sysmon AND data.win.system.eventID:10 AND data.win.eventdata.targetImage:*lsass* AND NOT data.win.eventdata.sourceImage:(*werfault* OR *MsMpEng* OR *svchost*)
```

**Suspicious GrantedAccess values (hex):**
- `0x1010` — Read + QueryInfo (Mimikatz default)
- `0x1410` — Read + QueryInfo + VM_Read
- `0x1FFFFF` — Full access (most aggressive)

**Data Sources:**
- Sysmon EID 10 (ProcessAccess) — `TargetImage`, `GrantedAccess`, `SourceImage`

**Baseline:** On a clean system, only `WerFault.exe`, `MsMpEng.exe` (Defender), and a small set of Windows system processes should access lsass.exe. Any other process = high-confidence credential access attempt.

**Result:** ⬜ Not yet hunted — scheduled

---

## Hypothesis 4 — Outbound Connection to Non-Standard Port from a Browser or Office Process

**MITRE:** T1071.001, T1048  
**Rationale:** C2 (Command and Control) frameworks often hijack legitimate browser or Office processes to blend outbound traffic into normal user activity. A Word process making a TCP connection to port 4444, 8443 (non-standard HTTPS), or an unusual IP is a strong indicator of macro-based malware or document exploitation.

**Hypothesis:**
> IF an attacker has established C2 via a document exploit or malicious macro,  
> THEN we will see Sysmon EID 3 (NetworkConnect) with `winword.exe`, `excel.exe`, `powerpnt.exe`, `msedge.exe` or `chrome.exe` as the **Image** connecting to a non-standard port (not 80, 443, 8080).

**Hunt Query (Wazuh Events DQL):**
```
rule.groups:sysmon AND data.win.system.eventID:3 AND data.win.eventdata.image:(*winword* OR *excel* OR *powerpnt* OR *outlook*) AND NOT (data.win.eventdata.destinationPort:80 OR data.win.eventdata.destinationPort:443 OR data.win.eventdata.destinationPort:8080)
```

**Suspicious Destination Ports:**
- 4444 — Metasploit default
- 1337, 31337 — Common attacker ports
- High-numbered random ports (>50000) from Office processes

**Data Sources:**
- Sysmon EID 3 (NetworkConnection) — `Image`, `DestinationIp`, `DestinationPort`

**Baseline:** Office processes should only connect to Microsoft CDN IPs on ports 80/443. Any other outbound connection from winword.exe is anomalous.

**Result:** ⬜ Not yet hunted — scheduled

---

## Hypothesis 5 — Binary Executed Directly from Temp or Downloads Folder

**MITRE:** T1204.002, T1059  
**Rationale:** Malware delivered via phishing or drive-by download is almost always executed from `%TEMP%`, `%APPDATA%\Local\Temp`, or `Downloads`. Legitimate software rarely executes from these paths. This hypothesis hunts for any process where `Image` path contains these directories.

**Hypothesis:**
> IF a user or attacker executed a malicious binary from a temporary or download location,  
> THEN we will see Sysmon EID 1 with an `Image` path containing `\Temp\`, `\Downloads\`, or `\AppData\Local\Temp\`.

**Hunt Query (Wazuh Events DQL):**
```
rule.groups:sysmon AND data.win.system.eventID:1 AND data.win.eventdata.image:(*\\Temp\\* OR *\\Downloads\\* OR *\\AppData\\Local\\Temp\\*)
```

**High-Value Executable Extensions to Focus On:**
- `.exe`, `.dll`, `.ps1`, `.bat`, `.vbs`, `.js`, `.hta`
- Any signed binary with a mismatched company name

**Data Sources:**
- Sysmon EID 1 (ProcessCreate) — `Image`, `CommandLine`, `ParentImage`
- Wazuh FIM Rule 550 (realtime monitoring on `%TEMP%` and `Downloads`)

**Enrichment:** Cross-reference `Image` hash against VirusTotal for any unfamiliar executable found in these paths.

**Baseline Check on Khonshu:**
```powershell
# Any executables currently sitting in Temp
Get-ChildItem "$env:TEMP" -Recurse -Include *.exe,*.ps1,*.bat,*.vbs | Select FullName, LastWriteTime
Get-ChildItem "$env:USERPROFILE\Downloads" -Include *.exe,*.ps1 | Select FullName, LastWriteTime
```

**Result:** ⬜ Not yet hunted — scheduled

---

## Hunt Tracking

| # | Hypothesis | Technique | Data Source | Priority | Status |
|---|---|---|---|---|---|
| H1 | LOLBin spawning shell | T1059.001, T1218 | Sysmon EID 1 | 🔴 High | ⬜ Scheduled |
| H2 | Non-standard registry autorun | T1547.001, T1112 | FIM Rule 750 + Sysmon EID 13 | 🟠 Medium | ⬜ Scheduled |
| H3 | LSASS memory read | T1003.001 | Sysmon EID 10 | 🔴 High | ⬜ Scheduled |
| H4 | Office/browser C2 outbound | T1071.001, T1048 | Sysmon EID 3 | 🟠 Medium | ⬜ Scheduled |
| H5 | Binary from Temp/Downloads | T1204.002 | Sysmon EID 1 + FIM 550 | 🔴 High | ⬜ Scheduled |

---

## Notes on Methodology

- Each hypothesis is falsifiable — a null result (no hits) is still a valid outcome and means the environment is clean for that technique
- Hunts should be re-run after every new attack simulation to verify detection coverage
- Results marked ⬜ Scheduled will be updated to ✅ Clean or ⚠️ Finding after each hunt run
- All DQL queries above can be run directly in Wazuh → Threat Hunting → Events tab, filtered to agent.id: 002 (Khonshu)
