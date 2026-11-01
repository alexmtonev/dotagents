#!/usr/bin/env bash
# Bring this machine in line with the repo. Add new steps here.
set -euo pipefail
cd "$(dirname "$0")"
./scripts/skills.sh
./scripts/settings.sh
