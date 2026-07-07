{ config, pkgs, ... }:
{
  home.username = "paiman";
  home.homeDirectory = "/Users/paiman";

  imports = [
    ./zsh.nix
    ./starship.nix
    ./ghostty.nix
    ./warp.nix
    ./tmux.nix
  ];

  home.packages = with pkgs; [
    starship
    zsh
    jq
    tree-sitter
    gcc
    nodejs
  ];

  home.file.".config/nvim".source = ./nvim;

  # ~/.config/mcphub/servers.json — dikelola Nix (deklaratif).
  # Figma remote pakai OAuth, jadi TIDAK ada secret di sini → aman masuk store.
  # Catatan: file ini jadi symlink read-only ke store, jadi tombol add/edit/delete
  # server di UI `:MCPHub` tidak bisa menulis ke sini. Tambah/hapus server = edit
  # blok ini lalu `darwin-rebuild switch`.
  home.file.".config/mcphub/servers.json".text = builtins.toJSON {
    mcpServers = {
      figma-desktop = {
        url = "http://127.0.0.1:3845/mcp";
      };
    };
  };

  home.stateVersion = "24.05";
}
