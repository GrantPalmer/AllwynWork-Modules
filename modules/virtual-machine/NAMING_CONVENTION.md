# Azure Virtual Machine Module - Naming Convention Documentation

This document outlines the comprehensive naming conventions used in the Virtual Machine module for consistent resource naming across Azure environments.

## Overview

The module implements a standardized naming convention that ensures all Azure resources follow a consistent, predictable pattern. This helps with:
- **Resource identification** and organization
- **Environment segregation** and management
- **Compliance** with enterprise naming standards
- **Automation** and scripting capabilities
- **Cost tracking** and allocation

## Core Naming Components

### Input Variables for Naming

| Variable | Type | Default | Description | Example Values |
|----------|------|---------|-------------|----------------|
| `region` | string | `"uks"` | Azure region abbreviation | `"uks"`, `"ukw"`, `"euw"`, `"neu"` |
| `environment` | string | `"prd"` | Environment designation | `"prd"`, `"dev"`, `"tst"`, `"stg"`, `"uat"` |
| `purpose` | string | *required* | Resource function/role | `"web"`, `"app"`, `"db"`, `"ad"`, `"pwsh"` |
| `app_shortcode` | string | `""` | Application identifier | `"CRM"`, `"ERP"`, `"AUK"`, `"LSH"` |
| `subname` | string | `""` | Additional identifier | `"frontend"`, `"backend"`, `"api"` |
| `instance` | string | `"01"` | Instance number | `"01"`, `"02"`, `"03"` |
| `additional_elements` | string | `"OS"` | Resource-specific suffix | `"OS"`, `"DATA"`, `"LOG"` |

### Variable Defaults and Fallbacks

```terraform
# App shortcode fallback
app_shortcode != "" ? var.app_shortcode : "AUK"

# Subname fallback  
subname != "" ? var.subname : "auk"
```

## Resource Naming Patterns

### 1. Virtual Machine Names

**Pattern**: `VM-<PURPOSE>-<APP_CODE>-<ENVIRONMENT>-<INSTANCE>`

**Format**: All UPPERCASE with hyphens
```terraform
vm_base_name = "VM-${upper(var.purpose)}-${upper(var.app_shortcode != "" ? var.app_shortcode : "AUK")}-${upper(var.environment)}"
```

**Examples**:
- `VM-WEB-CRM-PRD-01` - Production CRM web server #1
- `VM-APP-ERP-DEV-02` - Development ERP application server #2  
- `VM-DB-AUK-TST-01` - Test database server #1
- `VM-AD-LSH-PRD-03` - Production Active Directory server #3

### 2. Network Interface Card (NIC) Names

**Pattern**: `NIC-<subname>-vm-<purpose>-<subname>-<environment>-<INSTANCE>`

**Format**: All lowercase with hyphens
```terraform
nic_base_name = "NIC-${lower(var.subname != "" ? var.subname : "auk")}-vm-${lower(var.purpose)}-${lower(var.subname != "" ? var.subname : "auk")}-${lower(var.environment)}"
```

**Examples**:
- `NIC-frontend-vm-web-frontend-prd-01` - Production frontend web server NIC #1
- `NIC-api-vm-app-api-dev-02` - Development API application server NIC #2
- `NIC-auk-vm-db-auk-tst-01` - Test database server NIC #1 (default subname)

### 3. Disk Names

**Pattern**: `DSK-<REGION>-<APP_CODE>-<ENVIRONMENT>-<DISK_TYPE>-<INSTANCE>`

**Format**: All UPPERCASE with hyphens
```terraform
disk_base_name = "DSK-${upper(var.region)}-${upper(var.app_shortcode != "" ? var.app_shortcode : "AUK")}-${upper(var.environment)}-${upper(var.additional_elements)}"
```

**Examples**:
- `DSK-UKS-CRM-PRD-OS-01` - Production CRM OS disk #1 in UK South
- `DSK-UKW-ERP-DEV-DATA-02` - Development ERP data disk #2 in UK West
- `DSK-EUW-AUK-TST-LOG-01` - Test log disk #1 in Europe West

### 4. Computer/Hostname Names

**Pattern**: `az<purpose><app_code><environment><instance>`

**Format**: All lowercase, no separators, 15 character limit
```terraform
hostname_base = "az${lower(var.purpose)}${lower(var.app_shortcode != "" ? var.app_shortcode : "auk")}${lower(var.environment)}"
```

**Examples**:
- `azwebcrmprd01` - Production CRM web server #1
- `azapperpdev02` - Development ERP application server #2
- `azdbaukstg01` - Staging database server #1
- `azadlshprd03` - Production LSH Active Directory server #3

## Complete Naming Example

For a production CRM web server deployment with these variables:
```hcl
region          = "uks"
environment     = "prd" 
purpose         = "web"
app_shortcode   = "CRM"
subname         = "frontend"
instance        = "01"
server_count    = 2
```

**Generated Resource Names**:
- **VM #1**: `VM-WEB-CRM-PRD-01`
- **VM #2**: `VM-WEB-CRM-PRD-02`
- **NIC #1**: `NIC-frontend-vm-web-frontend-prd-01`
- **NIC #2**: `NIC-frontend-vm-web-frontend-prd-02`
- **Disk #1**: `DSK-UKS-CRM-PRD-OS-01`
- **Disk #2**: `DSK-UKS-CRM-PRD-OS-02`
- **Hostname #1**: `azwebcrmprd01`
- **Hostname #2**: `azwebcrmprd02`

## Region Abbreviations

| Region | Code | Azure Region |
|--------|------|--------------|
| `uks` | UK South | `uksouth` |
| `ukw` | UK West | `ukwest` |
| `euw` | Europe West | `westeurope` |
| `neu` | North Europe | `northeurope` |
| `use` | US East | `eastus` |
| `usw` | US West | `westus` |

## Environment Codes

| Environment | Code | Description |
|-------------|------|-------------|
| `prd` | Production | Live production environment |
| `dev` | Development | Development environment |
| `tst` | Test | Testing environment |
| `stg` | Staging | Pre-production staging |
| `uat` | User Acceptance Testing | UAT environment |

## Common Purpose Values

| Purpose | Description | Use Case |
|---------|-------------|----------|
| `web` | Web Server | Frontend web applications, IIS, Apache |
| `app` | Application Server | Business logic, APIs, middleware |
| `db` | Database Server | SQL Server, MySQL, PostgreSQL |
| `ad` | Active Directory | Domain controllers, LDAP |
| `dns` | DNS Server | Domain name resolution |
| `dhcp` | DHCP Server | IP address assignment |
| `file` | File Server | File shares, storage |
| `print` | Print Server | Printer management |
| `backup` | Backup Server | Backup and recovery |
| `monitor` | Monitoring | System monitoring, SCOM |
| `proxy` | Proxy Server | Web proxy, reverse proxy |
| `vpn` | VPN Server | Remote access |
| `mail` | Mail Server | Exchange, SMTP |
| `jump` | Jump Server | Bastion host, jump box |
| `test` | Test Server | General testing purposes |

## Application Short Codes

| Short Code | Application | Description |
|------------|-------------|-------------|
| `AUK` | Default/Allwyn UK | Default company identifier |
| `LSH` | Lottery Services Hub | Lottery platform |
| `CRM` | Customer Relationship Management | CRM system |
| `ERP` | Enterprise Resource Planning | ERP system |
| `HR` | Human Resources | HR systems |
| `FIN` | Finance | Financial systems |
| `LOG` | Logging | Centralized logging |
| `MON` | Monitoring | System monitoring |
| `SEC` | Security | Security tools |
| `BACK` | Backup | Backup systems |

## Naming Best Practices

### 1. Consistency
- Always use the same pattern across all environments
- Maintain consistent case sensitivity (UPPER for VMs/disks, lower for NICs/hostnames)
- Use standardized abbreviations

### 2. Clarity
- Purpose should clearly indicate the server's function
- App shortcodes should be recognizable and documented
- Environment codes should be unambiguous

### 3. Scalability
- Instance numbers should use leading zeros (01, 02, 03...)
- Plan for reasonable scale (99 instances max with 2-digit format)
- Consider regional deployment patterns

### 4. Character Limits
- **VM Names**: 64 characters max (Azure limit)
- **NIC Names**: 80 characters max (Azure limit)  
- **Disk Names**: 80 characters max (Azure limit)
- **Hostnames**: 15 characters max (Windows NetBIOS limit)

### 5. Validation
All naming variables include validation rules:
```terraform
validation {
  condition     = contains(["prd", "dev", "tst", "stg", "uat"], lower(var.environment))
  error_message = "Environment must be one of: prd, dev, tst, stg, uat."
}
```

## Tagging Convention

In addition to naming, the module applies comprehensive tags:

### Standard Tags (All Resources)
```terraform
base_tags = {
  Environment = title(var.environment)    # "Prd", "Dev", "Tst"
  Department  = var.department           # "Platform Engineering"
  Source      = "terraform"              # Always "terraform"
  Project     = var.project              # "CoreServices"
  CostCenter  = var.cost_center          # "TBC"
  RFC         = var.rfc                  # "TBC"
  UpdateRing  = var.update_ring          # "Priority", "Standard", "Extended"
}
```

### VM-Specific Tags
```terraform
vm_specific_tags = {
  AutoSchedule = var.stop_start_schedule  # "Weekdays=08:00-18:00 / Weekends=0"
}
```

### Timestamp Tags (Optional)
```terraform
timestamp_tags = {
  CreatedDate = formatdate("DD-MM-YYYY", timestamp())
  ExpiryDate  = formatdate("DD-MM-YYYY", expiry_time)
}
```

## Usage Examples

### Basic Web Server
```hcl
module "web_server" {
  source = "../../modules/virtual-machine"
  
  region        = "uks"
  environment   = "prd"
  purpose       = "web"
  app_shortcode = "CRM"
  subname       = "frontend"
  instance      = "01"
  server_count  = 2
  
  # Results in:
  # VMs: VM-WEB-CRM-PRD-01, VM-WEB-CRM-PRD-02
  # NICs: NIC-frontend-vm-web-frontend-prd-01, NIC-frontend-vm-web-frontend-prd-02
  # Disks: DSK-UKS-CRM-PRD-OS-01, DSK-UKS-CRM-PRD-OS-02
  # Hostnames: azwebcrmprd01, azwebcrmprd02
}
```

### Database Server with Data Disks
```hcl
module "database_server" {
  source = "../../modules/virtual-machine"
  
  region              = "euw"
  environment         = "prd"
  purpose             = "db"
  app_shortcode       = "ERP"
  instance            = "01"
  additional_elements = "DATA"  # For data disks
  
  # Results in:
  # VM: VM-DB-ERP-PRD-01
  # NIC: NIC-erp-vm-db-erp-prd-01 (using fallback subname)
  # Disk: DSK-EUW-ERP-PRD-DATA-01
  # Hostname: azdberpprd01
}
```

### Development Environment
```hcl
module "dev_app_server" {
  source = "../../modules/virtual-machine"
  
  region        = "ukw"
  environment   = "dev"
  purpose       = "app"
  app_shortcode = "TEST"
  subname       = "api"
  
  # Results in:
  # VM: VM-APP-TEST-DEV-01
  # NIC: NIC-api-vm-app-api-dev-01
  # Disk: DSK-UKW-TEST-DEV-OS-01
  # Hostname: azapptestdev01
}
```

## Compliance and Standards

This naming convention aligns with:
- **Microsoft Azure naming conventions**
- **Enterprise IT standards**
- **Infrastructure as Code best practices**
- **Multi-environment deployment patterns**
- **Disaster recovery planning**

## Troubleshooting Naming Issues

### Common Issues

1. **Name too long**
   - Check character limits for each resource type
   - Use shorter app_shortcode or purpose values
   - Consider abbreviations

2. **Invalid characters**
   - VMs/NICs: Only alphanumeric and hyphens
   - Hostnames: Only alphanumeric (Windows NetBIOS)
   - No spaces or special characters

3. **Duplicate names**
   - Ensure instance numbers are unique per environment
   - Check existing resources before deployment
   - Use terraform plan to preview names

4. **Case sensitivity**
   - VM names: UPPERCASE
   - NIC names: lowercase  
   - Hostnames: lowercase
   - Consistent casing is enforced by the module

### Validation Commands

```bash
# Preview all resource names
terraform plan | grep "name"

# Check for naming conflicts
az vm list --query "[].name" -o table

# Validate hostname length (15 char max)
echo "azwebcrmprd01" | wc -c
```

This naming convention ensures consistent, predictable, and manageable resource naming across all Azure virtual machine deployments.
