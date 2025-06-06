# Copyright (c) MongoDB, Inc. 2018-present.

if [ "$PLATFORM" = '' ]; then
    if [ "$OS" = 'Windows_NT' ]; then
        PLATFORM=win64
    else
        PLATFORM=macos
    fi
    echo "WARNING: no value provided for \$PLATFORM: using default of '$PLATFORM'"
fi

case "$PLATFORM" in
ubuntu1404-64)
    PLATFORM_ARCH='64'
    PLATFORM_NAME='linux'
    CMAKE_GENERATOR='Unix Makefiles'
    CMAKE_PATH='/opt/cmake/bin'
    ICU_PLATFORM='Linux'
    VARIANT='ubuntu1404-64'
    ;;
ubuntu1604-64)
    PLATFORM_ARCH='64'
    PLATFORM_NAME='linux'
    CMAKE_GENERATOR='Unix Makefiles'
    CMAKE_PATH='/opt/cmake/bin'
    ICU_PLATFORM='Linux'
    VARIANT='ubuntu1604-64'
    ;;
rhel70)
    PLATFORM_ARCH='64'
    PLATFORM_NAME='linux'
    CMAKE_GENERATOR='Unix Makefiles'
    CMAKE_PATH='/opt/cmake/bin'
    ICU_PLATFORM='Linux'
    VARIANT='rhel70'
    ;;
rhel80)
    PLATFORM_ARCH='64'
    PLATFORM_NAME='linux'
    CMAKE_GENERATOR='Unix Makefiles'
    CMAKE_PATH='/opt/cmake/bin'
    ICU_PLATFORM='Linux'
    VARIANT='rhel80'
    ;;
macos)
    PLATFORM_ARCH='64'
    PLATFORM_NAME='darwin'
    CMAKE_GENERATOR='Unix Makefiles'
    CMAKE_PATH='/Applications/Cmake.app/Contents/bin'
    ICU_PLATFORM='MacOSX'
    VARIANT='macos'
    ;;
win32)
    PLATFORM_ARCH='32'
    PLATFORM_NAME='windows'
	# Use OpenSSL on Windows.
    CMAKE_ARGS="$CMAKE_ARGS -DWITH_SSL=C:/openssl32/openssl-1_0_2k"
    CMAKE_PATH='/cygdrive/c/cmake/bin'
    CMAKE_GENERATOR='Visual Studio 14 2015'
    DEVENV_PATH='/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 14.0/Common7/IDE'
    BISON_PATH='/cygdrive/c/bison/bin'
    ICU_PLATFORM='Cygwin/MSVC'
    VARIANT='windows-32'
    ;;
win64)
    PLATFORM_ARCH='64'
    PLATFORM_NAME='windows'
	# Use OpenSSL on Windows.
    CMAKE_ARGS="$CMAKE_ARGS -DWITH_SSL=C:/openssl"
    CMAKE_GENERATOR='Visual Studio 14 2015 Win64'
    CMAKE_PATH='/cygdrive/c/cmake/bin'
    DEVENV_PATH='/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 14.0/Common7/IDE'
    BISON_PATH='/cygdrive/c/bison/bin'
    ICU_PLATFORM='Cygwin/MSVC'
    VARIANT='windows-64'
    ;;
*)
    echo "ERROR: invalid value for \$PLATFORM: '$PLATFORM'"
    echo "Allowed values: 'win64', 'win32', 'macos', 'rhel70', 'rhel80', 'ubuntu1404-64', 'ubuntu1604-64'"
    exit 1
    ;;
esac
