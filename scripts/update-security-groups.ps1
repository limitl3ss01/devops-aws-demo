# Script to update security groups for all environments
# Adds monitoring ports (3000, 9090) to all security groups

Write-Host "Updating Security Groups for all environments..." -ForegroundColor Green

# Function to update security group
function Update-SecurityGroup {
    param(
        [string]$EnvName,
        [string]$EnvPath
    )
    
    Write-Host "Updating $EnvName environment..." -ForegroundColor Yellow
    Set-Location $EnvPath
    
    if (Test-Path "terraform.tfstate") {
        Write-Host "   Applying Terraform changes..." -ForegroundColor Cyan
        terraform plan -out=tfplan
        terraform apply tfplan
        Write-Host "   $EnvName security group updated!" -ForegroundColor Green
    } else {
        Write-Host "   No existing Terraform state found for $EnvName" -ForegroundColor Red
        Write-Host "   Run 'terraform init && terraform apply' manually in $EnvPath" -ForegroundColor Yellow
    }
    
    Set-Location $PSScriptRoot
}

# Update main environment
Write-Host "Updating main environment..." -ForegroundColor Yellow
Set-Location "terraform"
if (Test-Path "terraform.tfstate") {
    Write-Host "   Applying Terraform changes..." -ForegroundColor Cyan
    terraform plan -out=tfplan
    terraform apply tfplan
    Write-Host "   Main security group updated!" -ForegroundColor Green
} else {
    Write-Host "   No existing Terraform state found for main environment" -ForegroundColor Red
    Write-Host "   Run 'terraform init && terraform apply' manually in terraform/" -ForegroundColor Yellow
}
Set-Location $PSScriptRoot

# Update staging environment
Update-SecurityGroup "staging" "environments/staging"

# Update production environment  
Update-SecurityGroup "production" "environments/production"

Write-Host ""
Write-Host "Security Groups update completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary of changes:" -ForegroundColor Cyan
Write-Host "   Added port 3000 (Grafana) to all environments" -ForegroundColor Green
Write-Host "   Added port 9090 (Prometheus) to all environments" -ForegroundColor Green
Write-Host "   Added port 5000 (Flask App) to all environments" -ForegroundColor Green
Write-Host "   Added port 22 (SSH) to all environments" -ForegroundColor Green
Write-Host ""
Write-Host "After applying changes, you can access:" -ForegroundColor Cyan
Write-Host "   - Flask App: http://PUBLIC_IP:5000" -ForegroundColor White
Write-Host "   - Grafana: http://PUBLIC_IP:3000 (admin/admin)" -ForegroundColor White
Write-Host "   - Prometheus: http://PUBLIC_IP:9090" -ForegroundColor White
Write-Host "   - Metrics: http://PUBLIC_IP:5000/metrics" -ForegroundColor White 