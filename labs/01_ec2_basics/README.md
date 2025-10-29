Lab 01 – EC2 Bootstrap Automation (Post-Lab Debrief)
🧭 Overview

In this lab, I used the AWS CLI to fully automate the deployment of a web server (Nginx) on an EC2 instance.
The goal was to understand how to provision compute resources programmatically, apply security controls, and use user data for automatic configuration at first boot.

🧱 Architecture Summary
+-------------------------------------------------------+
| AWS Account                                           |
|  Region: us-east-1                                    |
|                                                       |
|  +------------------------+                           |
|  |  Default VPC           |                           |
|  |   (Public Subnet)      |                           |
|  |                        |                           |
|  |   +-----------------+  |                           |
|  |   | EC2 Instance    |  |                           |
|  |   |  t2.micro       |  |                           |
|  |   |  Amazon Linux   |  |                           |
|  |   |  Nginx Server   |  |                           |
|  |   +--------┬--------+  |                           |
|  |            │  (attached via ENI)                   |
|  |   +--------▼--------+                              |
|  |   | Security Group  |                              |
|  |   |  Inbound:       |                              |
|  |   |   • 22/tcp → My IP (SSH)                      |
|  |   |   • 80/tcp → 0.0.0.0/0 (HTTP)                 |
|  |   |  Outbound: All                                |
|  |   +------------------+                             |
|  +------------------------+                           |
+-------------------------------------------------------+

⚙️ Core Steps Performed
1. Configure AWS CLI

Connected CLI to IAM user credentials to enable programmatic access (aws configure → aws sts get-caller-identity).

2. Created Key Pair (Authentication)
aws ec2 create-key-pair ...


Generated a .pem private key for SSH access and stored it securely outside version control.

Purpose: enables secure, passwordless SSH login.

Type: asymmetric encryption (public/private key pair).

3. Created Security Group (Network Firewall)
aws ec2 create-security-group ...
aws ec2 authorize-security-group-ingress ...


Opened port 22 (SSH) to my IP only

Opened port 80 (HTTP) to the world

Purpose: defines who can talk to the instance and on which ports.
Type: stateful firewall enforced at the AWS hypervisor layer.

4. Retrieved a Current Amazon Linux 2023 AMI
aws ssm get-parameter ...


Used SSM Parameter Store for a stable reference to the latest AMI instead of hardcoding an ID.

Purpose: ensures the automation always deploys the newest base image.

5. Launched the EC2 Instance
aws ec2 run-instances ...


Included:

Instance Type: t2.micro (free-tier)

Key Pair: $Project-key

Security Group: $Project-sg

Subnet: default public subnet

User Data: file://user-data.sh

Purpose: provisioned the actual compute resource and bootstrapped it automatically.

6. User Data Script (Bootstrap Automation)

The script (user-data.sh) automatically:

Updated the OS packages (dnf -y update)

Installed Nginx

Deployed a simple “It works!” web page

Started and enabled the Nginx service

Purpose: demonstrate Infrastructure as Code — the instance configures itself without manual SSH steps.

7. Validation

Accessed the public IP over HTTP → received 200 OK

Viewed “It works! 🚀” page in browser

Confirmed system health (aws ec2 describe-instance-status)

8. Cleanup
aws ec2 terminate-instances ...
aws ec2 delete-security-group ...


Purpose: prevent ongoing costs and practice safe cloud hygiene.

🧠 What I Learned
Concept	Key Takeaway
IAM & CLI	CLI credentials give controlled, auditable access without ever using root.
Key Pairs	Secure access mechanism—private key is never stored by AWS.
Security Groups	Virtual firewalls that enforce inbound/outbound rules at the network edge.
VPC/Subnets	The default VPC provides public subnets and routing by default.
User Data / Cloud-Init	Bootstrapping allows servers to self-configure at first boot.
Idempotency	AWS CLI operations are stateless — each run defines the full desired state.
Automation Mindset	DevOps is about repeatable processes — if you can do it once, script it.
🔍 Behind the Scenes (AWS Internal Flow)

CLI Command → AWS API Gateway (HTTPS)
Every aws ec2 ... call is an authenticated API request signed with your IAM credentials (SigV4).

Control Plane Update
EC2 stores metadata about your instance, SG, and key pair in the regional control plane.

Data Plane Execution
When the instance launches, AWS provisions hardware, attaches networking (ENI), and injects your public key and user data into the VM’s cloud-init process.

Network Enforcement
The SG rules are evaluated on each packet at the host’s hypervisor, ensuring network isolation per tenant.

🧩 Key Commands Reference
Purpose	Command
Verify identity	aws sts get-caller-identity
Create key pair	aws ec2 create-key-pair ...
Create SG	aws ec2 create-security-group ...
Add ingress rules	aws ec2 authorize-security-group-ingress ...
Find AMI	aws ssm get-parameter ...
Launch instance	aws ec2 run-instances ...
Wait for OK	aws ec2 wait instance-status-ok ...
Terminate	aws ec2 terminate-instances ...
🧰 Artifacts
File	Description
user-data.sh	Nginx bootstrap script
run.ps1	PowerShell automation script to deploy instance
cleanup.ps1	PowerShell script to destroy instance + SG
README.md	Lab documentation (this file)