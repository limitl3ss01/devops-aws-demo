# Script to safely add monitoring ports to existing security groups
# This avoids the "Still destroying..." issue

Write-Host "Safely adding monitoring ports to security groups..." -ForegroundColor Green

# Function to add monitoring ports to existing security group
function Add-MonitoringPorts {
    param(
        [string]$SecurityGroupId,
        [string]$Description
    )
    
    Write-Host "Adding monitoring ports to $Description ($SecurityGroupId)..." -ForegroundColor Yellow
    
    # Add Grafana port (3000)
    try {
        aws ec2 authorize-security-group-ingress `
            --group-id $SecurityGroupId `
            --protocol tcp `
            --port 3000 `
            --cidr 0.0.0.0/0 `
            --description "Grafana Dashboard"
        Write-Host "   Added port 3000 (Grafana)" -ForegroundColor Green
    } catch {
        Write-Host "   Port 3000 already exists or error occurred" -ForegroundColor Yellow
    }
    
    # Add Prometheus port (9090)
    try {
        aws ec2 authorize-security-group-ingress `
            --group-id $SecurityGroupId `
            --protocol tcp `
            --port 9090 `
            --cidr 0.0.0.0/0 `
            --description "Prometheus"
        Write-Host "   Added port 9090 (Prometheus)" -ForegroundColor Green
    } catch {
        Write-Host "   Port 9090 already exists or error occurred" -ForegroundColor Yellow
    }
}

# Get security group IDs from Terraform state
Write-Host "Getting security group IDs from Terraform state..." -ForegroundColor Cyan

# Main environment
if (Test-Path "terraform/terraform.tfstate") {
    Set-Location "terraform"
    $main_sg = terraform output -raw security_group_id 2>$null
    if ($main_sg) {
        Add-MonitoringPorts $main_sg "Main Environment"
    } else {
        Write-Host "Could not get main security group ID from Terraform state" -ForegroundColor Red
    }
    Set-Location $PSScriptRoot
}

# Staging environment
if (Test-Path "environments/staging/terraform.tfstate") {
    Set-Location "environments/staging"
    $staging_sg = terraform output -raw security_group_id 2>$null
    if ($staging_sg) {
        Add-MonitoringPorts $staging_sg "Staging Environment"
    } else {
        Write-Host "Could not get staging security group ID from Terraform state" -ForegroundColor Red
    }
    Set-Location $PSScriptRoot
}

# Production environment
if (Test-Path "environments/production/terraform.tfstate") {
    Set-Location "environments/production"
    $prod_sg = terraform output -raw security_group_id 2>$null
    if ($prod_sg) {
        Add-MonitoringPorts $prod_sg "Production Environment"
    } else {
        Write-Host "Could not get production security group ID from Terraform state" -ForegroundColor Red
    }
    Set-Location $PSScriptRoot
}

Write-Host ""
Write-Host "Security group ports added successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now access:" -ForegroundColor Cyan
Write-Host "   - Flask App: http://PUBLIC_IP:5000" -ForegroundColor White
Write-Host "   - Grafana: http://PUBLIC_IP:3000 (admin/admin)" -ForegroundColor White
Write-Host "   - Prometheus: http://PUBLIC_IP:9090" -ForegroundColor White
Write-Host "   - Metrics: http://PUBLIC_IP:5000/metrics" -ForegroundColor White 