Gh0stTrace - Process Anomaly Scanner for Linux

gh0sttrace.sh is a lightweight, terminal-friendly Bash tool designed to detect stealth processes, deleted-but-running executables, and non-TTY shell anomalies. It is ideal for blue teams, SOC analysts, and defenders looking to identify hidden activity on Linux systems using only native tools.

Features
- Detects deleted executables still running in memory (`(deleted)` ELF binaries).
- Flags shell processes without a TTY (common in reverse shells or automated attacks).
- Identifies suspicious parent-child shell relationships (cron, PID 1, orphaned shells).
- Scans for orphaned processes (PPID = 1).
- Color-coded output for easy triage in terminal environments.
- Requires no installation or dependencies; works on most modern Linux distributions.

Usage

1. Make executable: chmod +x gh0sttrace.sh

2. Run with root (recommended for full /proc visibility): sudo ./gh0sttrace.sh

3. Output will be displayed directly in terminal, highlighting alerts in red.

Example Output

[1] Checking for deleted-but-running ELF executables...
  [!] Deleted exec: PID=47291 | USER=ghost | EXE=/tmp/ghost_exec (deleted)
      CMD: /tmp/ghost_exec

[2] Scanning for suspicious shell processes (bash/sh/zsh)...
  [!] Non-TTY shell: PID=47301 | USER=nobody | PPID=987
      CMD: bash -c sleep 30

[3] Looking for orphaned processes (PPID = 1)...
  [!] Orphaned process: PID=47315 | USER=ghost | CMD=sh


Compatibility

- OS: Linux only
- Shells: bash, zsh, sh, dash
- Dependencies: None (uses standard tools: ps, grep, readlink, /proc)
- Recommended Terminal: Any ANSI-compliant terminal

License & Legal Disclaimer

This tool is provided for lawful use only. It is intended for system administrators, blue teams, and SOC analysts to audit their own Linux infrastructure. Unauthorized access, scanning, or reverse engineering of systems you do not own or have explicit permission to analyze may violate applicable laws.

By using Gh0stTrace, you agree to assume all responsibility and risk for its use. The authors disclaim all liability for misuse or damages arising from this software.