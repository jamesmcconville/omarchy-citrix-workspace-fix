#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$SCRIPT_DIR/citrix-workspace-compat.sh" install "$SCRIPT_DIR/citrix-compat.tar.gz"
