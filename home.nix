{ config, pkgs, ... }: {
  home.username = "paiman";
  home.homeDirectory = "/Users/paiman";

  imports = [
    ./zsh.nix
    ./starship.nix
    ./ghostty.nix
  ];

  home.packages = with pkgs; [
    starship
    zsh
  ];

  home.file.".config/nvim".source = ./nvim;

  home.stateVersion = "24.05";
}

