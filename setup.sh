#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
# shellcheck source=lib/deploy.sh
source "$ROOT/lib/deploy.sh"

profile='' plan=false noninteractive=false
while (($#)); do
  case "$1" in
    --profile) (($# >= 2)) || die "--profile needs a value"; profile=$2; shift 2 ;;
    --plan) plan=true; shift ;;
    --non-interactive) noninteractive=true; shift ;;
    -h|--help) echo 'Usage: setup.sh [--profile minimal|developer|desktop] [--plan] [--non-interactive]'; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done
if $noninteractive && [[ -z $profile ]]; then die "--non-interactive requires --profile"; fi
if [[ -z $profile ]]; then
  if [[ ! -t 0 ]]; then die "a profile is required when stdin is not interactive"; fi
  read -r -p 'Profile (minimal/developer/desktop) [developer]: ' profile
  profile=${profile:-developer}
fi
validate_profile "$profile"; platform_check; read_profile "$profile"

packages=(); for module in "${MODULES[@]}"; do while IFS= read -r pkg; do [[ -z $pkg || $pkg == \#* ]] || packages+=("$pkg"); done < "$ROOT/packages/$module"; done
mapfile -t packages < <(printf '%s\n' "${packages[@]}" | sort -u)
missing=(); for pkg in "${packages[@]}"; do dpkg-query -W -f='${db:Status-Abbrev}' "$pkg" 2>/dev/null | grep -q '^ii ' || missing+=("$pkg"); done
printf 'Profile: %s\nModules: %s\n' "$profile" "${MODULES[*]}"
printf 'Packages: %s\n' "${packages[*]:-(none)}"
echo 'Pinned user tools:'
for module in "${MODULES[@]}"; do
  [[ -x $ROOT/modules/$module.sh ]] && "$ROOT/modules/$module.sh" plan
done
echo 'Configuration:'; deployment_mappings "${MODULES[@]}" | deploy_plan
[[ " ${MODULES[*]} " != *' git '* ]] || printf '  SET git core.excludesFile = %s\n' "$XDG_CONFIG_HOME/git/ignore"
echo 'Manual actions: editor extensions (editors/*/extensions.txt); Go/Java (extras/install.sh).'
echo 'Trusted app utilities (intentional): appimages/install.sh; tarapps/install.sh.'
[[ $profile != desktop ]] || echo 'Desktop preferences are opt-in: extras/desktop-preferences.sh'
$plan && exit 0

if ((${#missing[@]})); then
  sudo apt-get update
  bad=()
  for pkg in "${missing[@]}"; do
    candidate="$(apt-cache policy "$pkg" | awk '/Candidate:/ { print $2; exit }')"
    [[ -n $candidate && $candidate != '(none)' ]] || bad+=("$pkg")
  done
  ((${#bad[@]} == 0)) || die "no apt candidate for: ${bad[*]} (nothing beyond apt was changed)"
  sudo apt-get install -y "${missing[@]}"
else
  echo 'All apt packages already installed; skipping apt.'
fi
for module in "${MODULES[@]}"; do
  [[ -x $ROOT/modules/$module.sh ]] && "$ROOT/modules/$module.sh" apply
done
mkdir -p "$HOME/.local/bin"
ln_compat() {
  local target=$1 name=$2 link
  link="$HOME/.local/bin/$name"
  command -v "$name" >/dev/null && return 0
  [[ -x $(command -v "$target" 2>/dev/null || true) ]] || return 0
  [[ ! -e $link || -L $link ]] || { echo "Refusing to replace unmanaged compatibility path: $link" >&2; return 1; }
  ln -sfnT "$(command -v "$target")" "$link"
}
ln_compat batcat bat; ln_compat fdfind fd
deployment_mappings "${MODULES[@]}" | deploy_apply
if [[ " ${MODULES[*]} " == *' git '* ]]; then git config --global core.excludesFile "$XDG_CONFIG_HOME/git/ignore"; fi
if ! "$ROOT/doctor.sh" --profile "$profile"; then
  echo "Setup finished, but required checks failed. Review the doctor output above." >&2
  exit 1
fi
mkdir -p "$STATE_DIR"; printf '%s\n' "$profile" > "$STATE_DIR/last-profile"
echo "Setup complete. Desktop preference changes remain opt-in: $ROOT/extras/desktop-preferences.sh"
