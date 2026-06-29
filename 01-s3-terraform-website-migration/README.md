# AWS S3 Static Website Migration with Terraform

## Project Overview

This project demonstrates how I used Terraform and AWS CLI to migrate an Amazon S3 static website from the Europe Stockholm region to the Middle East UAE region.

## Source Environment

- Source bucket: `thumbiportfolio1`
- Source region: `eu-north-1`
- Service: Amazon S3 Static Website Hosting

## Target Environment

- Target bucket: `thumbiportfolio1-uae-20e75668`
- Target region: `me-central-1`
- Service: Amazon S3 Static Website Hosting

## Tools Used

- Terraform
- AWS CLI
- Amazon S3
- PowerShell
- GitHub

## What Terraform Created

Terraform was used to create:

- A new S3 bucket in the UAE region
- Static website hosting configuration
- Public access settings
- Bucket policy for public website access
- Output values for the website URL

## What AWS CLI Did

AWS CLI was used to copy the website files from the old Stockholm bucket to the new UAE bucket.

```powershell
aws s3 sync s3://thumbiportfolio1 s3://thumbiportfolio1-uae-20e75668 --source-region eu-north-1 --region me-central-1