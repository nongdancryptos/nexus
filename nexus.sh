#!/usr/bin/env bash
set -euo pipefail

# =========================
# Basic config
# =========================
BASE_DIR="${HOME}/nexus_nodes"       # Directory that contains all nodes
SCREEN_PREFIX="nexus_node"           # Screen session name prefix
LOG_NAME="nexus.log"                 # Log file name inside each node HOME

# List NODE-IDs directly in the script (if you want)
NODE_IDS=( )

# Or read from a file (one node-id per line)
IDS_FILE="./id.txt"

# Optional: extra flags per node (if Nexus CLI supports them)
declare -A EXTRA_FLAGS
# Example:
# EXTRA_FLAGS["36063968"]="--port 47001"
# EXTRA_FLAGS["36063969"]="--port 47002"
# EXTRA_FLAGS["36063970"]="--port 47003"

# =========================
# Helpers
# =========================
red()   { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
cyan()  { printf "\033[36m%s\033[0m\n" "$*"; }

ensure_deps() {
  command -v screen >/dev/null 2>&1 || { red "Missing 'screen'. Install: sudo apt update && sudo apt install -y screen"; exit 1; }
  command -v nexus-network >/dev/null 2>&1 || { red "Missing 'nexus-network'. Install: curl https://cli.nexus.xyz/ | sh && source ~/.bashrc"; exit 1; }
}

load_ids() {
  if ((${#NODE_IDS[@]}==0)); then
    if [[ -f "$IDS_FILE" ]]; then
      # Normalize: remove CRLF, trim whitespace, drop empty lines
      mapfile -t NODE_IDS < <(tr -d '\r' < "$IDS_FILE" | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d')
    fi
  fi
  if ((${#NODE_IDS[@]}==0)); then
    red "No NODE-ID found. Fill the NODE_IDS array in this script or create $IDS_FILE (one id per line)."
    exit 1
  fi
}

start_one() {
  local node_id="$1"
  local node_home="${BASE_DIR}/${node_id}"
  local session="${SCREEN_PREFIX}_${node_id}"

  # If the screen session already exists → skip
  if screen -ls | grep -q "[.]${session}[[:space:]]"; then
    cyan "Skipping '${node_id}' because screen '${session}' is already running."
    return 0
  fi

  mkdir -p "$node_home"

  local flags=""
  if [[ -n "${EXTRA_FLAGS[$node_id]:-}" ]]; then
    flags="${EXTRA_FLAGS[$node_id]}"
  fi

  local run_cmd="export HOME='${node_home}';
echo \"[INFO] HOME=\$HOME\";
echo \"[INFO] Starting node-id=${node_id}\";
nexus-network start --node-id '${node_id}' ${flags} 2>&1 | tee -a '${node_home}/${LOG_NAME}'"

  screen -S "$session" -dm bash -lc "$run_cmd"
  green "Started node '${node_id}' in screen '${session}'. Log: ${node_home}/${LOG_NAME}"
}

start_all() {
  ensure_deps
  load_ids
  mkdir -p "$BASE_DIR"
  for id in "${NODE_IDS[@]}"; do
    start_one "$id"
  done
  cyan "Total nodes started: ${#NODE_IDS[@]}"
  echo
  echo "📜 List screens: screen -ls"
  echo "🔎 Tail a node log: tail -f ${BASE_DIR}/<node-id>/${LOG_NAME}"
  echo "🧲 Attach to a screen: screen -r ${SCREEN_PREFIX}_<node-id>"
  echo "❌ Stop one node:      screen -S ${SCREEN_PREFIX}_<node-id> -X quit"
}

stop_one() {
  local node_id="$1"
  local session="${SCREEN_PREFIX}_${node_id}"
  screen -S "$session" -X quit || true
  green "Stopped screen '${session}' (if it was running)."
}

stop_all() {
  load_ids
  for id in "${NODE_IDS[@]}"; do
    stop_one "$id"
  done
}

status() {
  screen -ls || true
}

usage() {
  cat <<EOF
Usage: $0 <command>

Commands:
  start       Start all nodes in NODE_IDS or id.txt
  stop        Stop all nodes
  status      Show screen sessions
  start-one   <node-id>  Start a single node
  stop-one    <node-id>  Stop a single node
EOF
}

# =========================
# Main
# =========================
cmd="${1:-}"
case "$cmd" in
  start)     start_all ;;
  stop)      stop_all ;;
  status)    status ;;
  start-one) id="${2:-}"; [[ -z "$id" ]] && { red "Missing <node-id>"; exit 1; }; ensure_deps; start_one "$id" ;;
  stop-one)  id="${2:-}"; [[ -z "$id" ]] && { red "Missing <node-id>"; exit 1; }; stop_one "$id" ;;
  *)         usage; exit 1 ;;
esac
