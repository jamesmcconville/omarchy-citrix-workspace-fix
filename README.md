# Citrix Workspace Compatibility Fix

This fixes Citrix Workspace on current Arch-based Omarchy installations when the installed Citrix build fails with missing legacy libraries such as `libxml2.so.2` or WebKitGTK 4.0.

The fix keeps old libraries private to Citrix. It does not replace current system libraries.

## Build The Portable Package

On a working instance, run:

```bash
chmod +x citrix-workspace-compat.sh
./citrix-workspace-compat.sh export citrix-compat.tar.gz
tar -czf citrix-workspace-fix.tar.gz \
  citrix-workspace-compat.sh install.sh README.md citrix-compat.tar.gz
```

This creates a self-contained `citrix-workspace-fix.tar.gz` package.

## Install On The Other Instance

Install the same Citrix Workspace package first, then copy and extract the package:

```bash
tar -xzf citrix-workspace-fix.tar.gz
chmod +x install.sh
./install.sh
```

The script installs the required Arch packages, restores the compatibility runtime under `/opt/Citrix/ICAClient/lib/compat`, and creates the desktop launcher.

Manual installation is also available:

```bash
chmod +x citrix-workspace-compat.sh
./citrix-workspace-compat.sh install citrix-compat.tar.gz
```

The Citrix installation must be at `/opt/Citrix/ICAClient`. To use another location:

```bash
ICA_ROOT=/path/to/ICAClient ./citrix-workspace-compat.sh install citrix-compat.tar.gz
```

The compatibility archive is specific to the Citrix build it was exported from. Re-export it if the Citrix Workspace version changes.
