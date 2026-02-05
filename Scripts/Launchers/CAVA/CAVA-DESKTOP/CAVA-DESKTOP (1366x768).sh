#!/bin/bash

# =====================================================
#                      HELP
# =====================================================
show_help() {
cat << EOF
Usage: $0 [OPTIONS]

This script launches or closes a CAVA visualizer in a dedicated GNOME Terminal window
with configurable size, position, workspace, and monitor settings.

Options:
  -h, --help       Show this help message and exit

User Configurations:
  PROFILE             GNOME Terminal profile for CAVA (colors, transparency, fonts)
  DELAY               Delay in seconds before window manipulation
  WIDTH, HEIGHT       Window dimensions in pixels
  WORKSPACE           Default workspace (0-indexed) for single workspace mode
  POSITION            Window placement: center | top | bottom | left | right | custom
  CUSTOM_X, CUSTOM_Y  Pixel coordinates for custom window placement
  TERMINAL_TITLE      Terminal title used to identify the CAVA window
  TARGET_MONITOR      Monitor to display CAVA on: primary | left | right | HDMI-1 etc.
  CAVA_CONFIG_PATH    Path to CAVA configuration file
  RERUN_ACTION        Script behavior on rerun: toggle | close | launch

Visibility Settings:
  VISIBILITY_MODE     single | all | custom
  SELECTED_WORKSPACES Array of workspace numbers (0-indexed) for custom mode

Examples:
  $0                 Toggle CAVA (launch if not running, close if running)
  $0 --help          Display this help message

EOF
exit 0
}

# Check for help argument
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
fi

# =====================================================
#              USER CONFIGURATIONS
# =====================================================

PROFILE="CAVA" 
TERMINAL_TITLE="CAVA"

DELAY=1.0

WIDTH=1400
HEIGHT=400

WORKSPACE=0

POSITION="custom"          
CUSTOM_X=4
CUSTOM_Y=338

TERMINAL_TITLE="CAVA"

TARGET_MONITOR="primary"   

CAVA_CONFIG_PATH="$HOME/.config/cava/config"

RERUN_ACTION="toggle"

# =====================================================
#              VISIBILITY SETTINGS
# =====================================================

VISIBILITY_MODE="single"    # single | all | custom
SELECTED_WORKSPACES=(0 2 4)

# =====================================================
#              INTERNAL FUNCTIONS
# =====================================================

get_cava_window() {
  xdotool search --name "$TERMINAL_TITLE" 2>/dev/null | tail -n 1
}

is_cava_running() {
  pgrep -f "cava" >/dev/null
}

get_monitor_geometry() {
  mapfile -t MONITORS < <(xrandr --query | awk '/ connected/{print $1}')
  PRIMARY=$(xrandr --query | awk '/ primary/{print $1}')

  case "$TARGET_MONITOR" in
    primary) MONITOR="$PRIMARY" ;;
    left)    MONITOR="${MONITORS[0]}" ;;
    right)   MONITOR="${MONITORS[1]:-${MONITORS[0]}}" ;;
    *)       MONITOR="$TARGET_MONITOR" ;;
  esac

  GEOMETRY=$(xrandr --query | grep -A1 "^$MONITOR " \
            | grep -oP '\d+x\d+\+\d+\+\d+' | head -n1)

  MON_WIDTH=${GEOMETRY%%x*}
  MON_HEIGHT=$(echo "$GEOMETRY" | cut -d'x' -f2 | cut -d'+' -f1)
  MON_X=$(echo "$GEOMETRY" | cut -d'+' -f2)
  MON_Y=$(echo "$GEOMETRY" | cut -d'+' -f3)
}

calculate_position() {
  case "$POSITION" in
    center)
      X=$((MON_X + (MON_WIDTH - WIDTH) / 2))
      Y=$((MON_Y + (MON_HEIGHT - HEIGHT) / 2))
      ;;
    top)
      X=$((MON_X + (MON_WIDTH - WIDTH) / 2))
      Y=$MON_Y
      ;;
    bottom)
      X=$((MON_X + (MON_WIDTH - WIDTH) / 2))
      Y=$((MON_Y + MON_HEIGHT - HEIGHT))
      ;;
    left)
      X=$MON_X
      Y=$((MON_Y + (MON_HEIGHT - HEIGHT) / 2))
      ;;
    right)
      X=$((MON_X + MON_WIDTH - WIDTH))
      Y=$((MON_Y + (MON_HEIGHT - HEIGHT) / 2))
      ;;
    custom)
      X=$CUSTOM_X
      Y=$CUSTOM_Y
      ;;
    *)
      X=$((MON_X + (MON_WIDTH - WIDTH) / 2))
      Y=$((MON_Y + (MON_HEIGHT - HEIGHT) / 2))
      ;;
  esac
}

launch_cava() {
  [[ ! -f "$CAVA_CONFIG_PATH" ]] && {
    echo "❌ CAVA config not found: $CAVA_CONFIG_PATH"
    exit 1
  }

  echo "🚀 Launching CAVA"

  gnome-terminal \
    --window-with-profile="$PROFILE" \
    --title="$TERMINAL_TITLE" \
    -- bash -c "cava -p \"$CAVA_CONFIG_PATH\"; exec bash" &

  sleep "$DELAY"

  WIN_ID=$(get_cava_window)
  [[ -z "$WIN_ID" ]] && exit 1

  wmctrl -ir "$WIN_ID" -b remove,maximized_vert,maximized_horz
  wmctrl -ir "$WIN_ID" -b add,below,skip_taskbar,skip_pager
  wmctrl -ir "$WIN_ID" -t "$WORKSPACE"

  calculate_position
  wmctrl -ir "$WIN_ID" -e 0,$X,$Y,$WIDTH,$HEIGHT

  xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a \
        -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DESKTOP"

  case "$VISIBILITY_MODE" in
    all)
      wmctrl -ir "$WIN_ID" -b add,sticky
      ;;
    custom)
      wmctrl -ir "$WIN_ID" -b remove,sticky
      for ws in "${SELECTED_WORKSPACES[@]}"; do
        wmctrl -ir "$WIN_ID" -t "$ws"
      done
      ;;
    *)
      wmctrl -ir "$WIN_ID" -b remove,sticky
      wmctrl -ir "$WIN_ID" -t "$WORKSPACE"
      ;;
  esac

  xdotool windowlower "$WIN_ID"
}

close_cava() {
  echo "🧹 Closing CAVA"
  pkill -f "cava"
  sleep 0.3
  for win in $(xdotool search --name "$TERMINAL_TITLE" 2>/dev/null); do
    wmctrl -ic "$win"
  done
}

# =====================================================
#                    MAIN
# =====================================================

get_monitor_geometry

case "$RERUN_ACTION" in
  close)
    close_cava
    ;;
  launch)
    launch_cava
    ;;
  toggle|*)
    if is_cava_running; then
      close_cava
    else
      launch_cava
    fi
    ;;
esac

