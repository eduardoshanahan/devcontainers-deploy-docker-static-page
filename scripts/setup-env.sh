#!/bin/bash
# =============================================================================
# Environment Setup Script for Static Web Deployment
# =============================================================================
# This script helps set up the secrets directory and vault configuration
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$PROJECT_ROOT/secrets"
VAULT_FILE="$SECRETS_DIR/vault.yml"
VAULT_EXAMPLE="$SECRETS_DIR/vault.example.yml"
VAULT_PASS_FILE="$SECRETS_DIR/.vault_pass"

echo "============================================================================="
echo "STATIC WEB DEPLOYMENT - SECRETS SETUP"
echo "============================================================================="

# Check if secrets directory exists
if [ ! -d "$SECRETS_DIR" ]; then
    echo "❌ Error: secrets directory not found at: $SECRETS_DIR"
    echo "   Please ensure the secrets directory exists."
    exit 1
fi

# Check if vault.yml already exists
if [ -f "$VAULT_FILE" ]; then
    echo "⚠️  vault.yml file already exists at: $VAULT_FILE"
    echo "   If you want to recreate it, delete the existing file first."
    echo "   Current vault file will be preserved."
    exit 0
fi

# Check if vault.example.yml exists
if [ ! -f "$VAULT_EXAMPLE" ]; then
    echo "❌ Error: vault.example.yml template not found at: $VAULT_EXAMPLE"
    echo "   Please ensure the template file exists."
    exit 1
fi

# Create vault.yml from template
echo " Creating vault.yml file from template..."
cp "$VAULT_EXAMPLE" "$VAULT_FILE"

echo "✅ vault.yml file created successfully at: $VAULT_FILE"
echo ""
echo "🔧 Next steps:"
echo "   1. Edit the vault.yml file with your actual values:"
echo "      ansible-vault edit $VAULT_FILE"
echo ""
echo "   2. Customize these variables:"
echo "      - vault_vps_server_ip: Your VPS IP address"
echo "      - vault_initial_deployment_user: Your initial username (sudo access)"
echo "      - vault_initial_deployment_ssh_key: Path to your initial SSH key"
echo "      - vault_containers_deployment_user: Your Docker user (Docker access)"
echo "      - vault_containers_deployment_ssh_key: Path to your Docker SSH key"
echo "      - vault_traefik_domain: Your domain name"
echo ""
echo "   3. Create vault password file:"
echo "      echo 'your-secure-password' > $VAULT_PASS_FILE"
echo "      chmod 600 $VAULT_PASS_FILE"
echo ""
echo "   4. Encrypt the vault file:"
echo "      ansible-vault encrypt $VAULT_FILE"
echo ""
echo "   5. Source the environment before running Ansible:"
echo "      source $SECRETS_DIR/.env"
echo ""
echo "⚠️  IMPORTANT: The vault.yml file is encrypted and NOT tracked in git for security."
echo "   Keep your vault password safe and don't share it with others."
echo ""
echo "📚 For more information, see: secrets/README.md"
