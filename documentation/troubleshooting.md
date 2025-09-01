# Troubleshooting Guide

## Overview

This document provides comprehensive troubleshooting guidance for the Static Web Deployment system, including common issues, diagnostic procedures, and resolution steps.

## Diagnostic Tools

### System Information Commands

```bash
# Check system status
systemctl status docker
systemctl status nginx

# Check container status
docker ps -a
docker logs static-web-yourdomain.com

# Check network status
docker network ls
docker network inspect traefik-network

# Check disk space
df -h
du -sh /var/lib/docker
```

### Ansible Diagnostic Commands

```bash
# Check Ansible connectivity
ansible -i src/inventory/hosts.yml all -m ping

# Validate playbook syntax
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --syntax-check

# Dry run deployment
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --check

# Verbose output
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml -vvv
```

## Common Issues and Solutions

### Deployment Issues

#### Issue: Vault Password File Not Found

**Symptoms:**
```
ERROR! Attempting to decrypt but no vault secrets found
```

**Diagnosis:**
```bash
# Check vault password file
ls -la secrets/.vault_pass
cat secrets/.vault_pass
```

**Solution:**
```bash
# Create vault password file
echo "your-vault-password" > secrets/.vault_pass
chmod 600 secrets/.vault_pass
```

#### Issue: SSH Connection Failed

**Symptoms:**
```
fatal: [vps]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh"}
```

**Diagnosis:**
```bash
# Test SSH connection manually
ssh -i /path/to/key ubuntu@server-ip

# Check SSH key permissions
ls -la ~/.ssh/
```

**Solution:**
```bash
# Fix SSH key permissions
chmod 600 ~/.ssh/private_key
chmod 644 ~/.ssh/public_key

# Test connection
ssh -i ~/.ssh/private_key ubuntu@server-ip
```

#### Issue: Docker Permission Denied

**Symptoms:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Diagnosis:**
```bash
# Check user groups
groups $USER
id $USER
```

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify docker access
docker ps
```

### Container Issues

#### Issue: Container Not Starting

**Symptoms:**
```
Container status: restarting
```

**Diagnosis:**
```bash
# Check container logs
docker logs static-web-yourdomain.com

# Check container configuration
docker inspect static-web-yourdomain.com
```

**Solution:**
```bash
# Remove and recreate container
docker rm -f static-web-yourdomain.com
./scripts/deploy.sh
```

#### Issue: Port Already in Use

**Symptoms:**
```
Bind for 0.0.0.0:8080 failed: port is already allocated
```

**Diagnosis:**
```bash
# Check port usage
netstat -tulpn | grep :8080
lsof -i :8080
```

**Solution:**
```bash
# Stop conflicting container
docker stop $(docker ps -q --filter "publish=8080")

# Or use different port
# Edit configuration to use different port
```

#### Issue: Network Connection Failed

**Symptoms:**
```
Container cannot connect to traefik-network
```

**Diagnosis:**
```bash
# Check network existence
docker network ls | grep traefik

# Check network configuration
docker network inspect traefik-network
```

**Solution:**
```bash
# Create network if missing
docker network create traefik-network

# Recreate container with network
docker rm -f static-web-yourdomain.com
./scripts/deploy.sh
```

### Web Server Issues

#### Issue: 502 Bad Gateway

**Symptoms:**
```
HTTP 502 Bad Gateway
```

**Diagnosis:**
```bash
# Check container status
docker ps | grep static-web

# Check nginx logs
docker logs static-web-yourdomain.com

# Test container directly
curl -I http://localhost:8080
```

**Solution:**
```bash
# Restart container
docker restart static-web-yourdomain.com

# Check nginx configuration
docker exec static-web-yourdomain.com nginx -t
```

#### Issue: SSL Certificate Issues

**Symptoms:**
```
SSL certificate not found or invalid
```

**Diagnosis:**
```bash
# Check Traefik logs
docker logs traefik

# Check certificate status
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com
```

**Solution:**
```bash
# Restart Traefik
docker restart traefik

# Check Let's Encrypt rate limits
# Wait if rate limited
```

#### Issue: Content Not Loading

**Symptoms:**
```
Page loads but content is missing or incorrect
```

**Diagnosis:**
```bash
# Check content files
docker exec static-web-yourdomain.com ls -la /usr/share/nginx/html/

# Check file permissions
docker exec static-web-yourdomain.com ls -la /usr/share/nginx/html/index.html
```

**Solution:**
```bash
# Fix file permissions
docker exec static-web-yourdomain.com chown nginx:nginx /usr/share/nginx/html/index.html

# Recreate content
./scripts/deploy.sh
```

### Network Issues

#### Issue: Domain Not Resolving

**Symptoms:**
```
Domain name does not resolve to server IP
```

**Diagnosis:**
```bash
# Check DNS resolution
nslookup yourdomain.com
dig yourdomain.com

# Check domain configuration
whois yourdomain.com
```

**Solution:**
```bash
# Update DNS records
# Point A record to server IP
# Wait for DNS propagation (up to 48 hours)
```

#### Issue: Firewall Blocking Traffic

**Symptoms:**
```
Connection refused or timeout
```

**Diagnosis:**
```bash
# Check firewall status
sudo ufw status
sudo iptables -L

# Test port accessibility
telnet yourdomain.com 80
telnet yourdomain.com 443
```

**Solution:**
```bash
# Allow HTTP and HTTPS traffic
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

## Advanced Troubleshooting

### Performance Issues

#### High CPU Usage

**Diagnosis:**
```bash
# Check container resource usage
docker stats static-web-yourdomain.com

# Check system load
top
htop
```

**Solution:**
```bash
# Limit container resources
docker update --cpus="0.5" --memory="512m" static-web-yourdomain.com
```

#### High Memory Usage

**Diagnosis:**
```bash
# Check memory usage
free -h
docker stats --no-stream
```

**Solution:**
```bash
# Restart container
docker restart static-web-yourdomain.com

# Check for memory leaks
docker logs static-web-yourdomain.com | grep -i memory
```

### Log Analysis

#### Nginx Access Logs

```bash
# View access logs
docker exec static-web-yourdomain.com tail -f /var/log/nginx/access.log

# Analyze access patterns
docker exec static-web-yourdomain.com awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr
```

#### Nginx Error Logs

```bash
# View error logs
docker exec static-web-yourdomain.com tail -f /var/log/nginx/error.log

# Check for specific errors
docker exec static-web-yourdomain.com grep -i error /var/log/nginx/error.log
```

#### Container Logs

```bash
# View container logs
docker logs static-web-yourdomain.com

# Follow logs in real-time
docker logs -f static-web-yourdomain.com

# View logs with timestamps
docker logs -t static-web-yourdomain.com
```

### Configuration Issues

#### Template Rendering Errors

**Diagnosis:**
```bash
# Check template syntax
ansible-playbook -i src/inventory/hosts.yml src/playbooks/deploy_static_web.yml --syntax-check

# Validate template variables
ansible -i src/inventory/hosts.yml all -m debug -a "var=traefik_domain"
```

**Solution:**
```bash
# Fix template syntax
# Check variable definitions
# Validate vault configuration
```

#### Variable Resolution Issues

**Diagnosis:**
```bash
# Check variable values
ansible -i src/inventory/hosts.yml all -m debug -a "var=variable_name"

# Validate vault access
ansible-vault view secrets/vault.yml
```

**Solution:**
```bash
# Fix variable definitions
# Check vault encryption
# Validate inventory configuration
```

## Recovery Procedures

### Complete System Recovery

#### Backup Restoration

```bash
# Restore from backup
cp secrets/vault.yml.backup secrets/vault.yml
cp src/inventory/group_vars/all/main.yml.backup src/inventory/group_vars/all/main.yml

# Redeploy system
./scripts/deploy.sh
```

#### Container Recovery

```bash
# Remove all containers
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Redeploy from scratch
./scripts/deploy.sh
```

### Partial Recovery

#### Configuration Recovery

```bash
# Restore specific configuration
git checkout HEAD -- src/inventory/group_vars/all/main.yml

# Redeploy with restored configuration
./scripts/deploy.sh
```

#### Content Recovery

```bash
# Restore content files
docker cp backup/index.html static-web-yourdomain.com:/usr/share/nginx/html/

# Restart container
docker restart static-web-yourdomain.com
```

## Prevention Strategies

### Regular Maintenance

#### Daily Checks

- Container status verification
- Disk space monitoring
- Log file rotation
- SSL certificate status

#### Weekly Checks

- Security updates
- Performance monitoring
- Backup verification
- Configuration review

#### Monthly Checks

- Security audit
- Performance optimization
- Documentation updates
- Disaster recovery testing

### Monitoring Setup

#### Health Checks

```bash
# Automated health check script
#!/bin/bash
curl -f http://localhost:8080 || exit 1
curl -f https://yourdomain.com || exit 1
```

#### Alerting

- Container down alerts
- SSL certificate expiration alerts
- Disk space alerts
- Performance degradation alerts

## Getting Help

### Documentation Resources

- [Project README](README.md)
- [Architecture Documentation](architecture.md)
- [Configuration Management](configuration-management.md)
- [Security Implementation](security.md)

### Support Channels

- **Repository Issues**: Create detailed issue reports
- **Documentation**: Check existing documentation
- **Community**: Ansible and Docker communities
- **Professional Support**: Commercial support options

### Issue Reporting

When reporting issues, include:

- **System Information**: OS, Docker version, Ansible version
- **Error Messages**: Complete error output
- **Logs**: Relevant log files
- **Steps to Reproduce**: Detailed reproduction steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens

## Troubleshooting Checklist

### Pre-Troubleshooting

- [ ] **Document the Issue**: Record symptoms and error messages
- [ ] **Gather Information**: Collect system logs and configuration
- [ ] **Check Documentation**: Review relevant documentation
- [ ] **Identify Scope**: Determine if issue affects single component or entire system

### During Troubleshooting

- [ ] **Start Simple**: Begin with basic diagnostic commands
- [ ] **Check Logs**: Review all relevant log files
- [ ] **Test Connectivity**: Verify network and service connectivity
- [ ] **Validate Configuration**: Check configuration files and settings
- [ ] **Test Components**: Verify individual component functionality

### Post-Troubleshooting

- [ ] **Document Solution**: Record the resolution steps
- [ ] **Update Documentation**: Add new troubleshooting information
- [ ] **Prevent Recurrence**: Implement measures to prevent similar issues
- [ ] **Share Knowledge**: Update team knowledge base

## Specific Error Messages and Solutions

### Ansible Errors

#### "Failed to connect to the host via ssh"

**Common Causes:**
- SSH key permissions incorrect
- SSH key not in authorized_keys
- Network connectivity issues
- User account locked

**Solutions:**
```bash
# Fix SSH key permissions
chmod 600 ~/.ssh/private_key

# Test SSH connection
ssh -i ~/.ssh/private_key user@server

# Check authorized_keys
ssh-copy-id -i ~/.ssh/public_key user@server
```

#### "Permission denied while trying to connect to the Docker daemon socket"

**Common Causes:**
- User not in docker group
- Docker daemon not running
- Incorrect socket permissions

**Solutions:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Start Docker daemon
sudo systemctl start docker
sudo systemctl enable docker

# Check Docker status
sudo systemctl status docker
```

### Docker Errors

#### "Container name already in use"

**Common Causes:**
- Previous container not removed
- Container name conflict

**Solutions:**
```bash
# Remove existing container
docker rm -f container-name

# List all containers
docker ps -a

# Remove all stopped containers
docker container prune
```

#### "Port is already allocated"

**Common Causes:**
- Another service using the port
- Previous container still running

**Solutions:**
```bash
# Find process using port
sudo netstat -tulpn | grep :8080
sudo lsof -i :8080

# Kill process using port
sudo kill -9 PID

# Stop Docker container using port
docker stop $(docker ps -q --filter "publish=8080")
```

### Network Errors

#### "Connection refused"

**Common Causes:**
- Service not running
- Firewall blocking connection
- Wrong port or IP

**Solutions:**
```bash
# Check service status
systemctl status service-name

# Check firewall
sudo ufw status
sudo iptables -L

# Test connectivity
telnet hostname port
nc -zv hostname port
```

#### "Name or service not known"

**Common Causes:**
- DNS resolution failure
- Incorrect hostname
- Network connectivity issues

**Solutions:**
```bash
# Check DNS resolution
nslookup hostname
dig hostname

# Check /etc/hosts
cat /etc/hosts

# Test network connectivity
ping hostname
```

## Performance Troubleshooting

### Slow Response Times

**Diagnosis:**
```bash
# Check container resource usage
docker stats

# Check system load
top
htop
iostat

# Check network latency
ping -c 10 hostname
traceroute hostname
```

**Solutions:**
```bash
# Increase container resources
docker update --cpus="1.0" --memory="1g" container-name

# Optimize nginx configuration
# Add caching headers
# Enable gzip compression
```

### High Memory Usage

**Diagnosis:**
```bash
# Check memory usage
free -h
docker stats --no-stream

# Check for memory leaks
docker logs container-name | grep -i memory
```

**Solutions:**
```bash
# Restart container
docker restart container-name

# Limit container memory
docker update --memory="512m" container-name

# Check for memory leaks in application
```

### High CPU Usage

**Diagnosis:**
```bash
# Check CPU usage
top
htop
docker stats

# Check for high CPU processes
ps aux --sort=-%cpu | head
```

**Solutions:**
```bash
# Limit container CPU
docker update --cpus="0.5" container-name

# Optimize application code
# Add caching
# Reduce processing load
```

This completes the comprehensive troubleshooting documentation with all the missing sections and specific error message solutions.
