#!/usr/bin/env bash

# URL des Debian-Bookworm-Repositories
REPO_URL="$1"
DISTRIBUTION="$2"
PACKAGE="$3"

if [[ -z "${REPO_URL}" || -z "${DISTRIBUTION}" || -z "${PACKAGE}" ]]; then
  echo "get-apt-version.sh REPO_URL DISTRIBUTION PACKAGE"
  exit 255
fi

# Download Packages to tmpfile
TEMP_FILE=$(mktemp)
curl -s "${REPO_URL}/pub/repos/apt/dists/${DISTRIBUTION}/main/binary-amd64/Packages" -o "$TEMP_FILE"

# Extract version
VERSION=$(cat $TEMP_FILE | awk "/Package: ${PACKAGE}\$/ {found=1} found && /Version:/ {print \$2; exit}")

# Delete temp file
rm "$TEMP_FILE"

# Return version
echo "$VERSION"