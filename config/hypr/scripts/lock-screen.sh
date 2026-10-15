#!/usr/bin/env bash

set -Eeuo pipefail

LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/hyprlock.launch.lock"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

if pgrep -x hyprlock >/dev/null 2>&1; then
  exit 0
fi

if [[ $# -gt 0 ]]; then
  exec hyprlock --config "$1" --immediate-render
fi

exec hyprlock --immediate-render
