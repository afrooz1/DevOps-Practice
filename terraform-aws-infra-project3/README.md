# 🚀 Project 3 – Deploy an EC2 Web Server with Terraform on AWS

This project demonstrates **Infrastructure as Code (IaC)** using **Terraform** to automate the provisioning of an **AWS EC2 instance** running **Nginx** on Amazon Linux.  

The setup includes creating a custom **VPC**, **subnet**, **Internet Gateway**, **route table**, and **security group**, followed by deploying an EC2 instance that automatically installs and starts Nginx via user data.

---

## 🏗️ Project Architecture
AWS Cloud
│
├── VPC (Custom)
│ ├── Subnet (Public)
│ ├── Internet Gateway
│ ├── Route Table (0.0.0.0/0 → IGW)
│ └── Security Group (Inbound: 22, 80)
│
└── EC2 Instance (Amazon Linux 2)
└── Nginx Web Server

---

## ⚙️ Technologies Used

- **Terraform** (IaC tool)
- **AWS EC2**, **VPC**, **Subnet**, **Internet Gateway**, **Route Table**, **Security Group**
- **Nginx** (web server)
- **Windows OS** (Terraform + AWS CLI setup)

---

## 📁 Project Structure
terraform-aws-infra/
│
├── main.tf → VPC, Subnet, IGW, Route Table, Security Group
├── ec2.tf → EC2 instance + Nginx installation (via user_data)
├── variables.tf → Input variables (region, instance type, etc.)
├── SecurityGroup.tf
├── outputs.tf → Outputs public IP & URL
├── provider.tf → AWS provider & region configuration
├── .gitignore → Keeps credentials/state files private
└── README.md → Documentation


---

## 🔧 Prerequisites

- AWS Account
- Terraform installed
- AWS CLI configured (`aws configure`)
- SSH key pair (e.g., `terraform-key`)

---

## 🚀 Deployment Steps

### Step 1 — Initialize Terraform
```bash
terraform init

### Step 2 — Validate configuration
terraform validate

### Step 3 — Preview infrastructure
terraform plan

### Step 4 — Deploy infrastructure
terraform apply -auto-approve

### Step 5 — Access the web server

Copy the public IP from Terraform output and open in browser:
http://<public-ip>

You should see the Nginx default welcome page.

### 📤 Outputs

Public IP: Accessible web server

Region: AWS region used

Example output:

region = "ap-southeast-1"
instance_public_ip = "13.250.xx.xx"
instance_url = "http://13.250.xx.xx"

### 🧹 Cleanup

To destroy all resources and avoid billing:

terraform destroy -auto-approve

###🧠 Key Learnings

Used Terraform to create complete infrastructure automatically.

Learned about AWS VPC networking, subnet, IGW, and EC2.

Automated software installation using user_data.

Managed infrastructure lifecycle (init → plan → apply → destroy).

---
👨‍💻 Author

Afrooz Habib
DevSecOps & Cloud Enthusiast 🌐
GitHub: @afrooz1
