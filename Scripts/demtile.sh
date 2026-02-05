#!/bin/bash

# ================= HELP SECTION (ADDED) =================
function show_help {
	echo "Demitile Window Positioning Script"
	echo ""
	echo "Description:"
	echo "  Dynamically resizes and positions the active window"
	echo "  based on mouse pointer location on the screen."
	echo ""
	echo "Usage:"
	echo "  $0"
	echo ""
	echo "How It Works:"
	echo "  Move your mouse pointer to a region of the screen and run the script."
	echo "  The window will resize depending on pointer position."
	echo ""
	echo "Mouse Zones:"
	echo "  Left side    → Tile window left"
	echo "  Right side   → Tile window right"
	echo "  Top          → Upper tiling"
	echo "  Bottom       → Lower tiling"
	echo "  Center       → Centered layout"
	echo ""
	echo "Repeated execution toggles window sizes:"
	echo "  Half → Quarter → Three-Quarter → Full"
	echo ""
	echo "Requirements:"
	echo "  xdotool, wmctrl, xprop, xwininfo"
	echo ""
	echo "Help:"
	echo "  help, -h, --help   Show this message"
	echo ""
}
# ========================================================

# ----------- HELP TRIGGER (ADDED) -----------
if [[ "$1" == "help" || "$1" == "-h" || "$1" == "--help" ]]; then
	show_help
	exit 0
fi
# -------------------------------------------


# MIT License
# 
# Copyright (c) 2021 David Yockey
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This script is dedicated to everyone's favorite assistants, Trial and Error,
# without whom its development would not have been possible. :)

# General Purpose Null Value
NUL=0

# Window Gravity Constant (see https://specifications.freedesktop.org/wm-spec/wm-spec-1.3.html#idm45850117550944)
NORTH_WEST_GRAVITY=1

# DEMITILE_XPOS Constants (not X or Y indices for refering to a partition containing the mouse pointer)
LFT=1
CTR=2	# Centered in Work Area
RGT=3
CTB=4	# Centered at Top or Bottom

# Get current mouse pointer screen position
# -- Needs to be early in the script to get an accurate position of the mouse as intended by the user
eval $(xdotool getmouselocation --shell)
mouseX=$X
mouseY=$Y

# Load presistant variables
varfile=$HOME/.demitile_vars
DEMITILE_WIN=0
DEMITILE_XPOS=$NUL	# 1=Centered, 2=Left, 3=Right
DEMITILE_YPOS=$NUL
DEMITILE_MODE=$NUL	# 1=Half, 2=One-Fourth, 3=Three-Fourths, 4=Full
if [ -e $varfile ]
	then
		exec 3<$varfile
		read -u3 DEMITILE_WIN DEMITILE_XPOS DEMITILE_YPOS DEMITILE_MODE
		exec 3<&-
fi

# Save presistant variables
function save_vars()
{
	DEMITILE_WIN=$ActiveWindow
	DEMITILE_XPOS=$1
	DEMITILE_YPOS=$2
	DEMITILE_MODE=$3
	echo -e "$DEMITILE_WIN $DEMITILE_XPOS $DEMITILE_YPOS $DEMITILE_MODE" > $varfile
}

function sizeX_HalfX()
{
	sizeX=$HalfX
	if [ $Yp -eq 1 ]
		then 
			DEMITILE_MODE="1"
		else
			# Prime for sizeX=$HalfX upon switch to $Ypart -eq 1 tile
			DEMITILE_MODE="3"
	fi
}

function increment_DEMITILE_MODE()
{
	DEMITILE_MODE=$((DEMITILE_MODE + 1))
	if [ $DEMITILE_MODE -eq "4" ]
		then
			DEMITILE_MODE="1"
	fi
}

# Get the upper-left position, height, and width of the current
# desktop's workarea (i.e. desktop geometry excluding area of panels)
waGeometry=$(wmctrl -d | sed -n 's/^.*\*.*WA: \(.*\)  Workspace.*$/\1/p')

# Bash string manipulations to seperate out the pertinent values
# (ref - https://tldp.org/LDP/abs/html/string-manipulation.html)
waX=$(expr match "$waGeometry" '\(^[0-9][0-9]*\)')
waY=$(expr match "$waGeometry" '.*,\([0-9][0-9]*\)')
waW=$(expr match "$waGeometry" '.* \([0-9][0-9]*\)')
waH=$(expr match "$waGeometry" '.*x\([0-9][0-9]*\)')

# Get active window and make sure it's `Normal` before proceding
ActiveWindow=$(xdotool getactivewindow)

# Unmaximize if maximized
wmctrl -i -r $ActiveWindow -b remove,maximized_vert,maximized_horz

WinType=$(xwininfo -wm -id $(xdotool getactivewindow) | sed -n '/Window type/{n
s/^.*\(Normal\)$/\1/p
}')
if [ "$WinType" != "Normal" ]
	then
		exit 1
fi

# Window Position Values based on Workarea Geometry
MinX=$waX
MidX=$((waW/2))

ModX=0
if [ $((waW%2)) -eq 1 ]
	then
		ModX=1
fi

MinY=$waY
MidY=$((waH/2))

ModY=0
if [ $((waH%2)) -eq 1 ]
	then
		ModY=1
fi

extents=$(xprop -id $ActiveWindow | sed -n 's/^_NET_FRAME_EXTENTS(CARDINAL) = \(.*\)$/\1/p')
if [ "$extents" != "" ]
	then
		nlb=$(echo $extents | cut -d ',' -f1)
		nrb=$(echo $extents | cut -d ',' -f2)
		ntb=$(echo $extents | cut -d ',' -f3)
		nbb=$(echo $extents | cut -d ',' -f4)
	else
		nlb=0
		nrb=0
		ntb=0
		nbb=0
fi

extents=$(xprop -id $ActiveWindow | sed -n 's/^_GTK_FRAME_EXTENTS(CARDINAL) = \(.*\)$/\1/p')
if [ "$extents" != "" ]
	then
		glb=$(echo $extents | cut -d ',' -f1)
		grb=$(echo $extents | cut -d ',' -f2)
		gtb=$(echo $extents | cut -d ',' -f3)
		gbb=$(echo $extents | cut -d ',' -f4)
	else
		glb=0
		grb=0
		gtb=0
		gbb=0
fi

thirdW=$((waW/3))
thirdH=$((waH/3))

xborders=$((-nlb-nrb+glb+grb))
HalfX=$((MidX+$xborders+ModX))
QtrX=$(((MidX/2)+$xborders+ModX))
TriQtrX=$((MidX+(MidX/2)+$xborders+ModX))
MaxX=$((waW+$xborders))

yborders=$((-ntb-nbb+gtb+gbb))
HalfY=$((MidY+yborders+ModY))
MaxY=$((waH+yborders))

Xpart=$(((mouseX-MinX)/thirdW))
Ypart=$(((mouseY-MinY)/thirdH))

posX=0
posY=0
sizeX=0
sizeY=0

Yp=1

if [ $Xpart -eq 0 ]
	then
		posX=$((MinX-glb))
		if [ $Yp -ne 1 -o $DEMITILE_WIN != $ActiveWindow -o $DEMITILE_XPOS != $LFT -o $Ypart != $DEMITILE_YPOS ]
			then
				sizeX_HalfX
			else
				increment_DEMITILE_MODE
				case "$DEMITILE_MODE" in
					1) sizeX=$HalfX ;;
					2) sizeX=$QtrX ;;
					3) sizeX=$TriQtrX ;;
				esac
		fi
		DEMITILE_XPOS=$LFT
	elif [ $Xpart -eq 1 ]
		then
			posX=$((MinX-glb))
			eval $(xdotool getwindowgeometry --shell $ActiveWindow)
			if [ $Yp -eq 4 -o $DEMITILE_WIN != $ActiveWindow -o $DEMITILE_XPOS != $CTB -o $Ypart != $DEMITILE_YPOS -o $DEMITILE_MODE != 4 ]
				then
					sizeX=$MaxX
					DEMITILE_MODE=4
				else
					sizeX=$HalfX
					posX=$((posX + (MidX/2)))
					DEMITILE_MODE=2
			fi
			if [ $Ypart -ne 1 ]
				then
					DEMITILE_XPOS=$CTB
			fi
	else
		posX=$((MidX + waX - glb))
		if [ $Yp -ne 1 -o $DEMITILE_WIN != $ActiveWindow -o $DEMITILE_XPOS != $RGT -o $Ypart != $DEMITILE_YPOS ]
			then
				sizeX_HalfX
			else
				increment_DEMITILE_MODE
				case "$DEMITILE_MODE" in
					1) sizeX=$HalfX ;;
					2)
						posX=$((posX + (MidX/2)))
						sizeX=$QtrX ;;
					3)
						posX=$((posX - (MidX/2)))
						sizeX=$TriQtrX ;;
				esac
		fi
		DEMITILE_XPOS=$RGT
fi
DEMITILE_YPOS=$Ypart

if [ $Ypart -eq 0 ]
	then
		posY=$((MinY-gtb))
		sizeY=$HalfY
	elif [ $Ypart -eq 1 ]
		then
			posY=$((MinY-gtb))
			sizeY=$MaxY
	else
		posY=$((MidY + waY - gtb))
		sizeY=$HalfY
fi

if [ $Xpart -eq 1 -a $Ypart -eq 1 ]
	then
		sizeX=$HalfX
		sizeY=$MaxY
		posX=$(( MidX - nlb - ($sizeX / 2) + MinX ))
		posY=$(( MidY - ntb - ($sizeY / 2) + MinY ))
		wmctrl -i -r $ActiveWindow -e $NORTH_WEST_GRAVITY,$posX,$posY,$sizeX,$sizeY
		sleep 0.25
		wmctrl -i -r $ActiveWindow -e $NORTH_WEST_GRAVITY,-1,-1,$sizeX,$sizeY
		save_vars $CTR $NUL $DEMITILE_MODE
	else
		wmctrl -i -r $ActiveWindow -e $NORTH_WEST_GRAVITY,$posX,$posY,$sizeX,$sizeY
		sleep 0.25
		wmctrl -i -r $ActiveWindow -e $NORTH_WEST_GRAVITY,-1,-1,$sizeX,$sizeY
		save_vars $DEMITILE_XPOS $DEMITILE_YPOS $DEMITILE_MODE
fi
