local v = require("vars")

local function bind(mod, key, dispatcher, opts)
    hl.bind(mod .. " + " .. key, dispatcher, opts)
end

local function exec(command)
    -- Run commands through the Lua API at keypress time.  This avoids relying
    -- on a pre-built dispatcher for shell commands with paths, quotes, or
    -- expansions (screenshots, Quickshell IPC, etc.).
    return function()
        hl.exec_cmd(command)
    end
end

local function add_common_binds(mod, remote)
    bind(mod, "T", exec(remote and "kitty -o confirm_os_window_close=0 -e sh -c \"fastfetch; exec $SHELL\"" or "wezterm --config enable_wayland=false -e sh -c \"sleep 0.2; fastfetch; exec $SHELL\""))
    bind(mod, "Q", hl.dsp.window.close())
    bind(mod, "E", exec(v.file_manager))
    bind(mod, "F", hl.dsp.window.fullscreen())
    bind(mod, "P", hl.dsp.window.float({ action = "toggle" }))
    bind(mod, "J", hl.dsp.layout("togglesplit"))
    bind(mod, "L", exec("@DOTFILES_HOME@/.config/hypr/scripts/lock-screen.sh"))
    bind(mod, "B", exec("zen-browser"))
    bind(mod .. " + SHIFT", "N", exec("systemctl --user restart dynis"))
    bind(mod, "Y", exec("easyeffects &"))
    if not remote then
        bind(mod, "H", exec("hyprctl dispatch setfloating active && hyprctl dispatch pin active"))
    end

    for _, direction in ipairs({ { "H", "left" }, { "L", "right" }, { "K", "up" }, { "J", "down" } }) do
        bind(mod .. " + SHIFT", direction[1], hl.dsp.window.swap({ direction = direction[2] }))
    end
    for _, direction in ipairs({ "left", "right", "up", "down" }) do
        bind(mod, direction, hl.dsp.focus({ direction = direction }))
    end
    for workspace = 1, 10 do
        local key = workspace % 10
        bind(mod, tostring(key), hl.dsp.focus({ workspace = workspace }))
        bind(mod .. " + SHIFT", tostring(key), hl.dsp.window.move({ workspace = workspace }))
    end
    bind(mod, "S", hl.dsp.workspace.toggle_special("magic"))
    bind(mod .. " + SHIFT", "S", hl.dsp.window.move({ workspace = "special:magic" }))
    bind(mod, "mouse_down", hl.dsp.focus({ workspace = remote and "e+1" or "e-1" }))
    bind(mod, "mouse_up", hl.dsp.focus({ workspace = remote and "e-1" or "e+1" }))
    bind(mod, "mouse:272", hl.dsp.window.drag(), { mouse = true })
    bind(mod, "mouse:273", hl.dsp.window.resize(), { mouse = true })
end

bind(v.main_mod, "Super_L", exec("qs ipc -p @DOTFILES_HOME@/Documents/hyprland/dynamicIsland call tide mainmoddown"))
bind(v.main_mod, "Super_R", exec("qs ipc -p @DOTFILES_HOME@/Documents/hyprland/dynamicIsland call tide mainmoddown"))
bind(v.main_mod, "Super_L", exec("qs ipc -p @DOTFILES_HOME@/Documents/hyprland/dynamicIsland call tide mainmodup"), { release = true })
bind(v.main_mod, "Super_R", exec("qs ipc -p @DOTFILES_HOME@/Documents/hyprland/dynamicIsland call tide mainmodup"), { release = true })
add_common_binds(v.main_mod, false)
hl.bind("SUPER + V", hl.dsp.exec_cmd("qs ipc -p @DOTFILES_HOME@/.config/dynis call dynis clipboard"))
bind(v.main_mod .. " + ALT", "L", exec("@DOTFILES_HOME@/.config/hypr/scripts/lock-screen.sh @DOTFILES_HOME@/.config/hypr/hyprlock-message.conf"))
bind("ALT", "space", exec("qs ipc -p @DOTFILES_HOME@/.config/dynis call dynis launcher"))
-- Right Ctrl alone: select a region and save a screenshot.
hl.bind(
    "CTRL + Control_R",
    hl.dsp.exec_cmd("hyprshot -zm region"),
    { release = true, description = "Region screenshot" }
)
-- Right Alt + Right Ctrl: select a region, OCR Russian and English, copy text.
hl.bind(
    "ALT + CTRL + Control_R",
    hl.dsp.exec_cmd("@DOTFILES_HOME@/.config/hypr/scripts/ocr-region"),
    { release = true, description = "OCR selected region to clipboard" }
)

for _, key in ipairs({
    { "XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" },
    { "XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
    { "XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
    { "XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
}) do
    hl.bind(key[1], exec(key[2]), { locked = true, repeating = true })
end
for _, key in ipairs({
    { "XF86AudioNext", "playerctl next" }, { "XF86AudioPause", "playerctl play-pause" },
    { "XF86AudioPlay", "playerctl play-pause" }, { "XF86AudioPrev", "playerctl previous" },
}) do
    hl.bind(key[1], exec(key[2]), { locked = true })
end
