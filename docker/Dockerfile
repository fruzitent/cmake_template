# @help: https://docs.docker.com/reference/dockerfile

# hadolint global ignore=DL3006,DL3008,DL3018

# - alpine
# - ubuntu
# - servercore
ARG IMAGE="ubuntu"

# @see: https://docs.docker.com/build/building/multi-platform/#strategies
# - native
# - qemu
ARG STRATEGY="native"

ARG LINUX_ALPINE_IMAGE="docker.io/library/alpine"
ARG LINUX_ALPINE_TAG="3.19"

ARG LINUX_UBUNTU_IMAGE="docker.io/library/ubuntu"
ARG LINUX_UBUNTU_TAG="24.04"

ARG WINDOWS_SERVERCORE_IMAGE="mcr.microsoft.com/windows/servercore"
ARG WINDOWS_SERVERCORE_TAG="ltsc2022"

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ARG LINUX_WORKDIR="/app/"
ARG LINUX_OUTDIR="/"

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [strategy]                                                                                                        #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM --platform=${BUILDPLATFORM} ${LINUX_ALPINE_IMAGE}:${LINUX_ALPINE_TAG} as linux-alpine-native

# TODO: unimplemented
RUN exit 1

FROM ${LINUX_ALPINE_IMAGE}:${LINUX_ALPINE_TAG} as linux-alpine-qemu

FROM linux-alpine-${STRATEGY} as linux-alpine-strategy

# ----------------------------------------------------------------------------------------------------------------------

FROM --platform=${BUILDPLATFORM} ${LINUX_UBUNTU_IMAGE}:${LINUX_UBUNTU_TAG} as linux-ubuntu-native

FROM ${LINUX_UBUNTU_IMAGE}:${LINUX_UBUNTU_TAG} as linux-ubuntu-qemu

FROM linux-ubuntu-${STRATEGY} as linux-ubuntu-strategy

# ----------------------------------------------------------------------------------------------------------------------

FROM --platform=${BUILDPLATFORM} ${WINDOWS_SERVERCORE_IMAGE}:${WINDOWS_SERVERCORE_TAG} as windows-servercore-native

FROM ${WINDOWS_SERVERCORE_IMAGE}:${WINDOWS_SERVERCORE_TAG} as windows-servercore-qemu

# TODO: unimplemented
RUN exit /b 1

FROM windows-servercore-${STRATEGY} as windows-servercore-strategy

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [base]                                                                                                            #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM linux-alpine-strategy as linux-alpine-base

SHELL ["/bin/sh", "-ex", "-c"]

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apk/ \
    --mount=type=cache,sharing=private,target=/var/lib/apk/ \
<<EOF
    apk update
    apk add \
        "ca-certificates" \
        "git" \
        ;
EOF

ENV AR="ar"
ENV AS="as"
ENV CC="gcc"
ENV CXX="g++"
ENV LD="ld"

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apk/ \
    --mount=type=cache,sharing=private,target=/var/lib/apk/ \
<<EOF
    apk update
    apk add \
        "binutils" \
        "g++" \
        "gcc" \
        "musl-dev" \
        ;
    ${AR} --version
    ${AS} --version
    ${CC} --version
    ${CXX} --version
    ${LD} --version
EOF

ENV PATH="/usr/lib/ninja-build/bin/:${PATH}"

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apk/ \
    --mount=type=cache,sharing=private,target=/var/lib/apk/ \
<<EOF
    apk update
    apk add \
        "cmake" \
        "make" \
        "ninja-build" \
        ;
    cmake --version
    make --version
    ninja --version
EOF

ARG LINUX_WORKDIR
ARG WORKDIR=${LINUX_WORKDIR}
WORKDIR ${WORKDIR}

# ----------------------------------------------------------------------------------------------------------------------

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
    git --version
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
    update-alternatives --install "/usr/local/bin/ar" "ar" "/usr/bin/${AR}" 1
    update-alternatives --install "/usr/local/bin/as" "as" "/usr/bin/${AS}" 1
    update-alternatives --install "/usr/local/bin/ld" "ld" "/usr/bin/${LD}" 1
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
    cmake --version
    make --version
    ninja --version
EOF

ARG LINUX_WORKDIR
ARG WORKDIR=${LINUX_WORKDIR}
WORKDIR ${WORKDIR}

# ----------------------------------------------------------------------------------------------------------------------

FROM windows-servercore-strategy as windows-servercore-base

SHELL ["C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-Command", "$ErrorActionPreference = 'Stop';", "$ProgressPreference = 'SilentlyContinue';", "Set-PSDebug -Trace 0;"]

# TODO: https://github.com/moby/buildkit/pull/3158
ENV PATH="C:\Windows\System32;C:\Windows"

ARG BUILDARCH
ARG TARGETARCH

# @see: https://learn.microsoft.com/visualstudio/releases/2022/release-history#fixed-version-bootstrappers
ARG BUILDTOOLS_SHA256="9271cd86da634e354be6035c6aaaffd7c62e458f39410812fcb3f35f4e57d908"
ARG BUILDTOOLS_URI="https://download.visualstudio.microsoft.com/download/pr/cf977820-7491-4d7f-bd0f-500597f0ea0c/9271cd86da634e354be6035c6aaaffd7c62e458f39410812fcb3f35f4e57d908/vs_BuildTools.exe"

RUN \
<<EOF
    [System.Net.WebClient]::new().DownloadFile(${env:BUILDTOOLS_URI}, \"${env:TEMP}\\vs_buildtools.exe\")

    ${hash} = (Get-FileHash -Algorithm SHA256 -Path \"${env:TEMP}\\vs_buildtools.exe\").Hash
    if (${env:BUILDTOOLS_SHA256} -ne ${hash}) {
        throw \"hash mismatch: expected ${env:BUILDTOOLS_SHA256}, got ${hash}\"
    }

    switch(${env:TARGETARCH}) {
        \"amd64\" { ${arch} = \"\" }
        \"arm64\" { ${arch} = \"\" }
        default { throw \"Unsupported architecture: ${env:TARGETARCH}\" }
    }

    # TODO: PATH is not setup correctly when only either AMD64 or ARM64 is installed
    # TODO: https://developercommunity.visualstudio.com/t/vsdevcmd-creates-invalid-ARM64-build-con/10090339

    # @see: https://learn.microsoft.com/visualstudio/install/workload-and-component-ids
    Start-Process -FilePath \"${env:TEMP}\\vs_buildtools.exe\" -Wait -ArgumentList `
        \"--add\", \"Microsoft.VisualStudio.Component.VC.Tools.ARM64\", `
        \"--add\", \"Microsoft.VisualStudio.Component.VC.Tools.x86.x64\", `
        \"--add\", \"Microsoft.VisualStudio.Component.Windows11SDK.22621\", `
        \"--quiet\", \"--wait\"

    Remove-Item -Force -Path \"${env:TEMP}\\vs_buildtools.exe\"

    # https://learn.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022#developer-powershell
    & \"$(Get-CimInstance 'MSFT_VSInstance' -Namespace 'root/cimv2/vs' | Select-Object -ExpandProperty 'InstallLocation')\\Common7\\Tools\\Launch-VsDevShell.ps1\" -SkipAutomaticLocation -Arch ${env:TARGETARCH} -HostArch ${env:BUILDARCH}

    cl
EOF

ARG GIT_SHA256="a2377f6e4214f16afa1a5a23d9a291d09a2234bcac67c5aeb36d9cce4b7b4d5b"
ARG GIT_URI="https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/MinGit-2.44.0-busybox-64-bit.zip"

ENV PATH="C:\Program Files\Git\cmd;${PATH}"

RUN \
<<EOF
    [System.Net.WebClient]::new().DownloadFile(${env:GIT_URI}, \"${env:TEMP}\\MinGit.zip\")

    ${hash} = (Get-FileHash -Algorithm SHA256 -Path \"${env:TEMP}\\MinGit.zip\").Hash
    if (${env:GIT_SHA256} -ne ${hash}) {
        throw \"hash mismatch: expected ${env:GIT_SHA256}, got ${hash}\"
    }

    Expand-Archive -DestinationPath \"${env:ProgramFiles}\\Git\" -Path \"${env:TEMP}\\MinGit.zip\"
    Remove-Item -Force -Path \"${env:TEMP}\\MinGit.zip\"

    Get-ChildItem -Path \"${env:ProgramFiles}\\Git\\etc\\gitconfig\" | ForEach-Object {
        (Get-Content -Path ${_} | Select-String -NotMatch -Pattern \"path = \") | Set-Content -Path ${_}
    }

    git --version
EOF

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [deps]                                                                                                            #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM linux-${IMAGE}-base as linux-deps

ARG LINUX_WORKDIR

ENV CPM_SOURCE_CACHE="/var/cache/cpm/"

COPY "./cmake/CPM.cmake"    "${LINUX_WORKDIR}./cmake/"
COPY "./CMakeLists.txt"     "${LINUX_WORKDIR}./"
COPY "./Dependencies.cmake" "${LINUX_WORKDIR}./"

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

FROM linux-deps as linux-builder

ARG LINUX_WORKDIR

COPY "./cmake/"               "${LINUX_WORKDIR}/cmake/"
COPY "./configured_files/"    "${LINUX_WORKDIR}/configured_files/"
COPY "./fuzz_test/"           "${LINUX_WORKDIR}/fuzz_test/"
COPY "./include/"             "${LINUX_WORKDIR}/include/"
COPY "./src/"                 "${LINUX_WORKDIR}/src/"
COPY "./test/"                "${LINUX_WORKDIR}/test/"
COPY "./.clang-tidy"          "${LINUX_WORKDIR}/"
COPY "./.clangd.in"           "${LINUX_WORKDIR}/"
COPY "./CMakePresets.json"    "${LINUX_WORKDIR}/"
COPY "./ProjectOptions.cmake" "${LINUX_WORKDIR}/"

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

FROM scratch as linux-artifact

ARG LINUX_WORKDIR
ARG LINUX_OUTDIR

COPY --from=linux-builder "${LINUX_WORKDIR}/out/src/ftxui_sample/intro"                 "${LINUX_OUTDIR}/out/src/ftxui_sample/"
COPY --from=linux-builder "${LINUX_WORKDIR}/out/src/sample_library/libsample_library.a" "${LINUX_OUTDIR}/out/src/sample_library/"
COPY --from=linux-builder "${LINUX_WORKDIR}/out/test/constexpr_tests"                   "${LINUX_OUTDIR}/out/test/"
COPY --from=linux-builder "${LINUX_WORKDIR}/out/test/relaxed_constexpr_tests"           "${LINUX_OUTDIR}/out/test/"
COPY --from=linux-builder "${LINUX_WORKDIR}/out/test/tests"                             "${LINUX_OUTDIR}/out/test/"

# -------------------------------------------------------------------------------------------------------------------- #
#                                                                                                                      #
# => [runner]                                                                                                          #
#                                                                                                                      #
# -------------------------------------------------------------------------------------------------------------------- #

FROM ${LINUX_ALPINE_IMAGE}:${LINUX_ALPINE_TAG} as linux-alpine-runner

RUN \
    --mount=type=cache,sharing=private,target=/var/cache/apk/ \
    --mount=type=cache,sharing=private,target=/var/lib/apk/ \
<<EOF
    apk update
    apk add \
        "libstdc++" \
        ;
EOF

# ----------------------------------------------------------------------------------------------------------------------

FROM ${LINUX_UBUNTU_IMAGE}:${LINUX_UBUNTU_TAG} as linux-ubuntu-runner

# ----------------------------------------------------------------------------------------------------------------------

FROM linux-${IMAGE}-runner as linux-runner

ARG LINUX_WORKDIR

COPY --from=linux-builder "${LINUX_WORKDIR}/out/src/ftxui_sample/intro" "/usr/local/bin/"

RUN \
<<EOF
    intro --version
EOF

CMD ["intro"]

# //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FROM scratch as dummy
