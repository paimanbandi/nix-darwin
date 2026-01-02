# tmux.nix
{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    # Prefix key (default Ctrl+b)
    prefix = "C-b";

    # Enable mouse support but make scrolling work properly
    mouse = true;

    # Terminal settings
    terminal = "screen-256color";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;

    # Additional config
    extraConfig = ''
      # Mouse mode fixes untuk scroll
      bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
      bind -n WheelDownPane select-pane -t= \; send-keys -M

      # Visual improvements
      set -g status-style bg=default
      set -g status-left-length 90
      set -g status-right-length 90

      # Pane border colors
      set -g pane-border-style fg=colour240
      set -g pane-active-border-style fg=colour75

      # Copy mode vi keys
      setw -g mode-keys vi
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
    '';

    # Plugins (optional)
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      # resurrect  # Session persistence
      # continuum  # Auto-save sessions
    ];
  };
}
