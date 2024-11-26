ARG DOCKER_DEBIAN_VERSION=bookworm
ARG DOCKER_GCC_VERSION=14

FROM gcc:${DOCKER_GCC_VERSION}-${DOCKER_DEBIAN_VERSION}

ARG DOCKER_DEBIAN_VERSION
ARG DOCKER_GCC_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cmake \
    make \
    build-essential \
    debhelper \
    dh-make \
    dpkg-dev \
    fakeroot \
    devscripts \
    lintian \
    git \
    libtool autoconf automake \
    valgrind \
    lcov \
    gcovr \
    pkg-config \
    liburing-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} developer

RUN useradd -m -s /bin/bash -u ${USER_ID} -g developer developer

WORKDIR /app

RUN wget https://github.com/israellopezdeveloper/nanologger/releases/download/1.0.2/nanologger-1.0.2.deb && \
  apt install -y ./nanologger-1.0.2.deb && \
  rm nanologger-1.0.2.deb

USER developer

ENV CC=gcc
ENV CXX=g++

CMD ["/bin/bash"]
