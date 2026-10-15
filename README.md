# hyprland dotfiles

A personal Arch Linux desktop with dusty rose accents, quiet terminals and a Vernet lock screen.

Hyprland · Dynis / dynamicIsland · fish · WezTerm / Kitty · Hyprlock · GTK · Yazi

## Install

Run as your regular user on a working Arch installation:

```bash
git clone https://github.com/fanat-sira/hyprland-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh doctor
./install.sh plan
./install.sh config
```

SSH: `git clone git@github.com:fanat-sira/hyprland-dotfiles.git ~/dotfiles`

The installer previews every destination and asks before copying. Matching files are backed up to `~/.local/state/dotfiles/backups/`. Unrelated files and your Git identity are preserved. Use the installer to resolve home-directory markers in the configs.

## Packages

```bash
./install.sh packages base
./install.sh packages desktop    # base + desktop tools
./install.sh packages hardware   # optional: kernel, bootloader, drivers
```

Every package in these profiles was checked against the source installation's own pacman database. Review the hardware list before using it elsewhere. Installed AUR applications are listed in `packages/optional-aur.txt` for manual installation.

## Desktop

Hyprland uses `config/hypr/hyprland.lua` and Lua modules. Hyprlock and Hyprpaper use their native `.conf` formats. Keyboard layouts are US/RU; monitor selection is automatic.

Dynis, dynamicIsland, standup-daemon, spinning-fish-wallpaper and agunlocker are separate local projects. Their files were verified on the source installation; this repository includes integration settings, not application source or binaries. See [dependencies](docs/DEPENDENCIES.md).

## Layout

| Path | Contents |
| --- | --- |
| `config/` | Desktop, terminal, application and user service settings |
| `config/theme/` | Palette and theme generator |
| `home/` | Bash startup files |
| `packages/` | Package profiles and sanitized source audit |
| `local-share/fonts/` | Cormorant Garamond, Sun Gallant and licenses |
| `pictures/` | Wallpaper |
| `scripts/` | Installer, source and publication checks |

## Checks

`./scripts/check.sh` runs the installer smoke test, Lua syntax checks, ShellCheck, Gitleaks and publication content checks. It requires Python 3, Lua (`luac`), ShellCheck and Gitleaks.

[Source audit](packages/source-audit.json) records only selected package versions and generic paths. To repeat the audit against a mounted installation, use `scripts/audit-source.py --root /mnt/source-root --home /mnt/source-home/user`. The audit reads that installation directly and never runs its binaries or queries the host's package manager.

## License

Original contributions: [MIT](LICENSE). Fonts and artwork retain their own terms; see [third-party notices](THIRD_PARTY.md).
