# Copyright 2023 Carnegie Mellon University.
# MIT (SEI)
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# This material is based upon work funded and supported by the Department of
# Defense under Contract No. FA8702-15-D-0002 with Carnegie Mellon University
# for the operation of the Software Engineering Institute, a federally funded
# research and development center.
# The view, opinions, and/or findings contained in this material are those of
# the author(s) and should not be construed as an official Government position,
# policy, or decision, unless designated by other documentation.
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
# INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
# UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
# AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR
# PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE
# MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND
# WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# [DISTRIBUTION STATEMENT A] This material has been approved for public release
# and unlimited distribution.  Please see Copyright notice for non-US
# Government use and distribution.
# DM23-0186


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
RUN apt-get update && \
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
    make -f Makefile.init && \
    mkdir obj && \
    cd obj && \
    ../configure --enable-flopoco --enable-opt --prefix=/opt/panda --enable-release && \
    make -j4 && \
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
