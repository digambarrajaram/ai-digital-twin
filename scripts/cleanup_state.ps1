$ErrorActionPreference = "Stop"

# 1. Get AWS Account ID
try {
    $accountId = (aws sts get-caller-identity --query Account --output text).Trim()
    Write-Host "AWS Account ID: $accountId"
} catch {
    Write-Error "Failed to get AWS Account ID. Ensure you are logged in."
    exit 1
}

$bucketName = "twin-terraform-state-$accountId"
Write-Host "Targeting Bucket: $bucketName"

# 2. Check if bucket exists
$bucketExists = aws s3 ls "s3://$bucketName" 2>&1
if ($bucketExists -match "NoSuchBucket") {
    Write-Host "Bucket $bucketName does not exist."
    exit 0
}

# 3. Empty Bucket (Handling Versioning)
Write-Host "Fetching object versions..."
$versionsJson = aws s3api list-object-versions --bucket $bucketName --output json | Out-String

if ($null -ne $versionsJson -and $versionsJson.Trim() -ne "") {
    $versionsData = $versionsJson | ConvertFrom-Json
    
    # Delete Versions
    if ($versionsData.Versions) {
        Write-Host "Deleting objects..."
        foreach ($v in $versionsData.Versions) {
            Write-Host "  Deleting $($v.Key) (Version: $($v.VersionId))"
            aws s3api delete-object --bucket $bucketName --key $v.Key --version-id $v.VersionId
        }
    }

    # Delete DeleteMarkers
    if ($versionsData.DeleteMarkers) {
        Write-Host "Deleting delete markers..."
        foreach ($m in $versionsData.DeleteMarkers) {
            Write-Host "  Deleting $($m.Key) (Marker: $($m.VersionId))"
            aws s3api delete-object --bucket $bucketName --key $m.Key --version-id $m.VersionId
        }
    }
}

# 4. Delete Bucket
Write-Host "Deleting bucket..."
aws s3 rb "s3://$bucketName" --force
Write-Host "Successfully deleted $bucketName"
