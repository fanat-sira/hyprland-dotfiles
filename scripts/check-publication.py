#!/usr/bin/env python3
"""Check publication file contents without inspecting Git author identities."""
import argparse
import re
import shutil
import subprocess
from pathlib import Path

repo = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--worktree", action="store_true", help="Skip history checks")
parser.add_argument("--export", type=Path, help="Export reviewed files for a directory secret scan")
args = parser.parse_args()


def git(*parts):
    return subprocess.check_output(["git", "-C", str(repo), *parts])


names = sorted(set(git("ls-files", "--cached", "--others", "--exclude-standard", "-z").decode().split("\0")) - {""})
failures = []
for name in names:
    path = repo / name
    if not path.exists():
        continue
    parts = Path(name).parts
    if any(part in (".private", ".ssh", ".gnupg", ".aws", "node_modules") for part in parts) or path.name in (
            ".gitconfig", ".env", "fish_variables", "known_hosts") or path.name.startswith(".env."):
        failures.append("Private path: " + name)
        continue
    if path.is_symlink():
        failures.append("Review symlink before publication: " + name)
        continue
    data = path.read_bytes()
    if b"\0" not in data and re.search(rb"/home" rb"/(?!user(?:/|\b))[A-Za-z0-9_-]+(?:/|(?=[\s\"']))", data):
        failures.append("Personal home path: " + name)
    mailboxes = set(re.findall(rb"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b", data, re.I))
    mailboxes.discard(b"git@github.com")
    if mailboxes:
        failures.append("Email in publication file: " + name)
    if args.export:
        target = args.export / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)

if not args.worktree:
    if git("log", "HEAD", "--format=%h", "--", "home/.gitconfig").strip():
        failures.append("home/.gitconfig is still reachable from HEAD")

if failures:
    print("\n".join(failures))
    raise SystemExit(1)
print("PASS: publication files" + (" and HEAD history" if not args.worktree else " (history skipped)"))
