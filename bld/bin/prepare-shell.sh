# Copyright (c) MongoDB, Inc. 2018-present.

# This file should be sourced by all scripts in bld/bin

# we start by sourcing platforms.sh. this will set environment variables that
# differ depending on which platform we are building on
# shellcheck source=platforms.sh
. "$(dirname "$0")/platforms.sh"

# create variables for a number of useful directories
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
if [ "$OS" = "Windows_NT" ]; then
    SCRIPT_DIR="$(cygpath -m "$SCRIPT_DIR")"
fi
PROJECT_ROOT="$SCRIPT_DIR"/../..
BUILD_DIR="$PROJECT_ROOT/bld/build"
BUILD_SRC_DIR="$PROJECT_ROOT/bld/src"
ARTIFACTS_DIR="$PROJECT_ROOT/bld/artifacts"
BISON_DIR="$ARTIFACTS_DIR/bison"
MYSQL_HOME_DIR="$ARTIFACTS_DIR/mysql-home"
MONGOSQL_AUTH_ROOT="$PROJECT_ROOT/bld/mongosql-auth-c"

BOOST_BASENAME='boost_1_59_0'
BOOST_ARCHIVE_FILENAME="$BOOST_BASENAME.tar.gz"
BOOST_ARCHIVE="$ARTIFACTS_DIR/$BOOST_ARCHIVE_FILENAME"
BOOST_S3_URL="http://noexpire.s3.amazonaws.com/sqlproxy/sources/$BOOST_ARCHIVE_FILENAME"
BOOST_DIR="$ARTIFACTS_DIR/$BOOST_BASENAME"

# make sure binaries we use in our scripts are available in the PATH
PATH="$PATH:$DEVENV_PATH:$BISON_PATH:$CMAKE_PATH"

# add boost to the cmake arguments
CMAKE_ARGS="$CMAKE_ARGS -DWITH_BOOST=$BOOST_DIR"
platform="$(uname)"
if [ "Linux" = "$platform" ]; then
	# add system SSL (OpenSSL) to any Linux distro's cmake args.
    CMAKE_ARGS="$CMAKE_ARGS -DWITH_SSL=system"
fi

# set the build command
if [ "$OS" = 'Windows_NT' ]; then
	# also set the windows CMAKE to use OpenSSL
    BUILD='devenv.com MySQL.sln /Build Release /Project mysqlclient'
    BUILD_UNIT_TESTS='devenv.com MySQL.sln /Build Release /Project wildcard_hostname_validation_unit_tests'
    RUN_UNIT_TESTS="$BUILD_DIR/Release/wildcard_hostname_validation_unit_tests.exe"
else
    BUILD='make mysqlclient -j4'
    BUILD_UNIT_TESTS='make wildcard_hostname_validation_unit_tests'
    RUN_UNIT_TESTS="$BUILD_DIR/wildcard_hostname_validation_unit_tests"
fi

# export any environment variables that will be needed by subprocesses
export PATH

# Each script should run with errexit set and should start in the project root.
# In general, scripts should reference directories via the provided environment
# variables instead of making assumptions about the working directory.
set -o errexit
cd "$PROJECT_ROOT"
