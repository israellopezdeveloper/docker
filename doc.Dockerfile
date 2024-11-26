ARG DOCKER_DEBIAN_VERSION=bookworm
ARG DOCKER_DOC_VERSION=14

# Usa la imagen base de Debian más pequeña (slim)
FROM gcc:${DOCKER_DOC_VERSION}-${DOCKER_DEBIAN_VERSION}

ARG DOCKER_DEBIAN_VERSION
ARG DOCKER_DOC_VERSION

# Evitar preguntas interactivas durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Actualiza la lista de paquetes y instala dependencias mínimas
RUN apt-get update && apt-get install -y \
    cmake \
    make \
    git \
    libtool autoconf automake \
    doxygen \
    texlive-full \
    pkg-config \
    liburing-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ARG USER_ID=1000
ARG GROUP_ID=1000

# Crear el grupo con GID especificado
RUN groupadd -g ${GROUP_ID} developer

# Crear el usuario 'developer' con UID y GID especificados
RUN useradd -m -s /bin/bash -u ${USER_ID} -g developer developer

# Establecer el directorio de trabajo
WORKDIR /app

# Cambiar al usuario 'developer'
USER developer

# Establecer las variables de entorno CC y CXX
ENV CC=gcc
ENV CXX=g++

# Comando por defecto al iniciar el contenedor
CMD ["/bin/bash"]
