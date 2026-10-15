local env = {
    XCURSOR_THEME = "KawaiiCatPaw",
    XCURSOR_SIZE = "32",
    QT_AUTO_SCREEN_SCALE_FACTOR = "1",
    ELECTRON_OZONE_PLATFORM_HINT = "wayland",
    ELECTRON_ENABLE_NATIVE_WINDOW_OPEN = "1",
    QT_QPA_PLATFORM = "wayland;xcb",
    XDG_SESSION_TYPE = "wayland",
    HYPRSHOT_DIR = "@DOTFILES_HOME@/Pictures/Screenshots",
}

for name, value in pairs(env) do
    hl.env(name, value)
end
