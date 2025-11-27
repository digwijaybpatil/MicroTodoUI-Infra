# MicroTodoUI-Infra  
Infrastructure as Code (IaC) using **Terraform**, deploying a complete environment for the MicroTodo application on Azure.

This repository provisions:
- Azure Resource Group  
- Azure Virtual Network + Subnets  
- Azure Kubernetes Service (AKS)  
- Azure Container Registry (ACR)  
- Azure SQL Server + Database  
- GitHub Actions CI/CD pipelines  
- Secure Key Vault secret retrieval  

---

## 📦 Architecture Overview

```
Azure Resource Group
│
├─ Virtual Network (VNet)
│   ├─ ApplicationGatewaySubnet (reserved for AGIC/AppGW)
│   ├─ akssubnet (AKS nodes)
│   └─ data (future SQL private endpoint)
│
├─ Azure Container Registry (ACR)
│
├─ Azure Kubernetes Service (AKS)
│   └─ Pulls images from ACR via AcrPull role
│
├─ Azure SQL Server + Database
│   └─ Password fetched securely from Key Vault
│
└─ GitHub Actions Workflows
    ├─ dev-deploy.yml
    ├─ dev-destroy.yml
    ├─ prod-deploy.yml
    └─ pr.yml
```

---

## 🧱 Module Structure

```
modules/
  ├─ azurerm_virtual_network
  ├─ azurerm_subnet
  ├─ azurerm_resource_group
  ├─ azurerm_azure_container_registry
  ├─ azurerm_azure_kubernetes_cluster
  ├─ azurerm_mssql_server
  └─ azurerm_mssql_database

environments/
  ├─ dev
  └─ prod

.github/workflows/
  ├─ dev-deploy.yml
  ├─ dev-destroy.yml
  ├─ prod-deploy.yml
  └─ pr.yml
```

Each module contains:
- `main.tf`  
- `variables.tf`  
- `outputs.tf`  

---

## ⚙️ What Terraform Creates (Root main.tf Summary)

### 1. Resource Group  
### 2. Virtual Network (VNet)  
### 3. Subnets  
- ApplicationGatewaySubnet  
- akssubnet  
- data  

### 4. ACR (Azure Container Registry)  
### 5. AKS (Kubernetes Cluster)  
- kubenet (default)  
- SystemAssigned identity  
- Standard_B2s node pool  

### 6. Role Assignment  
- AKS identity → AcrPull on ACR  

### 7. SQL Server & SQL Database  
- Reads password from Key Vault  

---

## 🔐 Key Vault Integration

The SQL admin password **never appears in code**.  
Terraform fetches it:

```hcl
data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.existing_kv.id
}
```

This ensures secure secret handling.

---

## 🛠 Terraform Usage

### Initialize
```sh
terraform init
```

### Validate
```sh
terraform validate
```

### Plan
```sh
terraform plan -var-file="terraform.tfvars"
```

### Apply
```sh
terraform apply -var-file="terraform.tfvars"
```

### Destroy
```sh
terraform destroy -var-file="terraform.tfvars"
```

---

## 📁 terraform.tfvars Example

```hcl
application_name   = "microtodoapp"
environment        = "dev"

primary_location   = "centralindia"
vnet_address_space = "10.0.0.0/16"
node_vm_size       = "Standard_B2s"
```

---

## 🤖 GitHub Actions Workflows

### `pr.yml`
- Runs Terraform format, init, validate, plan  
- Ensures Pull Requests are safe

### `dev-deploy.yml`
- Deploys infra for Dev environment

### `dev-destroy.yml`
- Destroys Dev infrastructure on demand

### `prod-deploy.yml`
- Manually deploys Prod environment

All workflows use:
- Azure OIDC authentication (no secrets)  
- Terraform backend state stored in Azure Storage  

---

## 🌐 Networking Overview

| Subnet Name               | Purpose                               |
|---------------------------|----------------------------------------|
| ApplicationGatewaySubnet | Reserved for AGIC/App Gateway          |
| akssubnet                | AKS node pool                          |
| data                     | Reserved for SQL private endpoints     |

---

## 🧩 AKS ↔ ACR Integration

AKS uses a system-assigned identity.  
Terraform assigns AcrPull role:

```hcl
role_definition_name = "AcrPull"
principal_id         = module.aks.aks_identity_principal_id
```

This allows AKS to pull images without passwords.

---

## ✔ Ready for Microservices Deployment

Once the infrastructure is deployed, you can deploy microservices to AKS using:
- kubectl  
- Helm  
- ArgoCD  
- GitHub Actions  

---

## 📌 Future Enhancements

- NGINX Ingress Controller  
- App Gateway + AGIC  
- SQL Private Endpoint  
- ACR Private Endpoint  
- Multi-node AKS pools  
- ArgoCD GitOps automation  

---

