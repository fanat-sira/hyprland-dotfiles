#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DIR="$ROOT/theme"
GENERATED_DIR="$THEME_DIR/generated"

# shellcheck source=palette.sh
source "$THEME_DIR/palette.sh"

mkdir -p "$GENERATED_DIR"

lower_hex() {
  printf '%s' "${1#\#}" | tr '[:upper:]' '[:lower:]'
}

lower_css() {
  printf '#%s' "$(lower_hex "$1")"
}

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\/&|]/\\&/g'
}

render_template() {
  local target="$1"
  shift

  local tmp
  tmp="$(mktemp)"
  cat >"$tmp"

  while (($#)); do
    local key="$1"
    local value="$2"
    shift 2
    sed -i "s|__${key}__|$(escape_sed "$value")|g" "$tmp"
  done

  mkdir -p "$(dirname "$target")"
  mv "$tmp" "$target"
}

render_template "$GENERATED_DIR/ui-colors.css" \
  BACKGROUND_BASE_CSS "$(lower_css "$BACKGROUND_BASE")" \
  BACKGROUND_SURFACE_CSS "$(lower_css "$BACKGROUND_SURFACE")" \
  BACKGROUND_ELEVATED_CSS "$(lower_css "$BACKGROUND_ELEVATED")" \
  BACKGROUND_LAYER_CSS "$(lower_css "$BACKGROUND_LAYER")" \
  BACKGROUND_LAYER_ALT_CSS "$(lower_css "$BACKGROUND_LAYER_ALT")" \
  FOREGROUND_PRIMARY_CSS "$(lower_css "$FOREGROUND_PRIMARY")" \
  FOREGROUND_SECONDARY_CSS "$(lower_css "$FOREGROUND_SECONDARY")" \
  FOREGROUND_MUTED_CSS "$(lower_css "$FOREGROUND_MUTED")" \
  FOREGROUND_DISABLED_CSS "$(lower_css "$FOREGROUND_DISABLED")" \
  ACCENT_PRIMARY_CSS "$(lower_css "$ACCENT_PRIMARY")" \
  ACCENT_PRIMARY_DARK_CSS "$(lower_css "$ACCENT_PRIMARY_DARK")" \
  ACCENT_PRIMARY_SOFT_CSS "$(lower_css "$ACCENT_PRIMARY_SOFT")" \
  ACCENT_HIGHLIGHT_CSS "$(lower_css "$ACCENT_HIGHLIGHT")" \
  ACCENT_HIGHLIGHT_SOFT_RGBA "$ACCENT_HIGHLIGHT_SOFT_RGBA" \
  NEUTRAL_LIGHT_CSS "$(lower_css "$NEUTRAL_LIGHT")" \
  NEUTRAL_MEDIUM_CSS "$(lower_css "$NEUTRAL_MEDIUM")" \
  NEUTRAL_DARK_CSS "$(lower_css "$NEUTRAL_DARK")" \
  STATUS_SUCCESS_CSS "$(lower_css "$STATUS_SUCCESS")" \
  STATUS_WARNING_CSS "$(lower_css "$STATUS_WARNING")" \
  STATUS_ERROR_CSS "$(lower_css "$STATUS_ERROR")" <<'EOF'
/* Generated from ~/.config/theme/palette.sh by theme/apply.sh */
@define-color bg0 __BACKGROUND_BASE_CSS__;
@define-color bg1 __BACKGROUND_SURFACE_CSS__;
@define-color bg2 __BACKGROUND_ELEVATED_CSS__;
@define-color bg3 __BACKGROUND_LAYER_CSS__;
@define-color bg4 __BACKGROUND_LAYER_ALT_CSS__;

@define-color text __FOREGROUND_PRIMARY_CSS__;
@define-color text2 __FOREGROUND_SECONDARY_CSS__;
@define-color text3 __FOREGROUND_MUTED_CSS__;
@define-color text_disabled __FOREGROUND_DISABLED_CSS__;

@define-color primary __ACCENT_PRIMARY_CSS__;
@define-color primary_dark __ACCENT_PRIMARY_DARK_CSS__;
@define-color primary_soft __ACCENT_PRIMARY_SOFT_CSS__;
@define-color accent_glow __ACCENT_HIGHLIGHT_CSS__;
@define-color accent_glow_soft __ACCENT_HIGHLIGHT_SOFT_RGBA__;
@define-color neutral_light __NEUTRAL_LIGHT_CSS__;
@define-color neutral_mid __NEUTRAL_MEDIUM_CSS__;
@define-color neutral_dark __NEUTRAL_DARK_CSS__;
@define-color success __STATUS_SUCCESS_CSS__;
@define-color warning __STATUS_WARNING_CSS__;
@define-color error __STATUS_ERROR_CSS__;

@define-color accent __ACCENT_PRIMARY_CSS__;
@define-color accent2 __ACCENT_PRIMARY_SOFT_CSS__;
@define-color txt __FOREGROUND_PRIMARY_CSS__;
@define-color txt2 __FOREGROUND_SECONDARY_CSS__;
@define-color bg __BACKGROUND_SURFACE_CSS__;

@define-color border __ACCENT_PRIMARY_CSS__;
@define-color border_active __ACCENT_PRIMARY_SOFT_CSS__;
@define-color urgent __NEUTRAL_DARK_CSS__;
EOF

render_template "$ROOT/kitty/colors.conf" \
  FOREGROUND_PRIMARY "$FOREGROUND_PRIMARY" \
  FOREGROUND_SECONDARY "$FOREGROUND_SECONDARY" \
  FOREGROUND_MUTED "$FOREGROUND_MUTED" \
  BACKGROUND_BASE "$BACKGROUND_BASE" \
  BACKGROUND_ELEVATED "$BACKGROUND_ELEVATED" \
  BACKGROUND_LAYER "$BACKGROUND_LAYER" \
  BACKGROUND_LAYER_ALT "$BACKGROUND_LAYER_ALT" \
  ACCENT_PRIMARY_DARK "$ACCENT_PRIMARY_DARK" \
  ACCENT_HIGHLIGHT "$ACCENT_HIGHLIGHT" \
  ACCENT_PRIMARY_SOFT "$ACCENT_PRIMARY_SOFT" \
  ACCENT_PRIMARY "$ACCENT_PRIMARY" \
  NEUTRAL_LIGHT "$NEUTRAL_LIGHT" \
  NEUTRAL_MEDIUM "$NEUTRAL_MEDIUM" \
  NEUTRAL_DARK "$NEUTRAL_DARK" \
  STATUS_SUCCESS "$STATUS_SUCCESS" \
  BACKGROUND_SURFACE "$BACKGROUND_SURFACE" \
  ACCENT_HIGHLIGHT_BRIGHT "$ACCENT_HIGHLIGHT_BRIGHT" \
  <<'EOF'
# Generated from ~/.config/theme/palette.sh by theme/apply.sh

foreground __FOREGROUND_PRIMARY__
background __BACKGROUND_BASE__
selection_foreground __FOREGROUND_PRIMARY__
selection_background __BACKGROUND_ELEVATED__

cursor __ACCENT_PRIMARY_SOFT__
cursor_text_color __BACKGROUND_BASE__

url_color __ACCENT_PRIMARY__

active_border_color __ACCENT_PRIMARY_SOFT__
inactive_border_color __ACCENT_PRIMARY__

wayland_titlebar_color __BACKGROUND_SURFACE__
macos_titlebar_color __BACKGROUND_SURFACE__

active_tab_foreground __FOREGROUND_PRIMARY__
active_tab_background __ACCENT_PRIMARY__
inactive_tab_foreground __FOREGROUND_SECONDARY__
inactive_tab_background __BACKGROUND_SURFACE__
tab_bar_background __BACKGROUND_SURFACE__

mark1_foreground __FOREGROUND_PRIMARY__
mark1_background __ACCENT_PRIMARY__
mark2_foreground __FOREGROUND_PRIMARY__
mark2_background __ACCENT_PRIMARY_SOFT__
mark3_foreground __FOREGROUND_PRIMARY__
mark3_background __BACKGROUND_LAYER__

# The 16 terminal colors
color0  __ACCENT_HIGHLIGHT_BRIGHT__
color8  __FOREGROUND_SECONDARY__

color1  __ACCENT_PRIMARY_DARK__
color9  __ACCENT_PRIMARY__

color2  __NEUTRAL_MEDIUM__
color10 __STATUS_SUCCESS__

color3  __ACCENT_PRIMARY_SOFT__
color11 __ACCENT_HIGHLIGHT__

color4  __ACCENT_PRIMARY__
color12 __ACCENT_HIGHLIGHT_BRIGHT__

color5  __ACCENT_HIGHLIGHT__
color13 __ACCENT_PRIMARY_SOFT__

color6  __STATUS_SUCCESS__
color14 __NEUTRAL_LIGHT__

color7  __FOREGROUND_MUTED__
color15 __FOREGROUND_PRIMARY__
EOF

render_template "$ROOT/yazi/theme.toml" \
  BACKGROUND_BASE "$BACKGROUND_BASE" \
  BACKGROUND_SURFACE "$BACKGROUND_SURFACE" \
  BACKGROUND_ELEVATED "$BACKGROUND_ELEVATED" \
  BACKGROUND_LAYER "$BACKGROUND_LAYER" \
  FOREGROUND_PRIMARY "$FOREGROUND_PRIMARY" \
  FOREGROUND_SECONDARY "$FOREGROUND_SECONDARY" \
  FOREGROUND_MUTED "$FOREGROUND_MUTED" \
  FOREGROUND_DISABLED "$FOREGROUND_DISABLED" \
  ACCENT_PRIMARY "$ACCENT_PRIMARY" \
  ACCENT_PRIMARY_SOFT "$ACCENT_PRIMARY_SOFT" \
  ACCENT_HIGHLIGHT "$ACCENT_HIGHLIGHT" \
  STATUS_SUCCESS "$STATUS_SUCCESS" \
  STATUS_WARNING "$STATUS_WARNING" \
  STATUS_ERROR "$STATUS_ERROR" <<'EOF'
"$schema" = "https://yazi-rs.github.io/schemas/theme.json"

[mgr]
cwd = { fg = "__ACCENT_PRIMARY_SOFT__", bold = true }
find_keyword = { fg = "__ACCENT_HIGHLIGHT__", bold = true, italic = true, underline = true }
find_position = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_HIGHLIGHT__", bold = true, italic = true }
symlink_target = { fg = "__FOREGROUND_MUTED__", italic = true }
marker_copied = { fg = "__ACCENT_PRIMARY__", bg = "__ACCENT_PRIMARY__" }
marker_cut = { fg = "__STATUS_ERROR__", bg = "__STATUS_ERROR__" }
marker_marked = { fg = "__ACCENT_HIGHLIGHT__", bg = "__ACCENT_HIGHLIGHT__" }
marker_selected = { fg = "__ACCENT_PRIMARY_SOFT__", bg = "__ACCENT_PRIMARY_SOFT__" }
count_copied = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_PRIMARY__" }
count_cut = { fg = "__FOREGROUND_PRIMARY__", bg = "__STATUS_ERROR__" }
count_selected = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_HIGHLIGHT__" }
border_symbol = "│"
border_style = { fg = "__ACCENT_PRIMARY__" }

[tabs]
active = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_HIGHLIGHT__", bold = true }
inactive = { fg = "__FOREGROUND_SECONDARY__", bg = "__BACKGROUND_SURFACE__" }

[mode]
normal_main = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_PRIMARY__", bold = true }
normal_alt = { fg = "__FOREGROUND_PRIMARY__", bg = "__BACKGROUND_ELEVATED__" }
select_main = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_HIGHLIGHT__", bold = true }
select_alt = { fg = "__FOREGROUND_PRIMARY__", bg = "__BACKGROUND_LAYER__" }
unset_main = { fg = "__FOREGROUND_PRIMARY__", bg = "__STATUS_ERROR__", bold = true }
unset_alt = { fg = "__FOREGROUND_PRIMARY__", bg = "__BACKGROUND_LAYER__" }

[indicator]
parent = { fg = "__FOREGROUND_MUTED__", bg = "__BACKGROUND_SURFACE__" }
current = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_PRIMARY_SOFT__", bold = true }
preview = { fg = "__ACCENT_HIGHLIGHT__", underline = true }

[status]
overall = { fg = "__FOREGROUND_PRIMARY__", bg = "__BACKGROUND_SURFACE__" }
perm_sep = { fg = "__FOREGROUND_DISABLED__" }
perm_type = { fg = "__STATUS_SUCCESS__" }
perm_read = { fg = "__ACCENT_PRIMARY_SOFT__" }
perm_write = { fg = "__STATUS_WARNING__" }
perm_exec = { fg = "__ACCENT_PRIMARY__" }
progress_label = { fg = "__FOREGROUND_SECONDARY__", bold = true }
progress_normal = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_PRIMARY__" }
progress_error = { fg = "__FOREGROUND_PRIMARY__", bg = "__STATUS_ERROR__" }

[which]
mask = { bg = "__BACKGROUND_BASE__" }
cand = { fg = "__ACCENT_PRIMARY_SOFT__" }
rest = { fg = "__FOREGROUND_MUTED__" }
desc = { fg = "__ACCENT_HIGHLIGHT__" }
separator_style = { fg = "__BACKGROUND_LAYER__" }

[confirm]
border = { fg = "__ACCENT_PRIMARY__" }
title = { fg = "__ACCENT_HIGHLIGHT__" }
btn_yes = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_PRIMARY__", bold = true }
btn_no = { fg = "__FOREGROUND_PRIMARY__", bg = "__BACKGROUND_LAYER__" }

[spot]
border = { fg = "__ACCENT_PRIMARY__" }
title = { fg = "__ACCENT_HIGHLIGHT__" }
tbl_col = { fg = "__ACCENT_PRIMARY_SOFT__" }
tbl_cell = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_HIGHLIGHT__" }

[notify]
title_info = { fg = "__ACCENT_PRIMARY_SOFT__" }
title_warn = { fg = "__STATUS_WARNING__" }
title_error = { fg = "__STATUS_ERROR__" }

[pick]
border = { fg = "__ACCENT_PRIMARY__" }
active = { fg = "__ACCENT_HIGHLIGHT__", bold = true }

[input]
border = { fg = "__ACCENT_PRIMARY__" }
selected = { fg = "__FOREGROUND_PRIMARY__", bg = "__BACKGROUND_LAYER__" }

[cmp]
border = { fg = "__ACCENT_PRIMARY__" }
active = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_PRIMARY_SOFT__" }

[tasks]
border = { fg = "__ACCENT_PRIMARY__" }
hovered = { fg = "__ACCENT_HIGHLIGHT__", bold = true }

[help]
on = { fg = "__ACCENT_PRIMARY_SOFT__" }
run = { fg = "__ACCENT_HIGHLIGHT__" }
hovered = { fg = "__BACKGROUND_BASE__", bg = "__ACCENT_HIGHLIGHT__", bold = true }
footer = { fg = "__FOREGROUND_PRIMARY__", bg = "__BACKGROUND_SURFACE__" }
EOF

render_template "$ROOT/btop/themes/miku_light.theme" \
  BACKGROUND_BASE "$BACKGROUND_BASE" \
  FOREGROUND_PRIMARY "$FOREGROUND_PRIMARY" \
  ACCENT_PRIMARY_SOFT "$ACCENT_PRIMARY_SOFT" \
  ACCENT_HIGHLIGHT "$ACCENT_HIGHLIGHT" \
  BACKGROUND_ELEVATED "$BACKGROUND_ELEVATED" \
  FOREGROUND_MUTED "$FOREGROUND_MUTED" \
  FOREGROUND_SECONDARY "$FOREGROUND_SECONDARY" \
  ACCENT_PRIMARY "$ACCENT_PRIMARY" \
  BACKGROUND_LAYER "$BACKGROUND_LAYER" \
  STATUS_SUCCESS "$STATUS_SUCCESS" \
  STATUS_WARNING "$STATUS_WARNING" \
  STATUS_ERROR "$STATUS_ERROR" \
  NEUTRAL_LIGHT "$NEUTRAL_LIGHT" \
  NEUTRAL_MEDIUM "$NEUTRAL_MEDIUM" \
  NEUTRAL_DARK "$NEUTRAL_DARK" <<'EOF'
theme[main_bg]="__BACKGROUND_BASE__"
theme[main_fg]="__FOREGROUND_PRIMARY__"
theme[title]="__ACCENT_PRIMARY_SOFT__"
theme[hi_fg]="__ACCENT_HIGHLIGHT__"
theme[selected_bg]="__BACKGROUND_ELEVATED__"
theme[selected_fg]="__FOREGROUND_PRIMARY__"
theme[inactive_fg]="__FOREGROUND_MUTED__"
theme[graph_text]="__FOREGROUND_SECONDARY__"
theme[meter_bg]="__BACKGROUND_LAYER__"
theme[proc_misc]="__FOREGROUND_SECONDARY__"
theme[cpu_box]="__ACCENT_PRIMARY__"
theme[mem_box]="__ACCENT_PRIMARY__"
theme[net_box]="__ACCENT_PRIMARY__"
theme[proc_box]="__ACCENT_HIGHLIGHT__"
theme[div_line]="__BACKGROUND_LAYER__"
theme[temp_start]="__STATUS_SUCCESS__"
theme[temp_mid]="__STATUS_WARNING__"
theme[temp_end]="__STATUS_ERROR__"
theme[cpu_start]="__ACCENT_PRIMARY_SOFT__"
theme[cpu_mid]="__ACCENT_PRIMARY__"
theme[cpu_end]="__ACCENT_HIGHLIGHT__"
theme[free_start]="__NEUTRAL_LIGHT__"
theme[free_mid]="__STATUS_SUCCESS__"
theme[free_end]="__ACCENT_HIGHLIGHT__"
theme[cached_start]="__FOREGROUND_MUTED__"
theme[cached_mid]="__FOREGROUND_SECONDARY__"
theme[cached_end]="__FOREGROUND_PRIMARY__"
theme[available_start]="__STATUS_SUCCESS__"
theme[available_mid]="__ACCENT_PRIMARY_SOFT__"
theme[available_end]="__ACCENT_HIGHLIGHT__"
theme[used_start]="__STATUS_WARNING__"
theme[used_mid]="__STATUS_ERROR__"
theme[used_end]="__STATUS_ERROR__"
theme[download_start]="__ACCENT_PRIMARY_SOFT__"
theme[download_mid]="__ACCENT_PRIMARY__"
theme[download_end]="__ACCENT_HIGHLIGHT__"
theme[upload_start]="__NEUTRAL_MEDIUM__"
theme[upload_mid]="__STATUS_SUCCESS__"
theme[upload_end]="__ACCENT_HIGHLIGHT__"
theme[process_start]="__FOREGROUND_SECONDARY__"
theme[process_mid]="__ACCENT_PRIMARY_SOFT__"
theme[process_end]="__ACCENT_HIGHLIGHT__"
EOF

printf 'Applied palette %s\n' "$THEME_NAME"
