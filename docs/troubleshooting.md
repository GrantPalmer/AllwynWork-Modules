# Troubleshooting Guide

This guide helps resolve common issues when using the Terraform Azure modules.

## Common Issues

### Provider Version Conflicts

**Problem:** Multiple modules requiring different Azure provider versions
```
Error: Module requires provider["registry.terraform.io/hashicorp/azurerm"] ~> 3.1.0,
but currently selected version is 3.116.0
```

**Solution:**
1. Update all modules to use the same provider version
2. Use version constraints that are compatible
3. Check the [Provider Requirements](./provider-requirements.md)

### Resource Naming Conflicts

**Problem:** Resources with duplicate names
```
Error: A resource with the ID "/subscriptions/.../resourceGroups/rg-name" already exists
```

**Solutions:**
1. Verify resource names are unique within their scope
2. Check the naming convention variables
3. Use different resource_suffix values
4. Ensure proper resource deletion if recreating

### Permission Issues

**Problem:** Insufficient Azure permissions
```
Error: Authorization failed. The client '...' does not have authorization to perform action
```

**Solutions:**
1. Verify Azure RBAC permissions
2. Check subscription access
3. Ensure service principal has required roles
4. Contact Azure administrator

### State File Issues

**Problem:** Terraform state inconsistencies
```
Error: Resource exists in configuration but not in state
```

**Solutions:**
1. Import existing resources: `terraform import`
2. Refresh state: `terraform refresh`
3. Remove from state if intentional: `terraform state rm`
4. Restore from backup if available

## Module-Specific Issues

### Virtual Machine Modules

**Issue:** Domain join failures
- Verify Active Directory credentials
- Check network connectivity to domain controllers
- Ensure proper DNS configuration
- Validate OU path syntax

**Issue:** VM size not available
- Check regional availability
- Verify quota limits
- Try alternative VM sizes
- Contact Azure support for quota increases

### Storage Account Modules

**Issue:** Storage account name conflicts
- Names must be globally unique
- Use only lowercase letters and numbers
- Maximum 24 characters
- Check availability with Azure CLI

**Issue:** Network access restrictions
- Verify firewall rules
- Check virtual network service endpoints
- Validate IP address ranges
- Test connectivity from allowed networks

### Network Modules

**Issue:** CIDR block overlaps
- Ensure non-overlapping address spaces
- Plan network topology carefully
- Use Azure IP address planning tools
- Document network assignments

**Issue:** NSG rule conflicts
- Check rule priorities (lower number = higher priority)
- Verify source/destination specifications
- Test connectivity after rule changes
- Use Azure Network Watcher for diagnostics

## Debugging Commands

### Terraform Debugging
```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Validate configuration
terraform validate

# Check formatting
terraform fmt -check -recursive

# Plan with target resource
terraform plan -target=module.resource_name

# Show current state
terraform show

# List resources in state
terraform state list
```

### Azure CLI Debugging
```bash
# Check current context
az account show

# List available regions
az account list-locations --output table

# Check resource group
az group show --name "resource-group-name"

# Verify permissions
az role assignment list --assignee "user@domain.com"

# Check resource availability
az vm list-skus --location "UK South" --output table
```

## Performance Issues

### Slow Terraform Operations

**Causes:**
- Large number of resources
- Complex module dependencies
- Network latency
- Provider limitations

**Solutions:**
- Use targeted plans: `terraform plan -target=`
- Parallelize when possible
- Optimize module structure
- Consider state file organization

### Azure API Rate Limits

**Symptoms:**
- HTTP 429 errors
- Intermittent failures
- Slow resource creation

**Solutions:**
- Implement retry logic
- Reduce concurrent operations
- Use appropriate resource batching
- Contact Azure support for limit increases

## Best Practices for Prevention

### Development Practices
1. Always test in development environment first
2. Use version pinning for modules
3. Implement proper CI/CD validation
4. Regular state file backups

### Resource Management
1. Use consistent naming conventions
2. Implement proper tagging strategies
3. Regular cleanup of unused resources
4. Monitor costs and usage

### Security Practices
1. Never commit secrets to version control
2. Use Azure Key Vault for sensitive data
3. Implement least privilege access
4. Regular security reviews

## Getting Additional Help

### Internal Resources
- Check module README files
- Review existing GitHub issues
- Consult team documentation
- Contact module maintainers

### External Resources
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Documentation](https://docs.microsoft.com/en-us/azure/)
- [Terraform Community Forums](https://discuss.hashicorp.com/c/terraform-providers/tf-azure/33)
- [Azure Support](https://azure.microsoft.com/en-us/support/)

### Creating Support Tickets

When creating an issue, include:
1. Terraform version
2. Azure provider version
3. Module version
4. Complete error messages
5. Relevant configuration snippets
6. Steps to reproduce
7. Expected vs actual behavior

### Log Collection

Useful logs to collect:
- Terraform debug logs (`TF_LOG=DEBUG`)
- Azure CLI verbose output (`--debug`)
- Network traces if connectivity issues
- Azure portal activity logs
