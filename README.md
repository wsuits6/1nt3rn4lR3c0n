# InternRecon
```
██╗    ██╗███████╗██╗   ██╗██╗████████╗███████╗ ██████╗ 
██║    ██║██╔════╝██║   ██║██║╚══██╔══╝██╔════╝██╔════╝ 
██║ █╗ ██║███████╗██║   ██║██║   ██║   ███████╗███████╗ 
██║███╗██║╚════██║██║   ██║██║   ██║   ╚════██║██╔═══██╗
╚███╔███╔╝███████║╚██████╔╝██║   ██║   ███████║╚██████╔╝
 ╚══╝╚══╝ ╚══════╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝ ╚═════╝ 
```

## Overview
InternRecon is a Windows batch tool for automated internal network reconnaissance. It collects system information, discovers live hosts, and enumerates network resources to a USB drive for offline analysis.

## What It Collects

### System Information
- `ipconfig.txt` - Full network adapter configuration
- `arp.txt` - ARP cache (MAC address mappings)
- `netstat.txt` - Active network connections
- `routes.txt` - Routing table
- `firewall_rules.txt` - Windows Firewall configuration

### User/Group Enumeration
- `local_users.txt` - All local user accounts
- `local_groups.txt` - All local security groups
- `local_admins.txt` - Members of Administrators group

### Network Discovery
- `live_hosts.txt` - Active hosts on subnet (ping sweep)
- `netbios.txt` - NetBIOS information per host
- `shares.txt` - Shared folders/resources per host
- `admin_candidates.txt` - Hosts with admin-related names

## Requirements
- Windows system (7/8/10/11, Server 2008+)
- USB drive labeled **Hsociety**
- Administrator privileges recommended
- Network connectivity

## Usage

1. Insert USB drive labeled `Hsociety`
2. Double-click `InternRecon.bat`
3. Wait for scan to complete (may take several minutes)

Results saved to:
```
Hsociety:\Recon\YYYY-MM-DD\
```

## Output Structure
```
Recon/
└── YYYY-MM-DD/
    ├── ipconfig.txt
    ├── arp.txt
    ├── netstat.txt
    ├── local_users.txt
    ├── local_groups.txt
    ├── local_admins.txt
    ├── routes.txt
    ├── firewall_rules.txt
    ├── live_hosts.txt
    ├── netbios.txt
    ├── shares.txt
    └── admin_candidates.txt
```

## Features
- ✓ Automated subnet detection
- ✓ Full /24 network ping sweep
- ✓ NetBIOS enumeration
- ✓ SMB share discovery
- ✓ Heuristic admin host detection
- ✓ Date-organized output
- ✓ No external dependencies

## Operational Notes
- **Scan time**: 5-10 minutes for typical /24 network
- **Stealth**: Uses standard Windows tools (low profile)
- **Firewall**: May be blocked by restrictive policies
- **Permissions**: Some data requires admin rights
- **Detection**: Network scans may trigger IDS/IPS alerts

## Network Scan Details
The tool performs:
1. Local system enumeration (instant)
2. Ping sweep of entire /24 subnet (~2-5 min)
3. NetBIOS queries to discovered hosts
4. SMB share enumeration attempts

## Configuration
Edit these variables in the script if needed:
```batch
set "USB_LABEL=Hsociety"  :: USB drive label
set "BASE_DIR=Recon"      :: Output directory name
```

## Limitations
- Only scans single /24 subnet
- Requires NetBIOS/SMB enabled on targets
- Some info requires local admin rights
- Does not attempt authentication

## Disclaimer
**Use this tool only on networks you own or have explicit authorization to assess.**

This tool is intended for:
- Authorized internal network audits
- Pentesting with written permission
- Red team exercises in controlled environments

Unauthorized network scanning may violate:
- Computer Fraud and Abuse Act (CFAA)
- Company policies
- Local/international laws

The author assumes no responsibility for misuse or unauthorized use.

## Author
**Wsuits6**  
Internal reconnaissance tooling for authorized security assessments.

## Version History
- **v1.1** - Current release
  - Date-based organization
  - Admin candidate heuristics
  - Improved error handling

---

**⚠️ WARNING**: This tool performs active network scanning. Use only in authorized environments.