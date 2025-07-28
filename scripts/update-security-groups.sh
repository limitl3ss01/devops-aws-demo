#!/bin/bash

# Script to update security groups for all environments
# Adds monitoring ports (3000, 9090) to all security groups

echo "🔧 Updating Security Groups for all environments..."

# Function to update security group
update_security_group() {
    local env_name=$1
    local env_path=$2
    
    echo "📦 Updating $env_name environment..."
    cd "$env_path"
    
    if [ -f "terraform.tfstate" ]; then
        echo "   Applying Terraform changes..."
        terraform plan -out=tfplan
        terraform apply tfplan
        echo "   ✅ $env_name security group updated!"
    else
        echo "   ⚠️  No existing Terraform state found for $env_name"
        echo "   Run 'terraform init && terraform apply' manually in $env_path"
    fi
    
    cd - > /dev/null
}

# Update main environment
echo "🏠 Updating main environment..."
cd terraform
if [ -f "terraform.tfstate" ]; then
    echo "   Applying Terraform changes..."
    terraform plan -out=tfplan
    terraform apply tfplan
    echo "   ✅ Main security group updated!"
else
    echo "   ⚠️  No existing Terraform state found for main environment"
    echo "   Run 'terraform init && terraform apply' manually in terraform/"
fi
cd ..

# Update staging environment
update_security_group "staging" "environments/staging"

# Update production environment  
update_security_group "production" "environments/production"

echo ""
echo "🎯 Security Groups update completed!"
echo ""
echo "📋 Summary of changes:"
echo "   ✅ Added port 3000 (Grafana) to all environments"
echo "   ✅ Added port 9090 (Prometheus) to all environments"
echo "   ✅ Added port 5000 (Flask App) to all environments"
echo "   ✅ Added port 22 (SSH) to all environments"
echo ""
echo "🌐 After applying changes, you can access:"
echo "   - Flask App: http://PUBLIC_IP:5000"
echo "   - Grafana: http://PUBLIC_IP:3000 (admin/admin)"
echo "   - Prometheus: http://PUBLIC_IP:9090"
echo "   - Metrics: http://PUBLIC_IP:5000/metrics" 