#!/bin/bash
# =============================================================================
# Vault Setup Script for Static Web Deployment
# =============================================================================
# This script helps set up and manage the Ansible vault
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$PROJECT_ROOT/secrets"
VAULT_FILE="$SECRETS_DIR/vault.yml"
VAULT_PASS_FILE="$SECRETS_DIR/.vault_pass"

echo "============================================================================="
echo "STATIC WEB DEPLOYMENT - VAULT SETUP"
echo "============================================================================="

# Check if secrets directory exists
if [ ! -d "$SECRETS_DIR" ]; then
    echo "❌ Error: secrets directory not found at: $SECRETS_DIR"
    echo "   Please run ./scripts/setup-env.sh first"
    exit 1
fi

# Check if vault.yml exists
if [ ! -f "$VAULT_FILE" ]; then
    echo "❌ Error: vault.yml file not found at: $VAULT_FILE"
    echo "   Please run ./scripts/setup-env.sh first"
    exit 1
fi

# Check if vault is already encrypted
if ansible-vault view "$VAULT_FILE" >/dev/null 2>&1; then
    echo "✅ Vault file is already encrypted"
    echo ""
    echo "Available commands:"
    echo "  ansible-vault edit $VAULT_FILE    # Edit encrypted vault"
    echo "  ansible-vault view $VAULT_FILE    # View encrypted vault"
    echo "  ansible-vault rekey $VAULT_FILE   # Change vault password"
else
    echo "⚠️  Vault file is not encrypted"
    echo ""
    echo "To encrypt the vault file:"
    echo "  1. Create vault password file:"
    echo "     echo 'your-secure-password' > $VAULT_PASS_FILE"
    echo "     chmod 600 $VAULT_PASS_FILE"
    echo ""
    echo "  2. Encrypt the vault file:"
    echo "     ansible-vault encrypt $VAULT_FILE"
    echo ""
    echo "  3. Test the encryption:"
    echo "     ansible-vault view $VAULT_FILE"
fi

echo ""
echo "📚 For more information, see: secrets/README.md"
