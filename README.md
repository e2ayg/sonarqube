## SonarQube Community on AWS ECS using Terraform


This project sets up a complete AWS ECS infrastructure for running SonarQube Community Edition. 

### Who this project is for
This project is intended for DevOps teams who want to automate the deployment of SonarQube Community on AWS.
SSolution helps you automate the deployment of resources required to run SonarQube on AWS ECS, including CloudWatch monitoring, RDS database, EFS storage, and an ALB.
Unlike manually configuring infrastructure, solution leverages Terraform to ensure infrastructure as code, making it reproducible and maintainable.

Here's what it includes:

#### Container Management

- **ECR Repository:** Stores SonarQube Docker images
- **ECS Cluster and Service:** Runs SonarQube containers

#### Database

- **RDS Instance:** PostgreSQL database for SonarQube data


### Auto-Scaling

- **Auto Scaling Target:** Configures the ECS service to scale automatically.
- **Scaling Policies:** Defines the rules to scale up or down based on CPU utilization.
- **CloudWatch Alarms:** Triggers scaling actions based on CPU utilization thresholds.

#### Storage

- **EFS File System:** Persistent storage for SonarQube data

#### Security and Access Control

- **IAM Policies and Roles:** Manages permissions for ECS tasks
- **Security Groups:** Controls network access for all components

#### Monitoring and Logging

- **CloudWatch Dashboard:** Monitors ECS CPU and Memory usage
- **CloudWatch Log Group:** Collects ECS logs
- **CloudWatch Alarms:** Alerts for high CPU and Memory use

#### Networking

- **Load Balancer:** Distributes incoming traffic
- **VPC and Subnets:** Provides isolated network environment

#### Notifications

- **SNS Topic and Subscription:** Sends email alerts about SonarQube Infrastructure 

This setup provides a scalable, secure, and monitored environment for running SonarQubeCommunity in AWS.

### Project dependencies
Before using solution, ensure you have:

- OpenSSL
- Terraform v1.8.0 or higher
- AWS CLI configured with appropriate credentials


### Install SonarQube on AWS

Clone the repository:

```Bash
git clone git@github.com:e2ayg/sonarqube.git
cd sonarqube
```

### Dockerfile

This project uses a custom Dockerfile to build the SonarQube container image. The Dockerfile is based on the official SonarQube community edition image and includes the following customizations:
```Docker
# Use the official SonarQube community edition as the base image
FROM sonarqube:9.9.6-community

# Create necessary directories with correct permissions
USER root
RUN mkdir -p /opt/sonarqube/data /opt/sonarqube/logs /opt/sonarqube/extensions && \
    chown -R sonarqube:sonarqube /opt/sonarqube/data /opt/sonarqube/logs /opt/sonarqube/extensions

# Expose the web port
EXPOSE 9000

# Define volumes to be mounted at container startup
VOLUME ["/opt/sonarqube/data", "/opt/sonarqube/logs", "/opt/sonarqube/extensions"]

# Switch to the non-root user
USER sonarqube

```
### Generate a Self-Signed Certificate

Run the [self-signed-cert.sh](/scripts/self-signed-cert.sh) script to prepare and upload it to the AWS ACM.
Replace script variables with the necessary values.

```Bash
./scripts/self-signed-cert.sh
```

### Prepare the Terraform backend:

Run the [prepare=backend.sh](/scripts/prepare-backend.sh) script to prepare the backend configuration for Terraform:

```Bash
./scripts/prepare-backend.sh
```

### Replace Backend S3 Bucket and DynamoDB Table Values:

After running the script, replace the backend S3 bucket and DynamoDB table values in your terraform configuration with the outputs from the script.

In your terraform configuration file [main.tf](/terraform/main.tf), find the backend configuration block and replace the placeholders with the actual values from the script outputs:

```Bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.33.0"
    }
  }
  backend "s3" {
    bucket         = "<S3 bucket name>"
    key            = "./terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "<DynamoDB table name>"
    encrypt        = true
  }
}
```


Create a `terraform.tfvars` file in the root of your Terraform configuration directory and add the following variables:

```
db_username     = "<database username>"
db_password     = "<database password>"
allowed_ip      = "<Allowed IP address - ex. 10.0.0.5/32>"
aws_region      = "us-west-2"
cerfiticate_arn = "Self-Signed AWS ACM certificate ARN"
email           = "email for alerts"
```


Initialize the Terraform configuration:

```Bash
terraform init
```

Check the Terraform configuration:

```Bash
terraform plan
```

Apply the Terraform configuration:

```Bash
terraform apply
```

This command will create the necessary resources on AWS as described in the Terraform plan output.

By following these steps, you will have a fully functional SonarQube setup on AWS ECS managed by Terraform, allowing for easy scaling and maintenance.