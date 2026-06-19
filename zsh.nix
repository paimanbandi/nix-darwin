{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      c = "clear";
      x = "exit";
      ll = "lsd -al --color=always";
      gs = "git status";
      gb = "git branch";
      gbr = "git branch -r";
      gba = "git branch -a";
      ga = "git add";
      gaa = "git add .";
      gco = "git checkout";
      gcob = "git checkout -b";
      gcm = "git commit -m";
      gca = "git commit --amend";
      gcam = "git commit --amend -m";
      gl = "git log";
      glf = "git log --graph --decorate --color --pretty=format:'%C(auto)%h %C(bold blue)%d %C(reset)%s %C(green)(%cr) %C(bold yellow)<%an>'";
      gpl = "git pull";
      gplr = "git pull --rebase";
      gps = "git push";
      gpo = "git push origin";
      gpf = "git push --force";
      gpfl = "git push --force-with-lease";
      gf = "git fetch";
      gft = "git fetch --tags";
      gri = "git rebase -i";
      drs = "sudo darwin-rebuild switch --flake ~/.config/nix-darwin";
      nvim = "~/Applications/nvim-macos-arm64/bin/nvim";
      ndf = "cd ~/.config/nix-darwin && nvim flake.nix";
      nhm = "cd ~/.config/nix-darwin && nvim home.nix";
      nzr = "cd ~/.config/nix-darwin && nvim zsh.nix";
      ncf = "cd ~/.config/nix-darwin && nvim nvim/";
      cb = "cargo build";
      cc = "cargo clean";
      cr = "cargo run";
      cw = "cargo watch -x run";
      sma = "sqlx migrate add";
      smr = "sqlx migrate run";
      smi = "sqlx migrate info";
      smv = "sqlx migrate revert";
    };

    initContent = builtins.concatStringsSep "\n" (
      map builtins.readFile [
        ./zsh-init.sh
        ./secrets.sh
      ]
    );
  };
}
