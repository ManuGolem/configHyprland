#!/bin/bash

# Configuración
DOWNLOAD_DIR="$HOME/Downloads"
VIDEO_EXTENSIONS=("mp4" "avi" "mov" "mkv" "flv" "wmv" "webm" "mpeg" "mpg")

# Función para listar videos
listar_videos() {
    echo "📂 Videos encontrados en $DOWNLOAD_DIR:"
    local videos=()
    local i=1

    # Listas separadas
    local fecha_videos=()
    local otros_videos=()

    # Buscar archivos con extensiones de video
    for ext in "${VIDEO_EXTENSIONS[@]}"; do
        while IFS= read -r -d $'\0' file; do
            filename=$(basename "$file")
            # Detectar si empieza con fecha (formato YYYY-MM-DD)
            if [[ "$filename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
                fecha_videos+=("$file")
            else
                otros_videos+=("$file")
            fi
        done < <(find "$DOWNLOAD_DIR" -type f -iname "*.$ext" -print0 2>/dev/null)
    done

    # Combinar listas: primero los de fecha
    all_videos=("${fecha_videos[@]}" "${otros_videos[@]}")

    if [ ${#all_videos[@]} -eq 0 ]; then
        echo "❌ No se encontraron videos en $DOWNLOAD_DIR"
        exit 1
    fi

    # Mostrar con numeración
    for file in "${all_videos[@]}"; do
        echo "  $i. $(basename "$file")"
        videos+=("$file")
        ((i++))
    done

    echo "  $i. Ingresar manualmente"
    ((i++))
    echo "  $i. Salir"

    # Selección de archivo
    read -p "🔢 Selecciona un número (1-${#videos[@]}): " seleccion

    if [ "$seleccion" -ge 1 ] && [ "$seleccion" -le ${#videos[@]} ]; then
        input="${videos[$((seleccion - 1))]}"
    elif [ "$seleccion" -eq $((${#videos[@]} + 1)) ]; then
        read -p "📝 Ingresa la ruta completa del archivo: " input
    else
        echo "🚫 Operación cancelada"
        exit 0
    fi
}

# Menú principal
echo "🎬 CONVERSOR DE VIDEO A 60 FPS"
echo "1. Seleccionar video de $DOWNLOAD_DIR"
echo "2. Ingresar ruta manualmente"
echo "3. Salir"

read -p "🔢 Elige una opción (1-3): " opcion

case $opcion in
1)
    listar_videos
    ;;
2)
    read -p "📝 Ingresa la ruta completa del archivo: " input
    ;;
3)
    echo "👋 ¡Hasta luego!"
    exit 0
    ;;
*)
    echo "❌ Opción no válida"
    exit 1
    ;;
esac

# Validar archivo de entrada
if [ ! -f "$input" ]; then
    echo "❌ El archivo '$input' no existe o no es válido"
    exit 1
fi

# Solicitar nombre de salida
default_output="video_convertido_$(date +%Y%m%d_%H%M%S).mp4"
read -p "💾 Nombre del archivo de salida [por defecto: $default_output]: " output
output=${output:-$default_output}

# Si el output no contiene una ruta (no tiene /)
if [[ "$output" != */* ]]; then
    output="$HOME/Downloads/$output"
    echo "📂 El archivo se guardará en: $output"
fi

# Convertir
echo "🔄 Convirtiendo '$input' a '$output' a 60 FPS..."
ffmpeg -i "$input" \
    -c:v libx264 -crf 23 -preset fast -pix_fmt yuv420p \
    -c:a aac -b:a 192k -ar 48000 \
    -movflags +faststart \
    -r 60 \
    "$output.mp4"

# Resultado
if [ $? -eq 0 ]; then
    echo "✅ ¡Conversión exitosa! Archivo guardado como: $output"
    echo "📂 Ruta completa: $output"
else
    echo "❌ Error durante la conversión"
    exit 1
fi
