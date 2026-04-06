# AppImage Management

A lightweight system for managing AppImages as proper desktop apps — with launcher icons, app menu entries, URI scheme handlers, and a clean update workflow — without the friction of manually editing `.desktop` files each time.

## What It Sets Up

```
~/Applications/                              ← home for all AppImages
~/.local/bin/appimage-install                ← install any AppImage as a desktop app
~/.local/bin/appimage-update                 ← update an installed AppImage
~/.local/bin/appimage-uninstall              ← remove an installed AppImage
```

## Installation

From the repo root:

```bash
cd appimages && ./install.sh
```

Or as part of the master installer:

```bash
./install.sh   # choose "AppImage Management" when prompted
```

### Dependencies

Both scripts rely on standard tools that ship with any GNOME/KDE desktop. If for some reason they're missing:

| Tool                    | Debian/Ubuntu        | Arch               | Fedora               |
|-------------------------|----------------------|--------------------|----------------------|
| `update-desktop-database` | `desktop-file-utils` | `desktop-file-utils` | `desktop-file-utils` |
| `gtk-update-icon-cache`   | `libgtk-3-bin`       | `gtk3`             | `gtk3`               |

---

## Usage

### Installing a new AppImage

```bash
appimage-install ~/Downloads/SomeApp-1.2.3.AppImage
```

The script will:
1. Suggest a name derived from the filename (e.g. `some-app`) — confirm or type your own
2. Move the file to `~/Applications/<name>.AppImage`
3. Extract the icon and metadata bundled inside the AppImage
4. Write `~/.local/share/applications/<name>.desktop`
5. Refresh the desktop database and icon cache

The app appears in the launcher immediately.

### Removing an installed AppImage

```bash
appimage-uninstall <name>
```

Shows every file that will be deleted (AppImage, desktop entry, icon) and prompts for confirmation before touching anything. Defaults to **No** — you must explicitly type `y`.

```bash
appimage-uninstall -y <name>   # skip confirmation (for scripting)
```

### Updating an installed AppImage

```bash
appimage-update <name> ~/Downloads/NewVersion.AppImage
```

Examples:
```bash
appimage-update obsidian    ~/Downloads/Obsidian-2.0.0.AppImage
appimage-update capacities  ~/Downloads/Capacities-2.0.0.AppImage
appimage-update t3code      ~/Downloads/t3code-0.0.16.AppImage
```

The script will:
1. Replace `~/Applications/<name>.AppImage` with the new file
2. Refresh the icon from the new build
3. Update the version field in the existing `.desktop` entry
4. Refresh caches

---

## How It Works

### Why `~/Applications/`

AppImages need a stable path that desktop entries can point to. `~/Downloads/` gets cleaned periodically; `~/Applications/` is the dedicated, permanent home. This mirrors the macOS convention and keeps Downloads uncluttered.

### Desktop Entries (`.desktop` files)

The XDG Desktop Entry spec is how Linux launchers (GNOME, KDE, etc.) know about apps. Each `.desktop` file in `~/.local/share/applications/` defines:

- `Name` — label shown in the launcher
- `Exec` — what to run (points to `~/Applications/<name>.AppImage --no-sandbox %U`)
- `Icon` — absolute path to the PNG (bypasses icon theme lookup, always works)
- `StartupWMClass` — used by the dock to group windows under the right launcher icon
- `MimeType` — registers URI scheme handlers (e.g. `obsidian://`, `capacities://`)

### `--no-sandbox`

Both scripts append `--no-sandbox` to the `Exec` line. Electron apps (most AppImages) require this when running from an AppImage because the Chromium sandbox needs kernel namespace privileges that the AppImage runtime doesn't grant. System-installed `.deb` packages ship a setuid `chrome-sandbox` binary that handles this differently.

### Icon Resolution

Icons are installed with an absolute path (`Icon=/home/.../.../name.png`) rather than a theme name. This bypasses the icon theme cache lookup entirely — more reliable across distros and desktop environments, and consistent with how other locally-installed apps (Zed, Kitty) work on this system.

### The `appimage-install` name suggestion

The script strips version patterns from the filename and lowercases the result:

| Raw filename                  | Suggested name  |
|-------------------------------|-----------------|
| `Capacities-1.60.1.AppImage`  | `capacities`    |
| `Obsidian-1.7.3.AppImage`     | `obsidian`      |
| `T3Code-0.0.15.AppImage`      | `t3code`        |
| `Some-App_v2.0-beta.AppImage` | `some-app`      |

You can override it at the prompt.

---

Use `ls ~/Applications/` to see installed AppImages on this machine.

---

## Replicating on a New Machine

On a fresh install, run `./install.sh` from the repo root (or `appimages/install.sh` directly). Then re-download your AppImages and run `appimage-install` for each:

```bash
appimage-install ~/Downloads/Obsidian-x.x.x.AppImage
appimage-install ~/Downloads/Capacities-x.x.x.AppImage
# etc.
```

Desktop entries and icons are regenerated from the AppImage contents — nothing else needs to be copied over.
