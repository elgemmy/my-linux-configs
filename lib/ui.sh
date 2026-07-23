#!/usr/bin/env bash

# Small terminal UI shared by setup and doctor. Respect NO_COLOR and avoid
# escape sequences when output is redirected to a log.
if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
  UI_RED=$'\033[0;31m'
  UI_GREEN=$'\033[0;32m'
  UI_YELLOW=$'\033[1;33m'
  UI_BLUE=$'\033[0;34m'
  UI_PURPLE=$'\033[0;35m'
  UI_CYAN=$'\033[0;36m'
  UI_BOLD=$'\033[1m'
  UI_RESET=$'\033[0m'
else
  UI_RED=''
  UI_GREEN=''
  UI_YELLOW=''
  UI_BLUE=''
  UI_PURPLE=''
  UI_CYAN=''
  UI_BOLD=''
  UI_RESET=''
fi

ui_header() {
  printf '\n%s%s╭─────────────────────────────────────────────────────────────%s\n' "$UI_PURPLE" "$UI_BOLD" "$UI_RESET"
  printf '%s%s│ %s%s\n' "$UI_PURPLE" "$UI_BOLD" "$*" "$UI_RESET"
  printf '%s%s╰─────────────────────────────────────────────────────────────%s\n\n' "$UI_PURPLE" "$UI_BOLD" "$UI_RESET"
}

ui_step() {
  printf '%s▶%s %s%s%s\n' "$UI_CYAN" "$UI_RESET" "$UI_BOLD" "$*" "$UI_RESET"
}

ui_info() {
  printf '%s•%s %s\n' "$UI_BLUE" "$UI_RESET" "$*"
}

ui_ok() {
  printf '%s✓%s %s\n' "$UI_GREEN" "$UI_RESET" "$*"
}

ui_warn() {
  printf '%s!%s %s\n' "$UI_YELLOW" "$UI_RESET" "$*" >&2
}

ui_error() {
  printf '%s✗%s %s\n' "$UI_RED" "$UI_RESET" "$*" >&2
}
