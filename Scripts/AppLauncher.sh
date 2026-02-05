#!/usr/bin/env bash

# ============================================================
# CONFIG
# ============================================================
FISH_FUNCTIONS_DIR="$HOME/.config/fish/functions"
PREVIEW_POSITION="bottom"
PREVIEW_SIZE="40%"

PIPE=" │ "

# ============================================================
# THEME (Dynamic Only)
# ============================================================
RESET=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim)

FG=$(tput setaf 7)
ACCENT=$(tput setaf 4)
SUBTLE=$(tput setaf 8 2>/dev/null || tput setaf 7)

export FZF_DEFAULT_OPTS="
--color=fg:7,bg:0,hl:4
--color=fg+:7,bg+:8,hl+:4
--color=info:4,prompt:4,pointer:4,spinner:4
"

# ============================================================
# ALIASES
# ============================================================
declare -A ALIASES=(
["anydesk"]="AnyDesk"
["applauncher"]="Application Launcher (TUI)"
["appimageupdate"]="AppImageUpdater"
["boxes"]="GNOME Boxes"
["crt"]="Cool Retro Term"
["dolphin-emu"]="Dolphin Emulator"
["duckstation"]="DuckStation"
["eden"]="Eden Emulator"
["ghostty"]="Ghostty Terminal"
["kando-appimage"]="Kando"
["localsend"]="LocalSend"
["melonds"]="MelonDS"
["mgba"]="mGBA"
["onlyoffice"]="ONLYOFFICE"
["opera-browser"]="Opera Browser"
["polybar-appimage"]="Polybar"
["ppsspp"]="PPSSPP"
["ryujinx"]="Ryujinx"
["stacer"]="Stacer"
["tanuki3ds"]="Tanuki3DS"
["walc"]="WALC"
["warp"]="Warp Terminal"
["waveterm"]="Wave Terminal"
["wezterm"]="WezTerm"
["wps-office"]="WPS Office"
["youtube-music"]="YouTube Music"
["zen-browser"]="Zen Browser"
["ani-cli"]="Ani CLI"
["autotile"]="AutoTile"
["bash2048"]="2048"
["bashventure"]="Bashventure"
["brogue"]="Brogue CE"
["demitile"]="Demitile"
["minesweeper"]="Minesweeper"
["shtris"]="Shtris"
["snake"]="Snake (ascii)"
["snake-main"]="Snake"
["termclock"]="TermClock"
["tetris"]="Tetris"
["astroterm"]="AstroTerm"
["bluetuith"]="Bluetuith"
["bt"]="Bluetooth Manager"
["carbonyl"]="Carbonyl"
["chess-tui"]="Chess TUI"
["clidle"]="Clidle (wordle)"
["clipse"]="Clipse (clipboard)"
["cloudflare-speed-cli"]="Cloudflare Speed Test CLI"
["cortile"]="Cortile"
["crunchycleaner"]="CrunchyCleaner"
["deletor"]="Deletor"
["diskonaut"]="Diskonaut"
["dooit"]="Dooit"
["doxx"]="Doxx:Document Viewer"
["draw"]="Draw"
["dua"]="Disk Usage Analyzer (dua)"
["duf"]="Disk Usage/Free Utility (duf)"
["fastfetch"]="Fastfetch"
["gambit"]="Gambit"
["gdu"]="Go Disk Usage (gdu)"
["glow"]="Glow Markdown Viewer"
["goful"]="Goful"
["gopher64"]="Gopher64"
["helm"]="Helm"
["hydrotodo"]="HydroTodo"
["jif"]="Jif"
["jolt"]="Jolt"
["kbt"]="Keyboard Tester"
["nnn-emoji"]="nnn File Manager (emoji plugin)"
["occt"]="OCCT"
["omm"]="OMM"
["outside"]="Outside"
["pass-cli"]="Pass CLI"
["pomo"]="Pomo Timer"
["portal"]="Portal"
["sampler"]="Sampler"
["smassh"]="Smassh"
["sonicradio"]="SonicRadio"
["sudoku"]="Sudoku"
["spf"]="Super File Manager"
["tt"]="Task Timer"
["taskwire"]="Taskwire"
["termeverything"]="TermEverything"
["termusic"]="Termusic"
["termusic-server"]="Termusic Server"
["todo-linux"]="Todo Linux"
["tran"]="Tran"
["ttyper"]="TTYper"
["tjournal"]="TUI-Journal"
["tuime"]="Tuime"
["tuios"]="TUI OS"
["typioca"]="Typioca"
["typtea"]="Typtea"
["viu"]="VIU Media (anime)"
["wifi-tui"]="WiFi TUI"
["wiki-tui"]="Wiki TUI"
["wiper"]="Wiper"
["wtfutil"]="WTF"
["xleak"]="XLeak:Sheet Viewer"
["xplr"]="Xplr File Manager"
["yazi"]="Yazi File Manager"
["youtube-tui"]="YouTube TUI"
["zellij"]="Zellij"
["zentile"]="Zentile"
)

# ============================================================
# CATEGORY GROUPS
# ============================================================
APPIMAGES=("anydesk" "appimageupdate" "boxes" "crt" "dolphin-emu" "duckstation" "eden" "ghostty" "kando-appimage" "localsend" "melonds" "mgba" "onlyoffice" "opera-browser" "polybar-appimage" "ppsspp" "ryujinx" "stacer" "tanuki3ds" "walc" "warp" "waveterm" "wezterm" "wps-office" "youtube-music" "zen-browser")

SCRIPTS=("ani-cli" "autotile" "bash2048" "bashventure" "brogue" "demitile" "minesweeper" "shtris" "snake" "snake-main" "termclock" "tetris")

LINUX_EXECUTABLES=("astroterm" "bluetuith" "bt" "carbonyl" "chess-tui" "clidle" "clipse" "cloudflare-speed-cli" "cortile" "crunchycleaner" "deletor" "diskonaut" "dooit" "doxx" "draw" "dua" "duf" "fastfetch" "gambit" "gdu" "glow" "goful" "gopher64" "helm" "hydrotodo" "jif" "jolt" "kbt" "nnn-emoji" "occt" "omm" "outside" "pass-cli" "pomo" "portal" "sampler" "smassh" "sonicradio" "sudoku" "spf" "tt" "taskwire"  "termeverything" "termusic" "termusic-server" "todo-linux" "tran" "ttyper" "tjournal" "tuime" "tuios" "typioca" "typtea" "viu" "wifi-tui" "wiki-tui" "wiper" "wtfutil" "xleak" "xplr" "yazi" "youtube-tui" "zellij" "zentile")

# ============================================================
# SUBCATEGORY GROUPS
# ============================================================
EMULATION=("boxes" "dolphin-emu" "duckstation" "eden" "gopher64" "melonds" "mgba" "ppsspp" "ryujinx" "tanuki3ds")
GAMES=("bash2048" "bashventure" "brogue" "chess-tui" "clidle" "gambit" "minesweeper" "shtris" "snake" "snake-main" "sudoku" "tetris")
FILE_MANAGERS=("goful" "yazi" "nnn-emoji" "spf" "xplr" "bt")
DISKSPACE_VISUALIZERS=("dua" "duf" "diskonaut" "gdu")
FILE_TRANSFER=("portal" "tran" "localsend")
FILE_VIEWERS=("glow" "xleak" "doxx" "jif")
MEDIA=("carbonyl" "termeverything" "sonicradio" "termusic" "termusic-server" "youtube-tui" "viu" "ani-cli" "youtube-music")
MULTIPLEXERS=("cortile" "tuios" "zentile" "zellij" "demitile" "autotile")
SYSTEM_CLEANERS=("crunchycleaner" "deletor" "wiper")
SYSTEMTOOLS_AND_INFORMATION=("fastfetch" "outside" "pass-cli" "sampler" "wifi-tui" "wtfutil" "bluetuith" "clipse" "cloudflare-speed-cli" "jolt" "kbt" "occt" "taskwire" "stacer")
TIMERS_AND_CLOCKS=("pomo" "helm" "tuime" "termclock")
TODO_LISTS=("omm" "hydrotodo" "dooit" "tjournal" "todo-linux" "tt")
TYPINGSPEED_TESTS=("typtea" "smassh" "ttyper" "typioca")
TERMINALS=("crt" "ghostty" "warp" "waveterm" "wezterm")
WEB_BROWSERS=("opera-browser" "zen-browser")
OFFICE_SUITES=("onlyoffice" "wps-office")
MISCELLANEOUS=("anydesk" "appimageupdate" "kando-appimage" "polybar-appimage" "walc" "draw" "astroterm" "wiki-tui")

# ============================================================
# CATEGORY LOGIC
# ============================================================
in_group() {
  local name="$1"
  shift
  local group=("$@")

  for item in "${group[@]}"; do
    [[ "$item" == "$name" ]] && return 0
  done
  return 1
}

category_of() {
  local name="$1"

  if in_group "$name" "${APPIMAGES[@]}"; then
    echo "📦 AppImages"
  elif in_group "$name" "${SCRIPTS[@]}"; then
    echo "🎮 Scripts"
  elif in_group "$name" "${LINUX_EXECUTABLES[@]}"; then
    echo "🖥 Linux Executables"
  else
    echo "📦 Other"
  fi
}

subcategory_of() {
  local name="$1"

  if in_group "$name" "${EMULATION[@]}"; then
    echo "Emulation"
  elif in_group "$name" "${GAMES[@]}"; then
    echo "Games"
  elif in_group "$name" "${FILE_MANAGERS[@]}"; then
    echo "File Managers"
  elif in_group "$name" "${DISKSPACE_VISUALIZERS[@]}"; then
    echo "Disk-Space Visualizers"
  elif in_group "$name" "${FILE_TRANSFER[@]}"; then
    echo "File Transfer"
  elif in_group "$name" "${FILE_VIEWERS[@]}"; then
    echo "File Viewer"
  elif in_group "$name" "${MEDIA[@]}"; then
    echo "Media"
  elif in_group "$name" "${MISCELLANEOUS[@]}"; then
    echo "Miscellaneous"
  elif in_group "$name" "${MULTIPLEXERS[@]}"; then
    echo "Multiplexers"
  elif in_group "$name" "${SYSTEM_CLEANERS[@]}"; then
    echo "System Cleaners"
  elif in_group "$name" "${SYSTEMTOOLS_AND_INFORMATION[@]}"; then
    echo "System Tools & Information"
  elif in_group "$name" "${TIMERS_AND_CLOCKS[@]}"; then
    echo "Timers & Clocks"
  elif in_group "$name" "${TODO_LISTS[@]}"; then
    echo "ToDo Lists"
  elif in_group "$name" "${TYPINGSPEED_TESTS[@]}"; then
    echo "Typing-Speed Tests"
  elif in_group "$name" "${TERMINALS[@]}"; then
    echo "Terminals"
  elif in_group "$name" "${WEB_BROWSERS[@]}"; then
    echo "Web Browsers"
  elif in_group "$name" "${OFFICE_SUITES[@]}"; then
    echo "Office Suites"
  else
    echo "General"
  fi
}

display_name_of() {
  [[ -n "${ALIASES[$1]}" ]] && echo "${ALIASES[$1]}" || echo "$1"
}

build_preview_window() {
  echo "$PREVIEW_POSITION:$PREVIEW_SIZE:wrap"
}

# ============================================================
# LOAD FUNCTIONS
# ============================================================
mapfile -t FUNCTIONS < <(
  find "$FISH_FUNCTIONS_DIR" -type f -name "*.fish" \
    -exec basename {} .fish \; | sort
)

[[ ${#FUNCTIONS[@]} -eq 0 ]] && exit 1

# ============================================================
# WIDTH CALCULATION
# ============================================================
max_app=0
max_cmd=0
max_cat=0
max_sub=0

for fn in "${FUNCTIONS[@]}"; do
  app=$(display_name_of "$fn")
  cmd="$fn"
  cat=$(category_of "$fn")
  sub=$(subcategory_of "$fn")

  (( ${#app} > max_app )) && max_app=${#app}
  (( ${#cmd} > max_cmd )) && max_cmd=${#cmd}
  (( ${#cat} > max_cat )) && max_cat=${#cat}
  (( ${#sub} > max_sub )) && max_sub=${#sub}
done

((max_cat+=2))
((max_sub+=1))

# ============================================================
# BUILD MENU
# ============================================================
MENU=()
counter=1

for fn in "${FUNCTIONS[@]}"; do
  app=$(display_name_of "$fn")
  cmd="$fn"
  cat=$(category_of "$fn")
  sub=$(subcategory_of "$fn")

  MENU+=("$(printf \
"%3d ${PIPE}%-*s${PIPE}%-*s${PIPE}${DIM}%-*s  ${RESET}${PIPE}${DIM}%-*s${RESET}" \
    "$counter" \
    "$max_app" "$app" \
    "$max_cmd" "$cmd" \
    "$max_cat" "$cat" \
    "$max_sub" "$sub")")

  ((counter++))
done

# ============================================================
# HEADER
# ============================================================
HEADER="${BOLD}$(printf \
" No ${PIPE}%-*s${PIPE}%-*s${PIPE}%-*s${PIPE}%-*s" \
"$max_app" "Application" \
"$max_cmd" "Command" \
"$max_cat" "Category" \
"$max_sub" "Subcategory")${RESET}"

# ============================================================
# FZF PICKER
# ============================================================
selection=$(printf "%s\n" "${MENU[@]}" | fzf \
  --ansi \
  --header="$HEADER" \
  --prompt="🚀 Launch > " \
  --height=100% \
  --reverse \
  --border \
  --preview-window="$(build_preview_window)" \
  --preview '
    display_fn=$(echo {} | awk -F "│" "{print \$2}" | xargs)
    real_fn=$(echo {} | awk -F "│" "{print \$3}" | xargs)
    category=$(echo {} | awk -F "│" "{print \$4}" | xargs)
    subcategory=$(echo {} | awk -F "│" "{print \$5}" | xargs)

    file="'"$FISH_FUNCTIONS_DIR"'/$real_fn.fish"

    if [[ -f "$file" ]]; then
        desc=$(grep -Po "(?<=--description\s\")[^\"]*" "$file")
        link=$(grep -Po "(?<=--link\s\")[^\"]*" "$file")
    fi

    [[ -z "$desc" ]] && desc="No description available."

    echo "'$BOLD'🚀 Application:'$RESET' $display_fn"
    echo "'$BOLD'🧾 Command:'$RESET' $real_fn"
    echo
    echo "'$BOLD'🗂 Category:'$RESET' $category"
    echo "'$BOLD'📁 Subcategory:'$RESET' $subcategory"
    echo
    echo "'$BOLD'📝 Description:'$RESET' $desc"

    if [[ -n "$link" ]]; then
        echo
        echo "'$BOLD'🔗 Link:'$RESET' $link"
    fi

    echo
    echo "'$BOLD'📄 Fish file:'$RESET' $file"
  ' \
  --bind "ctrl-h:execute(
      real_fn=\$(echo {} | awk -F '│' '{print \$3}' | xargs);
      if command -v fish >/dev/null 2>&1; then
          fish -c \"if type \$real_fn >/dev/null 2>&1; \$real_fn -h || \$real_fn --help; end\" | less;
      fi
  )"
)

[[ -z "$selection" ]] && exit 0

cmd=$(echo "$selection" | awk -F '│' '{print $3}' | xargs)

echo
echo "▶ Launching '$cmd' via Fish..."
exec fish -c "$cmd"
