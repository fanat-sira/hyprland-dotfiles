local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- XWayland is deliberately used here: it is more reliable for this setup.
config.enable_wayland = false
config.freetype_pcf_long_family_names = true

config.font = wezterm.font('Sun Gallant')
config.font_size = 16.5

config.line_height = 1.0
config.cell_width = 1.0

config.custom_block_glyphs = false
config.freetype_load_flags = 'DEFAULT'

config.hide_tab_bar_if_only_one_tab = true
config.bold_brightens_ansi_colors = false

config.colors = {
  -- Base
  background = '#FAFAF9',
  foreground = '#555555',

  -- Dusty rose accent
  cursor_bg = '#B7838E',
  cursor_fg = '#FAFAF9',
  cursor_border = '#B7838E',

  -- Очень слабый rose tint.
  -- Выделение заметно, но не выглядит отдельным цветным блоком.
  selection_bg = '#E8DCDF',
  selection_fg = '#343434',

  scrollbar_thumb = '#AAAAAA',
  split = '#AAAAAA',

  -- Почти полностью grayscale.
  --
  -- Green специально становится dusty rose:
  -- fish сейчас использует green для prompt.
  ansi = {
    '#303030', -- black
    '#606060', -- red
    '#B7838E', -- green -> ACCENT
    '#888888', -- yellow
    '#747474', -- blue
    '#747474', -- magenta
    '#AAAAAA', -- cyan
    '#EEEEEC', -- white
  },

  brights = {
    '#606060', -- bright black
    '#888888', -- bright red
    '#C59AA3', -- bright green -> ACCENT
    '#AAAAAA', -- bright yellow
    '#888888', -- bright blue
    '#747474', -- bright magenta
    '#AAAAAA', -- bright cyan
    '#EEEEEC', -- bright white
  },

  tab_bar = {
    background = '#FAFAF9',

    active_tab = {
      bg_color = '#B7838E',
      fg_color = '#FAFAF9',
    },

    inactive_tab = {
      bg_color = '#EEEEEC',
      fg_color = '#606060',
    },

    inactive_tab_hover = {
      bg_color = '#E8DCDF',
      fg_color = '#555555',
    },

    new_tab = {
      bg_color = '#FAFAF9',
      fg_color = '#747474',
    },

    new_tab_hover = {
      bg_color = '#E8DCDF',
      fg_color = '#555555',
    },
  },
}

return config
