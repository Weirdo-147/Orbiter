#!/usr/bin/env bash

set -euo pipefail

OS="$(uname -s)"

say() {
  printf '[bootstrap] %s\n' "$*"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

check_cmd() {
  local name="$1"
  if have "$name"; then
    say "found $name ($("$name" --version 2>/dev/null | head -n1 || echo 'version unknown'))"
    return 0
  fi

  say "missing required command: $name"
  case "$OS" in
    Darwin)
      say "install hint (macOS): brew install $name"
      ;;
    Linux)
      say "install hint (Ubuntu/Debian): sudo apt-get install -y $name"
      say "install hint (Fedora/RHEL): sudo dnf install -y $name"
      ;;
    *)
      say "install hint: install '$name' using your OS package manager"
      ;;
  esac
  return 1
}

check_go_version() {
  local min_go="1.22"
  if ! have go; then
    return 1
  fi

  local raw major minor
  raw="$(go version | awk '{print $3}')"     # e.g. go1.22.4
  raw="${raw#go}"
  major="${raw%%.*}"
  minor="${raw#*.}"
  minor="${minor%%.*}"

  if [[ "$major" -gt 1 || ( "$major" -eq 1 && "$minor" -ge 22 ) ]]; then
    say "go version ${raw} satisfies minimum ${min_go}+"
    return 0
  fi

  say "go version ${raw} is below minimum ${min_go}+"
  return 1
}

check_optional_tool() {
  local name="$1"
  local install_cmd="$2"

  if have "$name"; then
    say "found optional tool: $name"
  else
    say "optional tool missing: $name"
    say "install hint: $install_cmd"
  fi
}

main() {
  say "verifying local development prerequisites"

  local ok=0
  check_cmd git || ok=1
  check_cmd make || ok=1
  check_cmd go || ok=1
  check_go_version || ok=1

  check_optional_tool golangci-lint 'go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest'

  if [[ "$ok" -ne 0 ]]; then
    say "one or more required prerequisites are missing/outdated"
    exit 1
  fi

  say "all required prerequisites are available"
}

main "$@"
