# Java extra

Java is intentionally excluded from the normal setup profiles. Install the one
default JDK selected by Ubuntu or Debian:

```bash
./extras/install.sh java
```

The installer uses the `default-jdk` metapackage and reports the resulting
`JAVA_HOME`. The managed Zsh configuration derives `JAVA_HOME` dynamically when
`java` is available; it does not assume a JDK version or CPU-specific path.

Verify with:

```bash
java -version
echo "$JAVA_HOME"
```

Use `sudo update-alternatives --config java` if you intentionally install more
than one JDK later.
