hl.config({
    input = {
        kb_layout = "us, ru",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:win_space_toggle",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 1.0,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
            tap_to_click = true,
            drag_lock = true,
            scroll_factor = 0.2,
            clickfinger_behavior = true,
            middle_button_emulation = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace", scale = 0.4 })
hl.gesture({ fingers = 3, direction = "down", action = "close", mods = "ALT" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen", mods = "SUPER" })
