{ config, pkgs, ... }:
{
  xdg.configFile."warp/themes/ghostty-clone.yaml".text = ''
    name: Ghostty Clone
    background: "#282c34"
    foreground: "#abb2bf"
    cursor: "#e5c07b"
    selection-background: "#5c6370"
    selection-foreground: "#ffffff"
    ansi:
      - "#282c34" # 0
      - "#e06c75" # 1
      - "#98c379" # 2
      - "#e5c07b" # 3
      - "#61afef" # 4
      - "#c678dd" # 5
      - "#56b6c2" # 6
      - "#abb2bf" # 7
    brightAnsi:
      - "#5c6370" # 8
      - "#e06c75" # 9
      - "#98c379" # 10
      - "#e5c07b" # 11
      - "#61afef" # 12
      - "#c678dd" # 13
      - "#56b6c2" # 14
      - "#ffffff" # 15
  '';
}
