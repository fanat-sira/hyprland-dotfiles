local commands = {
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XDG_RUNTIME_DIR",
    "nm-applet --indicator",
    "wl-paste --watch cliphist store",
    "@DOTFILES_HOME@/.config/hypr/scripts/lock-screen.sh",
    "hyprpaper",
    "blueman-applet",
    "systemctl --user restart dynis.service",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(commands) do
        hl.exec_cmd(command)
    end
end)
