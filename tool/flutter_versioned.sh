#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd -- "$project_dir"

# Flutter requires a numeric build number; commit count gives each commit in a
# linear history a stable number. CI can supply its own monotonic number.
description=$(git describe --tags --always --dirty --match 'v[0-9]*' --match '[0-9]*' 2>/dev/null || true)
version=0.0.0
if [[ $description =~ ^v?([0-9]+\.[0-9]+\.[0-9]+)(-[0-9]+-g[0-9a-f]+)?(-dirty)?$ ]]; then
  version=${BASH_REMATCH[1]}
else
  printf 'No reachable version tag (vMAJOR.MINOR.PATCH); using %s.\n' "$version" >&2
fi

build_number=${LUMADRIVE_BUILD_NUMBER:-}
if [[ -z $build_number ]]; then
  if [[ $(git rev-parse --is-shallow-repository 2>/dev/null || true) == true ]]; then
    printf 'Shallow Git history: set LUMADRIVE_BUILD_NUMBER or fetch the complete history.\n' >&2
    exit 1
  fi
  build_number=$(git rev-list --count HEAD 2>/dev/null || printf '1')
fi
if [[ ! $build_number =~ ^[1-9][0-9]*$ ]] || (( ${#build_number} > 9 )) || (( build_number > 2100000000 )); then
  printf 'LUMADRIVE_BUILD_NUMBER must be a positive integer no greater than 2100000000.\n' >&2
  exit 1
fi

if [[ ${1:-} == --print-version && $# == 1 ]]; then
  printf '%s+%s\n' "$version" "$build_number"
  exit 0
fi
if [[ $# -lt 2 || $1 != build ]]; then
  printf 'Usage: bash tool/flutter_versioned.sh build <target> [options]\n       bash tool/flutter_versioned.sh --print-version\n' >&2
  exit 2
fi
for arg in "$@"; do
  if [[ $arg == --build-name || $arg == --build-name=* || $arg == --build-number || $arg == --build-number=* ]]; then
    printf 'The wrapper sets build name and number; use LUMADRIVE_BUILD_NUMBER to override the number.\n' >&2
    exit 2
  fi
done
printf 'Building version %s+%s (Git: %s)\n' "$version" "$build_number" "${description:-unavailable}" >&2
exec "${FLUTTER_BIN:-flutter}" "$@" --build-name="$version" --build-number="$build_number"
