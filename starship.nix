{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    starship
  ];

  home.file.".config/starship.toml".text = ''
    [rust]
    command_timeout = 2000
  '';
}
