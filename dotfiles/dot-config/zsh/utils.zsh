

lnabs() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: lnabs <relative_target> <link_name>"
        echo "Example: lnabs ./Dotfiles/config/zsh ./.config/zsh"
        return 1
    fi
    local target="$1"
    local link="$2"
    # Ensure target exists
    if [[ ! -e "$PWD/$target" ]]; then
        echo "Error: Target '$PWD/$target' does not exist."
        return 1
    fi
    # Create the symlink with absolute path
    ln -sf "$PWD/$target" "$link"
    echo "Created symlink: $link -> $PWD/$target"
}

headless() {
  unset PULSE_SERVER
  pkill pulse
  local IP=127.0.0.1
  sleep 1
  pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=$IP auth-anonymous=1 port=8080" --exit-idle-time=-1
  export PULSE_SERVER=$IP:8080
}

function _smooth_fzf() {
  local fname
  local current_dir="$PWD"
  cd "${XDG_CONFIG_HOME:-~/.config}"
  fname="$(fzf)" || return
  $EDITOR "$fname"
  cd "$current_dir"
}

function _sudo_replace_buffer() {
  local old=$1 new=$2 space=${2:+ }

  # if the cursor is positioned in the $old part of the text, make
  # the substitution and leave the cursor after the $new text
  if [[ $CURSOR -le ${#old} ]]; then
    BUFFER="${new}${space}${BUFFER#$old }"
    CURSOR=${#new}
  # otherwise just replace $old with $new in the text before the cursor
  else
    LBUFFER="${new}${space}${LBUFFER#$old }"
  fi
}

function _sudo_command_line() {
  # If line is empty, get the last run command from history
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

  # Save beginning space
  local WHITESPACE=""
  if [[ ${LBUFFER:0:1} = " " ]]; then
    WHITESPACE=" "
    LBUFFER="${LBUFFER:1}"
  fi

  {
    # If $SUDO_EDITOR or $VISUAL are defined, then use that as $EDITOR
    # Else use the default $EDITOR
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}

    # If $EDITOR is not set, just toggle the sudo prefix on and off
    if [[ -z "$EDITOR" ]]; then
      case "$BUFFER" in
        sudo\ -e\ *) _sudo_replace_buffer "sudo -e" "" ;;
        sudo\ *) _sudo_replace_buffer "sudo" "" ;;
        *) LBUFFER="sudo $LBUFFER" ;;
      esac
      return
    fi

    # Check if the typed command is really an alias to $EDITOR

    # Get the first part of the typed command
    local cmd="${${(Az)BUFFER}[1]}" 
    
    local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
    local editorcmd="${${(Az)EDITOR}[1]}"

    if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) \
      || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] \
      || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
      _sudo_replace_buffer "$cmd" "sudo -e"
      return
    fi

    # Check for editor commands in the typed command and replace accordingly
    case "$BUFFER" in
      $editorcmd\ *) _sudo_replace_buffer "$editorcmd" "sudo -e" ;;
      \$EDITOR\ *) _sudo_replace_buffer '$EDITOR' "sudo -e" ;;
      sudo\ -e\ *) _sudo_replace_buffer "sudo -e" "$EDITOR" ;;
      sudo\ *) _sudo_replace_buffer "sudo" "" ;;
      *) LBUFFER="sudo $LBUFFER" ;;
    esac
  } always {
    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"

    # Redisplay edit buffer (compatibility with zsh-syntax-highlighting)
    zle redisplay
  }
}

function _vi_search_fix() {
  zle vi-cmd-mode
  zle .vi-history-search-backward
}

function toppy() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n 21
}

function cd() {
	z "$@" && ls --group-directories-first --color=auto -F
}

function git-svn(){
  if [[ ! -z "$1" && ! -z "$2" ]]; then
          echo "Starting clone/copy ..."
          repo=$(echo $1 | sed 's/\/$\|.git$//')
          svn export "$repo/trunk/$2"
  else
          echo "Use: git-svn <repository> <subdirectory>"
  fi  
}

function zle-keymap-select {
if [[ $KEYMAP == vicmd ]]; then
  echo -ne '\e[1 q'  # Blinking block in normal mode
else
  echo -ne '\e[5 q'  # Blinking bar in insert mode
fi
}
zle -N zle-keymap-select

function zle-line-init {
echo -ne '\e[5 q'  # Bar cursor when shell starts
}
zle -N zle-line-init

rmpc(){
  pgrep -x "mpd" || mpd

  local TERMINAL=$(ps -p $PPID -o comm=)

  if [[ "${TERMINAL}" == "st" ]]; then
    command rmpc $@
  elif [[ "${TERMINAL}" == "com.termux" ]]; then
    command rmpc -c $HOME/.config/rmpc/config-termux.ron $@
  elif [ "${TERMINAL}" == "foot" ] || [ "${TERMINAL}" == "alacritty" ]; then
    command rmpc -c $HOME/.config/rmpc/config-foot.ron $@
  else
    command rmpc -c $HOME/.config/rmpc/config-ueberzug.ron $@
  fi

  mpc --host 127.0.0.1 --port 8600 stop
}

vplay(){
    SDL_HINT_RENDER_DRIVER=opengl
    ffplay -vcodec $(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $1)_mediacodec $1
}
