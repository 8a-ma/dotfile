#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMBNAIL_DIR="$HOME/.cache/wallpaper-thumbs"
ROFI_FONT="Monospace 10"
THUMB_SIZE=120

# Crear carpetas si no existe
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$THUMBNAIL_DIR"

# Generar miniaturas solo si faltan
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,gif,webp}; do
    [ -f "$img" ] || continue
    base=$(basename "$img")
    thumb="$THUMBNAIL_DIR/${base%.*}.png"
    
    if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
        convert -resize "${THUMB_SIZE}x${THUMB_SIZE}>" "$img" "$thumb" 2>/dev/null || \
        magick -resize "${THUMB_SIZE}x${THUMB_SIZE}>" "$img" "$thumb" 2>/dev/null
    fi
done

# Crear lista para rofi con miniaturas
mapfile -t images < <(ls "$WALLPAPER_DIR"/*.{jpg,jpeg,png,gif,webp} 2>/dev/null)
list=""
for img in "${images[@]}"; do
    [ -f "$img" ] || continue
    base=$(basename "$img")
    thumb="$THUMBNAIL_DIR/${base%.*}.png"
    
    list+="$base\x00icon\x1f$thumb\n"
done

# Mostrar en Rofi con miniaturas
selected=$(echo -ne "$list" | rofi -dmenu -p "Wallpaper" \
    -i \
    -font "$ROFI_FONT" \
    -width 40 \
    -show-icons)

[ -z "$selected" ] && exit 0

# Aplicar wallpaper con feh
wallpaper="$WALLPAPER_DIR/$selected"

if [ -f "$wallpaper" ]; then
    feh --bg-fill "$wallpaper"
else
    echo "Error: file not found ($wallpaper)"
fi