$ErrorActionPreference = "Stop"

# 1. Get AWS Account ID
try {
    $accountId = (aws sts get-caller-identity --query Account --output text).Trim()
    Write-Host "AWS Account ID: $accountId"
} catch {
    Write-Error "Failed to get AWS Account ID. Ensure you are logged in."
    exit 1
}

$region = "us-east-1" 
$bucketName = "twin-terraform-state-$accountId"
$tableName = "twin-terraform-locks"

# 2. Create S3 Backend Bucket
Write-Host "Checking S3 bucket: $bucketName..."
if (!(aws s3 ls "s3://$bucketName" 2>$null)) {
    Write-Host "Creating bucket $bucketName..."
    if ($region -eq "us-east-1") {
        aws s3 mb "s3://$bucketName"
    } else {
        aws s3 mb "s3://$bucketName" --region $region
    }
    
    Write-Host "Enabling versioning..."
    aws s3api put-bucket-versioning --bucket $bucketName --versioning-configuration Status=Enabled
} else {
    Write-Host "Bucket $bucketName already exists."
}

# 3. Create DynamoDB Lock Table
Write-Host "Checking DynamoDB table: $tableName..."
$tableExists = aws dynamodb list-tables --query "TableNames" --output text
if ($tableExists -notmatch $tableName) {
    Write-Host "Creating DynamoDB table $tableName..."
    aws dynamodb create-table `
        --table-name $tableName `
        --attribute-definitions AttributeName=LockID,AttributeType=S `
        --key-schema AttributeName=LockID,KeyType=HASH `
        --billing-mode PAY_PER_REQUEST `
        --region $region
    
    Write-Host "Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name $tableName
} else {
    Write-Host "Table $tableName already exists."
}

Write-Host "✅ Backend infrastructure ready."
