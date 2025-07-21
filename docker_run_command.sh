#!/bin/bash

# Parámetros con valores por defecto
IMAGE_NAME="yolo_gs_docker"
CONTAINER_NAME="yolo_gs_container"
USER="root"
CPUS="--cpuset-cpus=0-4"
GPUS="--gpus all"
RM=""
#OPTIONS="--shm-size=1g --privileged --ulimit memlock=-1 --ulimit stack=67108864 -it --net=host  -e DISPLAY=$DISPLAY"
OPTIONS="--shm-size=1g --privileged --ulimit memlock=-1 --ulimit stack=67108864 -it --net ros2_internal_net -e DISPLAY=$DISPLAY"
ENV_VARS="--env=\"DISPLAY\" --env=\"QT_X11_NO_MITSHM=1\"" # si se tiene problemas en interfaz esto poner en docker 
VOLUMES="-v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /dev:/dev"
DEVICES="--device=/dev/video0 --device=/dev/video1 --device=/dev/input/js0"
SHARED_PATH="-v ./ros2_ws/src/:/$USER/ros2_ws/src"

# Función para mostrar la ayuda
function show_help() {
    echo "Uso: ./docker_run_command.sh [opciones]"
    echo ""
    echo "Opciones disponibles:"
    echo "  --help -h              Muestra este mensaje de ayuda"
    echo "  --container-name NAME  Especifica un nombre para el contenedor (default: $IMAGE_NAME)"
    echo "  --image-name NAME      Especifica el nombre de la imagen a usar (default: $CONTAINER_NAME)"
    echo "  --cpus RANGE           Define el número de CPUs a asignar (ejemplo: 0-5, default: 0-9)"
    echo "  --no-gpus              Ejecuta el contenedor sin acceso a GPUs"
    echo "  --rm                   Borra el contenedor al salir (Default: no se borra)"
    echo ""
    exit 0
}

# Verificar si se solicita ayuda
if [ "$1" == "--h" ] || [ "$1" == "--help" ]; then
    show_help
fi

# Permitir modificar parámetros desde la terminal
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --container-name) CONTAINER_NAME="$2"; shift ;;
        --cpus) CPUS="--cpuset-cpus=$2"; shift ;;
        --no-gpus) GPUS=""; ;;
        --rm) RM="--rm"; ;;
        *) echo "❌ Opción desconocida: $1. Usa --h o --help para ver las opciones disponibles."; exit 1 ;;
    esac
    shift
done

# Comando para poder compartir pantalla desde el contenedor y tener interfaz grafica
xhost +local:

# Verificar si el contenedor ya existe
if  docker ps -a --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo "📦 El contenedor '$CONTAINER_NAME' ya existe. Reiniciándolo..."
     docker start -ai $CONTAINER_NAME
else
    echo "🚀 Iniciando un nuevo contenedor '$CONTAINER_NAME'..."
     docker run \
        $OPTIONS \
        $RM \
        $CPUS \
        $GPUS \
        $ENV_VARS \
        $VOLUMES \
        $DEVICES \
        --user=$USER \
        $SHARED_PATH \
        --name $CONTAINER_NAME \
        $IMAGE_NAME
fi

