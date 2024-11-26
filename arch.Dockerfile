FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed base-devel git make

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} developer

RUN useradd -m -s /bin/bash -u ${USER_ID} -g developer developer

RUN echo 'developer ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer

RUN mkdir -p /__w/ && \
  chown -R developer:developer /__w && chmod 777 /__w

USER developer

WORKDIR /app

CMD ["/bin/bash"]

