#!/bin/bash

# Configuración de posiciones para los monitores
monitor1="HDMI-A-1"
monitor2="HDMI-A-2"
unlockedY1=0
lockedY1=1152
unlockedY2=0
lockedY2=0

# Obtiene la posición actual de y de cada monitor
y1=$(hyprctl -j monitors | jq -r ".[] | select(.name==\"$monitor1\") | .y")
y2=$(hyprctl -j monitors | jq -r ".[] | select(.name==\"$monitor2\") | .y")

# Alterna el estado de los monitores
if [ "$y1" -eq "$unlockedY1" ] && [ "$y2" -eq "$unlockedY2" ]; then
    # Bloquea los monitores
    hyprctl keyword monitor "$monitor1",1920x1080@60,0x$lockedY1,1
    hyprctl keyword monitor "$monitor2",1920x1080@75,1920x$lockedY2,1
    echo "Monitores bloqueados"
else
    # Desbloquea los monitores
    hyprctl keyword monitor "$monitor1",1920x1080@60,0x$unlockedY1,1
    hyprctl keyword monitor "$monitor2",1920x1080@75,1920x$unlockedY2,1
    echo "Monitores desbloqueados"
fi

