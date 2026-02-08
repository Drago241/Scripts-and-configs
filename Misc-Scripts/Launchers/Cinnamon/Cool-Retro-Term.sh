#!/bin/bash

# =====================================================
#        COOL RETRO TERM DESKTOP-DOCK SCRIPT
# =====================================================

CRT_PROFILE="IBM 3278"
LAUNCH_CMD="cmatrix"              # leave empty for shell
TERMINAL_TITLE="RetroDock"

DELAY=1.2

# --- SIZE SETTINGS ---
SIZE_MODE="auto"                 # auto, custom
WIDTH=1366                       # used when SIZE_MODE="custom"
HEIGHT=732                       # used when SIZE_MODE="custom"

POSITION="bottom"              # center, top, bottom, left, right, custom
CUSTOM_X=200
CUSTOM_Y=300

WORKSPACE=0
TARGET_MONITOR="primary"       # primary, left, right, HDMI-1, DP-1, etc.

# --- VISIBILITY SETTINGS ---
VISIBILITY_MODE="single"       # single, all, custom
SELECTED_WORKSPACES=(0 2 4)    # used when VISIBILITY_MODE="custom"

# =====================================================

# --- Get window ID ---
get_crt_window() {
    xdotool search --name "$TERMINAL_TITLE" | tail -n1
}

# --- Detect monitor geometry ---
get_monitor_geometry() {
    MONITORS=($(xrandr --query | grep " connected" | awk '{print $1}'))
    PRIMARY=$(xrandr --query | grep " primary" | awk '{print $1}')

    case "$TARGET_MONITOR" in
        primary) MONITOR="$PRIMARY" ;;
        left) MONITOR="${MONITORS[0]}" ;;
        right) MONITOR="${MONITORS[1]}" ;;
        *) MONITOR="$TARGET_MONITOR" ;;
    esac

    GEOMETRY=$(xrandr --query | grep -A1 "^$MONITOR" | grep -oP '\d+x\d+\+\d+\+\d+' | head -n1)

    MON_WIDTH=$(echo "$GEOMETRY" | cut -d'x' -f1)
    MON_HEIGHT=$(echo "$GEOMETRY" | cut -d'x' -f2 | cut -d'+' -f1)
    MON_X=$(echo "$GEOMETRY" | cut -d'+' -f2)
    MON_Y=$(echo "$GEOMETRY" | cut -d'+' -f3)

    # --- Apply size mode ---
    if [[ "$SIZE_MODE" == "auto" ]]; then
        WIDTH=$MON_WIDTH
        HEIGHT=$MON_HEIGHT
    fi
}

# --- Calculate position ---
calculate_position() {
    case "$POSITION" in
        center) X=$((MON_X + (MON_WIDTH - WIDTH) / 2))
                Y=$((MON_Y + (MON_HEIGHT - HEIGHT) / 2)) ;;
        top)    X=$((MON_X + (MON_WIDTH - WIDTH) / 2))
                Y=$MON_Y ;;
        bottom) X=$((MON_X + (MON_WIDTH - WIDTH) / 2))
                Y=$((MON_Y + MON_HEIGHT - HEIGHT)) ;;
        left)   X=$MON_X
                Y=$((MON_Y + (MON_HEIGHT - HEIGHT) / 2)) ;;
        right)  X=$((MON_X + MON_WIDTH - WIDTH))
                Y=$((MON_Y + (MON_HEIGHT - HEIGHT) / 2)) ;;
        custom) X=$CUSTOM_X; Y=$CUSTOM_Y ;;
        *)      X=$((MON_X + (MON_WIDTH - WIDTH) / 2))
                Y=$((MON_Y + (MON_HEIGHT - HEIGHT) / 2)) ;;
    esac
}

# --- Launch dock terminal ---
launch_dock_terminal() {
    echo "🚀 Launching RetroDock on '$MONITOR'..."

    if [[ -z "$LAUNCH_CMD" ]]; then
        cool-retro-term --profile "$CRT_PROFILE" --title "$TERMINAL_TITLE" &
    else
        cool-retro-term --profile "$CRT_PROFILE" --title "$TERMINAL_TITLE" \
            -e bash -c "$LAUNCH_CMD" &
    fi

    sleep $DELAY
    WIN_ID=$(get_crt_window)
    [[ -z "$WIN_ID" ]] && echo "❌ No window detected" && exit 1

    wmctrl -ir "$WIN_ID" -b remove,maximized_vert,maximized_horz
    wmctrl -ir "$WIN_ID" -t $WORKSPACE

    calculate_position
    wmctrl -ir "$WIN_ID" -e 0,$X,$Y,$WIDTH,$HEIGHT

    # ---- DESKTOP window type (below windows, above desktop) ----
    xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a \
          -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DESKTOP"

    # ---- Passthrough / click-through ----
    xprop -id "$WIN_ID" -remove _NET_WM_INPUT
    xprop -id "$WIN_ID" -f _NET_WM_SHAPE_INPUT 32c -set _NET_WM_SHAPE_INPUT 0

    # ---- Layering hints ----
    wmctrl -ir "$WIN_ID" -b add,skip_taskbar,skip_pager,below

    # ---- Workspace visibility ----
    case "$VISIBILITY_MODE" in
        all)
            wmctrl -ir "$WIN_ID" -b add,sticky
            echo "🌍 Visible on all workspaces." ;;
        custom)
            wmctrl -ir "$WIN_ID" -b remove,sticky
            echo "🎯 Visible on selected workspaces: ${SELECTED_WORKSPACES[*]}"
            for ws in "${SELECTED_WORKSPACES[@]}"; do
                wmctrl -ir "$WIN_ID" -t "$ws"
            done ;;
        single|*)
            wmctrl -ir "$WIN_ID" -b remove,sticky
            wmctrl -ir "$WIN_ID" -t $WORKSPACE
            echo "🖥️ Visible only on workspace $WORKSPACE." ;;
    esac

    echo "✨ RetroDock positioned below windows and above desktop."
}

# --- Close dock terminal ---
close_dock_terminal() {
    echo "🧹 Closing RetroDock..."
    for win in $(xdotool search --name "$TERMINAL_TITLE" 2>/dev/null); do
        wmctrl -ic "$win"
    done
    pkill -f "$LAUNCH_CMD"
}

is_running() {
    xdotool search --name "$TERMINAL_TITLE" >/dev/null 2>&1
}

# --- MAIN TOGGLE ---
get_monitor_geometry
if is_running; then
    close_dock_terminal
else
    launch_dock_terminal
fi

