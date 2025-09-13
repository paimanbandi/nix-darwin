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
      gb  = "git branch";
      ga  = "git add";
      gaa = "git add .";
      gco = "git checkout";
      gcob = "git checkout branch";
      gcm = "git commit -m";
      gcam= "git commit --amend -m";
      gl  = "git log";
      glf = "git log --graph --decorate --color --pretty=format:'%C(auto)%h %C(bold blue)%d %C(reset)%s %C(green)(%cr) %C(bold yellow)<%an>'";
      gpl = "git pull";
      gplr = "git pull --rebase";
      gps = "git push";
      gpo = "git push origin";
      gf  = "git fetch";
      gft = "git fetch --tags";

      drs = "sudo darwin-rebuild switch --flake /etc/nix-darwin";

      nd  = "nvim .";
      ndf = "cd /etc/nix-darwin && nvim flake.nix";
      nhm = "cd /etc/nix-darwin && nvim home.nix";
      nzr = "cd /etc/nix-darwin && nvim zsh.nix";
      ncf = "cd /etc/nix-darwin && nvim nvim/";

      cb  ="cargo build";
      cc  ="cargo clean";
      cr  ="cargo run";
      cw  ="cargo watch -x run";

      sma = "sqlx migrate add";
      smr = "sqlx migrate run";
      smi = "sqlx migrate info";
      smv = "sqlx migrate revert";
    };

    initContent = ''
      export EDITOR=nvim
      export FLUTTER_HOME="/Users/paiman/Programs/flutter"
      export CARGO_HOME="/Users/paiman/.cargo"
      export PATH="/run/current-system/sw/bin:$FLUTTER_HOME/bin:$CARGO_HOME/bin:$PATH"
      eval "$(starship init zsh)"
      export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    '';
  };
}

