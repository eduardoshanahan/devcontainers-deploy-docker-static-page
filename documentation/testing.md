# Testing Procedures

## Overview

This document describes the comprehensive testing procedures for the Static Web Deployment system, including automated testing, manual validation, and integration testing strategies.

## Testing Architecture

### Testing Components

The testing system consists of two main playbooks:

- **`deploy_static_web.yml`**: Main deployment playbook with built-in validation
- **`test_traefik_integration.yml`**: Comprehensive integration testing playbook

### Testing Roles

#### Deploy Static Web Role (`deploy_static_web`)

**Purpose**: Deploy and validate static web container with Traefik integration

**Task Structure**:
- `preflight.yml`: Pre-deployment validation and setup
- `container.yml`: Container deployment and configuration
- `traefik_integration.yml`: Traefik network integration
- `validation.yml`: Post-deployment validation

#### Test Traefik Integration Role (`test_traefik_integration`)

**Purpose**: Comprehensive testing of Traefik integration and external access

**Task Structure**:
- `container_validation.yml`: Container status and network validation
- `network_validation.yml`: Network connectivity testing
- `ssl_validation.yml`: SSL certificate and HTTPS testing
- `diagnostics.yml`: Comprehensive diagnostic information

## Automated Testing

### Deployment Testing

#### Preflight Validation

The deployment includes comprehensive preflight checks:

```bash
# Run deployment with validation
./scripts/deploy.sh
```

**Preflight Checks Include**:
- Docker daemon accessibility verification
- Docker network listing and validation
- Traefik network existence verification
- Directory structure creation
- Port availability validation

#### Container Deployment Testing

**Container Validation**:
- Nginx configuration generation and validation
- Static web page template creation
- Container deployment with proper networking
- Traefik label configuration
- Port mapping verification

#### Post-Deployment Validation

**Built-in Validation**:
- Container readiness verification (60-second timeout)
- Port accessibility testing (localhost and container IP)
- HTTP response validation (200 status code)
- Content verification (correct HTML content)
- Container status monitoring

### Integration Testing

#### Traefik Integration Testing

```bash
# Run comprehensive integration tests
ansible-playbook -i src/inventory/hosts.yml src/playbooks/test_traefik_integration.yml --vault-password-file secrets/.vault_pass
```

**Integration Test Components**:

**Container Validation**:
- Static web container status verification
- Traefik container status checking
- Network membership validation
- Container network configuration

**Network Validation**:
- Docker network connectivity testing
- Inter-container communication validation
- Port accessibility verification

**SSL Validation**:
- HTTP to HTTPS redirect testing
- HTTPS certificate validation
- External domain access testing
- SSL/TLS configuration verification

**Diagnostics**:
- Comprehensive system status reporting
- Network configuration analysis
- Container health monitoring
- Performance metrics collection

## Manual Testing Procedures

### Local Testing

#### Container Access Testing

```bash
# Test localhost access
curl -I http://localhost:8080

# Test container IP access
curl -I http://$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' static-web-yourdomain.com):80

# Test content delivery
curl http://localhost:8080
```

#### Network Testing

```bash
# Check container networks
docker network inspect traefik-network

# Verify container network membership
docker inspect static-web-yourdomain.com | grep -A 10 "Networks"

# Test inter-container communication
docker exec traefik ping static-web-yourdomain.com
```

### External Testing

#### Domain Access Testing

```bash
# Test HTTP access (should redirect to HTTPS)
curl -I http://yourdomain.com

# Test HTTPS access
curl -I https://yourdomain.com

# Test SSL certificate
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com
```

#### Performance Testing

```bash
# Load testing with Apache Bench
ab -n 1000 -c 10 https://yourdomain.com/

# Response time testing
curl -w "@curl-format.txt" -o /dev/null -s https://yourdomain.com/
```

## Testing Scenarios

### Scenario 1: Fresh Deployment

**Objective**: Validate complete deployment from scratch

**Steps**:
1. Run deployment playbook
2. Verify all preflight checks pass
3. Confirm container deployment success
4. Validate Traefik integration
5. Test external access
6. Run integration test suite

**Expected Results**:
- All validation steps pass
- Container running and accessible
- HTTPS working with valid certificate
- Content served correctly

### Scenario 2: Container Recovery

**Objective**: Test container restart and recovery

**Steps**:
1. Stop the static web container
2. Restart the container
3. Verify automatic recovery
4. Test service availability
5. Validate Traefik re-discovery

**Expected Results**:
- Container restarts successfully
- Service remains available
- Traefik re-discovers the service
- No manual intervention required

### Scenario 3: Network Issues

**Objective**: Test network connectivity and recovery

**Steps**:
1. Disconnect container from Traefik network
2. Reconnect container to network
3. Verify network connectivity
4. Test service discovery
5. Validate external access

**Expected Results**:
- Network reconnection successful
- Service discovery works
- External access restored
- No data loss

### Scenario 4: SSL Certificate Issues

**Objective**: Test SSL certificate handling

**Steps**:
1. Check certificate status
2. Test certificate renewal
3. Verify HTTPS functionality
4. Test HTTP to HTTPS redirect
5. Validate certificate chain

**Expected Results**:
- Valid SSL certificate
- HTTPS working correctly
- HTTP redirects to HTTPS
- Certificate chain valid

## Testing Tools and Commands

### Ansible Testing Commands

```bash
# Syntax check
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --syntax-check

# Dry run
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --check

# Verbose output
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml -vvv

# Test specific role
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --tags validation
```

### Docker Testing Commands

```bash
# Container status
docker ps | grep static-web

# Container logs
docker logs static-web-yourdomain.com

# Network inspection
docker network inspect traefik-network

# Container inspection
docker inspect static-web-yourdomain.com
```

### Network Testing Commands

```bash
# Port testing
nmap -p 80,443,8080 yourdomain.com

# DNS testing
nslookup yourdomain.com
dig yourdomain.com

# SSL testing
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com
```

## Continuous Testing

### Automated Testing Pipeline

**Pre-Deployment Testing**:
- Syntax validation
- Dry run execution
- Configuration validation
- Dependency checking

**Deployment Testing**:
- Automated deployment execution
- Built-in validation steps
- Error detection and reporting
- Rollback on failure

**Post-Deployment Testing**:
- Health check validation
- Integration testing
- Performance monitoring
- Security scanning

### Testing Schedule

**Daily Testing**:
- Health check validation
- Basic functionality testing
- Performance monitoring

**Weekly Testing**:
- Comprehensive integration testing
- Security vulnerability scanning
- Performance benchmarking

**Monthly Testing**:
- Disaster recovery testing
- Load testing
- Security audit

## Troubleshooting Testing Issues

### Common Testing Problems

#### Container Not Accessible

**Symptoms**:
- HTTP 502/503 errors
- Connection timeouts
- Container not responding

**Diagnosis**:
```bash
# Check container status
docker ps | grep static-web

# Check container logs
docker logs static-web-yourdomain.com

# Test internal connectivity
curl -I http://localhost:8080
```

**Solutions**:
- Restart container
- Check network configuration
- Verify port mappings
- Review container logs

#### SSL Certificate Issues

**Symptoms**:
- HTTPS not working
- Certificate errors
- Mixed content warnings

**Diagnosis**:
```bash
# Check certificate status
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Check Traefik logs
docker logs traefik

# Verify domain configuration
nslookup yourdomain.com
```

**Solutions**:
- Check Traefik configuration
- Verify domain DNS settings
- Review Let's Encrypt logs
- Test certificate renewal

#### Network Connectivity Issues

**Symptoms**:
- Containers can't communicate
- Network not found
- Connection refused

**Diagnosis**:
```bash
# Check network status
docker network ls
docker network inspect traefik-network

# Test container connectivity
docker exec static-web-yourdomain.com ping traefik
```

**Solutions**:
- Recreate network
- Restart containers
- Check firewall settings
- Verify network configuration

## Testing Best Practices

### Test Environment

- **Isolation**: Use separate test environment
- **Data**: Use test data, not production data
- **Configuration**: Mirror production configuration
- **Monitoring**: Enable comprehensive logging

### Test Execution

- **Automation**: Automate repetitive tests
- **Documentation**: Document all test procedures
- **Reporting**: Generate detailed test reports
- **Validation**: Verify all test results

### Test Maintenance

- **Updates**: Keep tests current with code changes
- **Review**: Regular test review and improvement
- **Coverage**: Maintain comprehensive test coverage
- **Performance**: Monitor test execution performance

## Testing Metrics

### Key Performance Indicators

- **Deployment Success Rate**: Percentage of successful deployments
- **Test Coverage**: Percentage of code covered by tests
- **Test Execution Time**: Time to complete test suite
- **Issue Detection Rate**: Issues found during testing

### Quality Metrics

- **Defect Density**: Defects per deployment
- **Mean Time to Recovery**: Time to fix issues
- **Test Reliability**: Consistency of test results
- **User Satisfaction**: End-user experience metrics

## Conclusion

The testing procedures provide comprehensive validation of the Static Web Deployment system, ensuring reliable operation and quick issue detection. Regular testing helps maintain system health and provides confidence in deployment processes.

For additional testing scenarios or troubleshooting assistance, refer to the [Troubleshooting Guide](troubleshooting.md) or create an issue in the repository.
