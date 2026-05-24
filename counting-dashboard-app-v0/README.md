# 🚀 Counting Dashboard App (Terraform on AWS)

<img width="1551" height="664" alt="image" src="https://github.com/user-attachments/assets/5bfc3834-6ba5-4b64-849e-316a6d0d615e" />

> Infrastructure as Code project deploying a secure, production-style architecture using Terraform on AWS.

---

## 📖 Overview

This project provisions a **Counting Dashboard Application** using **Terraform**, following real-world DevOps practices.

It demonstrates:

* Infrastructure as Code (IaC)
* Secure AWS networking (VPC, public/private subnets)
* Controlled service-to-service communication
* Automated EC2 provisioning with user data scripts

---

## 🏗️ Architecture

![Architecture](./architecture.png)

### 🔍 Key Design

* **Dashboard Server (Public Subnet)**

  * Accessible via browser (`:9009`)
  * Acts as entry point

* **Counting Service (Private Subnet)**

  * No public access
  * Only reachable from Dashboard

---

## 🧠 Architecture Breakdown

| Component            | Description                            |
| -------------------- | -------------------------------------- |
| **VPC**              | `10.0.0.0/16`                          |
| **Public Subnet**    | `10.0.10.0/24` (Dashboard)             |
| **Private Subnet**   | `10.0.20.0/24` (Counting Service)      |
| **Internet Gateway** | Enables public access                  |
| **NAT Gateway**      | Allows private subnet outbound traffic |
| **Security Groups**  | Restrict access between services       |

---

## 🔐 Security

* 🔒 Private subnet isolates backend service
* 🔑 SSH access restricted via security groups
* 🚫 Sensitive files excluded using `.gitignore`
* 🔐 No secrets committed to repository

---

## ⚙️ Tech Stack

* **Terraform**
* **AWS (EC2, VPC, Networking)**
* **Shell Scripting (User Data)**

---

## 📁 Project Structure

```bash id="lq88y3"
.
├── main.tf
├── instance.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── keypair.tf
├── data.tf
├── counting-userdata.sh
├── dashboard-userdata.sh.tpl
├── .gitignore
└── README.md
```

##🚀 Getting Started

1️⃣ Initialize Terraform

terraform init

2️⃣ Validate

terraform validate

3️⃣ Plan

terraform plan

4️⃣ Apply

terraform apply 


## 📌 Key Learnings

✔️ Designing secure cloud architecture
✔️ Managing infrastructure with Terraform
✔️ Using Git & GitHub in real workflow
✔️ Implementing subnet isolation and access control


## ⭐ Final Note

This project simulates a **production-like DevOps setup** and showcases practical skills in cloud infrastructure and automation.
