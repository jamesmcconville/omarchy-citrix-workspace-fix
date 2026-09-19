# Citrix Workspace Fix For Omarchy

This fixes Citrix Workspace on current Arch-based Omarchy installations when Workspace opens and immediately exits, or does not open at all.

## What This Fixes

The affected Citrix build expects libraries that are no longer installed by current Arch packages:

- `libxml2.so.2`
- WebKitGTK 4.0
- Soup 2.4
- Older ICU and HarfBuzz libraries

The fix installs those libraries in Citrix's private directory. It does not replace or downgrade system libraries.

## Important: This Repository Does Not Include Binaries

The public repository contains the installer scripts only. The compatibility archive contains third-party binary libraries and is intentionally excluded from GitHub.

You need a `citrix-compat.tar.gz` made on a machine where this fix is already working, or from a separately obtained compatible Citrix package.

## Recommended Workflow

### 1. Prepare A Working Machine

On an Omarchy machine where Citrix is working and `/opt/Citrix/ICAClient/lib/compat` exists, clone this repository and export the runtime:

```bash
git clone https://github.com/jamesmcconville/omarchy-citrix-workspace-fix.git
cd omarchy-citrix-workspace-fix
chmod +x citrix-workspace-compat.sh
./citrix-workspace-compat.sh export citrix-compat.tar.gz
```

Create a portable package containing the scripts and runtime:

```bash
tar -czf citrix-workspace-fix.tar.gz \
  citrix-workspace-compat.sh install.sh README.md citrix-compat.tar.gz
```

Copy `citrix-workspace-fix.tar.gz` to the target machine.

### 2. Install Citrix On The Target Machine

Install the same Citrix Workspace version at `/opt/Citrix/ICAClient` before applying this fix. Then extract and run the installer:

```bash
tar -xzf citrix-workspace-fix.tar.gz
chmod +x install.sh
./install.sh
```

The installer will:

1. Install the required Arch packages: `libxml2-legacy`, `hyphen`, and `libmanette`.
2. Restore the private compatibility libraries.
3. Create the corrected Citrix launcher and desktop entry.

Log out and back in, or restart the application launcher, if Citrix does not immediately appear in the application menu.

## Verify The Fix

Launch **Citrix Workspace** from the application menu, or run:

```bash
~/.local/bin/citrix-workspace
```

The process should remain running instead of exiting with a shared-library error.

To check dependencies directly:

```bash
LD_LIBRARY_PATH=/opt/Citrix/ICAClient/lib/compat/lib/x86_64-linux-gnu:/opt/Citrix/ICAClient/lib/compat/usr/lib/x86_64-linux-gnu:/opt/Citrix/ICAClient/lib/compat/webkit2gtk-4.0-package/usr/lib/x86_64-linux-gnu:/opt/Citrix/ICAClient/lib:/usr/lib \
  ldd /opt/Citrix/ICAClient/selfservice | grep 'not found'
```

No output means all required libraries were found.

## Different Citrix Install Location

The default location is `/opt/Citrix/ICAClient`. If Citrix is installed elsewhere, pass the location during installation:

```bash
ICA_ROOT=/path/to/ICAClient ./install.sh
```

The compatibility archive must come from the same Citrix Workspace build. Re-export it when the Citrix version changes.

## If It Still Does Not Work

Run the launcher from a terminal and capture the error:

```bash
~/.local/bin/citrix-workspace 2>&1 | tee citrix-workspace.log
```

Check that the Citrix executable exists:

```bash
ls -l /opt/Citrix/ICAClient/selfservice
```
