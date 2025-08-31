# Provider Requirements

This document outlines the Azure provider version requirements and compatibility matrix for the Terraform modules.

## Current Standards

### Azure Provider Version
**Current Required Version:** `~> 3.116.0`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"
    }
  }
}
```

### Terraform Version
**Minimum Required:** `>= 1.0`

## Version Compatibility Matrix

| Module Version | Azure Provider | Terraform Version | Status |
|---------------|----------------|-------------------|---------|
| v2.x.x        | ~> 3.116.0     | >= 1.0           | ✅ Current |
| v1.x.x        | ~> 3.85.0      | >= 0.15          | ⚠️ Legacy |
| v0.x.x        | ~> 3.1.0       | >= 0.14          | ❌ Deprecated |

## Breaking Changes by Version

### Azure Provider 3.x → 3.116.x
- Enhanced security features
- New resource properties
- Improved validation
- Performance optimizations

**Migration Required:**
- Update provider version in all modules
- Test thoroughly in development
- Review deprecated arguments

### Key Changes in 3.116.0
- Security enhancements for virtual machines
- Updated API versions for storage accounts
- Improved networking resource support
- Enhanced monitoring capabilities

## Module-Specific Requirements

### Core Infrastructure Modules
| Module | Provider Version | Notes |
|--------|-----------------|-------|
| terraform-azurerm-resource-group | ~> 3.116.0 | Standard compatibility |
| terraform-azurerm-virtual-network | ~> 3.116.0 | Enhanced networking features |
| terraform-azurerm-storage-account | ~> 3.116.0 | Updated blob features |

### Compute Modules
| Module | Provider Version | Notes |
|--------|-----------------|-------|
| terraform-azurerm-windows-virtual-machine | ~> 3.116.0 | Security enhancements |
| terraform-azurerm-linux-virtual-machine | ~> 3.116.0 | Updated VM features |
| terraform-azurerm-azure-kubernetes-service | ~> 3.116.0 | Latest AKS capabilities |

### Security Modules
| Module | Provider Version | Notes |
|--------|-----------------|-------|
| terraform-azurerm-key-vault | ~> 3.116.0 | Enhanced RBAC support |
| terraform-azurerm-user-assigned-identity | ~> 3.116.0 | Standard compatibility |

## Update Schedule

### Regular Updates
- **Quarterly Reviews:** Check for new provider versions
- **Security Patches:** Apply immediately when available
- **Feature Updates:** Evaluate quarterly
- **Major Versions:** Plan migration with 6-month timeline

### Emergency Updates
Security vulnerabilities require immediate attention:
1. Assess impact within 24 hours
2. Test patches in development
3. Deploy to production within 1 week
4. Document changes and notify teams

## Upgrade Process

### Step 1: Planning
1. Review provider changelog
2. Identify breaking changes
3. Plan testing approach
4. Schedule maintenance windows

### Step 2: Testing
1. Update development environment first
2. Run comprehensive tests
3. Validate all module functionality
4. Check for deprecated features

### Step 3: Implementation
1. Update provider versions in modules
2. Test in staging environment
3. Deploy to production
4. Monitor for issues

### Step 4: Validation
1. Verify all resources function correctly
2. Check monitoring and logging
3. Validate security configurations
4. Document any issues or changes

## Version Pinning Strategy

### Recommended Approach
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0"  # Allow patch updates
    }
  }
}
```

### Rationale
- `~> 3.116.0` allows patch versions (3.116.1, 3.116.2, etc.)
- Prevents automatic minor version updates
- Ensures stability while allowing security patches
- Requires explicit action for feature updates

## Compatibility Testing

### Automated Testing
```bash
# Validate all modules
find . -name "*.tf" -path "*/terraform-*" -exec dirname {} \; | sort -u | while read dir; do
  echo "Testing $dir"
  cd "$dir"
  terraform init
  terraform validate
  cd - > /dev/null
done
```

### Manual Testing Checklist
- [ ] Provider initialization successful
- [ ] Module validation passes
- [ ] Resource creation works
- [ ] Outputs are correct
- [ ] Dependencies function properly
- [ ] Security features enabled

## Migration Guides

### From 3.85.x to 3.116.x
1. **Update provider block** in all modules
2. **Test networking modules** - enhanced features available
3. **Validate security configurations** - new options added
4. **Check storage accounts** - API updates implemented

### From 3.1.x to 3.116.x
⚠️ **Major migration required**

1. **Review all breaking changes** from 3.1 to 3.116
2. **Update resource configurations** for deprecated arguments
3. **Test extensively** - significant changes
4. **Plan phased rollout** - high risk migration
5. **Backup state files** before migration

## Support

### Provider Issues
- [Azure Provider GitHub](https://github.com/hashicorp/terraform-provider-azurerm)
- [Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Known Issues](https://github.com/hashicorp/terraform-provider-azurerm/issues)

### Version Information
```bash
# Check current provider version
terraform version

# List providers in use
terraform providers

# Check required versions
terraform providers schema -json | jq '.provider_schemas | keys'
```

## Future Roadmap

### Upcoming Changes
- Provider 4.x planning (2026)
- Azure API updates
- New resource types
- Enhanced security features

### Preparation Steps
1. Monitor provider announcements
2. Participate in beta testing
3. Plan migration timelines
4. Update documentation processes
