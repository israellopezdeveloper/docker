ARG DOCKER_DEBIAN_VERSION=bookworm
ARG DOCKER_CLANG_VERSION=19

FROM debian:${DOCKER_DEBIAN_VERSION}-slim

ARG DOCKER_DEBIAN_VERSION
ARG DOCKER_CLANG_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    debian-keyring \
    cmake \
    make \
    git \
    build-essential \
    debhelper \
    dh-make \
    dpkg-dev \
    fakeroot \
    devscripts \
    lintian \
    wget \
    gnupg \
    libtool autoconf automake \
    liburing-dev \
    ca-certificates \
    lldb \
    pkg-config  && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb http://apt.llvm.org/"${DOCKER_DEBIAN_VERSION}"/ llvm-toolchain-"${DOCKER_DEBIAN_VERSION}"-"${DOCKER_CLANG_VERSION}" main" >> /etc/apt/sources.list && \
    echo "deb-src http://apt.llvm.org/"${DOCKER_DEBIAN_VERSION}"/ llvm-toolchain-"${DOCKER_DEBIAN_VERSION}"-"${DOCKER_CLANG_VERSION}" main" >> /etc/apt/sources.list
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -

RUN apt-get purge --auto-remove -y gcc && \
    apt-get update && apt-get install -y \
    clang-${DOCKER_CLANG_VERSION} \
    lld-${DOCKER_CLANG_VERSION} \
    lldb-${DOCKER_CLANG_VERSION} \
    libclang-common-${DOCKER_CLANG_VERSION}-dev \
    valgrind \
    jq \
    && apt-get clean && \
    apt-get purge -y wget gnupg debian-keyring llvm-14 && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /lib/x86_64-linux-gnu/libasan.*

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} developer

RUN useradd -m -s /bin/bash -u ${USER_ID} -g developer developer

WORKDIR /app

RUN update-alternatives \
  --verbose  \
  --install  /usr/bin/llvm-config              llvm-config             /usr/bin/llvm-config-${DOCKER_CLANG_VERSION}               100 \
  --slave    /usr/bin/llvm-addr2line           llvm-addr2line          /usr/bin/llvm-addr2line-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-ar                  llvm-ar                 /usr/bin/llvm-ar-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-as                  llvm-as                 /usr/bin/llvm-as-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-bcanalyzer          llvm-bcanalyzer         /usr/bin/llvm-bcanalyzer-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-bitcode-strip       llvm-bitcode-strip      /usr/bin/llvm-bitcode-strip-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-c-test              llvm-c-test             /usr/bin/llvm-c-test-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-cat                 llvm-cat                /usr/bin/llvm-cat-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-cfi-verify          llvm-cfi-verify         /usr/bin/llvm-cfi-verify-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-cov                 llvm-cov                /usr/bin/llvm-cov-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-cvtres              llvm-cvtres             /usr/bin/llvm-cvtres-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-cxxdump             llvm-cxxdump            /usr/bin/llvm-cxxdump-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-cxxfilt             llvm-cxxfilt            /usr/bin/llvm-cxxfilt-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-cxxmap              llvm-cxxmap             /usr/bin/llvm-cxxmap-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-debuginfo-analyzer  llvm-debuginfo-analyzer /usr/bin/llvm-debuginfo-analyzer-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-debuginfod          llvm-debuginfod         /usr/bin/llvm-debuginfod-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-debuginfod-find     llvm-debuginfod-find    /usr/bin/llvm-debuginfod-find-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-diff                llvm-diff               /usr/bin/llvm-diff-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-dis                 llvm-dis                /usr/bin/llvm-dis-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-dlltool             llvm-dlltool            /usr/bin/llvm-dlltool-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-dwarfdump           llvm-dwarfdump          /usr/bin/llvm-dwarfdump-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-dwarfutil           llvm-dwarfutil          /usr/bin/llvm-dwarfutil-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-dwp                 llvm-dwp                /usr/bin/llvm-dwp-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-exegesis            llvm-exegesis           /usr/bin/llvm-exegesis-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-extract             llvm-extract            /usr/bin/llvm-extract-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-gsymutil            llvm-gsymutil           /usr/bin/llvm-gsymutil-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-ifs                 llvm-ifs                /usr/bin/llvm-ifs-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-install-name-tool   llvm-install-name-tool  /usr/bin/llvm-install-name-tool-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-jitlink             llvm-jitlink            /usr/bin/llvm-jitlink-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-jitlink-executor    llvm-jitlink-executor   /usr/bin/llvm-jitlink-executor-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-lib                 llvm-lib                /usr/bin/llvm-lib-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-libtool-darwin      llvm-libtool-darwin     /usr/bin/llvm-libtool-darwin-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-link                llvm-link               /usr/bin/llvm-link-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-lipo                llvm-lipo               /usr/bin/llvm-lipo-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-lto                 llvm-lto                /usr/bin/llvm-lto-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-lto2                llvm-lto2               /usr/bin/llvm-lto2-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-mc                  llvm-mc                 /usr/bin/llvm-mc-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-mca                 llvm-mca                /usr/bin/llvm-mca-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-ml                  llvm-ml                 /usr/bin/llvm-ml-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-modextract          llvm-modextract         /usr/bin/llvm-modextract-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-mt                  llvm-mt                 /usr/bin/llvm-mt-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-nm                  llvm-nm                 /usr/bin/llvm-nm-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-objcopy             llvm-objcopy            /usr/bin/llvm-objcopy-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-objdump             llvm-objdump            /usr/bin/llvm-objdump-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-opt-report          llvm-opt-report         /usr/bin/llvm-opt-report-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-otool               llvm-otool              /usr/bin/llvm-otool-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-pdbutil             llvm-pdbutil            /usr/bin/llvm-pdbutil-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-profdata            llvm-profdata           /usr/bin/llvm-profdata-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-profgen             llvm-profgen            /usr/bin/llvm-profgen-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-ranlib              llvm-ranlib             /usr/bin/llvm-ranlib-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-rc                  llvm-rc                 /usr/bin/llvm-rc-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-readelf             llvm-readelf            /usr/bin/llvm-readelf-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-readobj             llvm-readobj            /usr/bin/llvm-readobj-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-readtapi            llvm-readtapi           /usr/bin/llvm-readtapi-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-reduce              llvm-reduce             /usr/bin/llvm-reduce-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-remarkutil          llvm-remarkutil         /usr/bin/llvm-remarkutil-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-rtdyld              llvm-rtdyld             /usr/bin/llvm-rtdyld-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-sim                 llvm-sim                /usr/bin/llvm-sim-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-size                llvm-size               /usr/bin/llvm-size-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-split               llvm-split              /usr/bin/llvm-split-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-stress              llvm-stress             /usr/bin/llvm-stress-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-strings             llvm-strings            /usr/bin/llvm-strings-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-strip               llvm-strip              /usr/bin/llvm-strip-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-symbolizer          llvm-symbolizer         /usr/bin/llvm-symbolizer-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-tblgen              llvm-tblgen             /usr/bin/llvm-tblgen-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-tli-checker         llvm-tli-checker        /usr/bin/llvm-tli-checker-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-undname             llvm-undname            /usr/bin/llvm-undname-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-windres             llvm-windres            /usr/bin/llvm-windres-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/llvm-xray                llvm-xray               /usr/bin/llvm-xray-${DOCKER_CLANG_VERSION}

RUN update-alternatives \
  --verbose  \
  --install  /usr/bin/clang                    clang                   /usr/bin/clang-${DOCKER_CLANG_VERSION}               100 \
  --slave    /usr/bin/clang++                  clang++                 /usr/bin/clang++-${DOCKER_CLANG_VERSION} \
  --slave    /usr/bin/clang-cpp                clang-cpp               /usr/bin/clang-cpp-${DOCKER_CLANG_VERSION}

RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/clang++ 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/ld ld /usr/bin/lld-${DOCKER_CLANG_VERSION} 100 && \
    update-alternatives --install /usr/bin/ld ld /usr/bin/ld.bfd 50

RUN update-alternatives --set ld /usr/bin/lld-${DOCKER_CLANG_VERSION}

RUN rm /usr/bin/cpp && ln -s /usr/bin/clang++ /usr/bin/cpp && \
    rm /usr/bin/ar && ln -s /usr/bin/llvm-ar /usr/bin/ar && \
    rm /usr/bin/as && ln -s /usr/bin/llvm-as /usr/bin/as

RUN wget https://github.com/israellopezdeveloper/nanologger/releases/download/1.0.2/nanologger-1.0.2.deb && \
  apt install -y ./nanologger-1.0.2.deb && \
  rm nanologger-1.0.2.deb

USER developer

ENV CC=clang
ENV CXX=clang++
ENV LD_LIBRARY_PATH=/usr/lib/llvm-${DOCKER_CLANG_VERSION}/lib/clang/${DOCKER_CLANG_VERSION}/lib/linux/:$LD_LIBRARY_PATH


CMD ["/bin/bash"]
