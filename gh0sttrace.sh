#!/bin/bash

# Define ANSI colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

echo -e "${CYAN}============================================"
echo -e "[+] GHOSTHUNTER: Linux Process Anomaly Scanner"
echo -e "    Started at $(date)"
echo -e "============================================${RESET}"
echo

# SECTION 1: Deleted Executables Still Running
echo -e "${CYAN}[1] Checking for deleted-but-running ELF executables...${RESET}"
deleted_count=0

for pid in $(ls /proc | grep -E '^[0-9]+$'); do
  exe_path="/proc/$pid/exe"
  if [[ -L "$exe_path" ]] && readlink "$exe_path" 2>/dev/null | grep -q '(deleted)'; then
    exe_real=$(readlink "$exe_path")
    user=$(ps -o user= -p $pid)
    cmd=$(ps -p $pid -o cmd=)
    echo -e "  ${RED}[!] Deleted exec:${RESET} PID=${YELLOW}$pid${RESET} | USER=${YELLOW}$user${RESET} | EXE=${YELLOW}$exe_real${RESET}"
    echo -e "      CMD: $cmd"
    ((deleted_count++))
  fi
done

[[ $deleted_count -eq 0 ]] && echo -e "  ${GREEN}[-] No deleted executables found.${RESET}"
echo

# SECTION 2: Suspicious Shells
echo -e "${CYAN}[2] Scanning for suspicious shell processes (bash/sh/zsh)...${RESET}"
shell_count=0

for pid in $(pgrep -f 'bash|sh|zsh|dash'); do
  [[ ! -d "/proc/$pid" ]] && continue

  tty=$(ps -o tty= -p $pid | tr -d ' ')
  ppid=$(ps -o ppid= -p $pid | tr -d ' ')
  user=$(ps -o user= -p $pid)
  cmd=$(ps -o cmd= -p $pid)

  # Flag if shell has no TTY
  if [[ "$tty" == "?" ]]; then
    echo -e "  ${RED}[!] Non-TTY shell:${RESET} PID=${YELLOW}$pid${RESET} | USER=${YELLOW}$user${RESET} | PPID=${YELLOW}$ppid${RESET}"
    echo -e "      CMD: $cmd"
    ((shell_count++))
    continue
  fi

  # Flag if shell parent is PID 1 or suspicious
  pname=$(ps -o comm= -p $ppid 2>/dev/null)
  if [[ "$ppid" == "1" || "$pname" =~ (init|systemd|cron|atd) ]]; then
    echo -e "  ${RED}[!] Suspicious parent shell:${RESET} PID=${YELLOW}$pid${RESET} | PPID=${YELLOW}$ppid${RESET} ($pname) | USER=${YELLOW}$user${RESET}"
    echo -e "      CMD: $cmd"
    ((shell_count++))
    continue
  fi
done

[[ $shell_count -eq 0 ]] && echo -e "  ${GREEN}[-] No suspicious shell processes found.${RESET}"
echo

# SECTION 3: Orphaned Processes (PPID 1)
echo -e "${CYAN}[3] Looking for orphaned processes (PPID = 1)...${RESET}"
orphans=0

for pid in $(ps -e -o pid=); do
  ppid=$(ps -o ppid= -p $pid 2>/dev/null | tr -d ' ')
  [[ "$ppid" == "1" ]] || continue

  comm=$(ps -o comm= -p $pid)
  user=$(ps -o user= -p $pid)
  echo -e "  ${RED}[!] Orphaned process:${RESET} PID=${YELLOW}$pid${RESET} | USER=${YELLOW}$user${RESET} | CMD=${YELLOW}$comm${RESET}"
  ((orphans++))
done

[[ $orphans -eq 0 ]] && echo -e "  ${GREEN}[-] No orphaned processes found.${RESET}"
echo

echo -e "${CYAN}[+] Scan complete at $(date)${RESET}"
echo -e "${CYAN}============================================${RESET}"
