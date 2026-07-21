# Java customization

The supported default is Ubuntu or Debian's `default-jdk`, installed explicitly
with `./extras/install.sh java`. This keeps the machine on one distro-supported
JDK and avoids hard-coded Java 17/21 `amd64` paths.

For a manually installed vendor JDK, override the detected value locally:

```bash
# ~/.zshrc.local
export JAVA_HOME=/opt/java/current
export PATH="$JAVA_HOME/bin:$PATH"
```

Machine-specific Java paths belong in `~/.zshrc.local` and are not managed by
this repository.
