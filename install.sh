#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
home_placeholder='@DOTFILES_HOME@'
mode=${1:-help}
profile=desktop
assume_yes=false
backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/$(date +%Y%m%d-%H%M%S-%N)"
declare -a sources=() targets=() packages=()

usage() {
  cat <<'HELP'
Usage: ./install.sh plan|config|doctor
       ./install.sh packages [base|desktop|hardware]

  plan      List every destination without writing files.
  config    Preview, confirm, back up and copy individual files.
  packages  Install a selected profile; default: base + desktop.
  doctor    Check desktop commands and optional local applications.

Options: --yes (skip the installer prompt; package managers still confirm).
Existing unrelated files and your .gitconfig are preserved.
HELP
}

if (($#)); then shift; fi
for arg in "$@"; do
  case $arg in
    --yes) assume_yes=true ;;
    base|desktop|hardware) profile=$arg ;;
    *) printf 'Unknown argument: %s\n' "$arg" >&2; exit 1 ;;
  esac
done

add_tree() {
  local source=$1 target=$2 file relative
  [[ -d $source ]] || return 0
  while IFS= read -r -d '' file; do
    relative=${file#"$source"/}
    sources+=("$file")
    targets+=("$target/$relative")
  done < <(find "$source" -type f -print0 | sort -z)
}

build_plan() {
  local file
  sources=(); targets=()
  add_tree "$repo_dir/config" "$HOME/.config"
  for file in "$repo_dir"/home/.[!.]*; do
    [[ -f $file && ${file##*/} != .gitconfig ]] || continue
    sources+=("$file"); targets+=("$HOME/${file##*/}")
  done
  add_tree "$repo_dir/local-share/fonts" "$HOME/.local/share/fonts"
  add_tree "$repo_dir/pictures" "$HOME/Pictures"
}

show_plan() {
  local target action
  for target in "${targets[@]}"; do
    action=add
    [[ ! -e $target && ! -L $target ]] || action=replace
    printf '%-8s %s\n' "$action" "$target"
  done
  printf '\nBackups: %s\n' "$backup_dir"
}

validate_plan() {
  local target parent
  for target in "${targets[@]}"; do
    [[ ! -d $target || -L $target ]] || {
      printf 'A directory occupies a file destination: %s\n' "$target" >&2; return 1;
    }
    parent=${target%/*}
    while [[ $parent != "$HOME" && $parent != / ]]; do
      if [[ -L $parent || ( -e $parent && ! -d $parent ) ]]; then
        printf 'Destination parent must be a real directory: %s\n' "$parent" >&2
        return 1
      fi
      parent=${parent%/*}
    done
  done
}

confirm() {
  local answer
  $assume_yes && return 0
  printf '\n%s [y/N] ' "$1"
  read -r answer || return 1
  [[ $answer == y || $answer == Y ]]
}

require_user() {
  [[ $EUID -ne 0 ]] || { echo 'Run as a regular user.' >&2; exit 1; }
}

rewrite_home_path() {
  local file=$1 escaped_home
  escaped_home=$(printf '%s' "$HOME" | sed 's/[\\&|]/\\&/g')
  if grep -IqF -- "$home_placeholder" "$file"; then
    sed -i "s|$home_placeholder|$escaped_home|g" "$file"
  fi
}

install_config() {
  local i target relative
  for i in "${!sources[@]}"; do
    target=${targets[$i]}
    relative=${target#"$HOME"/}
    if [[ -e $target || -L $target ]]; then
      mkdir -p -- "$backup_dir/$(dirname -- "$relative")"
      mv -- "$target" "$backup_dir/$relative"
    fi
    mkdir -p -- "$(dirname -- "$target")"
    cp -a -- "${sources[$i]}" "$target"
    rewrite_home_path "$target"
  done
  if command -v fc-cache >/dev/null; then
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null
  fi
  printf 'Installed %s files. Backups: %s\n' "${#targets[@]}" "$backup_dir"
}

require_arch() {
  [[ -r /etc/os-release ]] || { echo 'Cannot detect OS.' >&2; exit 1; }
  # shellcheck source=/dev/null
  source /etc/os-release
  [[ ${ID:-} == arch || " ${ID_LIKE:-} " == *' arch '* ]] || {
    echo 'Package installation supports Arch Linux only.' >&2; exit 1;
  }
}

read_packages() {
  mapfile -t packages < <(sed -e 's/[[:space:]]*#.*//' -e '/^[[:space:]]*$/d' "$@" | sort -u)
}

install_packages() {
  require_arch
  local files=("$repo_dir/packages/base.txt")
  case $profile in
    desktop) files+=("$repo_dir/packages/desktop.txt") ;;
    hardware) files=("$repo_dir/packages/hardware.txt") ;;
  esac
  read_packages "${files[@]}"
  printf 'Package profile: %s\n' "$profile"
  printf '  %s\n' "${packages[@]}"
  confirm 'Install these packages?' || return 1
  sudo pacman -Syu --needed -- "${packages[@]}"
}

doctor() {
  local cmd path
  echo 'Required desktop commands:'
  for cmd in Hyprland wezterm fish hyprlock hyprpaper \
    wl-copy wl-paste cliphist playerctl wpctl \
    grim slurp tesseract; do
    command -v "$cmd" >/dev/null || printf '  missing: %s\n' "$cmd"
  done
  echo 'Optional commands:'
  for cmd in zen-browser qs nekobox; do
    command -v "$cmd" >/dev/null || printf '  missing: %s\n' "$cmd"
  done
  echo 'Optional local applications:'
  for path in "$HOME/.config/dynis" "$HOME/Documents/hyprland/dynamicIsland/run-local.sh" \
    "$HOME/.local/bin/standup-daemon" \
    "$HOME/.config/spinning-fish-wallpaper/spinning-fish-wallpaper" \
    "$HOME/.local/share/agunlocker/ag_proxy"; do
    [[ -e $path ]] || printf '  missing: %s\n' "$path"
  done
}

case $mode in
  plan) build_plan; validate_plan; show_plan ;;
  config)
    require_user; build_plan; validate_plan; show_plan
    confirm 'Apply these files?' || exit 1
    install_config
    ;;
  packages) require_user; install_packages ;;
  doctor) doctor ;;
  help|--help|-h) usage ;;
  *) usage; exit 1 ;;
esac
