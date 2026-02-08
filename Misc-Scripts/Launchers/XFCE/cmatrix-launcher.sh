#!/usr/bin/env bash

#
# 🖥 Universal Desktop Terminal Widget
#

# =====================================================
# HANDLE HELP FLAG
# =====================================================
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
cat << EOF
🖥 Universal Desktop Terminal Widget
EOF
exit 0
fi

echo "🖥 Universal Desktop Terminal Widget"

# =====================================================
# CONFIGURATION
# =====================================================
KITTY_APPIMAGE="/home/Muhammad-Abdullah/Desktop/kitty-0.14.3-x86_64.AppImage"
RUN_COMMAND="cmatrix"

DELAY=1.0

WIDTH=1500
HEIGHT=1500

POSITION="center"
CUSTOM_X=0
CUSTOM_Y=325

TARGET_MONITOR="primary"

WORKSPACE=0
VISIBILITY_MODE="single"
SELECTED_WORKSPACES=(0 2 4)

RERUN_ACTION="toggle"
CLICK_THROUGH=true

PID_FILE="/tmp/desktop_embed_launcher.pid"

# =====================================================
# DEPENDENCY CHECK
# =====================================================
for cmd in xdotool wmctrl xprop xrandr; do
command -v "$cmd" >/dev/null || { echo "❌ Missing dependency: $cmd"; exit 1; }
done

# =====================================================
# INSTANCE MANAGEMENT
# =====================================================
is_running() {
[[ -f "$PID_FILE" ]]
}

close_instance() {
[[ -f "$PID_FILE" ]] || { echo "No running instance"; return; }

WIN_ID=$(cat "$PID_FILE")

echo "🧹 Closing instance"
wmctrl -ic "$WIN_ID" 2>/dev/null
rm -f "$PID_FILE"
}

# =====================================================
# MONITOR GEOMETRY
# =====================================================
get_monitor_geometry() {

mapfile -t MONITORS < <(xrandr --query | awk '/ connected/{print $1}')
PRIMARY=$(xrandr --query | awk '/ primary/{print $1}')

case "$TARGET_MONITOR" in
primary) MONITOR="$PRIMARY" ;;
left) MONITOR="${MONITORS[0]}" ;;
right) MONITOR="${MONITORS[1]:-${MONITORS[0]}}" ;;
*) MONITOR="$TARGET_MONITOR" ;;
esac

GEOMETRY=$(xrandr --query | grep -A1 "^$MONITOR " \
| grep -oP '\d+x\d+\+\d+\+\d+' | head -n1)

MON_WIDTH=${GEOMETRY%%x*}
MON_HEIGHT=$(echo "$GEOMETRY" | cut -d'x' -f2 | cut -d'+' -f1)
MON_X=$(echo "$GEOMETRY" | cut -d'+' -f2)
MON_Y=$(echo "$GEOMETRY" | cut -d'+' -f3)

}

# =====================================================
# POSITION CALCULATION  (FIXED CENTERING)
# =====================================================
calculate_position() {

# XFCE / panel aware work area
read WA_X WA_Y WA_WIDTH WA_HEIGHT <<< \
$(xprop -root _NET_WORKAREA | awk -F' = |, ' '{print $2, $3, $4, $5}')

# Fallback if detection fails
if [[ -z "$WA_WIDTH" ]]; then
WA_X=$MON_X
WA_Y=$MON_Y
WA_WIDTH=$MON_WIDTH
WA_HEIGHT=$MON_HEIGHT
fi

case "$POSITION" in

center)
X=$((WA_X + (WA_WIDTH - WIDTH) / 2))
Y=$((WA_Y + (WA_HEIGHT - HEIGHT) / 2))
;;

top)
X=$((WA_X + (WA_WIDTH - WIDTH) / 2))
Y=$WA_Y
;;

bottom)
X=$((WA_X + (WA_WIDTH - WIDTH) / 2))
Y=$((WA_Y + WA_HEIGHT - HEIGHT))
;;

left)
X=$WA_X
Y=$((WA_Y + (WA_HEIGHT - HEIGHT) / 2))
;;

right)
X=$((WA_X + WA_WIDTH - WIDTH))
Y=$((WA_Y + (WA_HEIGHT - HEIGHT) / 2))
;;

custom|*)
X=$CUSTOM_X
Y=$CUSTOM_Y
;;

esac
}

# =====================================================
# CLICK THROUGH
# =====================================================
enable_click_through() {

local WIN_ID=$1
[[ "$CLICK_THROUGH" != true ]] && return

xdotool windowunmap "$WIN_ID"
xdotool windowmap "$WIN_ID"

xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a \
-set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DOCK"

wmctrl -ir "$WIN_ID" -b add,below,skip_taskbar,skip_pager

echo "✅ Click-through enabled"
}

# =====================================================
# WINDOW DETECTION
# =====================================================
get_kitty_window() {
xdotool search --class kitty 2>/dev/null | head -n 1
}

# =====================================================
# LAUNCH FUNCTION
# =====================================================
launch_instance() {

echo "🚀 Launching: $RUN_COMMAND"

"$KITTY_APPIMAGE" sh -c "$RUN_COMMAND" &

sleep "$DELAY"

WIN_ID=$(get_kitty_window)

[[ -z "$WIN_ID" ]] && { echo "❌ Could not detect window"; exit 1; }

echo "$WIN_ID" > "$PID_FILE"

wmctrl -ir "$WIN_ID" -b remove,maximized_vert,maximized_horz
wmctrl -ir "$WIN_ID" -b add,below,skip_taskbar,skip_pager
wmctrl -ir "$WIN_ID" -t "$WORKSPACE"

calculate_position

wmctrl -ir "$WIN_ID" -e 0,$X,$Y,$WIDTH,$HEIGHT

xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a \
-set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DOCK"

enable_click_through "$WIN_ID"

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

echo "✅ Widget running"
}

# =====================================================
# MAIN
# =====================================================
get_monitor_geometry

case "$RERUN_ACTION" in
close) close_instance ;;
launch) launch_instance ;;
toggle|*)
if is_running; then
close_instance
else
launch_instance
fi
;;
esac
