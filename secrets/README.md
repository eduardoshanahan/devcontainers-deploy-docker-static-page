# Secrets Directory

This directory contains all sensitive configuration data for the Static Web Deployment project.

## Files

- `vault.example.yml` - Template showing the structure of sensitive data
- `vault.yml` - **ENCRYPTED** file containing actual sensitive values
- `.env` - Non-sensitive environment variables
- `.vault_pass` - Vault password file (create this file with your password)

## Setup

1. Copy the example file:

   ```bash
   cp vault.example.yml vault.yml
   ```

2. Edit `vault.yml` with your real values:

   ```bash
   ansible-vault edit vault.yml
   ```

3. Create vault password file:

   ```bash
   echo "your-vault-password" > .vault_pass
   chmod 600 .vault_pass
   ```

4. Source environment variables:

   ```bash
   source .env
   ```

## Security

- All files in this directory are ignored by git
- Sensitive data is encrypted with Ansible Vault
- Never commit `vault.yml` or `.vault_pass` to version control
