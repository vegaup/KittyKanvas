#!/bin/bash

# Base URL
BASE_URL="https://raw.githubusercontent.com/vegaup/KittyKanvas/refs/heads/main/assets/cat"

# Store temp files
TEMP_DIR="/tmp/kittykanvas"
mkdir -p "$TEMP_DIR"

# Checks if it returns a 200
check_url() {
    local url="$1"
    if curl --output /dev/null --silent --head --fail "$url"; then
        return 0
    else
        return 1
    fi
}

# Clear previous findings
rm -f "$TEMP_DIR/valid_urls.txt"

# Find all available images
echo "Discovering available cat images..."
counter=1
valid_count=0

while true; do
    current_url="${BASE_URL}${counter}.png"
    
    if check_url "$current_url"; then
        echo "$current_url" >> "$TEMP_DIR/valid_urls.txt"
        echo "Found cat${counter}.png"
        ((valid_count++))
    else
        # If we hit 3 consecutive failures, assume we've found all images
        if [ "$counter" -gt 3 ]; then
            break
        fi
    fi
    ((counter++))
done

echo "Found $valid_count cat images!"

# Randomly select URL for wallpaper
random_url=$(shuf -n 1 "$TEMP_DIR/valid_urls.txt")

# Download the random kitty
wget -q "$random_url" -O "$TEMP_DIR/current_wallpaper.png"

# GNOME
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.background picture-uri "file://$TEMP_DIR/current_wallpaper.png"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$TEMP_DIR/current_wallpaper.png"
# KDE Plasma
elif command -v plasma-apply-wallpaperimage &> /dev/null; then
    plasma-apply-wallpaperimage "$TEMP_DIR/current_wallpaper.png"
fi

echo "Wallpaper set successfully!"