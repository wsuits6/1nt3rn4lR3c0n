@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ===============================

:: ██╗    ██╗███████╗██╗   ██╗██╗████████╗███████╗ ██████╗ 
:: ██║    ██║██╔════╝██║   ██║██║╚══██╔══╝██╔════╝██╔════╝ 
:: ██║ █╗ ██║███████╗██║   ██║██║   ██║   ███████╗███████╗ 
:: ██║███╗██║╚════██║██║   ██║██║   ██║   ╚════██║██╔═══██╗
:: ╚███╔███╔╝███████║╚██████╔╝██║   ██║   ███████║╚██████╔╝
::  ╚══╝╚══╝ ╚══════╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝ ╚═════╝ 
                                                           
::                                                          
:: ===============================
:: InternRecon v1.1
:: Wsuits6 Internal Recon Tool
:: ===============================

:: ---- CONFIG ----
set "USB_LABEL=Hsociety"
set "BASE_DIR=Recon"

:: ---- Detect USB drive by label ----
for /f "skip=1 tokens=1,2" %%A in ('wmic logicaldisk get Name^,VolumeName') do (
    if /I "%%B"=="%USB_LABEL%" set "USB_DRIVE=%%A"
)

if not defined USB_DRIVE (
    echo [!] USB drive with label "%USB_LABEL%" not found.
    echo [!] Insert the drive and try again.
    pause
    exit /b 1
)

:: ---- Date (locale-safe) ----
for /f %%i in ('wmic os get localdatetime ^| find "."') do set dt=%%i
set "TODAY=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%"

set "OUTPUT_DIR=%USB_DRIVE%\%BASE_DIR%\%TODAY%"
mkdir "%OUTPUT_DIR%" >nul 2>&1

:: ---- Output files ----
set "IPCFG=%OUTPUT_DIR%\ipconfig.txt"
set "ARP=%OUTPUT_DIR%\arp.txt"
set "NETSTAT=%OUTPUT_DIR%\netstat.txt"
set "USERS=%OUTPUT_DIR%\local_users.txt"
set "GROUPS=%OUTPUT_DIR%\local_groups.txt"
set "ADMINS=%OUTPUT_DIR%\local_admins.txt"
set "ROUTES=%OUTPUT_DIR%\routes.txt"
set "FW=%OUTPUT_DIR%\firewall_rules.txt"
set "HOSTS=%OUTPUT_DIR%\live_hosts.txt"
set "NBT=%OUTPUT_DIR%\netbios.txt"
set "SHARES=%OUTPUT_DIR%\shares.txt"
set "ADMIN_HUNT=%OUTPUT_DIR%\admin_candidates.txt"

echo [+] Starting InternRecon...
echo [+] Output directory: %OUTPUT_DIR%

:: ---- Basic system recon ----
ipconfig /all > "%IPCFG%"
arp -a > "%ARP%"
netstat -ano > "%NETSTAT%"
net user > "%USERS%"
net localgroup > "%GROUPS%"
net localgroup administrators > "%ADMINS%"
route print > "%ROUTES%"
netsh advfirewall firewall show rule name=all > "%FW%"

:: ---- Determine primary IPv4 ----
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do (
    for /f "tokens=1-4 delims=." %%B in ("%%A") do (
        set "SUBNET=%%B.%%C.%%D"
        goto :SUBNET_FOUND
    )
)

:SUBNET_FOUND
if not defined SUBNET (
    echo [!] Could not determine subnet.
    goto :END
)

echo [+] Scanning subnet %SUBNET%.0/24

:: ---- Ping sweep ----
for /L %%I in (1,1,254) do (
    ping -n 1 -w 300 %SUBNET%.%%I >nul && (
        echo %SUBNET%.%%I >> "%HOSTS%"
    )
)

:: ---- NetBIOS + Shares ----
for /f %%H in (%HOSTS%) do (
    echo ===== %%H ===== >> "%NBT%"
    nbtstat -A %%H >> "%NBT%" 2>&1

    echo ===== %%H ===== >> "%SHARES%"
    net view \\%%H >> "%SHARES%" 2>&1
)

:: ---- Admin hunt (heuristic) ----
findstr /i "admin administrator it server dc ceo boss" "%NBT%" > "%ADMIN_HUNT%"

:END
echo [+] Recon complete.
echo [+] Results saved to: %OUTPUT_DIR%
pause