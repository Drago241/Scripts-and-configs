#!/bin/bash

# =====================================================
#                 USER CONFIGURATIONS
# =====================================================

PROFILE="CMATRIX"          # GNOME Terminal profile name
DELAY=1.0                     # Time (seconds) to let terminal spawn
WIDTH=1400                    # Window width
HEIGHT=768                    # Window height
WORKSPACE=0                   # Default workspace (0 = first)
POSITION="center"             # center, top, bottom, left, right, custom
CUSTOM_X=-104                 # Used only if POSITION="custom"
CUSTOM_Y=338
TERMINAL_TITLE="cmatrix"     # Window name to identify terminal
TARGET_MONITOR="primary"      # primary, left, right, or a monitor name

# --- VISIBILITY SETTINGS ---
VISIBILITY_MODE="single"      # single, all, custom
SELECTED_WORKSPACES=(0 2 4)   # Only used when VISIBILITY_MODE="custom"

# =====================================================


# --- FUNCTION: Get window ID ---
get_dock_window() {
  xdotool search --name "$TERMINAL_TITLE" | tail -n 1
}

# --- FUNCTION: Detect monitor geometry ---
get_monitor_geometry() {
  MONITORS=($(xrandr --query | grep " connected" | awk '{print $1}'))
  PRIMARY=$(xrandr --query | grep " primary" | awk '{print $1}')

  if [[ "$TARGET_MONITOR" == "primary" ]]; then
    MONITOR="$PRIMARY"
  elif [[ "$TARGET_MONITOR" == "left" ]]; then
    MONITOR="${MONITORS[0]}"
  elif [[ "$TARGET_MONITOR" == "right" && ${#MONITORS[@]} -gt 1 ]]; then
    MONITOR="${MONITORS[1]}"
  else
    MONITOR="$TARGET_MONITOR"
  fi

  GEOMETRY=$(xrandr --query | grep -A1 "^$MONITOR " | grep -oP '\d+x\d+\+\d+\+\d+' | head -n1)
  MON_WIDTH=$(echo "$GEOMETRY" | cut -d'x' -f1)
  MON_HEIGHT=$(echo "$GEOMETRY" | cut -d'x' -f2 | cut -d'+' -f1)
  MON_X=$(echo "$GEOMETRY" | cut -d'+' -f2)
  MON_Y=$(echo "$GEOMETRY" | cut -d'+' -f3)
}

# --- FUNCTION: Calculate window position ---
calculate_position() {
  case "$POSITION" in
    "center") X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
              Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 )) ;;
    "top")    X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
              Y=$MON_Y ;;
    "bottom") X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
              Y=$(( MON_Y + MON_HEIGHT - HEIGHT )) ;;
    "left")   X=$MON_X
              Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 )) ;;
    "right")  X=$(( MON_X + MON_WIDTH - WIDTH ))
              Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 )) ;;
    "custom") X=$CUSTOM_X; Y=$CUSTOM_Y ;;
    *) echo "⚠️ Invalid POSITION. Defaulting to center."
       X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
       Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 )) ;;
  esac
}

# --- FUNCTION: Launch the dock terminal ---
launch_dock_terminal() {
  echo "🚀 Launching dock terminal on '$MONITOR'..."

  gnome-terminal \
    --window-with-profile="$PROFILE" \
    --title="$TERMINAL_TITLE" &

  sleep $DELAY
  WIN_ID=$(get_dock_window)

  if [[ -z "$WIN_ID" ]]; then
    echo "❌ Terminal window not detected. Exiting."
    exit 1
  fi

  wmctrl -ir "$WIN_ID" -t $WORKSPACE
  wmctrl -ir "$WIN_ID" -b add,below,skip_taskbar,skip_pager

  calculate_position
  wmctrl -ir "$WIN_ID" -e 0,$X,$Y,$WIDTH,$HEIGHT

  # --- MAKE IT A DOCK WINDOW ---
  xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a \
        -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DOCK"

  # --- PASSTHROUGH: disable input ---
  xprop -id "$WIN_ID" -remove _NET_WM_INPUT
  xprop -id "$WIN_ID" -f _NET_WM_SHAPE_INPUT 32c \
        -set _NET_WM_SHAPE_INPUT 0

  # --- VISIBILITY CONTROL ---
  case "$VISIBILITY_MODE" in
    "all") wmctrl -ir "$WIN_ID" -b add,sticky ;;
    "custom")
      wmctrl -ir "$WIN_ID" -b remove,sticky
      for ws in "${SELECTED_WORKSPACES[@]}"; do wmctrl -ir "$WIN_ID" -t $ws; done
      ;;
    *) wmctrl -ir "$WIN_ID" -b remove,sticky
       wmctrl -ir "$WIN_ID" -t $WORKSPACE ;;
  esac

  xdotool windowlower "$WIN_ID"
  echo "✅ Dock terminal placed at $POSITION on $MONITOR."
}

# --- FUNCTION: Close the dock terminal ---
close_dock_terminal() {
  echo "🧹 Closing dock terminal..."
  for win in $(xdotool search --name "$TERMINAL_TITLE" 2>/dev/null); do
    wmctrl -ic "$win"
  done
  echo "✅ Dock terminal closed."
}

# --- FUNCTION: Check if running ---
is_dock_terminal_running() {
  xdotool search --name "$TERMINAL_TITLE" >/dev/null 2>&1
}

# --- MAIN ---
get_monitor_geometry

if is_dock_terminal_running; then
  close_dock_terminal
else
  launch_dock_terminal
fi

