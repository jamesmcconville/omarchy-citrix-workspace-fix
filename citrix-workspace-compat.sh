#!/bin/sh
set -eu

ICA_ROOT=${ICA_ROOT:-/opt/Citrix/ICAClient}
COMPAT_DIR="$ICA_ROOT/lib/compat"

usage() {
    printf '%s\n' \
        "Usage:" \
        "  $0 export ARCHIVE.tar.gz" \
        "  $0 install ARCHIVE.tar.gz"
    exit 2
}

[ "$#" -eq 2 ] || usage
ACTION=$1
ARCHIVE=$2

case "$ACTION" in
    export)
        [ -d "$COMPAT_DIR" ] || {
            printf 'Missing compatibility directory: %s\n' "$COMPAT_DIR" >&2
            exit 1
        }
        tar -C "$ICA_ROOT/lib" -czf "$ARCHIVE" compat
        printf 'Created %s\n' "$ARCHIVE"
        ;;
    install)
        [ -f "$ARCHIVE" ] || {
            printf 'Archive not found: %s\n' "$ARCHIVE" >&2
            exit 1
        }
        [ -x "$ICA_ROOT/selfservice" ] || {
            printf 'Citrix Workspace is not installed at %s\n' "$ICA_ROOT" >&2
            exit 1
        }

        sudo pacman -S --needed --noconfirm libxml2-legacy hyphen libmanette
        sudo mkdir -p "$ICA_ROOT/lib"
        sudo tar -xzf "$ARCHIVE" -C "$ICA_ROOT/lib"

        USER_NAME=${SUDO_USER:-$USER}
        USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)
        [ -n "$USER_HOME" ] || {
            printf 'Could not determine home directory for %s\n' "$USER_NAME" >&2
            exit 1
        }

        sudo install -d -m 755 "$USER_HOME/.local/bin" "$USER_HOME/.local/share/applications"
        sudo tee "$USER_HOME/.local/bin/citrix-workspace" >/dev/null <<EOF
#!/bin/sh

ICA_ROOT=$ICA_ROOT
COMPAT_ROOT="\$ICA_ROOT/lib/compat"
export LD_LIBRARY_PATH="\$COMPAT_ROOT/lib/x86_64-linux-gnu:\$COMPAT_ROOT/usr/lib/x86_64-linux-gnu:\$COMPAT_ROOT/webkit2gtk-4.0-package/usr/lib/x86_64-linux-gnu:\$ICA_ROOT/lib:/usr/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export WEBKIT_EXEC_PATH="\$COMPAT_ROOT/webkit2gtk-4.0-package/usr/lib/x86_64-linux-gnu/webkit2gtk-4.0"

exec "\$ICA_ROOT/selfservice" --icaroot "\$ICA_ROOT" "\$@"
EOF
        sudo chmod 755 "$USER_HOME/.local/bin/citrix-workspace"
        sudo tee "$USER_HOME/.local/share/applications/selfservice.desktop" >/dev/null <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=Citrix Workspace
Categories=Application;Network;X-Red-Hat-Base;X-SuSE-Core-Internet;
Icon=$ICA_ROOT/icons/receiver.png
TryExec=$USER_HOME/.local/bin/citrix-workspace
Exec=$USER_HOME/.local/bin/citrix-workspace
EOF
        sudo chown "$USER_NAME:$USER_NAME" \
            "$USER_HOME/.local/bin/citrix-workspace" \
            "$USER_HOME/.local/share/applications/selfservice.desktop"
        update-desktop-database "$USER_HOME/.local/share/applications" 2>/dev/null || true
        printf 'Citrix compatibility runtime installed for %s\n' "$USER_NAME"
        ;;
    *)
        usage
        ;;
esac
