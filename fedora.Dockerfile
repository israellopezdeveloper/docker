ARG DOCKER_FEDORA_VERSION=41

FROM fedora:${DOCKER_FEDORA_VERSION}

ARG DOCKER_FEDORA_VERSION

RUN dnf install -y \
    rpm-build \
    redhat-rpm-config \
    gcc \
    make \
    tar \
    which \
    && dnf clean all

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} developer

RUN useradd -m -s /bin/bash -u ${USER_ID} -g developer developer

WORKDIR /app

USER developer

CMD ["/bin/bash"]

