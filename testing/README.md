# Testing Scripts

Scripts for testing the installation process and maintaining clean development environment.

## 📋 Available Scripts

### `backup-current-config.sh`
Creates timestamped backup of your current configuration files.
```bash
./backup-current-config.sh
```
**Backs up:**
- ZSH configuration (`.zshrc`, `.zshrc.local`, `.zshrc.work`)
- Oh My Zsh installation
- Vim configuration (`.vimrc`)
- Kitty terminal configuration
- Starship prompt configuration
- Current shell setting

### `test-fresh-install.sh`
Interactive script providing multiple testing methods.
```bash
./test-fresh-install.sh
```
**Options:**
- **Quick Clean Test**: Backup → Clean → Test (recommended)
- **New User Test**: Create test user for isolated testing
- **Docker Test**: Test in Ubuntu container

### `restore-config.sh`
Restores configuration from a specific backup directory.
```bash
./restore-config.sh ~/.config-backup-20241208-143025
```

### `clean-all.sh`
Safely removes testing backup directories while preserving your current configuration.
```bash
./clean-all.sh
```
**Removes:**
- All testing backup directories (`~/.config-backup-*`)
- Optionally: installed programs (starship, modern CLI tools)

**Preserves:**
- Your current configuration files (`.zshrc`, `.vimrc`, etc.)
- Oh My Zsh installation
- Current shell setting

## 🧪 Recommended Testing Workflow

1. **Backup current setup:**
   ```bash
   ./backup-current-config.sh
   ```

2. **Run quick clean test:**
   ```bash
   ./test-fresh-install.sh
   # Choose 'y' for quick clean simulation
   ```

3. **Test the installation:**
   ```bash
   cd ..
   ./install.sh
   ```

4. **View results:**
   ```bash
   exec zsh
   # Test features: coffee, bat, eza, starship prompt, etc.
   ```

5. **Restore original setup:**
   ```bash
   cd testing
   ./restore-config.sh ~/.config-backup-YYYYMMDD-HHMMSS
   ```

## 🐳 Alternative: Docker Testing

For completely isolated testing:
```bash
docker run -it --rm ubuntu:22.04 bash

# Inside container:
apt update && apt install -y git
git clone https://github.com/AhmedGamal2212/my-linux-configs
cd my-linux-configs
./install.sh
```

## 🧹 Cleaning Up

After testing, return to completely clean state:
```bash
./clean-all.sh
```

This removes all testing artifacts and restores system to pre-testing state.

After testing, run `post-setup/configure.sh` to create `.zshrc.local` and `.zshrc.work` templates.

---

*Created with ☕ by Ahmed Gamal (Gemmy)*
