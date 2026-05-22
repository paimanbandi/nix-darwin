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

    initContent = ''
      export EDITOR=nvim
      export NVIM_NO_TITLE=1
      export FLUTTER_HOME="/Users/paiman/Programs/flutter"
      export CARGO_HOME="/Users/paiman/.cargo"
      export PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      export DOCKER_HOST="unix:///Users/paiman/.colima/default/docker.sock"
      export PATH="$HOME/Applications/nvim-macos-arm64/bin:/run/current-system/sw/bin:$FLUTTER_HOME/bin:$CARGO_HOME/bin:$PATH"

      # ════════════════════════════════════════════════════════════
      # Auto-load secrets dari ~/.secrets.json
      # ════════════════════════════════════════════════════════════
      # Convention: nama key di JSON harus pakai env var standard (lowercase).
      # Contoh:
      #   aws_access_key_id      → $AWS_ACCESS_KEY_ID
      #   aws_secret_access_key  → $AWS_SECRET_ACCESS_KEY
      #   github_token           → $GITHUB_TOKEN
      #   openai_api_key         → $OPENAI_API_KEY
      #
      # Tambah secret baru = `secrets add <key> <value>` (no edit zsh.nix needed)
      if [ -f "$HOME/.secrets.json" ] && command -v jq >/dev/null 2>&1; then
        while IFS='=' read -r key value; do
          export "$key=$value"
        done < <(
          jq -r 'to_entries | .[] | "\(.key | ascii_upcase)=\(.value)"' \
            "$HOME/.secrets.json" 2>/dev/null
        )
      else
        [ ! -f "$HOME/.secrets.json" ] && echo "~/.secrets.json not found"
      fi

      eval "$(starship init zsh)"

      # History search
      autoload -U up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      bindkey '^[[B' down-line-or-beginning-search

      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # Ghostty dynamic title
      autoload -Uz add-zsh-hook
      function set_ghostty_title() {
        print -Pn "\e]0;%1~\a"
      }
      add-zsh-hook precmd set_ghostty_title

      # Function override for nvim
      function n() {
        print -Pn "\e]0;$(basename $PWD)\a"
        export NVIM_NO_TITLE=1
        nvim "$@"
      }
      function nd() {
        print -Pn "\e]0;$(basename $PWD)\a"
        export NVIM_NO_TITLE=1
        nvim .
      }

      # ════════════════════════════════════════════════════════════
      # Secrets management
      # ════════════════════════════════════════════════════════════
      # Helper: reload semua env vars dari secrets.json.
      # Pattern sama dengan auto-export di atas → konsisten.
      _reload_secrets() {
        local secrets_file="$HOME/.secrets.json"
        [ -f "$secrets_file" ] || return 0
        while IFS='=' read -r key value; do
          export "$key=$value"
        done < <(
          jq -r 'to_entries | .[] | "\(.key | ascii_upcase)=\(.value)"' \
            "$secrets_file" 2>/dev/null
        )
      }

      secrets() {
        local cmd="$1"
        local key="$2"
        local value="$3"
        local secrets_file="$HOME/.secrets.json"

        case "$cmd" in
          "show")
            if [ -f "$secrets_file" ]; then
              echo "Secrets in $secrets_file:"
              jq -r 'to_entries[] | "  \(.key): \(.value | tostring | .[0:10])..."' "$secrets_file"
              echo ""
              echo "Env vars yang di-export:"
              jq -r 'keys[] | "  $\(. | ascii_upcase)"' "$secrets_file"
            else
              echo "$secrets_file not found"
            fi
            ;;
          "add")
            if [ -z "$key" ] || [ -z "$value" ]; then
              echo "Usage: secrets add <key> <value>"
              echo ""
              echo "Tip: pakai nama key sesuai env var standard (lowercase)."
              echo "Contoh:"
              echo "  secrets add aws_access_key_id AKIA..."
              echo "  secrets add aws_secret_access_key ..."
              echo "  secrets add github_token ghp_..."
              return 1
            fi
            if [ -f "$secrets_file" ]; then
              jq --arg k "$key" --arg v "$value" '. + {($k): $v}' "$secrets_file" > "''${secrets_file}.tmp" && \
                mv "''${secrets_file}.tmp" "$secrets_file"
              echo "Added/updated: $key (env: \$$(echo $key | tr '[:lower:]' '[:upper:]'))"
            else
              echo "{\"$key\": \"$value\"}" > "$secrets_file"
              echo "Created $secrets_file with: $key"
            fi
            _reload_secrets
            echo "Reloaded env vars"
            ;;
          "remove"|"rm"|"delete"|"del")
            if [ -z "$key" ]; then
              echo "Usage: secrets remove <key>"
              return 1
            fi
            if [ -f "$secrets_file" ]; then
              jq "del(.$key)" "$secrets_file" > "''${secrets_file}.tmp" && \
                mv "''${secrets_file}.tmp" "$secrets_file"
              unset "$(echo $key | tr '[:lower:]' '[:upper:]')"
              echo "Removed: $key"
            fi
            ;;
          "get")
            if [ -z "$key" ]; then
              echo "Usage: secrets get <key>"
              return 1
            fi
            if [ -f "$secrets_file" ]; then
              jq -r ".$key // empty" "$secrets_file"
            else
              echo ""
            fi
            ;;
          "edit")
            nvim "$secrets_file"
            _reload_secrets
            echo "Reloaded env vars"
            ;;
          "reload")
            _reload_secrets
            echo "Reloaded env vars dari $secrets_file"
            ;;
          *)
            echo "Usage: secrets <command>"
            echo ""
            echo "Commands:"
            echo "  show                    Show all secrets (masked) + env var names"
            echo "  add <key> <value>       Add/update a secret"
            echo "  remove <key>            Remove a secret (alias: rm, delete, del)"
            echo "  get <key>               Get secret value (plain)"
            echo "  edit                    Edit secrets file (in nvim)"
            echo "  reload                  Reload env vars dari secrets.json"
            ;;
        esac
      }
    '';
  };
}
