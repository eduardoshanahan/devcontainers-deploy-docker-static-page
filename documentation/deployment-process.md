# Deployment Process

## Overview

This document describes the complete deployment process for the Static Web Deployment system, including prerequisites, configuration, execution, and validation steps.

## Prerequisites

### Server Requirements

- **Operating System**: Ubuntu 20.04 LTS or later
- **Docker**: Docker Engine 20.10 or later
- **Docker Compose**: Version 2.0 or later
- **Network**: Internet connectivity for SSL certificate generation
- **Domain**: Valid domain name pointing to server IP

### Local Requirements

- **Ansible**: Version 2.9 or later
- **Python**: Version 3.8 or later
- **SSH Client**: For server connectivity
- **Git**: For repository management

### Traefik Prerequisites

- **Traefik Network**: `traefik-network` must exist
- **Let's Encrypt**: Email configured for certificate generation
- **Port Access**: Ports 80 and 443 accessible

## Configuration Process

### Step 1: Secrets Configuration

```bash
# Copy example configuration
cp secrets/vault.example.yml secrets/vault.yml

# Edit with your values
ansible-vault edit secrets/vault.yml
```

Required configuration values:

- **Server IP**: Target server IP address
- **Domain**: Your domain name
- **SSH Keys**: Path to SSH private key
- **User Credentials**: Server user information

### Step 2: Environment Configuration

```bash
# Edit environment variables
nano secrets/.env
```

Configure non-sensitive environment variables:

- **Ansible Configuration**: Paths and settings
- **Deployment Options**: Customization options
- **Logging Configuration**: Log levels and paths

### Step 3: Inventory Validation

```bash
# Validate inventory configuration
ansible-inventory -i src/inventory/hosts.yml --list
```

## Deployment Execution

### Automated Deployment

```bash
# Run complete deployment
./scripts/deploy.sh
```

The deployment script performs:

1. **Environment Validation**: Check prerequisites
2. **Secrets Verification**: Validate encrypted configuration
3. **Server Connectivity**: Test SSH access
4. **Playbook Execution**: Run Ansible deployment
5. **Validation**: Post-deployment health checks

### Manual Deployment

```bash
# Run Ansible playbook directly
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --vault-id secrets/.vault_pass
```

### Deployment Options

#### Dry Run

```bash
# Check what would be deployed
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --check
```

#### Verbose Output

```bash
# Detailed deployment output
./scripts/deploy.sh -vvv
```

## Deployment Stages

### Stage 1: Preflight Checks

- **Server Connectivity**: SSH access verification
- **Docker Status**: Docker daemon availability
- **Network Validation**: Traefik network existence
- **Port Availability**: Required port accessibility

### Stage 2: Container Deployment

- **Directory Creation**: Application directories
- **Configuration Generation**: Nginx and application configs
- **Container Creation**: Docker container deployment
- **Network Integration**: Traefik network connection

### Stage 3: Service Integration

- **Traefik Discovery**: Automatic service detection
- **SSL Provisioning**: Let's Encrypt certificate generation
- **Health Validation**: Service health verification
- **Content Verification**: Web page accessibility

### Stage 4: Post-Deployment Validation

- **Container Status**: Running state verification
- **Port Accessibility**: Service port availability
- **Content Delivery**: Web page content verification
- **SSL Certificate**: HTTPS functionality validation

## Validation and Testing

### Automated Validation

The deployment includes built-in validation:

- **Container Health**: Docker container status checks
- **Port Testing**: HTTP response validation
- **Content Verification**: Web page content validation
- **SSL Testing**: HTTPS certificate validation

### Manual Testing

```bash
# Test localhost access
curl -I http://localhost:8080

# Test domain access
curl -I https://yourdomain.com

# Check container logs
docker logs static-web-yourdomain.com
```

### Health Check Commands

```bash
# Container status
docker ps | grep static-web

# Network connectivity
docker network inspect traefik-network

# SSL certificate status
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com
```

## Troubleshooting Deployment

### Common Issues

#### Container Not Starting

```bash
# Check container logs
docker logs static-web-yourdomain.com

# Verify configuration
docker inspect static-web-yourdomain.com
```

#### Network Issues

```bash
# Check network connectivity
docker network ls
docker network inspect traefik-network
```

#### SSL Certificate Issues

```bash
# Check Traefik logs
docker logs traefik

# Verify domain configuration
nslookup yourdomain.com
```

### Recovery Procedures

#### Container Recovery

```bash
# Restart container
docker restart static-web-yourdomain.com

# Recreate container
docker rm -f static-web-yourdomain.com
./scripts/deploy.sh
```

#### Configuration Recovery

```bash
# Restore from backup
cp secrets/vault.yml.backup secrets/vault.yml

# Redeploy with restored configuration
./scripts/deploy.sh
```

## Deployment Best Practices

### Pre-Deployment

- **Backup Configuration**: Always backup before changes
- **Test in Staging**: Validate changes in test environment
- **Review Changes**: Understand what will be deployed
- **Schedule Maintenance**: Plan deployment windows

### During Deployment

- **Monitor Progress**: Watch deployment output
- **Validate Each Stage**: Confirm each stage completion
- **Document Issues**: Record any problems encountered
- **Test Functionality**: Verify all features work

### Post-Deployment

- **Health Monitoring**: Monitor system health
- **Performance Validation**: Check response times
- **User Testing**: Validate user experience
- **Documentation Update**: Update deployment records
