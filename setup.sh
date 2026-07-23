#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/ui.sh
source "$ROOT/lib/ui.sh"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
# shellcheck source=lib/deploy.sh
source "$ROOT/lib/deploy.sh"

profile=''
plan=false
noninteractive=false
current_stage='initialization'
module_failures=()

on_unexpected_error() {
  local rc=$?
  trap - ERR
  ui_error "Setup stopped during $current_stage (exit $rc, line ${BASH_LINENO[0]})."
  exit "$rc"
}
trap on_unexpected_error ERR

while (($#)); do
  case "$1" in
    --profile) (($# >= 2)) || die "--profile needs a value"; profile=$2; shift 2 ;;
    --plan) plan=true; shift ;;
    --non-interactive) noninteractive=true; shift ;;
    -h|--help)
      echo 'Usage: setup.sh [--profile minimal|developer|desktop] [--plan] [--non-interactive]'
      exit 0
      ;;
    *) die "unknown argument: $1" ;;
  esac
done

if $noninteractive && [[ -z $profile ]]; then
  die "--non-interactive requires --profile"
fi
if [[ -z $profile ]]; then
  if [[ ! -t 0 ]]; then
    die "a profile is required when stdin is not interactive"
  fi
  read -r -p 'Profile (minimal/developer/desktop) [developer]: ' profile
  profile=${profile:-developer}
fi

current_stage='platform and profile validation'
validate_profile "$profile"
platform_check
read_profile "$profile"

packages=()
for module in "${MODULES[@]}"; do
  while IFS= read -r pkg; do
    [[ -z $pkg || $pkg == \#* ]] || packages+=("$pkg")
  done < "$ROOT/packages/$module"
done
mapfile -t packages < <(printf '%s\n' "${packages[@]}" | sort -u)

missing=()
for pkg in "${packages[@]}"; do
  dpkg-query -W -f='${db:Status-Abbrev}' "$pkg" 2>/dev/null |
    grep -q '^ii ' || missing+=("$pkg")
done

ui_header "Linux development environment"
ui_info "Profile: $profile"
ui_info "Modules: ${MODULES[*]}"
ui_info "APT packages: ${packages[*]:-(none)}"

printf '\n%s%sPinned user tools%s\n' "$UI_BOLD" "$UI_BLUE" "$UI_RESET"
for module in "${MODULES[@]}"; do
  if module_runner_required "$module"; then
    "$ROOT/modules/$module.sh" plan
  fi
done

printf '\n%s%sManaged configuration%s\n' "$UI_BOLD" "$UI_BLUE" "$UI_RESET"
deployment_mappings "${MODULES[@]}" | deploy_plan
[[ " ${MODULES[*]} " != *' git '* ]] ||
  printf '  SET git core.excludesFile = %s\n' "$XDG_CONFIG_HOME/git/ignore"

ui_info 'Go and Java remain optional through extras/install.sh.'
[[ $profile != desktop ]] ||
  ui_info 'Desktop preference changes remain opt-in.'

if $plan; then
  ui_ok 'Plan complete; no changes were made.'
  exit 0
fi

current_stage='APT package installation'
ui_header '1/4 System packages'
if ((${#missing[@]})); then
  ui_step "Installing ${#missing[@]} missing APT packages"
  sudo apt-get update
  bad=()
  for pkg in "${missing[@]}"; do
    candidate="$(apt-cache policy "$pkg" | awk '/Candidate:/ { print $2; exit }')"
    [[ -n $candidate && $candidate != '(none)' ]] || bad+=("$pkg")
  done
  ((${#bad[@]} == 0)) ||
    die "no apt candidate for: ${bad[*]} (nothing beyond apt was changed)"
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
  ui_ok 'System packages installed.'
else
  ui_ok 'All required APT packages are already installed.'
fi

current_stage='managed configuration deployment'
ui_header '2/4 Managed configuration'
# Deploy the usable baseline before network-backed modules. A later download
# failure still leaves shell/editor configuration ready for the next login.
deployment_mappings "${MODULES[@]}" | deploy_apply
if [[ " ${MODULES[*]} " == *' git '* ]]; then
  git config --global core.excludesFile "$XDG_CONFIG_HOME/git/ignore"
fi
ui_ok 'Configuration links deployed.'

mkdir -p "$HOME/.local/bin"
ln_compat() {
  local target=$1 name=$2 link
  link="$HOME/.local/bin/$name"
  command -v "$name" >/dev/null && return 0
  [[ -x $(command -v "$target" 2>/dev/null || true) ]] || return 0
  [[ ! -e $link || -L $link ]] || {
    ui_error "Refusing to replace unmanaged compatibility path: $link"
    return 1
  }
  ln -sfnT "$(command -v "$target")" "$link"
}
ln_compat batcat bat
ln_compat fdfind fd

if [[ " ${MODULES[*]} " == *' shell '* ]]; then
  zsh_path="$(command -v zsh)"
  current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [[ $current_shell != "$zsh_path" ]]; then
    ui_step "Setting the login shell to $zsh_path"
    sudo chsh -s "$zsh_path" "$(id -un)"
  else
    ui_ok "Login shell already uses $zsh_path."
  fi
fi

current_stage='user tool installation'
ui_header '3/4 User tools'
for module in "${MODULES[@]}"; do
  module_runner_required "$module" || continue
  ui_step "Installing $module"
  if "$ROOT/modules/$module.sh" apply; then
    ui_ok "$module is ready."
  else
    rc=$?
    module_failures+=("$module:$rc")
    ui_error "$module failed with exit $rc; continuing with the remaining tools."
  fi
done

current_stage='health checks'
ui_header '4/4 Verification'
doctor_ok=false
if "$ROOT/doctor.sh" --profile "$profile"; then
  doctor_ok=true
fi

ui_header 'Setup summary'
if ((${#module_failures[@]})); then
  ui_error "Failed modules: ${module_failures[*]}"
else
  ui_ok 'Every requested module completed.'
fi

if $doctor_ok && ((${#module_failures[@]} == 0)); then
  mkdir -p "$STATE_DIR"
  printf '%s\n' "$profile" > "$STATE_DIR/last-profile"
  ui_ok 'Development environment is ready.'
  ui_info "Open a new terminal or run: exec $(command -v zsh)"
  ui_info "Immediate PATH activation: export PATH=\"$HOME/.local/bin:\$PATH\""
  [[ $profile != desktop ]] ||
    ui_info 'Try: kitty --version; nvim --version; tree-sitter --version; kdev --check'
  exit 0
fi

ui_error 'Setup completed all possible work, but verification found problems.'
ui_info "Re-run this command after reviewing the failures above: $0 --profile $profile --non-interactive"
exit 1
