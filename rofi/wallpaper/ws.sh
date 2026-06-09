#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMBNAIL_DIR="$HOME/.cache/wallpaper-thumbs"
THEME="$HOME/.config/rofi/wallpaper/ws.rasi"
THUMB_SIZE=200

# --- Crear carpetas si no existen
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$THUMBNAIL_DIR"

# --- Función para generar una miniatura
make_thumb() {
    local src="$1"
    local dst="$2"
    # Intenta convert (ImageMagick) primero, luego gm (GraphicsMagick)
    if command -v convert &>/dev/null; then
        convert -thumbnail "${THUMB_SIZE}x${THUMB_SIZE}^" \
                -gravity center -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
                "$src" "$dst" 2>/dev/null
    elif command -v gm &>/dev/null; then
        gm convert -thumbnail "${THUMB_SIZE}x${THUMB_SIZE}^" \
                   -gravity center -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
                   "$src" "$dst" 2>/dev/null
    else
        echo "Error: se necesita imagemagick o graphicsmagick para las miniaturas" >&2
        exit 1
    fi
}

# --- Generar miniaturas solo si faltan o el original es más nuevo
shopt -s nullglob
images=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,gif,webp})
shopt -u nullglob

if [ ${#images[@]} -eq 0 ]; then
    notify-send -u normal "Wallpaper" "No se encontraron imágenes en $WALLPAPER_DIR"
    exit 0
fi

for img in "${images[@]}"; do
    [ -f "$img" ] || continue
    base=$(basename "$img")
    thumb="$THUMBNAIL_DIR/${base%.*}.png"
    if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
        make_thumb "$img" "$thumb"
    fi
done

# --- Construir lista para rofi: nombre visible + ícono (miniatura)
list=""
for img in "${images[@]}"; do
    [ -f "$img" ] || continue
    base=$(basename "$img")
    thumb="$THUMBNAIL_DIR/${base%.*}.png"
    # Nombre sin extensión para que sea más limpio en la UI
    label="${base%.*}"
    list+="${label}\x00icon\x1f${thumb}\n"
done

# --- Mostrar Rofi con tema personalizado
selected=$(echo -ne "$list" | rofi \
    -dmenu \
    -p "  Wallpaper" \
    -i \
    -show-icons \
    -theme "$THEME")

[ -z "$selected" ] && exit 0

# --- Reconstruir la ruta completa buscando la extensión original
wallpaper=""
for img in "${images[@]}"; do
    base=$(basename "$img")
    label="${base%.*}"
    if [ "$label" = "$selected" ]; then
        wallpaper="$img"
        break
    fi
done

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    notify-send -u critical "Wallpaper" "No se encontró el archivo: $selected"
    exit 1
fi

# --- Aplicar con feh
# --no-fehbg se omite intencionalmente: feh escribe ~/.fehbg automáticamente,
# lo que permite que el wallpaper persista entre sesiones vía autostart.
feh --bg-fill "$wallpaper"