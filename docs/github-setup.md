# GitHub Setup Instructions

## Create the Repo

1. Go to https://github.com/new
2. Name: `wazuh-soc-lab`
3. Description: `End-to-end SOC simulation lab — Wazuh SIEM, FIM, SCA, vulnerability management, and MITRE ATT&CK attack simulation`
4. Visibility: **Public** (portfolio visibility)
5. Add README: **No** (we have our own)
6. .gitignore: **None** (we have our own)
7. License: **MIT**
8. Click **Create repository**

---

## Push From Your Machine

```powershell
# On your Windows machine, open PowerShell
# Navigate to where you saved the repo folder

cd C:\wazuh-soc-lab  # or wherever you extracted the files

# Initialize git
git init
git add .
git commit -m "feat: initial lab documentation and config

- Wazuh 4.14.7 OVA + Windows 11 agent deployment
- Hardened ossec.conf with FIM realtime on 8 critical paths
- MITRE-mapped registry monitoring (10 keys, T1547/T1546/T1053)
- Vulnerability management: 131 CVEs discovered, 128 remediated
- Sysmon 15.21 with SwiftOnSecurity config
- Attack simulation scripts for T1110, T1059.001, T1053.005, T1547.001
- Incident report template
- Full deployment guide and vuln management report"

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/wazuh-soc-lab.git
git branch -M main
git push -u origin main
```

---

## Commit Strategy Going Forward

Make a commit after each meaningful lab action:

```powershell
# After running a simulation and documenting results
git add incidents/IR-2026-09-05-001.md
git commit -m "ir: add brute force incident report (T1110)

- 10 failed auth attempts triggered Rule 18152
- Sysmon EID1 captured net.exe process chain
- Security EventID 4625 x10 in 5-second window
- MITRE: T1110 detection validated"

# After completing MITRE matrix
git add README.md
git commit -m "docs: update MITRE coverage matrix

- T1110 brute force: simulated and detected
- T1059.001 PowerShell: simulated and detected
- T1053.005 scheduled task: simulated and detected
- T1547.001 startup persistence: simulated and detected"

# After completing SCA review
git add docs/sca-report.md
git commit -m "docs: add CIS Win11 SCA results

- Pass rate: X%
- Top 10 failures documented
- Remediation script added"
```

---

## Pinning the Repo

After pushing:
1. Go to your GitHub profile
2. Click **Customize your pins**
3. Pin `wazuh-soc-lab`
4. Add topics to the repo: `wazuh`, `soc`, `siem`, `blue-team`, `mitre-attack`, `sysmon`, `vulnerability-management`, `windows`, `security`

---

## Repository Description (Copy-Paste)

```
End-to-end SOC simulation lab — Wazuh SIEM with real-time FIM, 
CIS SCA, vulnerability management (131 CVEs → 0), Sysmon telemetry, 
and MITRE ATT&CK-mapped attack simulation on Windows 11.
```

## Topics to Add on GitHub

```
wazuh  siem  soc  blue-team  threat-detection  mitre-attack  
sysmon  vulnerability-management  fim  windows-security  
incident-response  security-lab  offensive-security  cis-benchmarks
```
