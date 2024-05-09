#!/bin/bash

# Obtener la fecha y hora actual del sistema
fecha_hora=$(date "+%Y-%m-%d_%H:%M:%S")

# Obtener el numero de ano, mes y dia actual del sistema
nro_ano=$(date +%Y)
nro_mes=$(date +%m)
nro_dia=$(date +%d)

# Definir la lista de directorios basados en diferentes fechas
directorios=( "/var/www/production/XXXX/TYYY/logs/XXXX/${nro_ano}-${nro_mes}"
   "/var/www/production/XXXX/TYYY/logs/XXXX/${nro_ano}-${nro_mes}"
)

# Definir errores a buscar
msj_error=("Falla de conexion" "[status] => ERROR" "500 Error interno" "Gateway Timeout" "Endpoint request timed out")

emails=("xxx@xxx")


# Iterar sobre la lista de directorios
for directorio in "${directorios[@]}"; do
    # Chequear si el directorio existe
    if [ -d "$directorio" ]; then
        archivos="${directorio}/${nro_ano}-${nro_mes}-${nro_dia}"
        # Recorrer la lista de errores
        for error in "${msj_error[@]}"; do
            # Buscar el error actual (insensible a mayusculas/minusculas) dentro del directorio
            archivos_con_coincidencia=$(grep -irl "$error" "$archivos"* 2>/dev/null)
            if [ -n "$archivos_con_coincidencia" ]; then
                echo "[$fecha_hora] YYYYY El error '$error' se encontro en el directorio $directorio en el siguiente archivo(s):"
                echo "$archivos_con_coincidencia"
                mkdir -p "$directorio/down_services_logs/${nro_ano}-${nro_mes}-${nro_dia}"
                while IFS= read -r archivo; do
                    nombre_archivo=$(basename "$archivo")
                    # Contar la cantidad de veces que aparece el error en el archivo
                    cantidad_ocurrencias=$(grep -c "$error" "$archivo")
                    mv -v "$archivo" "$directorio/down_services_logs/${nro_ano}-${nro_mes}-${nro_dia}/${nombre_archivo}_${fecha_hora}.log"
                    echo -e "Encontre $cantidad_ocurrencias veces el error $error en $archivo"
                #Si hay mas de 5 errores en el archivo, enviar el correo
                    if [ "$cantidad_ocurrencias" -gt 5 ]; then
                        # Enviar el correo electronico con el texto de la coincidencia y la cantidad de ocurrencias
                        echo -e "Subject: Alerta MS PAC TELCEL\n\n[$fecha_hora] El error '$error' se encontro $cantidad_ocurrencias veces en el archivo $archivo dentro del directorio $directorio \n \nPara mas informacion deberas ingresar al siguiente directorio: $directorio/down_services_logs/${nro_ano}-${nro_mes}-${nro_dia}/${nombre_archivo}_${fecha_hora}.log \n\n" | msmtp -a outlook $emails
                    fi
                done <<< "$archivos_con_coincidencia"
            else
                echo "[$fecha_hora] XXXXX El error '$error' es INEXISTENTE en el directorio $directorio"
            fi
        done
    else
        echo "[$fecha_hora] El directorio $directorio no existe"
    fi
done
