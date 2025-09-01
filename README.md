# Static Web Deployment with Ansible

## Overview

This project provides a complete Ansible-based solution for deploying static web pages using Docker containers with Traefik as a reverse proxy. The deployment is fully automated, secure, and follows infrastructure-as-code best practices.

## Features

- **Automated Deployment**: One-command deployment using Ansible
- **Docker Integration**: Containerized static web serving with Nginx
- **Traefik Integration**: Automatic SSL certificates and reverse proxy configuration
- **Security**: Encrypted secrets management with Ansible Vault
- **Modern UI**: Responsive, modern web page template
- **Domain-based Naming**: Dynamic container naming based on domain
- **Comprehensive Validation**: Built-in health checks and validation

## Quick Start

### Prerequisites

- Ansible installed locally
- SSH access to target server
- Domain name pointing to server
- Traefik already running on server

### Deployment

```bash
# Clone the repository
git clone <repository-url>
cd static-web-deployment

# Configure secrets (see SECRETS_AND_INVENTORY_GUIDE.md)
cp secrets/vault.example.yml secrets/vault.yml
# Edit secrets/vault.yml with your values
ansible-vault encrypt secrets/vault.yml

# Deploy
./scripts/deploy.sh
```

## Project Structure

```text
├── src/
│   ├── playbooks/           # Ansible playbooks
│   ├── roles/              # Ansible roles
│   └── inventory/          # Server inventory and variables
├── secrets/                # Encrypted configuration
├── scripts/                # Deployment scripts
├── documentation/          # Project documentation
└── .devcontainer/         # Development environment
```

## Documentation

- [SECRETS_AND_INVENTORY_GUIDE.md](SECRETS_AND_INVENTORY_GUIDE.md) - Configuration and secrets management
- [Traefik Integration Guide](how%20to%20deploy%20a%20docker%20container%20to%20be%20detected%20by%20traefik.md) - Traefik setup and configuration
- [documentation/](documentation/) - Detailed technical documentation

## Security

- All sensitive data is encrypted using Ansible Vault
- SSH key-based authentication
- No hardcoded credentials in code
- Secure secrets management following best practices

## Support

For issues and questions, please refer to the documentation in the `documentation/` directory or create an issue in the repository.
