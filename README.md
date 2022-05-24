# ACE Cloud Ops Infrastructure

### Summary

This repository builds out a __completed__ representation of the infrastructure created for the Aviatrix ACE Cloud Operations course.

It builds the following:

- Aviatrix Transit FireNet in AWS (with Fortinet FortiGate Firewall) with 2 spokes
- Aviatrix Transit in Azure with 2 spokes
- Aviatrix Transit in GCP with 1 spoke
- Ubuntu VMs with password authentication (1 per spoke)
- Multi-Cloud Segmentation (2 security domains, no connection policy)
- Site2Cloud connection between Spoke in GCP and On-Prem Cisco CSR (emulated in AWS)
- Site2Cloud connection between Transit in AWS and a separate On-Prem Cisco CSR (emulated in AWS)
- Egress FQDN gateway in Azure Spoke 1 and 2

<img src="topology.png">

Component | Version
--- | ---
Aviatrix Controller | UserConnect-6.6.5612 (6.6)
Aviatrix Terraform Provider | > 2.21.2
Terraform | > 1.0
Azure Terraform Provider | > 3.0.0
GCP Terraform Provider | 3.49
AWS Terraform Provider | > 3.0

### Dependencies

- Software version requirements met
- Aviatrix Controller with Access Accounts defined for AWS, and GCP. Default account names are 'aws-account' and 'gcp-account' respectively. 
- Azure account will be onboarded matching the TF credentials provided as environment variables.
- Sufficient limits in place for CSPs and regions in scope **_(EIPs, Compute quotas, etc.)_**
- Active subscriptions for the NGFW firewall images in scope
- Terraform 1.0 in the user environment
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
