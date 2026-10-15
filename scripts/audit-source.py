#!/usr/bin/env python3
"""Verify a mounted source installation without querying or running the host system."""
import argparse
from datetime import date
import json
from pathlib import Path, PurePosixPath
import posixpath

REPO = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--root", type=Path, required=True, help="Mounted source root filesystem")
parser.add_argument("--home", type=Path, required=True, help="Mounted source user's home")
parser.add_argument("--write", action="store_true", help="Save the sanitized source inventory")
args = parser.parse_args()
root = args.root.resolve()
home = args.home.resolve()
database = root / "var/lib/pacman/local"
if not database.is_dir() or not (root / "etc/os-release").is_file():
    parser.error("The source root must contain an OS and a local pacman database")

installed = {}
for desc in database.glob("*/desc"):
    fields = {}
    for block in desc.read_text().strip().split("\n\n"):
        lines = block.splitlines()
        if len(lines) > 1:
            fields[lines[0].strip("%")] = lines[1:]
    if "NAME" in fields:
        installed[fields["NAME"][0]] = fields["VERSION"][0]


def source_file(virtual):
    """Resolve absolute symlinks inside the offline root and its separate home mount."""
    home_prefix = "/home/" + home.name
    for _ in range(40):
        parts = PurePosixPath(posixpath.normpath(virtual)).parts[1:]
        for index in range(1, len(parts) + 1):
            prefix = "/" + "/".join(parts[:index])
            if prefix == home_prefix or prefix.startswith(home_prefix + "/"):
                physical = home / prefix.removeprefix(home_prefix).lstrip("/")
            else:
                physical = root / prefix.lstrip("/")
            if physical.is_symlink():
                target = str(physical.readlink())
                if not target.startswith("/"):
                    target = posixpath.join(posixpath.dirname(prefix), target)
                virtual = posixpath.join(target, *parts[index:])
                break
        else:
            return physical
    raise ValueError("Source symlink loop")


failures = []
profiles = {}
for package_file in sorted((REPO / "packages").glob("*.txt")):
    names = [line.split("#")[0].strip() for line in package_file.read_text().splitlines()]
    names = [name for name in names if name]
    profiles[package_file.name] = {}
    for name in names:
        if name not in installed:
            failures.append("Package not installed on source: " + name)
        else:
            profiles[package_file.name][name] = installed[name]

commands = "Hyprland wezterm kitty fish fastfetch btop yazi hyprlock hyprpaper hyprshot grim slurp tesseract wl-copy wl-paste cliphist playerctl wpctl qs nm-applet blueman-applet zen-browser easyeffects nekobox nvim code xdg-open ya".split()
for command in commands:
    if not source_file("/usr/bin/" + command).is_file():
        failures.append("Command absent from source: " + command)

local_paths = [
    ".config/dynis/shell.qml",
    "Documents/hyprland/dynamicIsland/run-local.sh",
    ".config/spinning-fish-wallpaper/spinning-fish-wallpaper",
    ".local/bin/standup-daemon",
    ".local/share/agunlocker/ag_proxy",
    ".local/share/icons/KawaiiCatPaw/index.theme",
    ".bun/bin/bun",
]
for relative in local_paths:
    if not source_file("/home/" + home.name + "/" + relative).is_file():
        failures.append("Local integration absent from source: ~/" + relative)
for unit in ("dynis.service", "tide-island.service"):
    if not source_file("/usr/lib/systemd/user/" + unit).is_file():
        failures.append("Service definition absent from source: " + unit)

for path in (REPO / "config").rglob("*"):
    if path.is_file() and not source_file("/home/" + home.name + "/.config/" + str(path.relative_to(REPO / "config"))).is_file():
        failures.append("Config absent from source: " + str(path.relative_to(REPO)))

if failures:
    print("\n".join(failures))
    raise SystemExit(1)
record = {
    "checked_on": date.today().isoformat(),
    "source": "Mounted Arch Linux root and its separate home filesystem",
    "packages": profiles,
    "config_files": sorted(str(path.relative_to(REPO)) for path in (REPO / "config").rglob("*") if path.is_file()),
    "commands": commands,
    "local_files": ["~/" + relative for relative in local_paths],
    "service_definitions": ["dynis.service", "tide-island.service"],
}
if args.write:
    (REPO / "packages/source-audit.json").write_text(json.dumps(record, indent=2) + "\n")
print("PASS: source package database, executable files, local integrations and shared config paths")
