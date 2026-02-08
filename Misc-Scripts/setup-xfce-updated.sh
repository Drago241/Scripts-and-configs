#!/bin/bash

# -- Step 1: Disable repository restrictions
# Label: Disable repository restrictions
echo "Disabling repository restrictions..."
# Add # to the second line of /etc/apt/sources.list (disable restrictions)
#sudo sed -i '/^deb cdrom:/ s/^/#/' /etc/apt/sources.list
echo "Repository restrictions disabled."

# -- Step 2: Update apt repositories
# Label: Update apt repositories
echo "Updating apt repositories..."
sudo apt update

# -- Step 3: Install .deb files from specified directories
# Label: Install .deb files
DEB_DIRS=(
  "$HOME/Linux/Linux-Customization/Debs"
  "$HOME/Linux/Linux-Customization/Debs/Optional Debs/Mainly for XFCE"
)

for DEB_DIR in "${DEB_DIRS[@]}"; do
    echo "Installing .deb files from $DEB_DIR..."
    if [ -d "$DEB_DIR" ]; then
        DEB_FILES=("$DEB_DIR"/*.deb)
        
        # Check if the glob actually matched any files
        if [ -e "${DEB_FILES[0]}" ]; then
            sudo apt install -y "${DEB_FILES[@]}"
        else
            echo "No .deb files found in $DEB_DIR."
        fi
    else
        echo "Directory $DEB_DIR does not exist!"
    fi
done

# -- Step 4: Run BTOP install script from its own directory
echo "Installing btop..."

BTOP_DIR="$HOME/Linux/Linux-Customization/Debs/btop"
BTOP_SCRIPT="install.sh"

if [ -f "$BTOP_DIR/$BTOP_SCRIPT" ]; then
    pushd "$BTOP_DIR" > /dev/null
    chmod +x "$BTOP_SCRIPT"
    bash "$BTOP_SCRIPT"
    popd > /dev/null
else
    echo "BTOP install script not found in $BTOP_DIR"
fi

# -- Step 5: Install specific packages
# Label: Install packages: chafa, jp2a, imagemagick, cool-retro-term, lxappearance, diodon, rofi, cava, xdotool, mpv, wmctrl, ttf-mscorefonts-installer, polybar, cmatrix, eddy, webp-pixbuf-loader, ffmpeg, fzf, devilspie2
sudo apt install chafa -y
sudo apt install jp2a -y
sudo apt install imagemagick -y
sudo apt install cool-retro-term -y
sudo apt install lxappearance -y
sudo apt install diodon -y
sudo apt install rofi -y
#sudo apt install cava -y
sudo apt install xdotool -y
sudo apt install mpv -y
sudo apt install wmctrl -y
sudo apt install ttf-mscorefonts-installer -y
sudo apt install polybar -y
sudo apt install cmatrix -y
sudo apt install eddy -y
sudo apt install webp-pixbuf-loader -y
sudo apt install ffmpeg -y
sudo apt install fzf -y
sudo apt install devilspie2 -y
for pkg in chafa jp2a imagemagick cool-retro-term lxappearance diodon rofi cava xdotool mpv wmctrl ttf-mscorefonts-installer polybar cmatrix eddy webp-pixbuf-loader ffmpeg fzf devilspie2; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        sudo apt install "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

# -- Step 6: Install conky and conky-manager2
# Label: Install conky and conky-manager2
echo "Installing conky and conky-manager2..."

# Adding PPA for conky manager
if ! dpkg -l | grep -q "conky-manager2"; then
    sudo add-apt-repository -y ppa:teejee2008/foss
    sudo apt update -y
    sudo apt install -y conky-manager2
fi

# If conky-manager2 installation fails, use fallback .deb file
if ! dpkg -l | grep -q "conky-manager2"; then
    CONKY_DEB="$HOME/Linux/Linux-Customization/Debs/Optional Debs/conky-manager2_2.72_amd64.deb"
    if [ -f "$CONKY_DEB" ]; then
        sudo dpkg -i "$CONKY_DEB"
        sudo apt --fix-broken install -y
    else
        echo "Conky manager .deb file not found."
    fi
fi

# -- Step 7: Install conky dependencies 
# Label: Install packages: conky-all lua5.4 zenity jq python3 python3-tk libqt5widgets5 libqt5gui5 libqt5core5a qt5-gtk2-platformtheme playerctl liblua5.3-0 libcairo2 libcurl3t64-gnutls libdbus-glib-1-2 libfontconfig1 libglib2.0-0 libical3t64 libimlib2t64 libircclient1 libiw30t64 libncurses6 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpulse0 librsvg2-2 libx11-6 libxdamage1 libxext6 libxfixes3 libxft2 libxinerama1 libxml2 libwayland-client0
sudo apt install conky-all lua5.4 zenity jq python3 python3-tk libqt5widgets5 libqt5gui5 libqt5core5a qt5-gtk2-platformtheme playerctl liblua5.3-0 libcairo2 libcurl3t64-gnutls libdbus-glib-1-2 libfontconfig1 libglib2.0-0 libical3t64 libimlib2t64 libircclient1 libiw30t64 libncurses6 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpulse0 librsvg2-2 libx11-6 libxdamage1 libxext6 libxfixes3 libxft2 libxinerama1 libxml2 libwayland-client0 -y

# -- Step 8: Install oh-my-posh
# Label: Install oh-my-posh
echo "Installing oh-my-posh..."
if ! command -v oh-my-posh &> /dev/null; then
    curl -s https://ohmyposh.dev/install.sh | bash -s
else
    echo "oh-my-posh already installed. Skipping."
fi

# -- Step 9: File/folder copying
# Label: Copy required files and folders
echo "Copying files and folders..."
cp -r "$HOME/Linux/Linux-Customization/.fonts" $HOME
cp -r "$HOME/Linux/Linux-Customization/.conky" $HOME
cp -r "$HOME/Linux/Linux-Customization/Icons, Themes & Cursors/Cursors/.icons" $HOME
cp -r "$HOME/Linux/Linux-Customization/Icons, Themes & Cursors/Icons/icons" "$HOME/.local/share"
cp -r "$HOME/Linux/Linux-Customization/Icons, Themes & Cursors/Themes/themes" "$HOME/.local/share"
cp -r "$HOME/Linux/Linux-Customization/Oh-My-Posh/Custom-Themes" "$HOME/.cache/oh-my-posh/themes/"
cp -a "$HOME/Linux/Linux-Customization/Configs/." "$HOME/.config/"
cp -a "$HOME/Linux/Linux-Customization/applications/" "$HOME/.local/share/applications/"

# -- Step 10: Run additional Rofi files setup script
# Label: Run additional Rofi files setup script
echo "Running additional Rofi files setup script..."
ROFI_FILES_SETUP="$HOME/Linux/Linux-Customization/Configs/rofi/setup.sh"
if [ -f "$ROFI_FILES_SETUP" ]; then
    bash "$ROFI_FILES_SETUP"
else
    echo "Rofi files setup script not found at $ROFI_FILES_SETUP."
fi

# -- Step 11: Cleanup
# Label: Clean up unused packages
echo "Cleaning up unused packages..."
sudo apt autoremove -y
sudo apt clean

# Finished
echo "Script completed successfully!"

