#!/bin/bash

# Function to generate a date string
generate_date_string() {
  date +"%Y%m%d%H%M%S"
}

# Define the name of the S3 bucket and DynamoDB table with date string suffix
DATE_STRING=$(generate_date_string)
TFSTATE_BUCKET_NAME="sonarqube-tfstate-$DATE_STRING"
TFSTATE_LOCK_TABLE="sonarqube-tfstate-lock-table-$DATE_STRING"
REGION="eu-west-2"

# Create the S3 bucket
aws s3api create-bucket \
    --bucket "$TFSTATE_BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

# Wait for the bucket to be created
sleep 10

# Enable bucket versioning
aws s3api put-bucket-versioning \
    --bucket "$TFSTATE_BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
    --bucket "$TFSTATE_BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Create the DynamoDB table
aws dynamodb create-table \
    --table-name "$TFSTATE_LOCK_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Wait for the table to be created
sleep 10

# Verify the table status
aws dynamodb describe-table \
    --table-name "$TFSTATE_LOCK_TABLE" \
    --query 'Table.TableStatus' \
    --output text

# Retry enabling point-in-time recovery until successful
RETRY_COUNT=0
MAX_RETRIES=5
RETRY_DELAY=10

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    aws dynamodb update-continuous-backups \
        --table-name "$TFSTATE_LOCK_TABLE" \
        --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true

    if [ $? -eq 0 ]; then
        echo "Point-in-time recovery enabled successfully."
        break
    else
        echo "Failed to enable point-in-time recovery. Retrying in $RETRY_DELAY seconds..."
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep $RETRY_DELAY
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Failed to enable point-in-time recovery after $MAX_RETRIES attempts."
    exit 1
fi

echo "S3 Bucket Created: $TFSTATE_BUCKET_NAME"
echo "DynamoDB Table Created: $TFSTATE_LOCK_TABLE"

echo "Terraform state successfully set up."
exit 0
