FROM agostini01/soda

SHELL ["/bin/bash", "-c"]

# upgrade some packages
# trusted-host stuff for mac os
RUN python3 -m pip install \
    --trusted-host pypi.org --trusted-host files.pythonhosted.org \
    --upgrade pip && \
    pip  \
    --trusted-host pypi.org --trusted-host files.pythonhosted.org \
    install \
    graphviz \
    numpy==1.20 \
    scikit-learn \
    torchview

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --fix-missing && \
    apt-get install -y \
    emacs \
    graphviz \
    python3-tk

# build bambu
RUN apt-get install -y \
    autoconf \
    autoconf-archive \
    automake \
    bison \
    clang \
    clang-12 \
    cmake \
    curl \
    doxygen \
    emacs \
    flex \
    g++ \
    g++-9 \
    g++-10 \
    g++-9-multilib \
    g++-10-multilib \
    gcc \
    gcc-9 \
    gcc-10 \
    gcc-9-plugin-dev \
    gcc-10-plugin-dev \
    gcc-9-multilib \
    gcc-10-multilib \
    gfortran-9 \
    gfortran-10 \
    gfortran-9-multilib \
    gfortran-10-multilib \
    git \
    gnupg \
    graphviz \
    iverilog \
    libbdd-dev \
    libboost-all-dev \
    libclang-dev \
    libclang-12-dev \
    libglpk-dev \
    libgsl-dev \
    libicu-dev \
    liblzma-dev \
    libmpc-dev \
    libmpfi-dev \
    libmpfr-dev \
    libsuitesparse-dev \
    libstdc++-10-dev \
    libtool \
    libxml2-dev \
    lld \
    lsb-release \
    make \
    ninja-build \
    pkg-config \
    python3 \
    python3-pip \
    python3-tk \
    software-properties-common \
    sudo \
    verilator \
    wget \
    x11-apps \
    zlib1g-dev

RUN echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-16 main" >> /etc/apt/sources.list && \
    echo "deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-16 main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421 && \
    apt update && \
    apt-get install -y \
    clang-16 \
    libclang-16-dev

RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-16 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-16 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100

ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++
RUN rm -rf /opt/panda && \
    git clone https://github.com/ferrandi/PandA-bambu.git && \
    cd PandA-bambu && \
    git checkout dev/panda && \
    git submodule update --init && \
    make -f Makefile.init && \
    mkdir obj && \
    cd obj && \
    ../configure --enable-flopoco --enable-opt --prefix=/opt/panda --disable-release && \
    make -j8 && \
    make install

# set up a user
RUN useradd -l -ms /bin/bash soda-opt-user && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    adduser soda-opt-user sudo
ARG SODA_OPT_HOME=/home/soda-opt-user
WORKDIR ${SODA_OPT_HOME}
USER soda-opt-user

# create directories to mount
RUN mkdir ${SODA_OPT_HOME}/env
RUN mkdir ${SODA_OPT_HOME}/work

COPY --chown=soda-opt-user:soda-opt-user ./scripts ./scripts
COPY --chown=soda-opt-user:soda-opt-user ./scripts/bash_aliases ./.bash_aliases

# go in as root and change user in entrypoint.sh
USER root

# set entrypoint
ENTRYPOINT ["./scripts/entrypoint.sh"]
