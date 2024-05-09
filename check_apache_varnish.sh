#!/bin/bash

# Función para reiniciar Apache2 y Varnish
restart_services() {
    systemctl restart apache2
    systemctl restart varnish
}

# Verificar el estado de Apache2
apache_status=$(systemctl is-active apache2)

# Verificar el estado de Varnish
varnish_status=$(systemctl is-active varnish)

# Verificar si alguno de los servicios está en estado "failed"
if [ "$apache_status" == "failed" ] || [ "$varnish_status" == "failed" ]; then
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") - Al menos uno de los servicios está en estado 'failed'. Reiniciando ambos servicios..."
    echo $(ps -eLf | grep apache2 | wc -l)
    restart_services
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") - Servicios reiniciados con éxito."
    echo $(ps -eLf | grep apache2 | wc -l)
else
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") - Ambos servicios están activos."
    echo $(ps -eLf | grep apache2 | wc -l)
fi
