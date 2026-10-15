#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_dir"
for cmd in python3 shellcheck gitleaks luac; do
  command -v "$cmd" >/dev/null || { printf 'Required command: %s\n' "$cmd" >&2; exit 1; }
done
python3 scripts/smoke-test.py
for lua_file in config/hypr/*.lua; do
  luac -p "$lua_file"
done
mapfile -d '' -t shell_scripts < <(find config home scripts -type f \
  \( -name '*.sh' -o -name '.bashrc' -o -name '.bash_profile' -o -name ocr-region \) -print0)
shellcheck -x -P SCRIPTDIR install.sh "${shell_scripts[@]}"
scan_dir=$(mktemp -d)
trap 'rm -rf -- "$scan_dir"' EXIT
python3 scripts/check-publication.py "$@" --export "$scan_dir"
gitleaks dir --redact --no-banner "$scan_dir"
if [[ ${1:-} != --worktree ]]; then
  gitleaks git --redact --no-banner --log-opts=HEAD .
fi
git diff --check
