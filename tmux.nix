{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-b";

    # Mouse ON tapi dengan proper config
    mouse = true;

    terminal = "screen-256color";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;

    extraConfig = ''
      # Fix scroll di Ghostty - CRITICAL!
      set -g mouse on

      # Scroll tanpa masuk copy mode otomatis
      bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; send-keys -M'"
      bind -n WheelDownPane select-pane -t= \; send-keys -M

      # Alternative scroll (uncomment kalau yang atas ga work):
      # unbind -T root WheelUpPane
      # unbind -T root WheelDownPane
      # bind -T root WheelUpPane   if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
      # bind -T root WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"

      # Vi mode
      setw -g mode-keys vi
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"

      # Split panes
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
