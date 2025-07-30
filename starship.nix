{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    starship
  ];

  home.file.".config/starship.toml".text = ''
    command_timeout = 2000
  '';
}
