# Java Development Kit Setup

Install Java 17 and 21 to work with the ZSH switcher functions.

## Quick Setup

### Automatic Installation
```bash
./install.sh
```

### Manual Installation

#### Ubuntu/Debian-based distributions
```bash
sudo apt update
sudo apt install -y openjdk-17-jdk openjdk-21-jdk
```

#### Fedora
```bash
sudo dnf install -y java-17-openjdk-devel java-21-openjdk-devel

# Add Fedora paths to local config
echo 'export JAVA_HOME_17=/usr/lib/jvm/java-17-openjdk' >> ~/.zshrc.local
echo 'export JAVA_HOME_21=/usr/lib/jvm/java-21-openjdk' >> ~/.zshrc.local
```

## Expected Paths

The ZSH configuration expects Java at these locations:

**Ubuntu/Debian:**
- Java 17: `/usr/lib/jvm/java-17-openjdk-amd64`
- Java 21: `/usr/lib/jvm/java-21-openjdk-amd64`

**Fedora:**
- Java 17: `/usr/lib/jvm/java-17-openjdk`
- Java 21: `/usr/lib/jvm/java-21-openjdk`

## Usage with ZSH

After installing both Java and ZSH configuration:

```bash
# Switch to Java 17
setJdk17
java -version

# Switch to Java 21  
setJdk21
java -version

# Check current JAVA_HOME
echo $JAVA_HOME
```

## Verification

```bash
# Check installations
ls -la /usr/lib/jvm/ | grep java

# Test Java versions directly
/usr/lib/jvm/java-17-openjdk*/bin/java -version
/usr/lib/jvm/java-21-openjdk*/bin/java -version
```

## Troubleshooting

**Wrong paths on your system:**
1. Find actual Java locations: `find /usr/lib/jvm -name "java-*-openjdk*"`
2. Create `~/.zshrc.local` with correct paths:
   ```bash
   export JAVA_HOME_17=/your/actual/java17/path
   export JAVA_HOME_21=/your/actual/java21/path
   ```

**Switcher functions not working:**
- Ensure ZSH configuration is installed
- Restart terminal or run `source ~/.zshrc`

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
