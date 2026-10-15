#!/usr/bin/env python3
"""Exercise the installer against a temporary account, without package installs."""
import os
import json
import re
from pathlib import Path
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]

with tempfile.TemporaryDirectory(prefix="dotfiles-smoke-") as work:
    root = Path(work)
    account = root / "home with spaces & pipes|"
    account.mkdir()
    stubs = root / "bin"
    stubs.mkdir()
    marker = root / "commands-called"
    for command in ("fc-cache", "sudo", "pacman", "yay", "flatpak"):
        stub = stubs / command
        stub.write_text('#!/bin/sh\nprintf "%s\\n" "$0 $*" >> "$SMOKE_COMMAND_LOG"\n')
        stub.chmod(0o755)
    env = dict(os.environ, HOME=str(account), XDG_STATE_HOME=str(account / ".local/state"),
               PATH=str(stubs) + ":" + os.environ["PATH"], SMOKE_COMMAND_LOG=str(marker))
    identity = "[user]\n name = local-user\n email =\n"
    (account / ".gitconfig").write_text(identity)
    (account / ".bashrc").write_text("original bashrc\n")
    unrelated = account / ".config/systemd/user/unrelated.service"
    unrelated.parent.mkdir(parents=True)
    unrelated.write_text("[Service]\nExecStart=/usr/bin/true\n")

    def run(*args, input_text="", success=True):
        result = subprocess.run(["bash", str(REPO / "install.sh"), *args],
                                env=env, input=input_text, text=True, capture_output=True)
        assert (result.returncode == 0) == success, (args, result.stdout, result.stderr)
        return result

    before = {p.relative_to(account): p.read_bytes() for p in account.rglob("*") if p.is_file()}
    plan = run("plan")
    assert str(unrelated) not in plan.stdout
    assert str(account / ".config/systemd/user/standup.service") in plan.stdout
    run("config", input_text="n\n", success=False)
    run("all", "--yes", success=False)
    run("plan", "--unknown", success=False)
    after = {p.relative_to(account): p.read_bytes() for p in account.rglob("*") if p.is_file()}
    assert before == after, "Preview or declined install wrote files"
    assert not marker.exists(), "Preview ran external installation commands"

    for _ in range(2):
        run("config", "--yes")
        assert unrelated.read_text() == "[Service]\nExecStart=/usr/bin/true\n"
        assert (account / ".gitconfig").read_text() == identity
        lock = account / ".config/hypr/hyprlock.conf"
        assert str(account) + "/Pictures/Wallpapers/the_shipwreck.jpeg" in lock.read_text()
        for p in (account / ".config").rglob("*"):
            if p.is_file() and b"\0" not in p.read_bytes():
                assert b"@DOTFILES_HOME@" not in p.read_bytes(), p
    backups = list((account / ".local/state/dotfiles/backups").iterdir())
    assert len(backups) == 2
    assert any((p / ".bashrc").read_text() == "original bashrc\n" for p in backups)
    assert all("fc-cache" in line for line in marker.read_text().splitlines()), "Package manager invoked"

    # An existing directory at a file destination must fail before any copies.
    bashrc = account / ".bashrc"
    bashrc.unlink()
    bashrc.mkdir()
    run("config", "--yes", success=False)
    assert len(list((account / ".local/state/dotfiles/backups").iterdir())) == 2
    bashrc.rmdir()

    # A symlinked destination parent must not redirect writes elsewhere.
    outside = root / "outside"
    outside.mkdir()
    (account / ".config/systemd/user").rename(account / ".config/systemd/saved-user")
    (account / ".config/systemd/user").symlink_to(outside, target_is_directory=True)
    run("config", "--yes", success=False)
    assert not list(outside.iterdir())

excluded = re.compile((REPO / "packages/excluded-components.regex").read_text().strip())
for package_file in (REPO / "packages").rglob("*.txt"):
    for line in package_file.read_text().splitlines():
        if line and not line.startswith("#"):
            assert not excluded.search(line), (package_file, line)
            assert not line.startswith("org.kde."), (package_file, line)
assert not (REPO / "config/xremap").exists()
assert not (REPO / "config/hypr/hyprland.conf").exists()
assert not (REPO / "config/hypr/gruvbox.conf").exists()

audit = json.loads((REPO / "packages/source-audit.json").read_text())
for package_file in (REPO / "packages").glob("*.txt"):
    selected = {line.split("#")[0].strip() for line in package_file.read_text().splitlines()}
    selected.discard("")
    assert selected == set(audit["packages"][package_file.name]), package_file
assert set(audit["config_files"]) == {
    str(path.relative_to(REPO)) for path in (REPO / "config").rglob("*") if path.is_file()
}

hardware = set((REPO / "packages/hardware.txt").read_text().split())
regular = set((REPO / "packages/base.txt").read_text().split()) | set(
    (REPO / "packages/desktop.txt").read_text().split())
assert not hardware & regular, hardware & regular
assert {"linux", "grub", "amd-ucode", "virtualbox-host-dkms", "vulkan-radeon"} <= hardware
print("PASS: preview, refusal, repeated install, backups, unrelated services, Git identity, path substitution, conflicts, package isolation")
