#!/usr/bin/env bash
set -euo pipefail

echo "[orbiter] bootstrap checks"

if command -v go >/dev/null 2>&1; then
  go version
else
  echo "go is not installed. Install Go 1.22+ to build Orbiter."
fi

echo "Bootstrap complete."
