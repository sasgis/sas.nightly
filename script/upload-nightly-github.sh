#!/bin/bash -ex

# Publishes nightly builds using GitHub CLI (https://cli.github.com/)
# 
# Requirements:
# 1. GitHub CLI must be installed
# 2. User must authenticate with "gh auth login"
# 3. For organization repositories, you need to grant write permissions: "gh auth refresh --scopes write:org"
#
# More details about authentication: https://cli.github.com/manual/gh_auth

function publish_nightly_release {

  local FILE1="$1"
  local FILE2="$2"
  local REPO="sasgis/sas.planet.src"
  local TAG="nightly"
  local RELEASE_NAME="Nightly Build"
  local DESCRIPTION="Automated nightly build: $(date -u +"%Y-%m-%d %H:%M:%S") UTC"

  if [[ -z "$FILE1" ]]; then
    echo "Error: no file provided"
    return 1
  fi

  if [[ ! -f "$FILE1" ]]; then
    echo "Error: first file not found — $FILE1"
    return 1
  fi

  if [[ -n "$FILE2" && ! -f "$FILE2" ]]; then
    echo "Error: second file not found — $FILE2"
    return 1
  fi

  echo "Removing existing release '$TAG' if it exists..."
  gh release delete "$TAG" --repo "$REPO" --yes || true

  echo "Creating new pre-release '$TAG'..."
  if [[ -n "$FILE2" ]]; then
    gh release create "$TAG" "$FILE1" "$FILE2" \
      --repo "$REPO" \
      --title "$RELEASE_NAME" \
      --notes "$DESCRIPTION" \
      --prerelease
  else
    gh release create "$TAG" "$FILE1" \
      --repo "$REPO" \
      --title "$RELEASE_NAME" \
      --notes "$DESCRIPTION" \
      --prerelease
  fi

  echo "Pre-release '$TAG' updated successfully"
}

