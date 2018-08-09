# AWS Terraform provisioning example

Takes 2 simple python Flask apps, one internal web service and one public-facing one,
and deploys them on AWS in a VPC.

Packer (https://www.packer.io/downloads.html) and Terraform (https://www.terraform.io/downloads.html)
required.

AMIs are created with Packer and Ansible.

Terraform used to provision AWS resources.

Things this creates:

- VPC
- Web service instances
- Elasticache
- ALB
- Autoscaling Group

Things missing:

- Real SQL database (RDS)
- Easier way to deploy web service code updates
- Autoscaling for internal service
- Externally-facing friendly hostname
