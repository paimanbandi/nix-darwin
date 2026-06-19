  export EDITOR=nvim
      export NVIM_NO_TITLE=1
      export FLUTTER_HOME="/Users/paiman/Programs/flutter"
      export CARGO_HOME="/Users/paiman/.cargo"
      export PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      export DOCKER_HOST="unix:///Users/paiman/.colima/default/docker.sock"
      export MAESTRO_BIN="$HOME/.maestro/bin"
     export ANDROID_HOME=$HOME/Library/Android/sdk
      export PATH="$HOME/Applications/nvim-macos-arm64/bin:/run/current-system/sw/bin:$FLUTTER_HOME/bin:$CARGO_HOME/bin:$MAESTRO_BIN:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"

      # ════════════════════════════════════════════════════════════
      # Multi-profile secrets management
      # ════════════════════════════════════════════════════════════
      # Folder structure:
      #   ~/.secrets/
      #   ├── .active             ← berisi nama profile aktif (mis. "waqfuel")
      #   ├── default.json        ← fallback profile
      #   ├── waqfuel.json
      #   ├── sesambungan.json
      #   └── kantor.json
      #
      # Convention key: env var standard (lowercase).
      # Contoh: aws_access_key_id → $AWS_ACCESS_KEY_ID

      SECRETS_DIR="$HOME/.secrets"
      ACTIVE_FILE="$SECRETS_DIR/.active"

      _get_active_profile() {
        if [ -f "$ACTIVE_FILE" ]; then
          cat "$ACTIVE_FILE"
        else
          echo "default"
        fi
      }

      _get_active_file() {
        local profile=$(_get_active_profile)
        echo "$SECRETS_DIR/${profile}.json"
      }

      _clear_secret_env() {
        local file="$1"
        [ -f "$file" ] || return 0
        while IFS= read -r key; do
          unset "$key"
        done < <(
          jq -r 'keys[] | ascii_upcase' "$file" 2>/dev/null
        )
      }

      _load_secrets_from() {
        local file="$1"
        [ -f "$file" ] || return 0
        while IFS='=' read -r key value; do
          export "$key=$value"
        done < <(
          jq -r 'to_entries | .[] | "\(.key | ascii_upcase)=\(.value)"' \
            "$file" 2>/dev/null
        )
      }

      # Auto-load active profile saat shell start
      if [ -d "$SECRETS_DIR" ] && command -v jq >/dev/null 2>&1; then
        ACTIVE_PROFILE=$(_get_active_profile)
        ACTIVE_SECRETS_FILE=$(_get_active_file)
        if [ -f "$ACTIVE_SECRETS_FILE" ]; then
          _load_secrets_from "$ACTIVE_SECRETS_FILE"
        else
          echo "⚠  Active profile '$ACTIVE_PROFILE' file not found: $ACTIVE_SECRETS_FILE"
        fi
      else
        [ ! -d "$SECRETS_DIR" ] && echo "~/.secrets/ directory not found"
      fi

      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(starship init zsh)"

      autoload -U up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      bindkey '^[[B' down-line-or-beginning-search

      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      autoload -Uz add-zsh-hook
      function set_ghostty_title() {
        print -Pn "\e]0;%1~\a"
      }
      add-zsh-hook precmd set_ghostty_title

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
      # secrets command — manage multiple secret profiles
      # ════════════════════════════════════════════════════════════
      secrets() {
        local cmd="$1"
        local arg1="$2"
        local arg2="$3"
        mkdir -p "$SECRETS_DIR"

        case "$cmd" in
          "list"|"ls")
            local active=$(_get_active_profile)
            echo "Secret profiles in $SECRETS_DIR:"
            echo ""
            for file in "$SECRETS_DIR"/*.json; do
              [ -f "$file" ] || continue
              local profile_name=$(basename "$file" .json)
              if [ "$profile_name" = "$active" ]; then
                echo "  ★ $profile_name (active)"
              else
                echo "    $profile_name"
              fi
            done
            ;;

          "use"|"switch")
            if [ -z "$arg1" ]; then
              echo "Usage: secrets use <profile-name>"
              echo ""
              echo "Available profiles:"
              for file in "$SECRETS_DIR"/*.json; do
                [ -f "$file" ] || continue
                echo "  - $(basename "$file" .json)"
              done
              return 1
            fi
            local new_file="$SECRETS_DIR/${arg1}.json"
            if [ ! -f "$new_file" ]; then
              echo "❌ Profile '$arg1' tidak ditemukan: $new_file"
              echo "   Bikin baru: secrets create $arg1"
              return 1
            fi
            local old_file=$(_get_active_file)
            [ -f "$old_file" ] && _clear_secret_env "$old_file"
            echo "$arg1" > "$ACTIVE_FILE"
            _load_secrets_from "$new_file"
            echo "✓ Switched to profile: $arg1"
            ;;

          "current"|"active")
            local active=$(_get_active_profile)
            local file=$(_get_active_file)
            echo "Active profile: $active"
            echo "File: $file"
            if [ -f "$file" ]; then
              echo ""
              echo "Loaded env vars:"
              jq -r 'keys[] | "  $\(. | ascii_upcase)"' "$file"
            fi
            ;;

          "create")
            if [ -z "$arg1" ]; then
              echo "Usage: secrets create <profile-name>"
              return 1
            fi
            local new_file="$SECRETS_DIR/${arg1}.json"
            if [ -f "$new_file" ]; then
              echo "❌ Profile '$arg1' sudah ada"
              return 1
            fi
            echo "{}" > "$new_file"
            echo "✓ Created profile: $arg1"
            echo "  Edit: secrets edit $arg1"
            echo "  Use:  secrets use $arg1"
            ;;

          "show")
            local profile="${arg1:-$(_get_active_profile)}"
            local file="$SECRETS_DIR/${profile}.json"
            if [ ! -f "$file" ]; then
              echo "❌ Profile '$profile' tidak ditemukan"
              return 1
            fi
            echo "Secrets di profile '$profile' ($file):"
            jq -r 'to_entries[] | "  \(.key): \(.value | tostring | .[0:10])..."' "$file"
            echo ""
            echo "Env vars (kalo profile ini active):"
            jq -r 'keys[] | "  $\(. | ascii_upcase)"' "$file"
            ;;

          "add")
            local key="$arg1"
            local value="$arg2"
            if [ -z "$key" ] || [ -z "$value" ]; then
              echo "Usage: secrets add <key> <value>"
              echo "       (operates on active profile: $(_get_active_profile))"
              return 1
            fi
            local file=$(_get_active_file)
            mkdir -p "$(dirname "$file")"
            if [ -f "$file" ]; then
              jq --arg k "$key" --arg v "$value" '. + {($k): $v}' "$file" > "${file}.tmp" && \
                mv "${file}.tmp" "$file"
            else
              echo "{\"$key\": \"$value\"}" > "$file"
            fi
            export "$(echo $key | tr '[:lower:]' '[:upper:]')"="$value"
            echo "✓ Added to '$(_get_active_profile)': $key (env: \$$(echo $key | tr '[:lower:]' '[:upper:]'))"
            ;;

          "remove"|"rm"|"delete"|"del")
            local key="$arg1"
            if [ -z "$key" ]; then
              echo "Usage: secrets remove <key>"
              return 1
            fi
            local file=$(_get_active_file)
            if [ -f "$file" ]; then
              jq "del(.$key)" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
              unset "$(echo $key | tr '[:lower:]' '[:upper:]')"
              echo "✓ Removed from '$(_get_active_profile)': $key"
            fi
            ;;

          "get")
            local key="$arg1"
            if [ -z "$key" ]; then
              echo "Usage: secrets get <key>"
              return 1
            fi
            local file=$(_get_active_file)
            [ -f "$file" ] && jq -r ".$key // empty" "$file"
            ;;

          "edit")
            local profile="${arg1:-$(_get_active_profile)}"
            local file="$SECRETS_DIR/${profile}.json"
            if [ ! -f "$file" ]; then
              echo "❌ Profile '$profile' tidak ditemukan"
              echo "   Bikin baru: secrets create $profile"
              return 1
            fi
            nvim "$file"
            if [ "$profile" = "$(_get_active_profile)" ]; then
              _clear_secret_env "$file"
              _load_secrets_from "$file"
              echo "✓ Reloaded env vars dari '$profile'"
            fi
            ;;

          "reload")
            local file=$(_get_active_file)
            _load_secrets_from "$file"
            echo "✓ Reloaded '$(_get_active_profile)'"
            ;;

          "copy"|"clone")
            local src="$arg1"
            local dst="$arg2"
            if [ -z "$src" ] || [ -z "$dst" ]; then
              echo "Usage: secrets copy <source-profile> <new-profile>"
              return 1
            fi
            local src_file="$SECRETS_DIR/${src}.json"
            local dst_file="$SECRETS_DIR/${dst}.json"
            if [ ! -f "$src_file" ]; then
              echo "❌ Source profile '$src' tidak ada"
              return 1
            fi
            if [ -f "$dst_file" ]; then
              echo "❌ Destination profile '$dst' udah ada"
              return 1
            fi
            cp "$src_file" "$dst_file"
            echo "✓ Copied '$src' → '$dst'"
            echo "  Edit: secrets edit $dst"
            ;;

          *)
            echo "Usage: secrets <command>"
            echo ""
            echo "Profile management:"
            echo "  list                       List all profiles (active marked with ★)"
            echo "  current                    Show active profile + loaded vars"
            echo "  use <profile>              Switch to a profile (loads its env vars)"
            echo "  create <profile>           Create new empty profile"
            echo "  copy <src> <dst>           Copy profile (templating)"
            echo "  edit [profile]             Edit profile (default: active)"
            echo "  show [profile]             Show secrets (masked)"
            echo "  reload                     Reload active profile"
            echo ""
            echo "Secret management (operates on active profile):"
            echo "  add <key> <value>          Add/update a secret"
            echo "  remove <key>               Remove a secret"
            echo "  get <key>                  Get secret value"
            echo ""
            echo "Active profile: $(_get_active_profile)"
            echo "Profiles dir:   $SECRETS_DIR"
            ;;
        esac
      }

      # ════════════════════════════════════════════════════════════
      # Auto-switch secrets profile berdasarkan direktori
      # ════════════════════════════════════════════════════════════
      # Tiap masuk ke folder repo tertentu, otomatis `secrets use <profile>`.
      # Guard cek profile aktif biar gak reload berulang tiap cd ke subfolder.
      _auto_secrets_profile() {
        case "$PWD/" in
          /Users/paiman/Projects/postmortem/repos/postmortem/*)
            [ "$(_get_active_profile)" != "postmortem" ] && secrets use postmortem ;;
          /Users/paiman/Projects/Discernere/repos/discernere/*)
            [ "$(_get_active_profile)" != "discernere" ] && secrets use discernere ;;
        esac
      }
      add-zsh-hook chpwd _auto_secrets_profile
      _auto_secrets_profile  # cek juga saat shell start (kalau udah di dalam folder)
      mkdir -p ~/.maestro
      echo "appleTeamId: $MAESTRO_APPLE_TEAM_ID" > ~/.maestro/config.yaml
