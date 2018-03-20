# Copyright (c) MongoDB, Inc. 2018-present.

# This file should be sourced by all scripts in bld/bin

# we start by sourcing platforms.sh. this will set environment variables that
# differ depending on which platform we are building on
# shellcheck source=platforms.sh
. "$(dirname "$0")/platforms.sh"

# create variables for a number of useful directories
SCRIPT_DIR=$(dirname $(readlink -f $0))
if [ "$OS" = "Windows_NT" ]; then
    SCRIPT_DIR="$(cygpath -m "$SCRIPT_DIR")"
fi
PROJECT_ROOT="$SCRIPT_DIR/../.."
BUILD_DIR="$PROJECT_ROOT/bld/build"
BUILD_SRC_DIR="$PROJECT_ROOT/bld/src"
ARTIFACTS_DIR="$PROJECT_ROOT/bld/artifacts"
BOOST_DIR="$ARTIFACTS_DIR/boost"
BISON_DIR="$ARTIFACTS_DIR/bison"
MYSQL_HOME_DIR="$ARTIFACTS_DIR/mysql-home"
MONGOSQL_AUTH_ROOT="$PROJECT_ROOT/bld/mongosql-auth-c"

# make sure binaries we use in our scripts are available in the PATH
PATH="$PATH:$DEVENV_PATH:$BISON_PATH:$CMAKE_PATH"

# set the cmake arguments
CMAKE_ARGS="-DWITH_BOOST=$BOOST_DIR -DDOWNLOAD_BOOST=1"

# set the build command
if [ "$OS" = 'Windows_NT' ]; then
    BUILD='devenv.com MySQL.sln /Build Release /Project mysqlclient'
else
    BUILD='make mysqlclient'
fi

# export any environment variables that will be needed by subprocesses
export PATH

# Each script should run with errexit set and should start in the project root.
# In general, scripts should reference directories via the provided environment
# variables instead of making assumptions about the working directory.
set -o errexit
cd "$PROJECT_ROOT"
