# EC2 Snapshot and Server Recovery with Terraform

## Project Overview

This project demonstrates how I used Terraform to create an EC2 server, create an AMI backup of the server, and launch a recovered EC2 server from that backup.

The purpose of the project was to understand how Infrastructure as Code can support basic server backup and recovery in AWS.

## Architecture

```text
Original EC2 Server
        ↓
AMI Backup
        ↓
EBS Snapshot created by AWS
        ↓
Recovered EC2 Server
```

## Tools Used

* AWS EC2
* Amazon Machine Image (AMI)
* EBS Snapshot
* Terraform
* AWS CLI
* PowerShell
* GitHub

## Region Used

The project was initially attempted in the AWS Middle East UAE region:

* `me-central-1`

However, the UAE region was showing service reliability warnings at the time. Because of that, the project was moved to:

* `eu-north-1` — Europe Stockholm

## What Terraform Created

Terraform was used to create:

* A custom VPC
* A public subnet
* An internet gateway
* A route table
* A route table association
* A security group allowing HTTP traffic
* An original EC2 web server
* An AMI backup of the original EC2 server
* A recovered EC2 server launched from the AMI backup

## Original Server

The original EC2 server was created using Terraform.

Original server URL:

```text
http://51.21.249.50
```

The server successfully loaded a web page in the browser.

## AMI Backup

After confirming the original server was working, Terraform was used to create an AMI backup.

AMI created:

```text
server-backup-project-02
```

The AMI backup was visible in the AWS Console under:

```text
EC2 → AMIs → Owned by me
```

Behind the AMI, AWS also created an EBS snapshot of the EC2 server disk.

## Recovered Server

Terraform then launched a recovered EC2 server from the AMI backup.

Recovered server URL:

```text
http://51.20.77.150
```

The recovered server successfully loaded the same website page, proving that the server recovery worked.

## Challenges Faced

### 1. AWS UAE Region Issue

The project was first attempted in the `me-central-1` region. The EC2 instance creation stayed stuck for a long time.

After checking the AWS Console, the UAE region showed a warning that the region was not currently reliable for customer workloads.

Solution:

* Stopped the Terraform apply operation.
* Checked Terraform state.
* Cleaned up partial resources.
* Changed the project region to `eu-north-1`.

### 2. Availability Zone Mismatch

After changing the region to Stockholm, the subnet still referenced a UAE availability zone:

```text
me-central-1a
```

This caused an error because Stockholm uses:

```text
eu-north-1a
eu-north-1b
eu-north-1c
```

Solution:

* Updated the subnet availability zone to `eu-north-1a`.

### 3. AMI Backup Terraform Error

The AMI backup block initially used an unsupported argument:

```text
no_reboot = true
```

Terraform rejected it.

Solution:

* Removed the unsupported argument.
* Re-ran `terraform plan` and `terraform apply`.

### 4. Recovery Proof File Not Found

The recovered server page loaded successfully, but the `/recovery-proof.txt` test URL returned `Not Found`.

This showed that the specific proof file was not present in the web directory at the time the AMI was created.

However, the recovered website page loaded successfully, which confirmed that the recovered server was launched correctly from the AMI.

## Terraform Commands Used

```powershell
terraform init
terraform plan
terraform apply
terraform state list
```

## Key Lessons Learned

* Terraform can automate EC2 infrastructure creation.
* AMIs can be used to create server backups.
* AWS creates EBS snapshots behind AMI backups.
* A recovered EC2 server can be launched from an AMI.
* AWS regions and availability zones must match.
* Terraform state shows which resources Terraform is managing.
* Regional AWS service health can affect infrastructure deployment.
* Recovery should always be tested after backup creation.

## Final Result

The project successfully demonstrated EC2 server backup and recovery using Terraform.

The original server was created, an AMI backup was generated, and a recovered EC2 server was launched from the backup image.
