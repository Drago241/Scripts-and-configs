#!/bin/bash

# =====================================================
#              USER CONFIGURATIONS
# =====================================================

PROFILE="CMATRIX"             # GNOME Terminal profile
DELAY=1.0                     # Time for terminal to spawn
WIDTH=1400                    # Window width (ignored if FULLSCREEN=1)
HEIGHT=768                   # Window height (ignored if FULLSCREEN=1)
WORKSPACE=0                   # Default workspace (0 = first)
POSITION="center"         # center, top, bottom, left, right, custom, fullscreen
CUSTOM_X=0                    # Only used when POSITION="custom"
CUSTOM_Y=0
TERMINAL_TITLE="CMATRIX"   # Used to identify the terminal window
TARGET_MONITOR="primary"      # primary, left, right, or specific name (HDMI-1, DP-1)

FULLSCREEN=0                  # 1 = full screen; 0 = manual W×H

# --- VISIBILITY SETTINGS ---
# Modes:
#   "single"   → only on workspace WORKSPACE
#   "all"      → appears on all workspaces
#   "custom"   → only on selected workspaces
VISIBILITY_MODE="single"

SELECTED_WORKSPACES=(0 2 4)   # Used only when VISIBILITY_MODE="custom"

# =====================================================
#               INTERNAL FUNCTIONS
# =====================================================

# --- Get window ID of CMATRIX terminal ---
get_cmatrix_window() {
  xdotool search --name "$TERMINAL_TITLE" | tail -n 1
}

# --- Detect monitor geometry ---
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

# --- Calculate final window position ---
calculate_position() {
  case "$POSITION" in
    "fullscreen")
      X=$MON_X
      Y=$MON_Y
      WIDTH=$MON_WIDTH
      HEIGHT=$MON_HEIGHT
      ;;
    "center")
      X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
      Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 ))
      ;;
    "top")
      X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
      Y=$MON_Y
      ;;
    "bottom")
      X=$(( MON_X + (MON_WIDTH - WIDTH) / 2 ))
      Y=$(( MON_Y + MON_HEIGHT - HEIGHT ))
      ;;
    "left")
      X=$MON_X
      Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 ))
      ;;
    "right")
      X=$(( MON_X + MON_WIDTH - WIDTH ))
      Y=$(( MON_Y + (MON_HEIGHT - HEIGHT) / 2 ))
      ;;
    "custom")
      X=$CUSTOM_X
      Y=$CUSTOM_Y
      ;;
    *)
      echo "⚠️ Unknown POSITION '$POSITION'. Defaulting to fullscreen."
      X=$MON_X
      Y=$MON_Y
      WIDTH=$MON_WIDTH
      HEIGHT=$MON_HEIGHT
      ;;
  esac
}

# --- Launch CMATRIX desktop window ---
launch_cmatrix() {
  echo "🚀 Launching CMATRIX desktop background on '$MONITOR'..."
  
  gnome-terminal \
    --window-with-profile="$PROFILE" \
    --title="$TERMINAL_TITLE" \
    -- bash -c "cmatrix; exec bash" &

  sleep $DELAY

  WIN_ID=$(get_cmatrix_window)
  if [[ -z "$WIN_ID" ]]; then
    echo "❌ Could not detect CMATRIX window."
    exit 1
  fi

  # Move to workspace
  wmctrl -ir "$WIN_ID" -t $WORKSPACE

  # Remove decorations
  wmctrl -ir "$WIN_ID" -b add,undecorated

  # Calculate position/geometry
  calculate_position
  wmctrl -ir "$WIN_ID" -e 0,$X,$Y,$WIDTH,$HEIGHT

  # Desktop window type → becomes wallpaper-like
  xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a \
        -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DOCK"

  # Always behind everything
  wmctrl -ir "$WIN_ID" -b add,below
  xdotool windowlower "$WIN_ID"

  # Make uninteractive (passthrough)
  xprop -id "$WIN_ID" -remove _NET_WM_INPUT
  xprop -id "$WIN_ID" -f _NET_WM_SHAPE_INPUT 32c -set _NET_WM_SHAPE_INPUT 0

  # Apply workspace visibility mode
  case "$VISIBILITY_MODE" in
    "all")
      wmctrl -ir "$WIN_ID" -b add,sticky
      ;;
    "custom")
      wmctrl -ir "$WIN_ID" -b remove,sticky
      for ws in "${SELECTED_WORKSPACES[@]}"; do
        wmctrl -ir "$WIN_ID" -t $ws
      done
      ;;
    "single" | *)
      wmctrl -ir "$WIN_ID" -b remove,sticky
      wmctrl -ir "$WIN_ID" -t $WORKSPACE
      ;;
  esac

  echo "✅ CMATRIX running as desktop background."
}

# --- Close CMATRIX ---
close_cmatrix() {
  echo "🧹 Closing CMATRIX background..."
  pkill -f "cmatrix"
  sleep 0.3
  for win in $(xdotool search --name "$TERMINAL_TITLE" 2>/dev/null); do
    wmctrl -ic "$win"
  done
  echo "✅ CMATRIX closed."
}

# --- Check if CMATRIX is running ---
is_cmatrix_running() {
  pgrep -f "cmatrix" >/dev/null 2>&1
}

# =====================================================
#                       MAIN
# =====================================================

get_monitor_geometry

if is_cmatrix_running; then
  close_cmatrix
else
  launch_cmatrix
fi

