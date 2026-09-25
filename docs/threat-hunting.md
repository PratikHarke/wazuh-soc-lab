# Threat Hunting Hypotheses — Wazuh SOC Lab

## Overview
Proactive threat hunting conducted against telemetry collected from two endpoints:
- **Khonshu** (Windows, agent ID 002) — primary Windows attack simulation host
- **kali** (Kali Linux, agent ID 004) — Linux endpoint, SSH brute force simulation host

Hunting performed via Wazuh Threat Hunting dashboard using DQL queries and MITRE ATT&CK mapping.

---

## Hypothesis 1 — LOLBin Abuse (Living Off the Land)
**Assumption:** An attacker on Khonshu is using legitimate Windows binaries to execute payloads and evade AV.
**Hunt Query:** `agent.name: Khonshu AND data.win.eventdata.image: (*certutil* OR *mshta* OR *rundll32*)`
**MITRE:** T1218 — System Binary Proxy Execution
**Status:** No hits detected — baseline established.

---

## Hypothesis 2 — Registry Autorun Persistence
**Assumption:** Malware established persistence via registry Run keys on Khonshu.
**Hunt Query:** `agent.name: Khonshu AND rule.id: 100003`
**MITRE:** T1547.001 — Boot or Logon Autostart: Registry Run Keys
**Status:** Confirmed — rule 100003 fired (IR-004).

---

## Hypothesis 3 — LSASS Memory Access
**Assumption:** Attacker dumping credentials from LSASS on Khonshu.
**Hunt Query:** `agent.name: Khonshu AND data.win.eventdata.targetImage: *lsass*`
**MITRE:** T1003.001 — OS Credential Dumping: LSASS Memory
**Status:** Planned — Phase 4.

---

## Hypothesis 4 — C2 Outbound Beacon
**Assumption:** Compromised host beaconing to C2 at regular intervals.
**Hunt Query:** `agent.name: (Khonshu OR kali) AND data.win.eventdata.destinationPort: (4444 OR 8080 OR 1337)`
**MITRE:** T1071.001 — Application Layer Protocol: Web Protocols
**Status:** Planned — Phase 4.

---

## Hypothesis 5 — Execution from Temp Directories
**Assumption:** Malware in %TEMP% or writable dirs executing on Khonshu.
**Hunt Query:** `agent.name: Khonshu AND data.win.eventdata.image: (*\\Temp\\* OR *\\AppData\\*)`
**MITRE:** T1059 — Command and Scripting Interpreter
**Status:** Confirmed — rule 100002 fired (IR-002).

---

## Hypothesis 6 — SSH Brute Force (Linux Endpoint)
**Assumption:** Attacker conducting credential brute force against SSH on Kali.
**Hunt Query:** `agent.name: kali AND rule.id: 100004`
**MITRE:** T1110 — Brute Force
**Status:** Confirmed — Hydra v9.6 detected, rule 100004 fired 7 Level-12 alerts (IR-005).

---

## Summary Table

| # | Hypothesis | Technique | Agent | Status |
|---|---|---|---|---|
| 1 | LOLBin abuse | T1218 | Khonshu | No hits (baseline) |
| 2 | Registry autorun | T1547.001 | Khonshu | Confirmed (IR-004) |
| 3 | LSASS dump | T1003.001 | Khonshu | Planned Phase 4 |
| 4 | C2 beacon | T1071.001 | Both | Planned Phase 4 |
| 5 | Exec from Temp | T1059 | Khonshu | Confirmed (IR-002) |
| 6 | SSH brute force | T1110 | kali | Confirmed (IR-005) |
