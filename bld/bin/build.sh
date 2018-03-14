#!/bin/bash

# shellcheck source=prepare-shell.sh
. "$(dirname "$0")/prepare-shell.sh"

# clear the MYSQL_HOME_DIR
rm -rf "$MYSQL_HOME_DIR"
mkdir -p "$MYSQL_HOME_DIR/lib"
mkdir -p "$MYSQL_HOME_DIR/include"
mkdir -p "$MYSQL_HOME_DIR/bin"

# clear the BUILD_DIR
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# run CMake in the BUILD_DIR
cd "$BUILD_DIR"
cmake "$PROJECT_ROOT" -G "$CMAKE_GENERATOR" -DWITH_BOOST="$BOOST_DIR" -DDOWNLOAD_BOOST=1

# build mysqlclient
devenv.com MySQL.sln /Build Release /Project mysqlclient

# copy artifacts needed to build ODBC driver into MYSQL_HOME_DIR
cp "$BUILD_DIR"/libmysql/Release/mysqlclient.lib "$MYSQL_HOME_DIR"/lib/
cp -r "$PROJECT_ROOT"/include "$MYSQL_HOME_DIR"/
cp -r "$BUILD_DIR"/include/* "$MYSQL_HOME_DIR"/include/
cp "$PROJECT_ROOT"/libbinlogevents/export/binary_log_types.h "$MYSQL_HOME_DIR"/include/
