#!/usr/bin/env bash
set -euo pipefail

# =========================
# Config cÆ¡ báº£n
# =========================
BASE_DIR="${HOME}/nexus_nodes"       # ThÆ° má»¥c chá»©a táº¥t cáº£ node
SCREEN_PREFIX="nexus_node"           # Tiá»n tá»‘ tÃªn screen
LOG_NAME="nexus.log"                 # TÃªn file log trong má»—i node HOME

# Liá»‡t kÃª NODE-ID ngay trong script (náº¿u muá»‘n)
NODE_IDS=( )

# Hoáº·c Ä‘á»c tá»« file (má»—i dÃ²ng 1 node-id)
IDS_FILE="./id.txt"

# Tuá»³ chá»n: thÃªm flags riÃªng cho tá»«ng node (náº¿u Nexus CLI há»— trá»£)
declare -A EXTRA_FLAGS
# VÃ­ dá»¥:
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
  command -v screen >/dev/null 2>&1 || { red "Thiáº¿u 'screen'. CÃ i: sudo apt update && sudo apt install -y screen"; exit 1; }
  command -v nexus-network >/dev/null 2>&1 || { red "Thiáº¿u 'nexus-network'. CÃ i: curl https://cli.nexus.xyz/ | sh && source ~/.bashrc"; exit 1; }
}

load_ids() {
  if ((${#NODE_IDS[@]}==0)); then
    if [[ -f "$IDS_FILE" ]]; then
      # Chuáº©n hoÃ¡: bá» CRLF, tÃ¡ch theo dÃ²ng, bá» rá»—ng
      mapfile -t NODE_IDS < <(tr -d '\r' < "$IDS_FILE" | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d')
    fi
  fi
  if ((${#NODE_IDS[@]}==0)); then
    red "ChÆ°a cÃ³ NODE-ID. HÃ£y Ä‘iá»n vÃ o máº£ng NODE_IDS trong script hoáº·c táº¡o file $IDS_FILE (má»—i dÃ²ng 1 id)."
    exit 1
  fi
}

start_one() {
  local node_id="$1"
  local node_home="${BASE_DIR}/${node_id}"
  local session="${SCREEN_PREFIX}_${node_id}"

  # Náº¿u screen Ä‘Ã£ tá»“n táº¡i â†’ bá» qua
  if screen -ls | grep -q "[.]${session}[[:space:]]"; then
    cyan "Bá» qua '${node_id}' vÃ¬ screen '${session}' Ä‘Ã£ cháº¡y."
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
  green "ÄÃ£ start node '${node_id}' trong screen '${session}'. Log: ${node_home}/${LOG_NAME}"
}

start_all() {
  ensure_deps
  load_ids
  mkdir -p "$BASE_DIR"
  for id in "${NODE_IDS[@]}"; do
    start_one "$id"
  done
  cyan "Tá»•ng sá»‘ node Ä‘Ã£ start: ${#NODE_IDS[@]}"
  echo
  echo "ðŸ“œ Liá»‡t kÃª screen: screen -ls"
  echo "ðŸ”Ž Xem log 1 node: tail -f ${BASE_DIR}/<node-id>/${LOG_NAME}"
  echo "ðŸ§· Gáº¯n vÃ o screen: screen -r ${SCREEN_PREFIX}_<node-id>"
  echo "âŒ Dá»«ng 1 node:    screen -S ${SCREEN_PREFIX}_<node-id> -X quit"
}

stop_one() {
  local node_id="$1"
  local session="${SCREEN_PREFIX}_${node_id}"
  screen -S "$session" -X quit || true
  green "ÄÃ£ dá»«ng screen '${session}' (náº¿u Ä‘ang cháº¡y)."
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
  start       Start toÃ n bá»™ node trong NODE_IDS hoáº·c id.txt
  stop        Stop toÃ n bá»™ node
  status      Xem danh sÃ¡ch screen
  start-one   <node-id>  Start Ä‘Æ¡n láº» 1 node
  stop-one    <node-id>  Stop Ä‘Æ¡n láº» 1 node
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
  start-one) id="${2:-}"; [[ -z "$id" ]] && { red "Thiáº¿u <node-id>"; exit 1; }; ensure_deps; start_one "$id" ;;
  stop-one)  id="${2:-}"; [[ -z "$id" ]] && { red "Thiáº¿u <node-id>"; exit 1; }; stop_one "$id" ;;
  *)         usage; exit 1 ;;
esac

