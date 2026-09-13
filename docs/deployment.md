# Deployment Guide

Step-by-step reproduction guide for the full lab setup from scratch.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Hypervisor | Oracle VirtualBox (free) |
| RAM | Minimum 8GB host RAM (4GB for OVA, 4GB for Windows) |
| Disk | 60GB free minimum |
| Network | Bridged or Host-Only adapter on VirtualBox |
| OS (host) | Windows 10/11 |

---

## Part 1 — Wazuh Server (OVA)

### 1.1 Download and Import OVA

```bash
# Download from Wazuh official
https://packages.wazuh.com/4.x/vm/wazuh-4.14.7.ova

# Import into VirtualBox:
# File → Import Appliance → select .ova → Import
```

### 1.2 Configure VirtualBox Network

```
VM Settings → Network → Adapter 1
  Attached to: Bridged Adapter
  Name: [your host network adapter]
```

### 1.3 Set Static IP (Prevents DHCP drift between sessions)

```bash
# SSH or console into the OVA
# Default creds: wazuh-user / wazuh

sudo su -

# Edit network config
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << 'EOF'
DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=none
IPADDR=10.249.232.254
PREFIX=24
GATEWAY=10.249.232.1
DNS1=8.8.8.8
DNS2=8.8.4.4
ONBOOT=yes
USERCTL=no
NM_CONTROLLED=yes
EOF

# Apply
ifdown eth0 && ifup eth0

# Verify
ip a s eth0
```

### 1.4 Start All Wazuh Services

```bash
# Always run as root
sudo su -

systemctl start wazuh-manager
systemctl start wazuh-indexer
systemctl start wazuh-dashboard

# Verify all running
systemctl status wazuh-manager | grep Active
systemctl status wazuh-indexer | grep Active
systemctl status wazuh-dashboard | grep Active
```

### 1.5 Access Dashboard

```
URL:      https://10.249.232.254
Username: admin
Password: (set during OVA first boot, or check /etc/wazuh-dashboard/opensearch_dashboards.yml)
```

---

## Part 2 — Windows Agent (Khonshu)

### 2.1 Download Agent Installer

```powershell
# Run as Administrator
winget install Wazuh.WazuhAgent
# OR download MSI directly:
Invoke-WebRequest -Uri "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.7-1.msi" -OutFile "C:\wazuh-agent.msi"
```

### 2.2 Install Agent

```powershell
msiexec.exe /i "C:\wazuh-agent.msi" /q `
  WAZUH_MANAGER="10.249.232.254" `
  WAZUH_AGENT_NAME="Khonshu" `
  WAZUH_REGISTRATION_SERVER="10.249.232.254"
```

> **Note:** Agent installs to `C:\Program Files (x86)\ossec-agent\` (32-bit path) — not the 64-bit Program Files directory.

### 2.3 Enroll Agent

```powershell
& "C:\Program Files (x86)\ossec-agent\agent-auth.exe" -m 10.249.232.254 -A "Khonshu"
# Expected: "Valid key received"
```

### 2.4 Open Firewall Port

```powershell
New-NetFirewallRule -DisplayName "Wazuh Agent TCP" `
  -Direction Outbound -Protocol TCP -RemotePort 1514 -Action Allow

New-NetFirewallRule -DisplayName "Wazuh Agent UDP" `
  -Direction Outbound -Protocol UDP -RemotePort 1514 -Action Allow
```

### 2.5 Apply Hardened Config

```powershell
# Backup original
Copy-Item "C:\Program Files (x86)\ossec-agent\ossec.conf" `
          "C:\Program Files (x86)\ossec-agent\ossec.conf.bak"

# Copy hardened config from this repo
Copy-Item "config\ossec.conf" `
          "C:\Program Files (x86)\ossec-agent\ossec.conf"
```

### 2.6 Start Service

```powershell
Start-Service WazuhSvc
Get-Service WazuhSvc
# Expected: Running
```

### 2.7 Verify in Dashboard

```
☰ Menu → Agents → Khonshu should show Active (green)
```

---

## Part 3 — Sysmon

### 3.1 Download and Install

```powershell
# Download Sysmon from Sysinternals
Invoke-WebRequest `
  -Uri "https://download.sysinternals.com/files/Sysmon.zip" `
  -OutFile "C:\Sysmon.zip" -UseBasicParsing

Expand-Archive -Path "C:\Sysmon.zip" -DestinationPath "C:\Sysmon" -Force

# Download SwiftOnSecurity config
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" `
  -OutFile "C:\sysmon-config.xml"

# Install
& "C:\Sysmon\sysmon64.exe" -accepteula -i C:\sysmon-config.xml

# Verify
Get-Service sysmon64
```

### 3.2 Add Sysmon to ossec.conf

In `C:\Program Files (x86)\ossec-agent\ossec.conf`, ensure this block is present:

```xml
<localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
</localfile>
```

### 3.3 Restart Agent and Verify

```powershell
Restart-Service WazuhSvc

# Trigger test event
Start-Process calc.exe
Start-Sleep -Seconds 3
Stop-Process -Name "CalculatorApp" -ErrorAction SilentlyContinue

# Check locally
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5 |
  Select-Object TimeCreated, Id | Format-Table
```

Then verify in dashboard:
```
Threat Hunting → Events
Filter: data.win.system.channel:Microsoft-Windows-Sysmon/Operational
```

---

## Part 4 — Vulnerability Detection (Server Side)

Add to `/var/ossec/etc/ossec.conf` on the Wazuh server:

```xml
<vulnerability-detector>
  <enabled>yes</enabled>
  <interval>5m</interval>
  <min_full_scan_interval>6h</min_full_scan_interval>
  <run_on_start>yes</run_on_start>

  <provider name="nvd">
    <enabled>yes</enabled>
    <update_interval>1h</update_interval>
  </provider>

  <provider name="msu">
    <enabled>yes</enabled>
    <update_interval>1h</update_interval>
  </provider>

  <target>
    <id>002</id>
    <enabled>yes</enabled>
  </target>
</vulnerability-detector>
```

```bash
systemctl restart wazuh-manager
```

Results appear in:
```
Dashboard → Threat Intelligence → Vulnerability Detection → Khonshu
```

---

## Common Issues & Fixes

| Symptom | Cause | Fix |
|---|---|---|
| Agent "Never Connected" | Firewall blocking :1514 | Add outbound firewall rule |
| `agent-auth.exe` not found | Wrong path assumption | Use `C:\Program Files (x86)\ossec-agent\agent-auth.exe` |
| Dashboard API Offline | Services not started / IP changed | `sudo su -` then `systemctl start wazuh-manager wazuh-indexer wazuh-dashboard` |
| IP changed after reboot | DHCP lease renewal | Set static IP in `ifcfg-eth0` |
| `systemctl` Access Denied on OVA | Running as `wazuh-user` | `sudo su -` first |
| Sysmon not in PATH after winget | winget installs launcher only | Direct download from sysinternals.com |
| CVEs still showing after upgrade | Syscollector cache lag | `Restart-Service WazuhSvc` to force rescan |

---

## Session Startup Checklist

Run this every time you start the lab after a reboot:

```bash
# On OVA (VirtualBox terminal)
sudo su -
systemctl start wazuh-manager wazuh-indexer wazuh-dashboard
ip a s eth0   # confirm IP is still 10.249.232.254
```

```powershell
# On Windows (Admin PowerShell)
Get-Service WazuhSvc          # confirm Running
Get-Service sysmon64          # confirm Running
```

```
# In browser
https://10.249.232.254        # confirm dashboard loads
☰ → Agents → Khonshu Active  # confirm agent connected
```
