#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/Neptune3013/fallout-limine-theme.git"
ORIGINAL_BACKGROUND_URL="https://raw.githubusercontent.com/shvchk/fallout-grub-theme/master/background.png"
REPO_REF="${REPO_REF:-main}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BOOT_DIR="${BOOT_DIR:-}"
SECURE_BOOT_MODE="auto"
ACTION="install"
INTERACTIVE_MENU=0
BOOT_TIMEOUT=""
BACKGROUND_VARIANT=""
BACKUP_ROOT="${BACKUP_ROOT:-$SCRIPT_DIR/fallout-limine-backups}"
ORIGINAL_CONF_BACKUP="${ORIGINAL_CONF_BACKUP:-$SCRIPT_DIR/limine.conf_backup}"
ORIGINAL_SPLASH_BACKUP="${ORIGINAL_SPLASH_BACKUP:-$SCRIPT_DIR/limine-splash_backup.png}"
TMP_DIR=""

MARKER_BEGIN="# BEGIN fallout-limine-theme (managed by install-fallout-limine-cachyos.sh)"
MARKER_END="# END fallout-limine-theme"
THEME_KEY_RE='^(timeout|default_entry|remember_last_entry|wallpaper|term_font|term_font_size|term_font_scale|interface_branding|term_background|term_margin|term_background_bright|term_foreground|term_foreground_bright|term_palette|term_palette_bright|interface_help_hidden):'

usage() {
  cat <<'EOF'
Install the Fallout Limine theme on CachyOS.

Usage:
  install-fallout-limine-cachyos.sh [options]

Run without options to open the interactive menu.

Options:
  --boot-dir PATH          Directory containing limine.conf (default: auto, then /boot)
  --secure-boot auto|yes|no
                           Append BLAKE2B hashes for theme files (default: auto)
  --timeout 5|10|15        Set Limine menu timeout (default: 15 from the theme)
  --background compressed|original
                           Use compressed Limine JPG or original GRUB PNG
  --restore-original-background
                           Restore permanent backups of CachyOS' original Limine config and splash screen
  -h, --help               Show this help

When previous backups are found in the script backup directory, the script
will list them and ask before deleting anything.
The original CachyOS limine.conf and limine-splash.png are stored as
limine.conf_backup and limine-splash_backup.png next to this script; they are
never removed by that cleanup prompt.

Environment:
  REPO_REF=main            Git ref to install from
  BOOT_DIR=/boot           Same as --boot-dir
EOF
}

log() {
  printf '[fallout-limine] %s\n' "$*"
}

section() {
  printf '\n[fallout-limine] == %s ==\n' "$*"
}

die() {
  printf '[fallout-limine] ERROR: %s\n' "$*" >&2
  exit 1
}

on_error() {
  local line="$1"
  local command="$2"
  local status="$3"

  printf '\n[fallout-limine] ERROR: command failed with exit code %s\n' "$status" >&2
  printf '[fallout-limine] ERROR: line %s: %s\n' "$line" "$command" >&2
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

run() {
  printf '[fallout-limine] $'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

parse_args() {
  if (($# == 0)); then
    INTERACTIVE_MENU=1
    ACTION=""
    return
  fi

  while (($#)); do
    case "$1" in
      --boot-dir)
        (($# >= 2)) || die "--boot-dir requires a path"
        BOOT_DIR="$2"
        shift 2
        ;;
      --secure-boot)
        (($# >= 2)) || die "--secure-boot requires auto, yes, or no"
        SECURE_BOOT_MODE="$2"
        shift 2
        ;;
      --timeout)
        (($# >= 2)) || die "--timeout requires 5, 10, or 15"
        BOOT_TIMEOUT="$2"
        shift 2
        ;;
      --background)
        (($# >= 2)) || die "--background requires compressed or original"
        BACKGROUND_VARIANT="$2"
        shift 2
        ;;
      --restore-original-background)
        ACTION="restore-original-background"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
  done

  case "$SECURE_BOOT_MODE" in
    auto|yes|no) ;;
    *) die "--secure-boot must be auto, yes, or no" ;;
  esac

  case "$BOOT_TIMEOUT" in
    ""|5|10|15) ;;
    *) die "--timeout must be 5, 10, or 15" ;;
  esac

  case "$BACKGROUND_VARIANT" in
    ""|compressed|original) ;;
    *) die "--background must be compressed or original" ;;
  esac
}

choose_from_menu() {
  local choice=""

  [[ -t 0 ]] || die "No interactive terminal available. Pass --restore-original-background or run with no options in a terminal."

  while true; do
    section "Interactive menu"
    printf '1) Apply the original full Fallout theme\n'
    printf '2) Restore the original CachyOS Limine config\n'
    printf '3) Exit\n'
    printf '[fallout-limine] Choose an option [1-3]: '
    read -r choice || die "Input cancelled."

    case "$choice" in
      1|"")
        ACTION="install"
        break
        ;;
      2)
        ACTION="restore-original-background"
        break
        ;;
      3|q|Q)
        log "No changes made."
        exit 0
        ;;
      *)
        log "Invalid menu choice: $choice"
        ;;
    esac
  done

  case "$ACTION" in
    install)
      log "Selected: apply the original full Fallout theme."
      ;;
    restore-original-background)
      log "Selected: restore the original CachyOS Limine config."
      ;;
