# @see: https://docs.docker.com/build/building/multi-platform/#strategies
# - native
# - qemu
ARG STRATEGY="qemu"

ARG LINUX_UBUNTU_IMAGE="docker.io/library/ubuntu"
ARG LINUX_UBUNTU_TAG="24.04"

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ARG LINUX_WORKDIR="/app/"
ARG LINUX_OUTDIR="/"

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

ENV AR="x86_64-linux-gnu-ar"
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
    # TODO: https://stackoverflow.com/questions/10173431/cross-gcc-doesnt-search-for-target-as-and-ld-in-path
    update-alternatives --install "/usr/bin/ar" "ar" "/usr/bin/${AR}" 1
    update-alternatives --install "/usr/bin/as" "as" "/usr/bin/${AS}" 1
    update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/${LD}" 1
    ${AR} --version
    ${AS} --version
    ${CC} --version
    ${CXX} --version
    ${LD} --version
EOF

FROM linux-ubuntu-base-common as linux-ubuntu-base-arm64

ENV AR="aarch64-linux-gnu-ar"
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
    ${AR} --version
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
    # TODO: pin cmake version until ports.ubuntu.com resolves discrepancy with cmake-data package
    apt-get -y install --no-install-recommends \
        "cmake=3.28.3-1" \
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

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [builder]                                                                                                         #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM linux-ubuntu-deps as linux-ubuntu-builder

COPY "./cmake/"               "./cmake/"
COPY "./configured_files/"    "./configured_files/"
COPY "./fuzz_test/"           "./fuzz_test/"
COPY "./include/"             "./include/"
COPY "./src/"                 "./src/"
COPY "./test/"                "./test/"
COPY "./.clang-tidy"          "./"
COPY "./.clangd.in"           "./"
COPY "./CMakePresets.json"    "./"
COPY "./ProjectOptions.cmake" "./"

ENV MAKEFLAGS="-j$(nproc)"

RUN \
    --mount=type=cache,sharing=private,target=${CPM_SOURCE_CACHE} \
<<EOF
    cmake -B "./out/" -S "./" \
        -D "CMAKE_BUILD_TYPE:STRING=Release" \
        -D "CMAKE_CATCH_DISCOVER_TESTS_DISCOVERY_MODE:STRING=PRE_TEST" \
        -D "myproject_PACKAGING_MAINTAINER_MODE:BOOL=ON" \
        ;
    cmake --build "./out/"
EOF

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [artifact]                                                                                                        #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM scratch as linux-ubuntu-artifact

ARG LINUX_WORKDIR
ARG LINUX_OUTDIR

COPY --from=linux-ubuntu-builder "${LINUX_WORKDIR}/out/src/ftxui_sample/intro"                 "${LINUX_OUTDIR}/out/src/ftxui_sample/"
COPY --from=linux-ubuntu-builder "${LINUX_WORKDIR}/out/src/sample_library/libsample_library.a" "${LINUX_OUTDIR}/out/src/sample_library/"
COPY --from=linux-ubuntu-builder "${LINUX_WORKDIR}/out/test/constexpr_tests"                   "${LINUX_OUTDIR}/out/test/"
COPY --from=linux-ubuntu-builder "${LINUX_WORKDIR}/out/test/relaxed_constexpr_tests"           "${LINUX_OUTDIR}/out/test/"
COPY --from=linux-ubuntu-builder "${LINUX_WORKDIR}/out/test/tests"                             "${LINUX_OUTDIR}/out/test/"

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [runner]                                                                                                          #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM ${LINUX_UBUNTU_IMAGE}:${LINUX_UBUNTU_TAG} as linux-ubuntu-runner

ARG LINUX_WORKDIR

COPY --from=linux-ubuntu-builder "${LINUX_WORKDIR}/out/src/ftxui_sample/intro" "/usr/local/bin/"

RUN \
<<EOF
    intro --version
EOF

CMD ["intro"]

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FROM scratch as dummy
