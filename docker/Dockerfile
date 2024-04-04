# @see: https://docs.docker.com/build/building/multi-platform/#strategies
# - native
# - qemu
ARG STRATEGY="qemu"

ARG LINUX_UBUNTU_IMAGE="docker.io/library/ubuntu"
ARG LINUX_UBUNTU_TAG="24.04"

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ARG LINUX_WORKDIR="/app/"

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [strategy]                                                                                                        #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM --platform=${BUILDPLATFORM} ${LINUX_UBUNTU_IMAGE}:${LINUX_UBUNTU_TAG} as linux-ubuntu-native

FROM ${LINUX_UBUNTU_IMAGE}:${LINUX_UBUNTU_TAG} as linux-ubuntu-qemu

FROM linux-ubuntu-${STRATEGY} as linux-ubuntu-strategy

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [base]                                                                                                            #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM linux-ubuntu-strategy as linux-ubuntu-base-common

SHELL ["/bin/sh", "-ex", "-c"]

# @see: https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/reference.md#run---mounttypecache
COPY <<EOF "/etc/apt/apt.conf.d/keep-cache"
Binary::apt::APT::Keep-Downloaded-Packages "1";
EOF

RUN \
<<EOF
    rm --force "/etc/apt/apt.conf.d/docker-clean"
EOF

ARG DEBIAN_FRONTEND="noninteractive"

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apt/ \
    --mount=type=cache,sharing=private,target=/var/lib/apt/ \
<<EOF
    apt-get update
    apt-get -y install --no-install-recommends \
        "ca-certificates" \
        "git" \
        ;
EOF

FROM linux-ubuntu-base-common as linux-ubuntu-base-amd64

ENV AS="x86_64-linux-gnu-as"
ENV CC="x86_64-linux-gnu-gcc"
ENV CXX="x86_64-linux-gnu-g++"
ENV LD="x86_64-linux-gnu-ld"

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apt/ \
    --mount=type=cache,sharing=private,target=/var/lib/apt/ \
<<EOF
    apt-get update
    apt-get -y install --no-install-recommends \
        "binutils-x86-64-linux-gnu" \
        "g++-x86-64-linux-gnu" \
        "gcc-x86-64-linux-gnu" \
        "libc6-dev-amd64-cross" \
        ;
    # TODO: CC does not use AS and LD on x86-64
    update-alternatives --install "/usr/bin/as" "as" "/usr/bin/${AS}" 1
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/${LD}" 1
    ${AS} --version
    ${CC} --version
    ${CXX} --version
    ${LD} --version
EOF

FROM linux-ubuntu-base-common as linux-ubuntu-base-arm64

ENV AS="aarch64-linux-gnu-as"
ENV CC="aarch64-linux-gnu-gcc"
ENV CXX="aarch64-linux-gnu-g++"
ENV LD="aarch64-linux-gnu-ld"

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apt/ \
    --mount=type=cache,sharing=private,target=/var/lib/apt/ \
<<EOF
    apt-get update
    apt-get -y install --no-install-recommends \
        "binutils-aarch64-linux-gnu" \
        "g++-aarch64-linux-gnu" \
        "gcc-aarch64-linux-gnu" \
        "libc6-dev-arm64-cross" \
        ;
    ${AS} --version
    ${CC} --version
    ${CXX} --version
    ${LD} --version
EOF

FROM linux-ubuntu-base-${TARGETARCH} as linux-ubuntu-base

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apt/ \
    --mount=type=cache,sharing=private,target=/var/lib/apt/ \
<<EOF
    apt-get update
    apt-get -y install --no-install-recommends \
        "cmake" \
        "make" \
        "ninja-build" \
        ;
EOF

ARG LINUX_WORKDIR
ARG WORKDIR=${LINUX_WORKDIR}
WORKDIR ${WORKDIR}

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [deps]                                                                                                            #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM linux-ubuntu-base as linux-ubuntu-deps

ENV CPM_SOURCE_CACHE="/var/cache/cpm/"

COPY "./cmake/CPM.cmake"    "./cmake/"
COPY "./CMakeLists.txt"     "./"
COPY "./Dependencies.cmake" "./"

RUN \
    --mount=type=cache,sharing=private,target=${CPM_SOURCE_CACHE} \
<<EOF
    export CPM_FETCH=1
    cmake -B "./out/" -S "./"
EOF

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FROM scratch as dummy
