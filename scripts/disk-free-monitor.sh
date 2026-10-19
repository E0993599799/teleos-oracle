#!/usr/bin/env bash
# disk-free-monitor.sh — read-only. Warn when C:/D: free space drops below a threshold.
# Never deletes, compacts, or touches WSL/VHDX. Safe to run from cron.
#
# Env overrides (for fixture testing):
#   MONITOR_THRESHOLD_PCT   alert when free% < this (default 10)
#   MONITOR_MOUNTS          space-separated mount points (default "/mnt/c /mnt/d")
#   MONITOR_OUT_DIR         where log + alert go (default: this repo's ψ dirs)
# Exit: 0 all OK, 2 at least one mount below threshold, 1 error.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THRESHOLD="${MONITOR_THRESHOLD_PCT:-10}"
MOUNTS="${MONITOR_MOUNTS:-/mnt/c /mnt/d}"
LOG_DIR="${MONITOR_OUT_DIR:-$ROOT/ψ/memory/disk-snapshots}"
ALERT="${MONITOR_OUT_DIR:-$ROOT/ψ/outbox}/DISK_LOW_ALERT.md"
LOG="$LOG_DIR/monitor.log"
mkdir -p "$LOG_DIR" "$(dirname "$ALERT")"

now="$(date '+%F %H:%M %z')"
breach=()
lines=()
for m in $MOUNTS; do
  # -P: stable columns; -m: MB. timeout guards against a hung 9p mount.
  row="$(timeout 20 df -Pm "$m" 2>/dev/null | tail -1)" || row=""
  if [ -z "$row" ]; then
    printf "%s\t%s\tERROR_df_failed\n" "$now" "$m" >> "$LOG"
    exit 1
  fi
  read -r _ size used avail _ <<<"$row"
  free_pct=$(( avail * 100 / size ))
  status=OK
  if [ "$free_pct" -lt "$THRESHOLD" ]; then status=LOW; breach+=("$m"); fi
  printf '%s\t%s\tfree=%s%%\tavail=%sMB\tused=%sMB\tsize=%sMB\t%s\n' \
    "$now" "$m" "$free_pct" "$avail" "$used" "$size" "$status" >> "$LOG"
  lines+=("| $m | ${free_pct}% | ${avail} MB | $status |")
done

if [ "${#breach[@]}" -gt 0 ]; then
  {
    echo "# DISK_LOW_ALERT"
    echo
    echo "Checked: $now (threshold: free < ${THRESHOLD}%)"
    echo
    echo "| mount | free | avail | status |"
    echo "|---|---|---|---|"
    printf '%s\n' "${lines[@]}"
    echo
    echo "Below threshold: ${breach[*]}"
    echo "Do NOT run \`wsl --shutdown\` / VHDX compact from inside WSL (see ~/.claude/RTK.md)."
    echo "History: $LOG"
  } > "$ALERT"
  echo "LOW: ${breach[*]} (alert: $ALERT)"
  exit 2
fi

rm -f "$ALERT"
echo "OK: all mounts >= ${THRESHOLD}% free"
exit 0
