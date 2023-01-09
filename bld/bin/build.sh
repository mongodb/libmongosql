#!/bin/bash
# Copyright (c) MongoDB, Inc. 2018-present.

# shellcheck source=prepare-shell.sh
. "$(dirname "$0")/prepare-shell.sh"

# if boost isn't already present, download it.
if [ ! -d "$BOOST_DIR" ]; then
    mkdir -p "$ARTIFACTS_DIR"
    rm -f "$BOOST_ARCHIVE"
    curl -o "$BOOST_ARCHIVE" "$BOOST_S3_URL"
    # need to supply --force-local because tar ascribes special meaning to colons in file names:
    # https://unix.stackexchange.com/questions/13377/tar-extraction-depends-on-filename/13381#13381
    if [ "$OS" = "Windows_NT" ]; then
        tar xzf "$BOOST_ARCHIVE" -C "$ARTIFACTS_DIR" --force-local
    else
        tar xzf "$BOOST_ARCHIVE" -C "$ARTIFACTS_DIR"
    fi
    rm "$BOOST_ARCHIVE"
fi

if [ -e "$MYSQL_HOME_DIR" ]; then
    echo "cleaning $MYSQL_HOME_DIR"
    rm -rf "$MYSQL_HOME_DIR"
fi
echo "creating $MYSQL_HOME_DIR tree"
mkdir -p "$MYSQL_HOME_DIR/lib"
mkdir -p "$MYSQL_HOME_DIR/include"
mkdir -p "$MYSQL_HOME_DIR/bin"

if [ -e "$BUILD_SRC_DIR" ]; then
    echo "cleaning $BUILD_SRC_DIR"
    rm -rf "$BUILD_SRC_DIR" || true
fi
echo "creating $BUILD_SRC_DIR tree"
mkdir -p "$BUILD_SRC_DIR"

# copy mysql source into BUILD_SRC_DIR.
echo "copying $PROJECT_ROOT into $BUILD_SRC_DIR"
for x in "$PROJECT_ROOT"/*; do
    if [ ! "$(basename "$x")" = bld ]; then
        echo "...copying $x to $BUILD_SRC_DIR"
        cp -r "$x" "$BUILD_SRC_DIR"/
    fi
done

# copy mongosql-auth source into BUILD_SRC_DIR.
cp -r "$MONGOSQL_AUTH_ROOT"/src/mongosql-auth "$BUILD_SRC_DIR"/plugin/auth/
cat "$MONGOSQL_AUTH_ROOT"/src/CMakeLists.txt >> "$BUILD_SRC_DIR"/plugin/auth/CMakeLists.txt
cp "$MONGOSQL_AUTH_ROOT"/cmake/*.cmake "$BUILD_SRC_DIR"/cmake

export ICU_DIR="$ARTIFACTS_DIR/icu"
export ICU_SRC_DIR="$ICU_DIR/icu/source"
export ICU_BUILD_DIR="$ICU_DIR/build"
export ENABLE_ICU='ON'
export CMAKE_ICU_ARGS="-DENABLE_ICU=$ENABLE_ICU -DICU_ROOT=$ICU_BUILD_DIR -DICU_INCLUDE_DIR=$ICU_SRC_DIR/common"
export CMAKE_ARGS="$CMAKE_ARGS $CMAKE_ICU_ARGS"

$PROJECT_ROOT/bld/bin/build-icu.sh

# clear the BUILD_DIR.
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

if [ "$PLATFORM" = macos ]; then
    SSL_DIR="$BUILD_DIR/1.0.2n"
    cd "$BUILD_DIR"
    curl -O https://mongo-bic-odbc-driver-resources.s3.amazonaws.com/macos/openssl-1.0.2n.zip
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "$PWD"
    echo "???????????????????????????????"
    unzip openssl-1.0.2n.zip
    echo "PWD $PWD"
    ls "."
    ls "___________________________________"
    echo "$SSL_DIR"
    ls "$SSL_DIR"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    CMAKE_ARGS="$CMAKE_ARGS -DWITH_SSL=$SSL_DIR -DCMAKE_VERBOSE_MAKEFILE=ON"
fi

echo "$CMAKE_ARGS"

# run CMake in the BUILD_DIR.
cd "$BUILD_DIR"
if [ -n "$CMAKE_GENERATOR" ]; then
    # shellcheck disable=SC2086
    cmake "$BUILD_SRC_DIR" -G "$CMAKE_GENERATOR" $CMAKE_ARGS
else
    # shellcheck disable=SC2086
    cmake "$BUILD_SRC_DIR" $CMAKE_ARGS
fi

# build mysqlclient and the unit test binary.  the following eval statements
# need to be unquoted because we want the shell to split on white space.
# Shellcheck wants us to quote references, so we need to supress the warnings
# for SC2086.
# shellcheck disable=SC2086
eval $BUILD
# shellcheck disable=SC2086
eval $BUILD_UNIT_TESTS

# copy artifacts needed to build ODBC driver into MYSQL_HOME_DIR.
mysqlclient='libmysqlclient.a'
if [ "$OS" = 'Windows_NT' ]; then
    mysqlclient='Release/mysqlclient.lib'
fi
if [ -e "$BUILD_DIR"/libmysql/"$mysqlclient" ]; then
    cp "$BUILD_DIR"/libmysql/"$mysqlclient" "$MYSQL_HOME_DIR"/lib/
else
    cp "$BUILD_DIR"/archive_output_directory/"$mysqlclient" "$MYSQL_HOME_DIR"/lib/
fi
cp -r "$PROJECT_ROOT"/include "$MYSQL_HOME_DIR"/
cp -r "$BUILD_DIR"/include/* "$MYSQL_HOME_DIR"/include/
cp "$PROJECT_ROOT"/libbinlogevents/export/binary_log_types.h "$MYSQL_HOME_DIR"/include/
