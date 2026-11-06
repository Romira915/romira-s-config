#!/bin/sh
# Close only the panes/tabs recorded in the run manifest. Workers passed via --keep are left open.
set -eu

RUN_DIR="" KEEP=" "
while [ $# -gt 0 ]; do
  case "$1" in
    --run-dir) RUN_DIR="$2"; shift 2 ;;
    --keep) shift; while [ $# -gt 0 ] && [ "${1#--}" = "$1" ]; do KEEP="$KEEP$1 "; shift; done ;;
    *) echo "usage: cleanup-workers.sh --run-dir DIR [--keep NAME...]" >&2; exit 2 ;;
  esac
done
MANIFEST="$RUN_DIR/manifest.jsonl"
[ -f "$MANIFEST" ] || { echo "manifest not found: $MANIFEST" >&2; exit 1; }

is_kept() {
  case "$KEEP" in *" $1 "*) return 0 ;; esac
  return 1
}

# Tabs that still host a kept worker must stay open.
KEPT_TABS=" "
for w in $KEEP; do
  t=$(jq -r --arg w "$w" 'select(.type=="pane" and .worker==$w) | .tab' "$MANIFEST" | head -n1)
  if [ -n "$t" ]; then KEPT_TABS="$KEPT_TABS$t "; fi
done

jq -r 'select(.type=="pane") | "\(.worker) \(.id)"' "$MANIFEST" | while read -r worker id; do
  if is_kept "$worker"; then echo "kept pane $id ($worker)"; continue; fi
  if herdr pane close "$id" >/dev/null 2>&1; then echo "closed pane $id ($worker)"; else echo "skip pane $id (already closed)"; fi
done

jq -r 'select(.type=="tab") | .id' "$MANIFEST" | while read -r id; do
  case "$KEPT_TABS" in *" $id "*) echo "kept tab $id"; continue ;; esac
  if herdr tab close "$id" >/dev/null 2>&1; then echo "closed tab $id"; else echo "skip tab $id (already closed)"; fi
done
