# ACE Cloud Ops Infrastructure

### Summary

This repository builds out a __completed__ representation of the infrastructure created for the Aviatrix ACE Cloud Ops course.

It builds the following:

- Aviatrix Transit FireNet in AWS (with Check Point Firewall) with 2 spokes
- Aviatrix Transit in Azure with 2 spokes
- Aviatrix Transit in GCP with 1 spoke
- Ubuntu VMs with password authentication (1 per spoke)
- Multi-Cloud Segmentation (2 security domains, no connection policy)
- Site2Cloud connection between Spoke in GCP and On-Prem Cisco CSR (emulated in AWS)
- Site2Cloud connection between Transit in AWS and a separate On-Prem Cisco CSR (emulated in AWS)
- Egress FQDN gateway in Azure Spoke 2

<img src="topology.png">

Component | Version
--- | ---
Aviatrix Controller | UserConnect-6.4.2618 (6.4)
Aviatrix Terraform Provider | > 2.19.1
Terraform | 0.15
Azure Terraform Provider | > 2.0.0
GCP Terraform Provider | 3.49
AWS Terraform Provider | > 3.0

### Dependencies

- Software version requirements met
- Aviatrix Controller with Access Accounts defined for AWS, Azure, and GCP
- Sufficient limits in place for CSPs and regions in scope **_(EIPs, Compute quotas, etc.)_**
- Active subscriptions for the NGFW firewall images in scope
- Terraform 0.13 in the user environment
- Terraform provider requirements are met (AWS, GCP, Azure) in the runtime environment
- Account credentials for each CSP defined in environment. The following environment variables will be needed:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - TF_VAR_azure_tenant_id
  - TF_VAR_azure_subscription_id
  - TF_VAR_azure_client_id
  - TF_VAR_azure_client_secret
  - GOOGLE_CREDENTIALS

### Workflow

- Modify ```terraform.tfvars``` as needed
- ```terraform init```
- ```terraform plan```
- ```terraform apply```