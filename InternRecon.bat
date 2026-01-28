


@echo off
setlocal EnableDelayedExpansion

:: Auto-detect USB drive labeled "Hsociety"
for /f "tokens=1,2*" %%a in ('wmic logicaldisk get name^,VolumeName ^| findstr Hsociety') do (
    set "usbDrive=%%a"
)

:: Check if drive was found
if not defined usbDrive (
    echo [!] USB drive with label Hsociety not found.
    pause
    exit /b
)

:: Create folder structure
set "today=%date:/=-%"
set "outputDir=%usbDrive%\Recon\%today%"
mkdir "%outputDir%" >nul 2>&1

:: Recon files
set "ipfile=%outputDir%\ipconfig.txt"
set "arpfile=%outputDir%\arp.txt"
set "netstatfile=%outputDir%\netstat.txt"
set "userfile=%outputDir%\local_users.txt"
set "groupfile=%outputDir%\local_groups.txt"
set "adminGroup=%outputDir%\local_admin_group.txt"
set "hostscan=%outputDir%\host_discovery.txt"
set "hostnames=%outputDir%\netbios_names.txt"
set "shares=%outputDir%\network_shares.txt"
set "routes=%outputDir%\routes.txt"
set "firewall=%outputDir%\firewall_rules.txt"
set "adminhunt=%outputDir%\admin_candidates.txt"

echo [+] Starting internal recon...
ipconfig /all > "%ipfile%"
arp -a > "%arpfile%"
netstat -ano > "%netstatfile%"
net user > "%userfile%"
net localgroup > "%groupfile%"
net localgroup administrators > "%adminGroup%"
route print > "%routes%"
netsh advfirewall firewall show rule name=all > "%firewall%"

:: Ping sweep to find live hosts
echo [+] Scanning subnet...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    for /f "tokens=1-4 delims=." %%b in ("%%a") do (
        set "subnet=%%b.%%c.%%d"
    )
)

for /l %%i in (1,1,254) do (
    set "ip=!subnet!.%%i"
    ping -n 1 -w 1 !ip! | find "Reply" >nul && echo [*] !ip! is alive >> "%hostscan%"
)

:: Try to resolve NetBIOS names and list shares
echo [+] Resolving NetBIOS names and shares...
for /f %%h in (%hostscan%) do (
    for /f "tokens=3" %%i in ("%%h") do (
        set "targetIP=%%i"
        echo --- %%i --- >> "%hostnames%"
        nbtstat -A %%i >> "%hostnames%"
        echo Shares on %%i >> "%shares%"
        net view \\%%i >> "%shares%" 2>&1
    )
)

:: Admin hunt: try to find hosts likely to be admins
echo [+] Hunting for Admin/IT PCs...
for /f "tokens=*" %%l in (%hostnames%) do (
    echo %%l | findstr /i "admin administrator it server dc boss ceo" >> "%adminhunt%"
)

echo [?] Recon complete. Results saved to:
echo %outputDir%
pause
