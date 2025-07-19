{ config, pkgs, ... }: {
  home.username = "paiman";
  home.homeDirectory = "/Users/paiman";

  imports = [
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    starship
    zsh
    git
  ];

  home.file.".config/nvim".source = ./nvim;

  home.stateVersion = "24.05";
}

