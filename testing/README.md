# Reproducible installer testing

The primary integration test runs the real setup as a non-root user in disposable
Debian and Ubuntu containers. For developer and desktop profiles it first
injects a failure immediately after the NVM checkout and confirms the next run
repairs it. It then performs a successful installation, repeats that installation
to catch non-idempotent behavior, runs `doctor.sh`, and starts the account's
configured login shell. Developer and desktop profiles verify NVM/Node/npm/npx;
the desktop profile validates the KDev desktop entry and diagnostic launcher.

## Run the matrix

Install Docker or Podman, then run:

```bash
./tests/container-smoke.sh
./tests/container-smoke.sh --profile minimal --distro debian-stable
./tests/container-smoke.sh --profile desktop --distro debian-stable
CONTAINER_ENGINE=podman ./tests/container-smoke.sh
```

Defaults:

- distributions: `debian:stable-slim` and `ubuntu:24.04`
- profile: `developer`
- repository: mounted read-only at `/workspace`
- test home: a fresh `/home/tester` destroyed after every run

Use `DISTROS="debian-12 ubuntu-24.04"` to select a matrix. Images are removed at
the end unless `KEEP_TEST_IMAGE=1` is set.

The harness deliberately downloads packages and pinned upstream tools, so it is
an integration test rather than an offline unit test. `tests/run.sh` remains the
fast, host-safe test suite and should be run before the container matrix.

## What containers do not prove

Containers exercise apt, sudo, file deployment, Zsh startup, Vim, NVM/Node,
Kitty package availability, health checks, and rerun safety. They do not run a
Cinnamon display manager or a real graphical login session. Consequently they
cannot prove:

- Cinnamon default-terminal preferences
- desktop launcher/menu refresh behavior
- a shell change taking effect after an actual logout/login
- rendering, fonts, clipboard integration, or Kitty GPU behavior

Those checks belong in disposable Cinnamon and GNOME virtual machines. Follow
`testing/vm/README.md` for the snapshot-based manual acceptance layer. Keep it
smaller than the container matrix; the installer core must not require a
graphical session.

## Legacy host-mutating helpers

The older `backup-current-config.sh`, `test-fresh-install.sh`,
`restore-config.sh`, and `clean-all.sh` scripts are retained for migration only.
They mutate the current host and are not the recommended validation path.
