# Java Installation for ZSH Switcher

This guide shows how to install Java 17 and 21 to match the paths defined in your `zshrc` configuration.

## Your ZSH Configuration Paths

Your `zshrc` expects Java to be installed at:
```bash
JAVA_HOME_17=/usr/lib/jvm/java-17-openjdk-amd64
JAVA_HOME_21=/usr/lib/jvm/java-21-openjdk-amd64
```

## Installation Instructions

### Debian/Ubuntu

```bash
# Update package list
sudo apt update

# Install Java 17 and 21 OpenJDK
sudo apt install -y openjdk-17-jdk openjdk-21-jdk

# Verify installation paths
ls -la /usr/lib/jvm/ | grep java
```

## Verify Installation

After installation, check that Java is properly installed:

```bash
# Check Java 17
/usr/lib/jvm/java-17-openjdk-amd64/bin/java -version

# Check Java 21
/usr/lib/jvm/java-21-openjdk-amd64/bin/java -version

# Test the switcher functions (after sourcing zshrc)
source ~/.zshrc
setJdk17
java -version
setJdk21
java -version
```

## Debian/Ubuntu Paths
```
/usr/lib/jvm/java-17-openjdk-amd64/
/usr/lib/jvm/java-21-openjdk-amd64/
```

## Customization for Different Systems

If your system uses different paths, update your `~/.zshrc.local`:

### For Custom Java Installations
```bash
# ~/.zshrc.local
export JAVA_HOME_17=/opt/java/jdk-17
export JAVA_HOME_21=/opt/java/jdk-21
```

## Alternative: Oracle JDK

If you prefer Oracle JDK over OpenJDK:

### Manual Installation
1. Download from [Oracle JDK Downloads](https://www.oracle.com/java/technologies/downloads/)
2. Extract to `/opt/java/`
3. Update paths in `~/.zshrc.local`

### Using Package Managers
```bash
# Ubuntu (requires adding Oracle repository)
sudo add-apt-repository ppa:linuxuprising/java
sudo apt update
sudo apt install oracle-java17-installer oracle-java21-installer
```

## Troubleshooting

### Java Commands Not Found
```bash
# Check installed Java versions
sudo update-alternatives --config java

# Add to PATH if needed (add to ~/.zshrc.local)
export PATH=$JAVA_HOME/bin:$PATH
```

### Wrong Java Version Active
```bash
# Check current Java version
java -version

# Use the switcher functions
setJdk17  # or setJdk21

# Verify the switch worked
java -version
echo $JAVA_HOME
```

### Path Not Found Errors
```bash
# Find actual Java installation paths
find /usr/lib/jvm -name "java-*-openjdk*" -type d

# Update your ~/.zshrc.local with correct paths
```

## Quick Setup Commands

### For Debian/Ubuntu
```bash
sudo apt update && sudo apt install -y openjdk-17-jdk openjdk-21-jdk
```

After installation, restart your terminal or run `source ~/.zshrc` to use the Java switcher functions.
