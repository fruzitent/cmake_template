@REM TODO: Docker Desktop v4.29.0 (buildkit v0.13.0)

@REM @see: https://github.com/microsoft/Windows-Containers/issues/389
@REM @see: https://uupdump.net/download.php?id=6d94591b-25ff-41d9-a6dc-37a152fac397&pack=en-us&edition=serverstandardcore
@REM TODO: --opt "platform=windows/amd64,windows/arm64"

call :servercore ^
    --opt "build-arg:TARGETARCH=amd64" ^
    --opt "target=windows-servercore-base" ^
    --output "name=ghcr.io/cpp-best-practices/cmake_template:latest-servercore,push=false,type=image" ^
    &

call :servercore ^
    --opt "build-arg:TARGETARCH=arm64" ^
    --opt "target=windows-servercore-base" ^
    --output "name=ghcr.io/cpp-best-practices/cmake_template:latest-servercore,push=false,type=image" ^
    &

goto :eof

:servercore
    buildctl build ^
        --frontend "dockerfile.v0" ^
        --local "context=./" ^
        --local "dockerfile=./docker/" ^
        --opt "filename=./Dockerfile" ^
        --opt "build-arg:IMAGE=servercore" ^
        --opt "build-arg:STRATEGY=native" ^
        --export-cache "type=inline" ^
        --import-cache "ref=ghcr.io/cpp-best-practices/cmake_template:latest-servercore,type=registry" ^
        %* || exit /b 1
