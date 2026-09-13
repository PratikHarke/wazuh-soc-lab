# Incident Report — IR-TEMPLATE
> Copy this file for each new incident. Replace all `[placeholders]`.

---

## 📋 Incident Summary

| Field | Value |
|---|---|
| **Incident ID** | IR-YYYY-MM-DD-XXX |
| **Severity** | [Critical / High / Medium / Low] |
| **Status** | [Open / Contained / Closed] |
| **Detection Time** | YYYY-MM-DD HH:MM:SS UTC |
| **Affected Host** | Khonshu (Windows 11, Agent ID: 002) |
| **MITRE Technique** | [Txxxx.xxx — Name] |
| **Initial Alert** | Wazuh Rule [ID] — [description] |
| **Analyst** | Pratik |

---

## 🕐 Timeline

| Time (UTC) | Event |
|---|---|
| HH:MM:SS | [First indicator observed] |
| HH:MM:SS | [Alert generated in Wazuh] |
| HH:MM:SS | [Investigation began] |
| HH:MM:SS | [Root cause identified] |
| HH:MM:SS | [Containment action taken] |
| HH:MM:SS | [Incident closed] |

---

## 🔍 Detection

### Alert Details
```
Rule ID:          [Wazuh rule ID]
Rule Level:       [0-15]
Rule Description: [text]
Log Source:       [e.g. Sysmon / Security / TaskScheduler]
EventID(s):       [e.g. 4625, Sysmon EID1]
```

### Dashboard Screenshot
> [Add screenshot from Wazuh Threat Hunting]

---

## 🔬 Investigation

### Log Sources Reviewed
- [ ] Windows Security Event Log
- [ ] Sysmon Operational Log
- [ ] Wazuh FIM Alerts
- [ ] PowerShell Script Block Log
- [ ] TaskScheduler Log
- [ ] Wazuh Registry Monitor

### Key Indicators (IOCs)

| Type | Value | Source |
|---|---|---|
| Process | [e.g. schtasks.exe] | Sysmon EID1 |
| File | [path/name] | Sysmon EID11 / FIM |
| Registry | [key path] | Wazuh registry monitor |
| Network | [IP:port] | Sysmon EID3 |
| Command | [cmdline] | Sysmon EID1 / EID4104 |

### MITRE ATT&CK Mapping

| Tactic | Technique | ID | Evidence |
|---|---|---|---|
| [e.g. Persistence] | [e.g. Scheduled Task] | [T1053.005] | [TaskScheduler EID4698] |

---

## 🛑 Containment

```
Actions taken:
1. [Step 1]
2. [Step 2]
```

---

## 🔧 Remediation

```
Root cause:    [description]
Fix applied:   [what was done]
Verified by:   [how you confirmed it's fixed]
```

---

## 📸 Evidence

### Alert in Dashboard
> [Screenshot: Wazuh alert view]

### Raw Log Entry
```json
{
  "timestamp": "",
  "rule": {
    "id": "",
    "level": ,
    "description": ""
  },
  "agent": {
    "id": "002",
    "name": "Khonshu"
  },
  "data": {
    "win": {
      "system": {
        "eventID": ""
      },
      "eventdata": {}
    }
  }
}
```

---

## 💡 Lessons Learned

```
What worked:    [detection that fired correctly]
What was slow:  [any delay in detection]
Gaps found:     [what wasn't detected and why]
Improvement:    [rule/config change to make next time]
```

---

## ✅ Sign-off

| | |
|---|---|
| Analyst | Pratik |
| Date Closed | YYYY-MM-DD |
| Final Status | Closed |
