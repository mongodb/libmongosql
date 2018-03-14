#!/bin/bash

# shellcheck source=prepare-shell.sh
. "$(dirname "$0")/prepare-shell.sh"

# clear BISON_DIR
rm -rf "$BISON_DIR"
mkdir -p "$BISON_DIR"

# download and install bison
cd "$BISON_DIR"
curl -O https://noexpire.s3.amazonaws.com/sqlproxy/binary/windows/bison-2.4.1-setup.exe
chmod +x bison-2.4.1-setup.exe
./bison-2.4.1-setup.exe /VERYSILENT /DIR='C:\bison'
