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
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --vault-password-file secrets/.vault_pass
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

**NEW**: Enhanced preflight validation includes:

- **Docker Accessibility**: Docker daemon version and accessibility verification
- **Network Discovery**: Complete Docker network listing and analysis
- **Traefik Network Validation**: Specific verification of `traefik-network` existence
- **Directory Structure**: Automatic creation of required deployment directories
- **Port Availability**: Validation of required port accessibility

### Stage 2: Container Deployment

**UPDATED**: Comprehensive container deployment process:

- **Configuration Generation**: Nginx configuration and static web page templates
- **Container Management**: Intelligent container removal and recreation
- **Port Conflict Resolution**: Automatic detection and resolution of port conflicts
- **Network Integration**: Seamless Traefik network connection
- **Label Configuration**: Complete Traefik service discovery labels
- **Logging Integration**: Container log monitoring and debugging

### Stage 3: Service Integration

**ENHANCED**: Advanced service integration:

- **Container Verification**: Real-time container status monitoring
- **Traefik Discovery**: Automatic service detection and registration
- **SSL Provisioning**: Let's Encrypt certificate generation
- **Health Validation**: Comprehensive service health verification
- **Content Verification**: Web page content and accessibility validation

### Stage 4: Post-Deployment Validation

**NEW**: Comprehensive validation suite:

- **Container Readiness**: 60-second timeout with port accessibility testing
- **Multi-Point Testing**: Localhost and container IP validation
- **HTTP Response Validation**: 200 status code verification
- **Content Verification**: HTML content validation and length checking
- **Performance Metrics**: Response time and content delivery validation

## Validation and Testing

### Built-in Validation

**UPDATED**: The deployment includes comprehensive built-in validation:

- **Container Health**: Docker container status and network verification
- **Port Testing**: Multi-point HTTP response validation (localhost and container IP)
- **Content Verification**: Web page content validation with specific content checks
- **Performance Monitoring**: Response time and content length validation
- **Log Analysis**: Container log monitoring and debugging information

### Integration Testing

**NEW**: Comprehensive integration testing playbook:

```bash
# Run integration tests
ansible-playbook -i src/inventory/hosts.yml src/playbooks/test_traefik_integration.yml --vault-password-file secrets/.vault_pass
```

**Integration Test Components**:

- **Container Validation**: Static web and Traefik container status verification
- **Network Validation**: Docker network connectivity and configuration testing
- **SSL Validation**: HTTPS certificate and redirect testing
- **Diagnostics**: Comprehensive system status and performance reporting

### Manual Testing

```bash
# Test localhost access
curl -I http://localhost:8080

# Test domain access
curl -I https://yourdomain.com

# Check container logs
docker logs static-web-yourdomain.com

# Run comprehensive integration tests
ansible-playbook -i src/inventory/hosts.yml src/playbooks/test_traefik_integration.yml --vault-password-file secrets/.vault_pass
```

### Health Check Commands

```bash
# Container status
docker ps | grep static-web

# Network connectivity
docker network inspect traefik-network

# SSL certificate status
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Integration test results
ansible-playbook -i src/inventory/hosts.yml src/playbooks/test_traefik_integration.yml --vault-password-file secrets/.vault_pass
```

## Troubleshooting Deployment

### Common Issues

#### Container Not Starting

```bash
# Check container logs
docker logs static-web-yourdomain.com

# Verify configuration
docker inspect static-web-yourdomain.com

# Run integration tests for diagnostics
ansible-playbook -i src/inventory/hosts.yml src/playbooks/test_traefik_integration.yml --vault-password-file secrets/.vault_pass
```

#### Network Issues

```bash
# Check network connectivity
docker network ls
docker network inspect traefik-network

# Run network validation tests
ansible-playbook -i src/inventory/hosts.yml src/playbooks/test_traefik_integration.yml --vault-password-file secrets/.vault_pass --tags network_validation
```

#### SSL Certificate Issues

```bash
# Check Traefik logs
docker logs traefik

# Verify domain configuration
nslookup yourdomain.com

# Run SSL validation tests
ansible-playbook -i src/inventory/hosts.yml src/playbooks/test_traefik_integration.yml --vault-password-file secrets/.vault_pass --tags ssl_validation
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

#### Integration Testing Recovery

```bash
# Run comprehensive diagnostics
ansible-playbook -i src/inventory/hosts.yml src/playbooks/test_traefik_integration.yml --vault-password-file secrets/.vault_pass --tags diagnostics
```

## Deployment Best Practices

### Pre-Deployment

- **Backup Configuration**: Always backup before changes
- **Test in Staging**: Validate changes in test environment
- **Review Changes**: Understand what will be deployed
- **Schedule Maintenance**: Plan deployment windows
- **Run Integration Tests**: Validate system health before deployment

### During Deployment

- **Monitor Progress**: Watch deployment output
- **Validate Each Stage**: Confirm each stage completion
- **Document Issues**: Record any problems encountered
- **Test Functionality**: Verify all features work
- **Check Validation Results**: Review built-in validation output

### Post-Deployment

- **Health Monitoring**: Monitor system health
- **Performance Validation**: Check response times
- **User Testing**: Validate user experience
- **Integration Testing**: Run comprehensive test suite
- **Documentation Update**: Update deployment records

### Testing Integration

**NEW**: Regular testing procedures:

- **Daily**: Basic health checks and functionality testing
- **Weekly**: Comprehensive integration testing
- **Monthly**: Performance benchmarking and security validation
- **Before Changes**: Always run integration tests before modifications
