# Dependencies

The package profiles and executable paths were verified against the mounted source installation, independently of the running desktop. Versions are recorded in [source-audit.json](../packages/source-audit.json).

| Feature | Installed tools |
| --- | --- |
| Session | Hyprland with the Lua `hl` API; XDG desktop portals |
| Shell and terminals | fish, WezTerm, Kitty, Fastfetch, Yazi, btop, Neovim |
| Desktop shell and launcher | Quickshell (`qs`), Dynis / dynamicIsland |
| Clipboard | `wl-copy`, `wl-paste`, `cliphist` |
| Lock screen and wallpaper | `hyprlock`, `hyprpaper` |
| Screenshots and OCR | `hyprshot`, `grim`, `slurp`, `tesseract`; English and Russian data |
| Media and audio | `playerctl`, `wpctl`, PipeWire, WirePlumber, EasyEffects |
| Network and Bluetooth | `nm-applet`, NetworkManager, Blueman, BlueZ |
| Appearance | Adwaita icons, Noto, Nerd Font symbols, Cormorant Garamond, Sun Gallant |
| AUR applications | `zen-browser`, `nekobox`, `code`; manual installation |

## Local integrations

These files exist on the source system and are not bundled:

| Integration | Path |
| --- | --- |
| Dynis | `~/.config/dynis/shell.qml`; `dynis.service` |
| dynamicIsland | `~/Documents/hyprland/dynamicIsland/run-local.sh`, `build-release/`; `tide-island.service` |
| Standup reminder | `~/.local/bin/standup-daemon` |
| Fish wallpaper | `~/.config/spinning-fish-wallpaper/spinning-fish-wallpaper` |
| agunlocker | `~/.local/share/agunlocker/ag_proxy` |
| Custom cursor | `~/.local/share/icons/KawaiiCatPaw` |
| Bun PATH entry in fish | `~/.bun/bin/bun` |

The installer copies service settings without enabling or starting services. The Hyprland startup hook restarts Dynis. The custom cursor is selected in `config/hypr/environment.lua`; install it separately or choose an installed cursor theme.
