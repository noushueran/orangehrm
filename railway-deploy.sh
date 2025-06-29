#!/bin/bash

# Railway Deployment Script for OrangeHRM
# This script helps you deploy OrangeHRM to Railway

set -e

echo "🚀 OrangeHRM Railway Deployment Script"
echo "======================================"

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
    echo "✅ Railway CLI installed successfully"
fi

# Check if user is logged in to Railway
if ! railway whoami &> /dev/null; then
    echo "🔐 Please login to Railway..."
    railway login
fi

echo ""
echo "📋 Pre-deployment checklist:"
echo "1. Ensure you have committed all changes to Git"
echo "2. Make sure your repository is pushed to GitHub"
echo "3. Verify all Railway configuration files are present"

echo ""
read -p "Do you want to continue with deployment? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Check if required files exist
echo "🔍 Checking required files..."

required_files=(
    "Dockerfile.railway"
    "railway.toml"
    "railway-install-config.yaml"
    "deploy.sh"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Required file missing: $file"
        echo "Please ensure all Railway configuration files are present"
        exit 1
    fi
done

echo "✅ All required files found"

# Initialize Railway project if not already done
if [[ ! -f ".railway" ]] && [[ ! -d ".railway" ]]; then
    echo "🚂 Initializing Railway project..."
    railway init
fi

# Deploy to Railway
echo "🚀 Deploying to Railway..."
railway up

echo ""
echo "✅ Deployment initiated successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Go to your Railway dashboard to monitor the deployment"
echo "2. Add a MySQL database service to your project"
echo "3. Wait for the deployment to complete"
echo "4. Access your application via the provided Railway URL"
echo ""
echo "🔗 Railway Dashboard: https://railway.app/dashboard"
echo ""
echo "⚠️  Important:"
echo "- The first deployment may take 5-10 minutes"
echo "- OrangeHRM will auto-install on first access"
echo "- Default admin credentials: Admin / Ohrm@1423"
echo "- Change admin password after first login"
echo ""
echo "🎉 Happy deploying!"
