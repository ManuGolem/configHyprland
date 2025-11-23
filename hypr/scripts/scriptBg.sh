#!/bin/sh

# Directorio de fondos de pantalla (se puede pasar como argumento o usar el predeterminado)
WallDir=${1:-~/Fondos/}

# Obtener la lista de monitores
MONITORS=$(hyprctl monitors | awk -F '[ ,]' '/^Monitor/ {print $2}')

# Selección de monitor con rofi
SELECTED_MONITOR=$(echo "$MONITORS" | rofi -no-config -theme fullscreen-preview.rasi -show -dmenu -p "Selecciona un monitor:")

# Si no se seleccionó un monitor, salir
if [ -z "$SELECTED_MONITOR" ]; then
    echo "No se seleccionó un monitor. Saliendo..."
    exit 1
fi

# Selección de fondo de pantalla
SELECTED_WALL=$(for a in ${WallDir}*.{jpg,png}; do echo -en "$a\0icon\x1f$a\n"; done | PREVIEW=true \
    rofi -no-config -theme fullscreen-preview.rasi -show -dmenu)

# Si no se seleccionó un fondo de pantalla, salir
if [ -z "$SELECTED_WALL" ]; then
    echo "No se seleccionó un fondo de pantalla. Saliendo..."
    exit 1
fi

# Aplicar fondo de pantalla al monitor seleccionado
hyprctl hyprpaper preload "$SELECTED_WALL"
hyprctl hyprpaper wallpaper "$SELECTED_MONITOR,$SELECTED_WALL"

# #!/bin/sh
#
# # Directorio de fondos de pantalla (se puede pasar como argumento o usar el predeterminado)
# WallDir=${1:-~/Fondos/}
# SELECTED_WALL=$(for a in ${WallDir}*.jpg; do echo -en "$a\0icon\x1f$a\n"; done | PREVIEW=true \
#     rofi -no-config -theme fullscreen-preview.rasi -show -dmenu)
# hyprctl hyprpaper preload "$SELECTED_WALL"
# hyprctl hyprpaper wallpaper "HDMI-A-1,$SELECTED_WALL"
