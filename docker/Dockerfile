# @see: https://docs.docker.com/build/building/multi-platform/#strategies
# - native
# - qemu
ARG STRATEGY="qemu"

ARG LINUX_UBUNTU_IMAGE="docker.io/library/ubuntu"
ARG LINUX_UBUNTU_TAG="24.04"

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

FROM linux-ubuntu-strategy as linux-ubuntu-base

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
ARG TARGETARCH

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apt/ \
    --mount=type=cache,sharing=private,target=/var/lib/apt/ \
<<EOF
    apt-get update
    apt-get -y install --no-install-recommends \
        "ca-certificates" \
        ;
EOF

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apt/ \
    --mount=type=cache,sharing=private,target=/var/lib/apt/ \
<<EOF
    apt-get update
    case "${TARGETARCH}" in
        amd64)
            apt-get -y install --no-install-recommends \
                "g++-x86-64-linux-gnu" \
                "gcc-x86-64-linux-gnu" \
                "libc6-dev-amd64-cross" \
                ;
            x86_64-linux-gnu-g++ --version
            x86_64-linux-gnu-gcc --version
            ;;
        arm64)
            apt-get -y install --no-install-recommends \
                "g++-aarch64-linux-gnu" \
                "gcc-aarch64-linux-gnu" \
                "libc6-dev-arm64-cross" \
                ;
            aarch64-linux-gnu-g++ --version
            aarch64-linux-gnu-gcc --version
            ;;
        *)
            echo "Unsupported architecture: ${TARGETARCH}"
            exit 1
            ;;
    esac
EOF

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apt/ \
    --mount=type=cache,sharing=private,target=/var/lib/apt/ \
<<EOF
    apt-get update
    apt-get -y install --no-install-recommends \
        "cmake" \
        ;
EOF

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FROM scratch as dummy
