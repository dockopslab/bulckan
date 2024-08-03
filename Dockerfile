# Usa la imagen base de Alpine
FROM alpine:latest

# Evita interacciones durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependencias esenciales
RUN apk update && \
    apk add --no-cache \
    git \
    curl \
    docker \
    bash \
    docker-compose

# Copia el script de despliegue al contenedor
COPY vulcan.sh /usr/local/bin/vulcan.sh

# Da permisos de ejecución al script
RUN chmod +x /usr/local/bin/vulcan.sh

# Define el punto de entrada para el contenedor
ENTRYPOINT ["/usr/local/bin/vulcan.sh"]


