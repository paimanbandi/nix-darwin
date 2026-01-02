# tmux.nix
{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-b";
    mouse = true; # ON tapi dengan config khusus

    terminal = "screen-256color";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;

    extraConfig = ''
      # Mouse ON
      set -g mouse on

      # Fix scroll untuk aplikasi dalam tmux (less/bat/vim)
      # Bypass tmux copy mode, langsung ke aplikasi
      set -ga terminal-overrides ',xterm*:smcup@:rmcup@'

      # Vi mode
      setw -g mode-keys vi

      # Split
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # Colors  
      set -g status-style bg=default
      set -g pane-border-style fg=colour240
      set -g pane-active-border-style fg=colour75
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
    ];
  };
}
