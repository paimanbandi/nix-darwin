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

  outputs = inputs@{ self, nix-darwin, nixpkgs, flake-utils, rust-overlay, home-manager }:
    let
      system = "aarch64-darwin";
      overlays = [ rust-overlay.overlays.default ];
      pkgs = import nixpkgs {
        inherit system overlays; 
        config.allowUnfree = true;
      };

      configuration = { pkgs, ... }: {
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
          lsd
          neofetch
          vim
          neovim
          git
          curl
          httpie
          grpcurl
          grpcui
          tree
          ripgrep
          ruby_3_2
          cocoapods
          zig
          vlang
	        (pkgs.rust-bin.stable.latest.complete)
          pkgs.rust-analyzer
          cargo-watch
          go
          protobuf
          prettier
          markdownlint-cli
          tailwindcss-language-server
          emmet-ls
          caddy
          yamllint
          ntp
          awscli
          # awscli2
          sshfs
          vscode-js-debug
          python314
          pipx
          wireguard-tools
          zulu8
          ripgrep-all
          openresolv
          swift-format
          chafa
          imagemagick
          luarocks
          httrack
          # podman
          # podman-compose
          docker
          docker-compose
          colima
          postgresql
          sqlx-cli
          d2
          mermaid-cli
        ];

        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nix.package = pkgs.nix;

        programs.zsh.enable = true;

        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6; 

        nixpkgs.hostPlatform = system;

        time.timeZone = "Asia/Jakarta";
      };
    in {
      darwinConfigurations."MacBook-Pro-de-Paiman" = nix-darwin.lib.darwinSystem {
        system = system;
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            users.users.paiman.home = "/Users/paiman";
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

