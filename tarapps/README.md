# Tarball App Management

A lightweight system for installing `.tar.gz` desktop apps (Electron IDEs, browsers, and other portable Linux builds) as proper desktop apps — with launcher icons, app menu entries, and a clean update/uninstall workflow — without manually extracting archives and hand-editing `.desktop` files each time.

This is the tarball sibling of the [`appimages/`](../appimages/README.md) module. Same conventions, adapted for the differences between a single AppImage file and a multi-file extracted folder.

## What It Sets Up

```
/opt/<App-dir>/                              ← extracted app payload (system-wide)
/usr/local/bin/<name>                        ← symlink so you can launch from any terminal
~/.local/share/applications/<name>.desktop   ← app menu entry
~/.local/share/icons/hicolor/512x512/apps/   ← launcher icon
~/.local/bin/tar-install                      ← install any tarball app as a desktop app
~/.local/bin/tar-update                       ← update an installed tarball app
~/.local/bin/tar-uninstall                    ← remove an installed tarball app
```

## Installation

From the repo root:

```bash
cd tarapps && ./install.sh
```

Or as part of the master installer:

```bash
./install.sh   # choose "Tarball App Management" when prompted
```

### Dependencies

| Tool                      | Debian/Ubuntu        | Arch                 | Fedora               |
|---------------------------|----------------------|----------------------|----------------------|
| `update-desktop-database` | `desktop-file-utils` | `desktop-file-utils` | `desktop-file-utils` |
| `gtk-update-icon-cache`   | `libgtk-3-bin`       | `gtk3`               | `gtk3`               |
| `tar`                     | `tar`                | `tar`                | `tar`                |

`node`/`npx` is **optional** — used only to pull an icon out of an Electron `app.asar` when the archive ships no loose icon.

---

## Usage

### Installing a new tarball app

```bash
tar-install ~/Downloads/Antigravity.tar.gz
```

The script will:
1. Inspect the archive and suggest a name from its top-level folder (e.g. `Antigravity-x64` → `antigravity`) — confirm or type your own
2. Extract to `/opt/<App-dir>` (asks for sudo)
3. Detect the launchable binary inside the folder
4. For Electron apps, setuid-root `chrome-sandbox` so the app runs **with** its sandbox
5. Symlink the binary to `/usr/local/bin/<name>`
6. Extract an icon — from the tree if present, otherwise from `resources/app.asar`
7. Write `~/.local/share/applications/<name>.desktop`
8. Refresh caches, **delete the source `.tar.gz`**, and clean up every temp file

The app appears in the launcher immediately.

### Removing an installed app

```bash
tar-uninstall <name>
```

Shows every file that will be deleted (the `/opt` dir, symlink, icon, desktop entry) and prompts before touching anything. Defaults to **No**.

```bash
tar-uninstall -y <name>   # skip confirmation (for scripting)
```

### Updating an installed app

```bash
tar-update <name> ~/Downloads/NewVersion.tar.gz
```

Swaps the `/opt` payload, re-applies the sandbox bit, refreshes the icon, fixes the `Exec` path if the folder name changed, and removes the source tarball.

---

## How It Works

### Why `/opt` (not `~/Applications`)

`~/Applications` is for **single-file AppImages**. A tarball app explodes into a directory tree (the Antigravity build is 382 files), so it needs a real install root. `/opt` is the FHS-conventional home for self-contained third-party software, and being root-owned it lets us set the one permission Electron's sandbox requires (below). The whole tree is removed on uninstall, so nothing lingers.

### `chrome-sandbox` and the setuid bit

Chromium-based apps (Electron — Antigravity, VS Code forks, Discord, …) ship a helper called `chrome-sandbox` that **must** be owned by `root` with the setuid bit (`chmod 4755`) or the app refuses to launch. Installing into `/opt` with sudo lets us set this, so the app runs with its security sandbox intact.

> This is the **inverse** of the AppImage module, which appends `--no-sandbox`: an AppImage can't setuid its bundled sandbox, so it disables it. A `/opt` install can do it properly.

### Icon Resolution

Tarballs rarely ship a loose icon or a `.desktop` file. The script first looks for a PNG in the extracted tree; if none is found and the app is Electron, it extracts `icon.png` from `resources/app.asar` via `@electron/asar`. Icons are written with an **absolute path** (`Icon=/home/.../<name>.png`), bypassing icon-theme lookup — consistent with the AppImage module and the other locally-installed apps on this system.

### The name suggestion

The top-level archive folder is stripped of arch/version suffixes and lowercased:

| Archive top folder      | Suggested name |
|-------------------------|----------------|
| `Antigravity-x64`       | `antigravity`  |
| `SomeApp-1.2.3-x86_64`  | `someapp`      |
| `cursor-0.40-linux`     | `cursor`       |

You can override it at the prompt.

### `find_binary` — the one heuristic worth tuning

A tarball folder contains many executables (the app, `chrome-sandbox`, `chrome_crashpad_handler`, `*.so`…). Only one is the thing to launch. `bin/tar-install` picks it in `find_binary()`:

1. an executable whose name matches the install name (e.g. `antigravity`), else
2. the first top-level executable that isn't a known Chromium helper or shared asset.

That covers Electron/VS Code-style builds. If you install apps with a different layout (binary in a `bin/` subdir, a wrapper script, etc.), `find_binary()` is the ~10-line function to adjust — everything else keys off its output. If you change it in `tar-install`, mirror the change in `tar-update`.

### No footprints

Every script extracts into `/tmp/<tool>-$$` and wipes it via a `trap … EXIT`, so temp files are removed even on failure or Ctrl-C. Installs delete the source tarball on success; uninstalls remove the `/opt` dir, symlink, icon, and desktop entry. `npx` may leave its usual package cache under `~/.npm` — that's npm's cache, not an app artifact.

---

## Replicating on a New Machine

Run `./install.sh` from the repo root (or `tarapps/install.sh` directly), then re-download and install each app:

```bash
tar-install ~/Downloads/Antigravity.tar.gz
# etc.
```
