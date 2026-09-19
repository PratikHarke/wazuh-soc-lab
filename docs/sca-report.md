# Security Configuration Assessment Report
**Agent:** Khonshu (002) — Windows 11  
**Policy:** CIS Microsoft Windows 11 Enterprise Benchmark v3.0.0  
**Scan Date:** 2026-09-13 @ 12:49:12  

---

## Summary

| Metric | Value |
|---|---|
| Total Checks | 482 |
| Passed | 120 |
| Failed | 353 |
| Not Applicable | 9 |
| CIS Score | 25% |

---

## Key Findings

A score of 25% indicates significant hardening gaps on the endpoint.
353 out of 482 CIS benchmarks are currently failing, representing
the default out-of-box Windows 11 configuration with no hardening applied.

### Known Failed Checks (from dashboard):
- 26000 — Enforce password history not set to 24 or more (FAILED)
- 26002 — Minimum password age not set to 1 or more days (FAILED)

### Known Passed Checks:
- 26001 — Maximum password age set to 365 or fewer days (PASSED)

---

## Gap Analysis

| Category | Status |
|---|---|
| Password Policy | Partially configured |
| Account Lockout | Not verified |
| Audit Policy | Enabled (configured separately) |
| Windows Firewall | Not verified |
| User Rights Assignment | Not verified |

---

## Notes
- This is a baseline scan — no hardening has been applied yet
- Score of 25% is expected for a default Windows 11 install
- Full remediation of CIS benchmarks is out of scope for this lab
- This SCA data serves as the baseline posture documentation
- Future work: selectively remediate top 10 failed checks and rescan
