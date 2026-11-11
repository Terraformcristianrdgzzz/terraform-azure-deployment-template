# Azure Terraform Deployment Template

A starter repository for deploying a small web server to Azure with Terraform. It composes two reusable modules:

- [`terraform-module-azurerm-network`](https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-network) creates a virtual network and subnet.
- [`terraform-module-azurerm-linux-webserver`](https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-linux-webserver) creates a Linux VM, public IP, network security group, and Apache.

The modules are pinned to `v0.1.0`. The VM size is `Standard_D2s_v7`. Check that the size is available and review its cost in your Azure region before deployment.

## What this template does

- Uses GitHub Actions and Microsoft Entra workload identity federation (OIDC) to authenticate to Azure without a client secret.
- Stores Terraform state in an Azure Blob backend using OIDC and Azure AD authentication.
- Provides a manually triggered workflow that formats, initializes, and validates Terraform. An optional input creates a plan; the workflow never applies changes.
- Keeps SSH network ingress closed by default. A VM administrator public key is still required to configure Linux login when creating a VM plan.

This is a template for a single deployment, not a `stage`/`prod` layout. A repository created from this template must have its own Azure backend and GitHub OIDC configuration.

## Repository contents

```text
.
├── .github/
│   └── workflows/
│       └── terraform-plan.yml
├── backend.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
├── variables.tf
└── versions.tf
```

## Setup

### 1. Create your repository from this template

After this repository is published and marked as a GitHub template, select **Use this template** to create a new repository. Then clone your new repository.

### 2. Prepare Azure

Create or select:

- A resource group where the network and VM resources will be deployed.
- A separate resource group, storage account, and private blob container for Terraform state.
- An Azure application/service principal configured with a federated credential that trusts this repository's GitHub `stage` environment.

Ensure `Microsoft.Network` and `Microsoft.Compute` are registered in the subscription. The Terraform provider is configured not to attempt subscription-wide provider registration.

Grant the federated identity only the required permissions:

- `Storage Blob Data Contributor` on the state container.
- Permissions to read and create the resources in the deployment resource group. Review the required actions and scope for your Azure setup before applying anything.

The workflow only runs a plan; it does not apply or destroy resources.

### 3. Configure the GitHub `stage` environment

In the new repository, create **Settings → Environments → New environment** named `stage`. Add these **environment variables**. They are configuration values, not client secrets:

| Variable | Example or purpose |
| --- | --- |
| `AZURE_CLIENT_ID` | Client ID of the Entra application used for OIDC. |
| `AZURE_TENANT_ID` | Entra tenant ID. |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID. |
| `TF_STATE_RESOURCE_GROUP` | Resource group containing the state storage account. |
| `TF_STATE_STORAGE_ACCOUNT` | Globally unique Azure storage account name. |
| `TF_STATE_CONTAINER` | Private blob container for Terraform state. |
| `TF_STATE_KEY` | Unique blob name, for example `webserver.tfstate`. |
| `AZURE_RESOURCE_GROUP` | Existing resource group for the network and VM. |
| `AZURE_LOCATION` | Azure region, for example `East US`. |
| `AZURE_VNET_NAME` | Virtual network name. |
| `AZURE_VNET_ADDRESS_SPACE` | Terraform list syntax, for example `["10.10.0.0/16"]`. |
| `AZURE_SUBNET_NAME` | Subnet name. |
| `AZURE_SUBNET_PREFIXES` | Terraform list syntax, for example `["10.10.1.0/24"]`. |
| `AZURE_VM_NAME` | VM name. |
| `AZURE_ADMIN_USERNAME` | Linux administrator username. |
| `ADMIN_SSH_PUBLIC_KEY` | Required only when creating a VM plan; the public key line, never the private key. |

You can generate an SSH key pair on your own computer with `ssh-keygen -t ed25519`. Keep the private key on your computer. The public key is not secret and can be stored as the `ADMIN_SSH_PUBLIC_KEY` environment variable. The public key does not open SSH in the network security group; inbound SSH remains disabled unless you explicitly configure a trusted source CIDR in `main.tf`.

The OIDC federated credential must trust the subject for the new repository's `stage` environment. Do not copy another repository's federated subject without updating it for this repository.

### 4. Review the Terraform inputs

Copy `terraform.tfvars.example` to `terraform.tfvars` for local runs, then change the sample resource names and CIDR ranges. The file is ignored by Git so local values are not committed.

The GitHub workflow reads deployment inputs from the `AZURE_*` environment variables above. Keep those values consistent with your local `terraform.tfvars`.

### 5. Run the workflow

Open **Actions → Terraform Plan → Run workflow**:

- Leave **Create a VM plan** unchecked to run formatting, initialization, and validation, including a check of remote state access.
- Check it to run `terraform plan`. This requires `ADMIN_SSH_PUBLIC_KEY`.

Review the plan and expected Azure costs before any future apply. Applying is intentionally not implemented in this template.

## Local validation

From the repository root:

```shell
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

For an actual plan, initialize the configured Azure backend and authenticate with an identity that has access to both the state container and deployment resources. Do not commit state files or saved plans.

## Cost and security

- A running VM, managed disk, and public IP may incur charges.
- HTTP is open to the Internet for this demonstration. Review the NSG before using it beyond a learning environment.
- SSH is closed by default; never allow it from the entire Internet.
- Terraform state and plan files may contain sensitive data. Keep the backend private and do not commit local state, plans, credentials, or private SSH keys.
- This template does not create resource groups, storage accounts, role assignments, or federated credentials.
