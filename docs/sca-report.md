# Security Configuration Assessment Report
**Policy:** CIS Microsoft Windows 11 Enterprise  
**Host:** Khonshu | **Agent ID:** 002  
**Scan Frequency:** Every 12 hours  
**Status:** 🔄 In Progress — fill with real dashboard data

---

## Summary

| Metric | Value |
|---|---|
| Policy | CIS Windows 11 Enterprise |
| Total Checks | [fill from dashboard] |
| Passed | [fill] |
| Failed | [fill] |
| Not Applicable | [fill] |
| Pass Rate | [fill]% |
| Scan Date | 2026-09-05 |

---

## How to Export Results

```
Dashboard → Endpoint Security → Configuration Assessment
→ Select: Khonshu
→ View all checks
→ Note: passed/failed counts, top failed checks
```

---

## Top Failed Checks (Fill From Dashboard)

> Navigate to Configuration Assessment → Khonshu → Filter: Failed
> Document the top 10 failures here

| # | Check ID | Description | Severity | Rationale |
|---|---|---|---|---|
| 1 | [CIS ID] | [Description] | [High/Med/Low] | [Why it matters] |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |
| 7 | | | | |
| 8 | | | | |
| 9 | | | | |
| 10 | | | | |

---

## Common CIS Win11 Failures (Reference)

These are typical findings on a default Windows 11 installation:

| CIS Control | Check | Default State | Risk |
|---|---|---|---|
| 2.3.1.1 | Accounts: Administrator account status | Enabled | Medium |
| 2.3.1.6 | Accounts: Rename administrator account | Default name | Low |
| 2.3.7.1 | Interactive logon: Do not display last username | Not configured | Low |
| 2.3.7.2 | Interactive logon: Do not require CTRL+ALT+DEL | Not configured | Medium |
| 2.3.11.x | Network security: LAN Manager auth level | Not configured | High |
| 17.x | Audit Policy | Incomplete | High |
| 18.x | Administrative Templates | Default values | Medium |
| 19.x | Windows Firewall | Partially configured | Medium |

---

## Hardening Actions (Fill After Review)

For each top failure, document the fix:

### Example Format:

#### CIS Check [ID]: [Name]
```
Current State:  [what's configured now]
Required State: [what CIS requires]
Risk:           [impact if not fixed]
Fix:
  - Via GPO:    [path → setting → value]
  - Via PS:     [PowerShell command to remediate]
  - Via Reg:    [Registry path + value]
Verification:   [how to confirm fix applied]
Status:         [Pending / Applied / Verified]
```

---

## Hardening Script (To Be Generated)

After reviewing top failures, a PowerShell remediation script will be added here:

```powershell
# CIS Windows 11 Enterprise — Remediation Script
# Generated from: Wazuh SCA results on Khonshu
# Date: [fill]
# Run as: Administrator

# [Remediation commands will be added here after SCA review]
```

---

## Before/After Comparison

| Metric | Before Hardening | After Hardening |
|---|---|---|
| Pass Rate | [fill]% | [fill after remediation]% |
| Critical Failures | [fill] | [fill] |
| High Failures | [fill] | [fill] |
| Medium Failures | [fill] | [fill] |

---

## Notes

- SCA results update every 12 hours (as configured in ossec.conf)
- Force rescan: `Restart-Service WazuhSvc` on the Windows endpoint
- Some CIS checks are informational only and may not require remediation in a lab context
- Prioritize High severity failures first for maximum security improvement
