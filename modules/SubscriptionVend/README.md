# Azure Subscription Vending Module

This module provides a comprehensive **true subscription vending solution** for Azure environments. It can either create new Azure subscriptions or provision foundational resources in existing subscriptions, along with proper access management through Azure AD access packages.

## 🎯 Key Capabilities

### **Option 1: Full Subscription Creation + Provisioning**
- ✅ **Creates new Azure subscriptions** via Enterprise Agreement/MCA billing
- ✅ **Provisions infrastructure** (Resource Groups, VNets, Subnets)
- ✅ **Sets up access management** via Azure AD access packages
- ✅ **Implements cost controls** with budgets and monitoring

### **Option 2: Infrastructure Provisioning Only**
- ✅ **Provisions infrastructure** in existing subscriptions
- ✅ **Sets up access management** via Azure AD access packages  
- ✅ **Implements cost controls** with budgets and monitoring

## 🚀 What This Module Actually Creates

### **When `create_new_subscription = true`:**
1. **🆕 New Azure Subscription** with proper billing assignment
2. **📦 Resource Group** (`sandbox_rg_01`)
3. **🌐 Virtual Network** (`sandbox_vnet_01`) with 3 subnets
4. **💰 Budget** (£100 annually with alerts)
5. **🔐 Access Package** for user access management
6. **📊 Governance** (tagging, monitoring, compliance)

### **When `create_new_subscription = false`:**
1. **📦 Resource Group** (`sandbox_rg_01`) in existing subscription
2. **🌐 Virtual Network** (`sandbox_vnet_01`) with 3 subnets  
3. **💰 Budget** (£100 annually with alerts)
4. **🔐 Access Package** for user access management
5. **📊 Governance** (tagging, monitoring, compliance)

## 📋 Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0.0 |

### **Prerequisites for Subscription Creation:**
- **Enterprise Agreement (EA)** or **Microsoft Customer Agreement (MCA)** billing account
- **Billing permissions** to create subscriptions
- **Azure AD permissions** for access package management

## 🔧 Usage Examples

### **Example 1: Create New Subscription + Full Setup**

```hcl
module "subscription_vending" {
  source = "./modules/SubscriptionVend"
  
  # Subscription Creation
  create_new_subscription = true
  subscription_name       = "AUK-Sandbox-Development-001"
  subscription_workload   = "DevTest"
  billing_account_name    = "your-billing-account"
  billing_profile_name    = "your-billing-profile"
  
  # Access Package Management
  create_access_package     = true
  access_package_name       = "Sandbox Development Access"
  access_package_description = "Provides contributor access to sandbox subscription"
  catalog_id                = "your-catalog-id"
  requestor_group_object_id = "group-who-can-request-access"
  approver_group_object_id  = "group-who-approves-access"
  
  # Default tags
  default_tags = {
    Environment = "Sandbox"
    CostCenter  = "IT-Development"
    Owner       = "Platform Team"
  }
}
```

### **Example 2: Use Existing Subscription + Setup Infrastructure**

```hcl
module "subscription_vending" {
  source = "./modules/SubscriptionVend"
  
  # Use existing subscription
  create_new_subscription   = false
  existing_subscription_id  = "f9b4de25-7e5e-4197-a401-cc87b3585f68"
  
  # Access Package Management
  create_access_package     = true
  access_package_name       = "Existing Subscription Access"
  catalog_id                = "your-catalog-id"
  requestor_group_object_id = "group-who-can-request-access"
  
  # Default tags
  default_tags = {
    Environment = "Sandbox"
    Purpose     = "Development"
  }
}
```

### **Example 3: Minimal Setup (No Access Package)**

```hcl
module "subscription_vending" {
  source = "./modules/SubscriptionVend"
  
  # Use existing subscription, no access package
  create_new_subscription = false
  existing_subscription_id = "f9b4de25-7e5e-4197-a401-cc87b3585f68"
  create_access_package   = false
}
```

## 📊 Variables

### **Subscription Creation Variables**

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_new_subscription"></a> [create\_new\_subscription](#input\_create\_new\_subscription) | Whether to create a new subscription | `bool` | `false` | no |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | Name for the new subscription | `string` | `"AUK-Sandbox-Subscription"` | no |
| <a name="input_subscription_workload"></a> [subscription\_workload](#input\_subscription\_workload) | Workload type (DevTest/Production) | `string` | `"DevTest"` | no |
| <a name="input_existing_subscription_id"></a> [existing\_subscription\_id](#input\_existing\_subscription\_id) | Existing subscription ID if not creating new | `string` | `""` | no |
| <a name="input_billing_account_name"></a> [billing\_account\_name](#input\_billing\_account\_name) | Billing account for subscription creation | `string` | `""` | no |

### **Access Package Variables**

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_access_package"></a> [create\_access\_package](#input\_create\_access\_package) | Whether to create access package | `bool` | `true` | no |
| <a name="input_access_package_name"></a> [access\_package\_name](#input\_access\_package\_name) | Name for the access package | `string` | `"Sandbox Subscription Access"` | no |
| <a name="input_catalog_id"></a> [catalog\_id](#input\_catalog\_id) | Azure AD catalog ID | `string` | `""` | no |
| <a name="input_requestor_group_object_id"></a> [requestor\_group\_object\_id](#input\_requestor\_group\_object\_id) | Group that can request access | `string` | `""` | no |
| <a name="input_approver_group_object_id"></a> [approver\_group\_object\_id](#input\_approver\_group\_object\_id) | Group that approves access | `string` | `""` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Target subscription ID (created or existing) |
| <a name="output_new_subscription_created"></a> [new\_subscription\_created](#output\_new\_subscription\_created) | Whether a new subscription was created |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the created resource group |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | ID of the created virtual network |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet names to IDs |
| <a name="output_access_package_id"></a> [access\_package\_id](#output\_access\_package\_id) | ID of the created access package |
| <a name="output_budget_name"></a> [budget\_name](#output\_budget\_name) | Name of the subscription budget |

## 🔐 Access Package Features

The module creates sophisticated access management:

### **Access Controls:**
- **👥 Requestor Groups**: Define who can request access
- **✅ Approval Workflow**: Optional approval process
- **⏰ Time-limited Access**: 30-day access periods by default
- **🔄 Quarterly Reviews**: Automatic access reviews
- **📝 Justification Required**: Business justification for requests

### **Role Assignments:**
- **Contributor Role**: Full resource management access
- **Subscription Scope**: Access to entire subscription
- **Granular Control**: Can be customized per use case

### **Governance:**
- **Automated Reviews**: Quarterly access reviews
- **Self-service**: Users can request access independently
- **Audit Trail**: Complete access history and justifications
- **Compliance**: Built-in controls for regulatory requirements

## 🏗️ Infrastructure Created

### **Resource Group:**
- **Name**: `sandbox_rg_01`
- **Location**: UK South
- **Purpose**: Container for all sandbox resources

### **Virtual Network:**
- **Name**: `sandbox_vnet_01`
- **Address Space**: `10.0.0.0/16`
- **Location**: UK South

### **Subnets:**
- **default**: `10.0.1.0/24` (General purpose)
- **web**: `10.0.2.0/24` (Web tier resources)
- **data**: `10.0.3.0/24` (Data tier resources)

### **Budget:**
- **Amount**: £100 annually
- **Notifications**: 80%, 90%, 100% forecasted
- **Contact**: grant.palmer@allwyn.co.uk

## 🚀 Deployment Process

### **1. Azure DevOps Pipeline**
The module includes CI/CD pipeline:
- **Service Connection**: `auk-azdo-deploy-AUK-SBX-Sandbox-004`
- **State Management**: Automated Terraform state management
- **Branch Protection**: Naming convention validation

### **2. Deployment Steps**
1. **Configure billing** (if creating subscriptions)
2. **Set up Azure AD catalog** (for access packages)
3. **Configure service connections**
4. **Deploy via pipeline**
5. **Verify access package functionality**

### **3. Post-Deployment**
- **Test access requests** through Azure AD portal
- **Verify budget alerts** are working
- **Confirm network connectivity**
- **Validate governance controls**

## 🎯 Use Cases

### **Sandbox Provisioning:**
- Development teams requesting isolated environments
- Testing new Azure services safely
- POC and experimentation environments

### **Training Environments:**
- Learning Azure services with cost controls
- Hands-on workshops and training
- Certification preparation environments

### **Project Isolation:**
- Separate billing and resource management
- Project-specific access controls
- Compliance and governance requirements

## 💡 Benefits

1. **🔒 Security**: Proper access controls and time-limited access
2. **💰 Cost Control**: Built-in budgets and monitoring
3. **⚡ Speed**: Automated provisioning reduces setup time
4. **📊 Governance**: Consistent tagging and compliance
5. **🎯 Self-Service**: Users can request access independently
6. **📋 Audit**: Complete trail of access and resource usage

## ⚠️ Important Notes

### **Subscription Creation Requirements:**
- Requires **Enterprise Agreement** or **Microsoft Customer Agreement**
- Service principal needs **billing permissions**
- May take several minutes to complete

### **Access Package Requirements:**
- Azure AD **P2 license** required for access packages
- **Identity Governance** must be enabled
- Catalog must exist before deployment

### **Cost Considerations:**
- **Azure AD P2**: Required for access packages (~£8/user/month)
- **Subscription Creation**: Depends on billing agreement
- **Resource Costs**: Standard Azure pricing applies

## 🔧 Troubleshooting

### **Common Issues:**

1. **Subscription Creation Fails**
   - Verify billing account permissions
   - Check Enterprise Agreement status
   - Confirm subscription limits

2. **Access Package Creation Fails**
   - Verify Azure AD P2 licenses
   - Check catalog permissions
   - Confirm Identity Governance is enabled

3. **Resource Deployment Fails**
   - Check subscription quotas
   - Verify service principal permissions
   - Confirm resource naming conventions

## 📞 Support

For issues or questions:
- **Contact**: grant.palmer@allwyn.co.uk
- **Documentation**: https://allwyn.sharepoint.com/sites/PlatformOperations-Cloud
- **Azure Support**: For platform-level issues
