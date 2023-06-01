# Documentación del script de Bash para streaming de video

Este script de Bash permite realizar streaming de video utilizando ya sea FFMPEG o TSPLAY. A continuación, se presenta una descripción de los parámetros y opciones disponibles.

## Parámetros de entrada

El script requiere los siguientes parámetros:

1. `destination`: Es la dirección IP y puerto de destino (formato: IP:PORT).
2. `video`: Es la ruta al archivo de video que se desea transmitir.

## Opciones

Además de los parámetros de entrada, el script acepta las siguientes opciones:

- `-l`: Esta opción permite establecer el nivel de log para FFMPEG. Los valores válidos son: quiet, panic, fatal, error, warning, info, verbose, debug, trace.
- `-t`: Esta opción permite especificar la cantidad de hilos de FFMPEG a utilizar para la codificación. El valor debe ser numérico y no mayor a 4.
- `-s`: Esta opción permite establecer el nombre del servicio, usualmente el nombre del cliente.
- `-p`: Esta opción permite establecer el nombre del proveedor.
- `-z`: Esta opción permite establecer el tamaño de los paquetes a enviar. El valor debe ser numérico y no mayor a 1500.
- `--tsplay`: Esta opción habilita el modo de TSPLAY en lugar de FFMPEG.

## Ejecución del script

El script verifica la validez de los parámetros y opciones. Si se pasa un argumento inválido, se muestra un mensaje de error y se termina el script. Una vez que se han procesado todos los argumentos, el script verifica la validez del parámetro `destination` y la existencia del archivo de video.

En función de si se ha habilitado TSPLAY o no, el script realizará streaming del video utilizando FFMPEG o TSPLAY. En el caso de FFMPEG, se muestran los valores que se utilizarán para la transmisión antes de iniciarla.

## Ejemplos de uso

Para hacer streaming de un video con FFMPEG usando 4 hilos, el nivel de log "warning", un tamaño de paquete de 1200, el nombre de servicio "MyService" y el nombre del proveedor "MyProvider", se puede utilizar el siguiente comando:

```bash
./script.sh -l warning -t 4 -s MyService -p MyProvider -z 1200 192.168.0.1:1234 /path/to/video.mp4
```

Para hacer streaming de un video usando TSPLAY, se puede utilizar el siguiente comando:

```bash
./script.sh --tsplay 192.168.0.1:1234 /path/to/video.ts
```

## Nota

Este script no maneja los errores que pueden producirse durante la ejecución de FFMPEG o TSPLAY. Es responsabilidad del usuario asegurarse de que estos programas estén correctamente instalados y configurados en su sistema.

## Descripción de los parámetros de FFMPEG

El comando `ffmpeg` utilizado en el script tiene muchos parámetros. A continuación se describen cada uno de ellos:

- `-loglevel <logLevel>`: Este parámetro define el nivel de registro para FFMPEG. Los posibles valores pueden ser quiet, panic, fatal, error, warning, info, verbose, debug, trace.

- `-threads <threads>`: Este parámetro permite establecer la cantidad de hilos que FFMPEG utilizará para la codificación.

- `-re`: Este parámetro hace que FFMPEG lea el archivo de entrada a su velocidad nativa, en lugar de leerlo lo más rápido posible.

- `-fflags +genpts`: Este parámetro se utiliza para forzar la generación de marcas de tiempo.

- `-stream_loop -1`: Este parámetro permite que el video se reproduzca en bucle infinitamente.

- `-i <video>`: Este parámetro especifica la ruta al archivo de video que se va a transmitir.

- `-c:v copy -bsf:v h264_mp4toannexb -c:a copy`: Estos parámetros especifican que el video y el audio se deben copiar tal como están, sin recodificación. El video se procesa con un filtro de formato de bit para convertirlo en formato Annex B H.264.

- `-metadata service_name=<serviceName> -metadata service_provider=<providerName>`: Estos parámetros se utilizan para establecer metadatos sobre el nombre del servicio y el proveedor del servicio.

- `-max_interleave_delta 0 -use_wallclock_as_timestamps 1 -flush_packets 1`: Estos parámetros controlan cómo FFMPEG escribe y sincroniza los paquetes en la transmisión.

- `-f mpegts udp://<destination>?pkt_size=<packetSize>`: Este parámetro especifica el formato de salida (MPEG-TS) y la dirección IP y el puerto de destino para la transmisión. También se especifica el tamaño de los paquetes en la transmisión.

## Descripción de los parámetros de TSPLAY

El comando `tsplay` utilizado en el script tiene los siguientes parámetros:

- `-loop -1`: Este parámetro permite que el video se reproduzca en bucle infinitamente.

- `-i <video>`: Este parámetro especifica la ruta al archivo de video que se va a transmitir.

- `-o udp://<destination>`: Este parámetro especifica la dirección IP y el puerto de destino para la transmisión.

A diferencia de FFMPEG, TSPLAY tiene una interfaz mucho más sencilla y directa, pero es menos flexible y ofrece menos opciones de control sobre el proceso de transmisión.
