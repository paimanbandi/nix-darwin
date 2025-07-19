{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      c   = "clear";
      x   = "exit";
      ll  = "lsd -al --color=always";

      gs  = "git status";
      gcm = "git commit -m";

      drs = "sudo darwin-rebuild switch --flake /etc/nix-darwin";

      nd  = "nvim .";
      ndf = "cd /etc/nix-darwin && nvim flake.nix";
      nhm = "cd /etc/nix-darwin && nvim home.nix";
      nzr = "cd /etc/nix-darwin && nvim zsh.nix";
      ncf = "cd /etc/nix-darwin && nvim nvim/";

      cr="cargo run";
      cw="cargo watch -x run";

    };

    initContent = ''
      export EDITOR=nvim
      export FLUTTER_HOME="/Users/paiman/Programs/flutter"
      export PATH="/run/current-system/sw/bin:$FLUTTER_HOME/bin:$PATH"
      eval "$(starship init zsh)"
    '';
  };
}

