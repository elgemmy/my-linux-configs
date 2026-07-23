# Disposable desktop acceptance VMs

Use two virtual machines for the final, human-visible checks:

1. Debian stable with Cinnamon
2. Debian stable with GNOME

Using the same Debian release isolates desktop-environment differences. The
container matrix already covers Ubuntu package compatibility.

## Host prerequisites

Install a KVM/libvirt frontend such as GNOME Boxes or Virtual Machine Manager.
Hardware virtualization should be enabled in firmware. Allocate approximately
4 CPU threads, 8 GiB RAM, and a 40 GiB dynamically allocated disk per VM.

Download one current Debian amd64 installer ISO. During installation, create a
normal user with sudo access. Select Cinnamon for one VM and GNOME for the
other; keep other optional desktop environments unchecked.

## Create reusable clean states

For each VM:

1. Complete Debian installation and apply system updates.
2. Install `git` if the installer did not include it.
3. Shut down the VM.
4. Name a snapshot `clean-debian-cinnamon` or `clean-debian-gnome`.

Before every acceptance run, restore the clean snapshot. Do not pre-clone either
configuration repository. The point is to prove the same zero-state path used
on a new personal machine.

## Run an acceptance test

Inside the restored VM, install the single download prerequisite and use the
fresh-machine entrypoint:

```bash
sudo apt-get update
sudo apt-get install -y curl
curl -fsSL https://raw.githubusercontent.com/elgemmy/my-linux-configs/testing-deb-vm/bootstrap.sh | bash

cd ~/.local/share/my-linux-configs
./tests/run.sh
./setup.sh --profile desktop --non-interactive
./doctor.sh --profile desktop
```

Then log out through the desktop UI and log back in. A reboot is not a
substitute for checking the logout/login experience, though doing both once is
useful.

## Manual checklist

- `echo "$SHELL"` reports the path returned by `command -v zsh`.
- A newly opened terminal starts Zsh without manually running `zsh`.
- `nvm`, `node`, `npm`, and `npx` work in that newly opened terminal.
- `node --version` matches `NODE_VERSION` in `versions.conf`.
- `nvim --version` matches `NEOVIM_VERSION` and opens with the cloned config.
- `git -C ~/.config/nvim remote get-url origin` points to `elgemmy/nvim-config`.
- `vim` starts and clipboard copy/paste works with the desktop.
- `kitty --version` matches `KITTY_VERSION` in `versions.conf`.
- Kitty and Kitty Open appear through the upstream desktop entries.
- Kitty appears in the application menu and opens normally.
- KDev appears in the application menu and opens its tracked session.
- `kdev --check` succeeds in a terminal.
- `desktop-file-validate ~/.local/share/applications/kdev.desktop` succeeds.
- A deliberate KDev failure produces a useful entry in
  `~/.local/state/linux-config/kdev.log`.
- Font rendering and Kitty shortcuts are usable.
- Running setup a second time does not replace personal local overrides or ask
  unnecessary questions.
- `doctor.sh --profile desktop` finishes successfully.

Test default-terminal and autostart behavior only after explicitly running:

```bash
./extras/desktop-preferences.sh
```

Record any desktop-specific difference before restoring the snapshot. A passing
container matrix plus both passing VM checklists is the release gate for a new
installer version.
