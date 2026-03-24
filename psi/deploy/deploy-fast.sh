#!/bin/bash
#
# Fast deploy: update just the PSI plugin without a full Discourse rebuild.
# This copies new plugin files and restarts the container (~30 seconds).
#
# Use this for plugin-only changes (templates, styles, Ruby, JS).
# Use deploy.sh for changes that need a full rebuild (new gems, migrations).
#
# Usage:
#   ./psi/deploy/deploy-fast.sh              # uses SERVER from .env
#   ./psi/deploy/deploy-fast.sh 1.2.3.4      # specify server IP directly
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load config
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

SERVER="${1:-${SERVER:-}}"
SSH_USER="${SSH_USER:-root}"
BRANCH="${BRANCH:-main}"

if [ -z "$SERVER" ]; then
    echo "Error: No server specified."
    echo "Either pass it as an argument: ./deploy-fast.sh 1.2.3.4"
    echo "Or set SERVER in $SCRIPT_DIR/.env"
    exit 1
fi

echo "==> Fast-deploying PSI plugin to $SSH_USER@$SERVER (branch: $BRANCH)"

ssh "$SSH_USER@$SERVER" bash -s -- "$BRANCH" << 'REMOTE_SCRIPT'
set -euo pipefail
BRANCH="$1"

PLUGIN_REPO_DIR="/var/psi-discourse"
CONTAINER_PLUGIN_DIR="/var/discourse/shared/standalone/plugins/psi"

# Update the repo
if [ -d "$PLUGIN_REPO_DIR" ]; then
    cd "$PLUGIN_REPO_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git reset --hard "origin/$BRANCH"
else
    git clone -b "$BRANCH" git@github.com:wearenewpublic/psi-discourse.git "$PLUGIN_REPO_DIR"
fi

# Check if there are new migrations (need full rebuild)
if [ -d "$CONTAINER_PLUGIN_DIR/db" ]; then
    OLD_MIGRATIONS=$(ls "$CONTAINER_PLUGIN_DIR/db/migrate/" 2>/dev/null | wc -l)
    NEW_MIGRATIONS=$(ls "$PLUGIN_REPO_DIR/plugins/psi/db/migrate/" 2>/dev/null | wc -l)
    if [ "$NEW_MIGRATIONS" -gt "$OLD_MIGRATIONS" ]; then
        echo "WARNING: New database migrations detected."
        echo "You should run deploy.sh (full rebuild) instead."
        echo "Continuing anyway, but migrations won't run until a full rebuild."
    fi
fi

# Sync plugin files into the shared volume
mkdir -p "$CONTAINER_PLUGIN_DIR"
rsync -a --delete "$PLUGIN_REPO_DIR/plugins/psi/" "$CONTAINER_PLUGIN_DIR/"
echo "==> Plugin files synced"

# Copy into the running container and restart
cd /var/discourse
./launcher restart app
echo "==> Container restarted"

echo ""
echo "==> Fast deploy complete!"
REMOTE_SCRIPT

echo "==> Done!"
