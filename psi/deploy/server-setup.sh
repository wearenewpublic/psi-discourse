#!/bin/bash
#
# One-time server setup for PSI-Discourse on a fresh Ubuntu droplet.
# Run this from your local machine:
#
#   ./psi/deploy/server-setup.sh 1.2.3.4 your-email@example.com
#
# After this completes, you'll need to:
# 1. Add the printed deploy key to GitHub (repo Settings → Deploy keys)
# 2. Run the Discourse installer interactively
# 3. Edit app.yml to add the plugin hook
# 4. Rebuild
#
# Or just follow the interactive prompts.

set -euo pipefail

SERVER="${1:-}"
ADMIN_EMAIL="${2:-}"

if [ -z "$SERVER" ] || [ -z "$ADMIN_EMAIL" ]; then
    echo "Usage: ./server-setup.sh SERVER_IP ADMIN_EMAIL"
    exit 1
fi

SSH_USER="${SSH_USER:-root}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Setting up PSI-Discourse on $SERVER"

# Save server to .env for future deploys
cat > "$SCRIPT_DIR/.env" << EOF
SERVER=$SERVER
SSH_USER=$SSH_USER
ADMIN_EMAIL=$ADMIN_EMAIL
BRANCH=main
EOF
echo "==> Saved config to psi/deploy/.env"

echo ""
echo "==> Step 1: Server preparation"
echo "   SSHing into server to set up deploy key and install Docker..."
echo ""

ssh "$SSH_USER@$SERVER" bash -s << 'REMOTE_SETUP'
set -euo pipefail

echo "==> Waiting for any background apt processes to finish..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "   Waiting for apt lock..."
    sleep 5
done

echo "==> Generating GitHub deploy key..."
if [ ! -f /root/.ssh/psi_deploy_key ]; then
    ssh-keygen -t ed25519 -f /root/.ssh/psi_deploy_key -N "" -q
    cat >> /root/.ssh/config << 'SSHCONF'
Host github.com
  IdentityFile /root/.ssh/psi_deploy_key
  StrictHostKeyChecking accept-new
SSHCONF
    chmod 600 /root/.ssh/config
fi

echo ""
echo "============================================"
echo "  DEPLOY KEY (add this to GitHub):"
echo "============================================"
cat /root/.ssh/psi_deploy_key.pub
echo "============================================"
echo ""
echo "Go to: https://github.com/wearenewpublic/psi-discourse/settings/keys"
echo "Click 'Add deploy key', paste the key above, and save."
echo ""
REMOTE_SETUP

echo ""
echo "==> Step 2: Add the deploy key to GitHub"
echo "   Copy the key printed above and add it at:"
echo "   https://github.com/wearenewpublic/psi-discourse/settings/keys"
echo ""
read -p "   Press Enter once you've added the deploy key..."

echo ""
echo "==> Step 3: Run the Discourse installer"
echo "   Now SSH into your server and run the installer:"
echo ""
echo "   ssh $SSH_USER@$SERVER"
echo "   wget -qO- https://raw.githubusercontent.com/discourse/discourse_docker/main/install-discourse | sudo bash"
echo ""
echo "   During setup:"
echo "   - Admin email: $ADMIN_EMAIL"
echo "   - Domain: choose free subdomain (answer 'No')"
echo "   - SMTP: skip it"
echo ""
echo "   After the installer finishes, come back here."
echo ""
read -p "   Press Enter once the Discourse installer is complete..."

echo ""
echo "==> Step 4: Adding PSI plugin to Discourse config"

ssh "$SSH_USER@$SERVER" bash -s << 'REMOTE_PLUGIN'
set -euo pipefail

APP_YML="/var/discourse/containers/app.yml"

if [ ! -f "$APP_YML" ]; then
    echo "Error: $APP_YML not found. Is Discourse installed?"
    exit 1
fi

# Clone the repo
echo "==> Cloning PSI-Discourse repo..."
if [ ! -d /var/psi-discourse ]; then
    git clone git@github.com:wearenewpublic/psi-discourse.git /var/psi-discourse
fi

# Add plugin hook to app.yml if not already present
if grep -q "psi-discourse" "$APP_YML"; then
    echo "==> PSI plugin hook already in app.yml"
else
    echo "==> Adding PSI plugin to app.yml..."
    # Add the plugin copy command after the docker_manager clone line
    sed -i '/git clone https:\/\/github.com\/discourse\/docker_manager.git/a\          - mkdir -p /var/www/discourse/plugins/psi \&\& cp -r /var/psi-discourse/plugins/psi/* /var/www/discourse/plugins/psi/' "$APP_YML"
fi

echo "==> Rebuilding Discourse with PSI plugin..."
cd /var/discourse
./launcher rebuild app

echo ""
echo "==> Setup complete!"
REMOTE_PLUGIN

echo ""
echo "============================================"
echo "  PSI-Discourse is deployed!"
echo "============================================"
echo ""
echo "  Visit your forum and enable the PSI plugin:"
echo "  Admin → Settings → search 'psi' → enable 'psi_enabled'"
echo ""
echo "  For future deploys, just run:"
echo "    ./psi/deploy/deploy.sh"
echo ""
