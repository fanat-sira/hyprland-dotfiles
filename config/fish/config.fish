if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Add to ~/.config/fish/config.fish
set -gx PATH $HOME/.local/bin $PATH


# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
