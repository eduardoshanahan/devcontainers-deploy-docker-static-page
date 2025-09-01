#!/bin/bash

# =============================================================================
# STATIC WEB DEPLOYMENT SCRIPT
# =============================================================================

set -e
set -o pipefail

echo "=============================================================================="
echo "STATIC WEB DEPLOYMENT - STARTING"
echo "=============================================================================="

# Source environment variables from secrets
SECRETS_ENV_FILE="$(dirname "$0")/../secrets/.env"
if [ ! -f "$SECRETS_ENV_FILE" ]; then
    echo "ERROR: secrets/.env file not found at $SECRETS_ENV_FILE"
    echo "Please run: ./scripts/setup-env.sh"
    exit 1
fi

source "$SECRETS_ENV_FILE"

# Check if vault file exists
VAULT_FILE="$(dirname "$0")/../secrets/vault.yml"
if [ ! -f "$VAULT_FILE" ]; then
    echo "ERROR: Vault file not found at $VAULT_FILE"
    echo "Please run: ./scripts/vault-setup.sh"
    exit 1
fi

# Check if vault password file exists
VAULT_PASS_FILE="$(dirname "$0")/../secrets/.vault_pass"
if [ ! -f "$VAULT_PASS_FILE" ]; then
    echo "ERROR: Vault password file not found at $VAULT_PASS_FILE"
    echo "Please run: ./scripts/vault-setup.sh"
    exit 1
fi

# Check if vault file is encrypted
if ! ansible-vault view "$VAULT_FILE" --vault-password-file "$VAULT_PASS_FILE" >/dev/null 2>&1; then
    echo "ERROR: Vault file is not encrypted or password is incorrect"
    echo "Please run: ./scripts/vault-setup.sh"
    exit 1
fi

echo "Loading environment variables from: $SECRETS_ENV_FILE"
echo "Vault file found at: $VAULT_FILE"
echo "✅ Vault file is encrypted"
echo "✅ Vault password file found"
echo ""

echo "Deployment Configuration:"
echo "   Domain: Configured via vault"
echo "   Network: traefik-network"
echo "   Container: static-web-[domain]"
echo ""

# # Prompt for confirmation
# read -p "Proceed with Static Web deployment? (y/N): " -n 1 -r
# echo
# if [[ ! $REPLY =~ ^[Yy]$ ]]; then
#     echo "Deployment cancelled"
#     exit 0
# fi

echo "Running Static Web deployment..."

# Run Ansible playbook with vault file as extra vars and pass through all arguments
ansible-playbook \
    -i src/inventory/hosts.yml \
    --vault-password-file "$VAULT_PASS_FILE" \
    --extra-vars "@$VAULT_FILE" \
    src/playbooks/deploy_static_web.yml \
    "$@"

echo ""
echo "=============================================================================="
echo "STATIC WEB DEPLOYMENT - COMPLETED"
echo "=============================================================================="
echo "Your static web page should now be accessible via Traefik"
echo "=============================================================================="