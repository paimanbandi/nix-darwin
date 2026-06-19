export EDITOR=nvim
export NVIM_NO_TITLE=1
export FLUTTER_HOME="/Users/paiman/Programs/flutter"
export CARGO_HOME="/Users/paiman/.cargo"
export PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export DOCKER_HOST="unix:///Users/paiman/.colima/default/docker.sock"
export MAESTRO_BIN="$HOME/.maestro/bin"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$HOME/Applications/nvim-macos-arm64/bin:/run/current-system/sw/bin:$FLUTTER_HOME/bin:$CARGO_HOME/bin:$MAESTRO_BIN:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"

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

mkdir -p ~/.maestro
echo "appleTeamId: $MAESTRO_APPLE_TEAM_ID" >~/.maestro/config.yaml
