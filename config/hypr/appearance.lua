hl.config({
    general = {
        gaps_in = 40,
        gaps_out = 80,
        border_size = 0,
        col = {
            active_border = "rgba(b88590ff)",
            inactive_border = "rgba(b8859088)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 15,
        rounding_power = 3,
        active_opacity = 0.99,
        inactive_opacity = 0.9,
        shadow = {
            enabled = true,
            range = 20,
            render_power = 2,
            color = "rgba(00000055)",
            offset = { 0, 0 },
            scale = 1.0,
        },
        glow = {
            enabled = false,
        },
        blur = {
            enabled = true,
            size = 10,
            passes = 2,
            new_optimizations = true,
            contrast = 1.0,
            brightness = 1.0,
            noise = 0.015,
            vibrancy = 0.2,
        },
    },
    dwindle = { preserve_split = true },
    master = { new_status = "master" },
    misc = { force_default_wallpaper = -1, disable_hyprland_logo = false },
    -- KawaiiCatPaw is an XCursor theme converted from the supplied Windows set.
    cursor = { enable_hyprcursor = true, sync_gsettings_theme = true },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "myBezier" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 7, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
