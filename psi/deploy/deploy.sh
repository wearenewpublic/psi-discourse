#!/bin/bash
#
# Deploy PSI-Discourse to your DigitalOcean server.
# Run this from your local machine after initial setup is complete.
#
# Usage:
#   ./psi/deploy/deploy.sh              # uses SERVER from .env
#   ./psi/deploy/deploy.sh 1.2.3.4      # specify server IP directly
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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
    echo "Either pass it as an argument: ./deploy.sh 1.2.3.4"
    echo "Or set SERVER in $ENV_FILE"
    exit 1
fi

echo "==> Deploying PSI-Discourse to $SSH_USER@$SERVER (branch: $BRANCH)"

# SSH into the server and run the update
ssh "$SSH_USER@$SERVER" bash -s -- "$BRANCH" << 'REMOTE_SCRIPT'
set -euo pipefail
BRANCH="$1"

echo "==> Updating PSI plugin from branch: $BRANCH"

DISCOURSE_DIR="/var/discourse"
PLUGIN_REPO_DIR="/var/psi-discourse"
PLUGIN_DEST="/var/discourse/shared/standalone/plugins/psi"

# Clone or update the repo
if [ -d "$PLUGIN_REPO_DIR" ]; then
    cd "$PLUGIN_REPO_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git reset --hard "origin/$BRANCH"
    echo "==> Updated repo to latest $BRANCH"
else
    git clone -b "$BRANCH" git@github.com:wearenewpublic/psi-discourse.git "$PLUGIN_REPO_DIR"
    echo "==> Cloned repo"
fi

# Copy plugin into Discourse plugins (used by after_code hook on rebuild)
mkdir -p "$PLUGIN_DEST"
rsync -a --delete "$PLUGIN_REPO_DIR/plugins/psi/" "$PLUGIN_DEST/"
echo "==> Plugin files synced"

# Rebuild Discourse
cd "$DISCOURSE_DIR"
echo "==> Rebuilding Discourse (this takes a few minutes)..."
./launcher rebuild app

echo ""
echo "==> Deploy complete!"
REMOTE_SCRIPT

echo "==> Done! Your site should be live shortly."
