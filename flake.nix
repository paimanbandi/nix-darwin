{
  description = "Paiman's nix-darwin config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      flake-utils,
      rust-overlay,
      home-manager,
    }:
    let
      system = "aarch64-darwin";
      overlays = [ rust-overlay.overlays.default ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      configuration =
        { pkgs, ... }:
        {
          nix.enable = false;

          system.primaryUser = "paiman";

          homebrew = {
            enable = true;
            casks = [
              "macfuse"
            ];
            onActivation = {
              cleanup = "zap";
              autoUpdate = true;
              upgrade = true;
            };
          };

          environment.systemPackages = with pkgs; [
            # Shell utilities
            lsd
            tree
            neofetch

            # Text editors
            vim
            neovim

            # Version control
            git

            # Network utilities
            curl
            httpie
            sshfs
            ntp
            wireguard-tools
            openresolv

            # Search tools
            ripgrep
            ripgrep-all

            # gRPC tools
            grpcurl
            grpcui

            # Programming languages
            ## Ruby
            ruby_3_2
            cocoapods

            ## Rust
            (pkgs.rust-bin.stable.latest.complete)
            pkgs.rust-analyzer
            cargo-watch

            ## Go
            go

            ## Zig
            zig

            ## V
            vlang

            ## Python
            python314
            pipx

            ## Java
            zulu8

            ## Swift
            swift-format

            # Build tools & protocols
            protobuf

            # Formatters
            prettier
            nixfmt-rfc-style
            yamllint

            # Language servers
            tailwindcss-language-server
            emmet-ls

            # Markdown tools
            markdownlint-cli

            # Web server
            caddy

            # Cloud & Infrastructure
            awscli
            # awscli2

            # Container & virtualization
            docker
            docker-compose
            colima
            # podman
            # podman-compose

            # Database
            postgresql
            sqlx-cli
            redis

            # Debugging
            vscode-js-debug

            # Diagram tools
            d2
            mermaid-cli

            # Image utilities
            chafa
            imagemagick

            # Package managers
            luarocks

            # Web scraping
            httrack

            # File Manager
            yazi
          ];

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          nix.package = pkgs.nix;

          programs.zsh.enable = true;

          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;

          nixpkgs.hostPlatform = system;

          time.timeZone = "Asia/Jakarta";
        };
    in
    {
      darwinConfigurations."MacBook-Pro-de-Paiman" = nix-darwin.lib.darwinSystem {
        system = system;
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            users.users.paiman = {
              home = "/Users/paiman";
              shell = pkgs.zsh;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.paiman = import ./home.nix;
          }
        ];
        specialArgs = {
          inherit pkgs;
        };
      };
    };
}
