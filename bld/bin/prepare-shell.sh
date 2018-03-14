# This file should be sourced by all scripts in bld/bin

# we start by sourcing platforms.sh. this will set environment variables that
# differ depending on which platform we are building on
# shellcheck source=platforms.sh
. "$(dirname "$0")/platforms.sh"

# create variables for a number of useful directories
SCRIPT_DIR=$(dirname $(readlink -f $0))
PROJECT_ROOT="$SCRIPT_DIR/../.."
BUILD_DIR="$PROJECT_ROOT/bld/build"
ARTIFACTS_DIR="$PROJECT_ROOT/bld/artifacts"
BOOST_DIR="$ARTIFACTS_DIR/boost"
BISON_DIR="$ARTIFACTS_DIR/bison"
MYSQL_HOME_DIR="$ARTIFACTS_DIR/mysql-home"

# fix paths for cygwin
if [ "$PLATFORM_NAME" = "windows" ]; then
    SCRIPT_DIR="$(cygpath -w "$SCRIPT_DIR")"
    PROJECT_ROOT="$(cygpath -w "$PROJECT_ROOT")"
    ARTIFACTS_DIR="$(cygpath -w "$ARTIFACTS_DIR")"
    BOOST_DIR="$(cygpath -w "$BOOST_DIR")"
    BISON_DIR="$(cygpath -w "$BISON_DIR")"
    MYSQL_HOME_DIR="$(cygpath -w "$MYSQL_HOME_DIR")"
fi

# set the CMake generator
CMAKE_GENERATOR="Visual Studio 12 2013"
if [ "$PLATFORM_ARCH" = "64" ]; then
    CMAKE_GENERATOR="$CMAKE_GENERATOR Win64"
fi

# make sure binaries we use in our scripts are available in the PATH
DEVENV_PATH='/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 12.0/Common7/IDE'
BISON_PATH='/cygdrive/c/bison/bin'
CMAKE_PATH='/cygdrive/c/cmake/bin'
PATH="$PATH:$DEVENV_PATH:$BISON_PATH:$CMAKE_PATH"

# export any environment variables that will be needed by subprocesses
export PATH

# Each script should run with errexit set and should start in the project root.
# In general, scripts should reference directories via the provided environment
# variables instead of making assumptions about the working directory.
set -o errexit
cd "$PROJECT_ROOT"
