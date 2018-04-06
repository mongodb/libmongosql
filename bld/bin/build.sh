#!/bin/bash
# Copyright (c) MongoDB, Inc. 2018-present.

# shellcheck source=prepare-shell.sh
. "$(dirname "$0")/prepare-shell.sh"

# if boost isn't already present, download it
if [ ! -d "$BOOST_DIR" ]; then
    rm -f "$BOOST_ARCHIVE"
    curl -o "$BOOST_ARCHIVE" "$BOOST_S3_URL"
    # need to supply --force-local because tar ascribes special meaning to colons in file names:
    # https://unix.stackexchange.com/questions/13377/tar-extraction-depends-on-filename/13381#13381
    tar xzf "$BOOST_ARCHIVE" -C "$ARTIFACTS_DIR" --force-local
    rm "$BOOST_ARCHIVE"
fi

# clear the MYSQL_HOME_DIR
rm -rf "$MYSQL_HOME_DIR"
mkdir -p "$MYSQL_HOME_DIR/lib"
mkdir -p "$MYSQL_HOME_DIR/include"
mkdir -p "$MYSQL_HOME_DIR/bin"

# clear BUILD_SRC_DIR
rm -rf "$BUILD_SRC_DIR"
mkdir -p "$BUILD_SRC_DIR"

# copy mysql source into BUILD_SRC_DIR
cp -r "$PROJECT_ROOT"/* "$BUILD_SRC_DIR"/ || true
rm -rf "$BUILD_SRC_DIR"/bld

# copy mongosql-auth source into BUILD_SRC_DIR
cp -r "$MONGOSQL_AUTH_ROOT"/src/mongosql-auth "$BUILD_SRC_DIR"/plugin/auth/
cat "$MONGOSQL_AUTH_ROOT"/src/CMakeLists.txt >> "$BUILD_SRC_DIR"/plugin/auth/CMakeLists.txt
cp "$MONGOSQL_AUTH_ROOT"/cmake/*.cmake "$BUILD_SRC_DIR"/cmake

# clear the BUILD_DIR
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# run CMake in the BUILD_DIR
cd "$BUILD_DIR"
if [ -n "$CMAKE_GENERATOR" ]; then
    cmake "$BUILD_SRC_DIR" -G "$CMAKE_GENERATOR" $CMAKE_ARGS
else
    cmake "$BUILD_SRC_DIR" $CMAKE_ARGS
fi

# build mysqlclient
eval $BUILD

# copy artifacts needed to build ODBC driver into MYSQL_HOME_DIR
mysqlclient='libmysqlclient.a'
if [ "$OS" = 'Windows_NT' ]; then
    mysqlclient='Release/mysqlclient.lib'
fi
cp "$BUILD_DIR"/libmysql/"$mysqlclient" "$MYSQL_HOME_DIR"/lib/
cp -r "$PROJECT_ROOT"/include "$MYSQL_HOME_DIR"/
cp -r "$BUILD_DIR"/include/* "$MYSQL_HOME_DIR"/include/
cp "$PROJECT_ROOT"/libbinlogevents/export/binary_log_types.h "$MYSQL_HOME_DIR"/include/
