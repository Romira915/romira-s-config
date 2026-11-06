#!/bin/sh
# Spawn one worker agent in a Herdr pane and record what was created in the run manifest.
# Output: one JSON line {"name","kind","pane_id","tab_id","created_tab","ready"}
# Exit: 0 ready, 3 blocked at startup (inspect the pane), 1 other failure, 2 usage
set -eu

usage() {
  echo "usage: spawn-worker.sh --run-dir DIR --name NAME --kind KIND [--cwd DIR] [--tab TAB_ID] [--direction right|down] [--timeout MS] [-- agent-args...]" >&2
  exit 2
}

RUN_DIR="" NAME="" KIND="" CWD="$PWD" TAB="" DIRECTION="" TIMEOUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --run-dir) RUN_DIR="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --kind) KIND="$2"; shift 2 ;;
    --cwd) CWD="$2"; shift 2 ;;
    --tab) TAB="$2"; shift 2 ;;
    --direction) DIRECTION="$2"; shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    --) shift; break ;;
    *) usage ;;
  esac
done
[ -n "$RUN_DIR" ] && [ -n "$NAME" ] && [ -n "$KIND" ] || usage

if [ "${HERDR_ENV:-}" != 1 ]; then
  echo "not running inside Herdr (HERDR_ENV != 1)" >&2
  exit 1
fi
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

mkdir -p "$RUN_DIR"
MANIFEST="$RUN_DIR/manifest.jsonl"

record() {
  # $1=type $2=id $3=tab_id
  jq -cn --arg type "$1" --arg id "$2" --arg tab "$3" --arg name "$NAME" '{type:$type,id:$id,tab:$tab,worker:$name}' >>"$MANIFEST"
}

CREATED_TAB=false
if [ -z "$TAB" ]; then
  res=$(herdr tab create --workspace "${HERDR_WORKSPACE_ID:?}" --cwd "$CWD" --label workers --no-focus)
  TAB=$(printf '%s' "$res" | jq -r '.result.tab.tab_id')
  PANE=$(printf '%s' "$res" | jq -r '.result.root_pane.pane_id')
  CREATED_TAB=true
  record tab "$TAB" "$TAB"
  record pane "$PANE" "$TAB"
else
  # Split the largest pane in the target tab so columns/rows stay usable.
  ws=${TAB%%:*}
  any=$(herdr pane list --workspace "$ws" | jq -r --arg t "$TAB" '[.result.panes[] | select(.tab_id == $t)][0].pane_id // empty')
  [ -n "$any" ] || { echo "no pane found in tab $TAB" >&2; exit 1; }
  target=$(herdr pane layout --pane "$any" | jq -c '.result.layout.panes | max_by(.rect.width * .rect.height)')
  tpane=$(printf '%s' "$target" | jq -r '.pane_id')
  if [ -z "$DIRECTION" ]; then
    # Terminal cells are roughly twice as tall as wide.
    DIRECTION=$(printf '%s' "$target" | jq -r 'if .rect.width >= .rect.height * 2.5 then "right" else "down" end')
  fi
  res=$(herdr pane split "$tpane" --direction "$DIRECTION" --cwd "$CWD" --no-focus)
  PANE=$(printf '%s' "$res" | jq -r '.result.pane.pane_id')
  record pane "$PANE" "$TAB"
fi

emit() {
  # $1=ready(true|false)
  jq -cn --arg name "$NAME" --arg kind "$KIND" --arg pane "$PANE" --arg tab "$TAB" --argjson created "$CREATED_TAB" --argjson ready "$1" \
    '{name:$name,kind:$kind,pane_id:$pane,tab_id:$tab,created_tab:$created,ready:$ready}'
}

set -- herdr agent start "$NAME" --kind "$KIND" --pane "$PANE" ${TIMEOUT:+--timeout "$TIMEOUT"} ${1+--} "$@"
if err=$("$@" 2>&1 >/dev/null); then
  record agent "$NAME" "$TAB"
  emit true
  exit 0
fi
echo "$err" >&2
emit false
case "$err" in
  # Blocked at a startup dialog (e.g. folder trust); the name stays usable for read/send-keys.
  *agent_not_ready*) record agent "$NAME" "$TAB"; exit 3 ;;
  *) exit 1 ;;
esac
