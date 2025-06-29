#!/bin/bash

# Railway Setup Verification Script
echo "🔍 Verifying Railway deployment setup..."
echo "=================================="

# Check if required files exist
echo "📁 Checking required files:"

files=(
    "Dockerfile"
    "railway.toml"
    "railway.json"
    "railway-install-config.yaml"
    "deploy.sh"
    ".env.railway"
    "README-Railway.md"
)

all_files_exist=true

for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file"
    else
        echo "❌ $file (missing)"
        all_files_exist=false
    fi
done

# Check package.json files
echo ""
echo "📦 Checking package.json files:"

if [[ -f "src/client/package.json" ]]; then
    echo "✅ src/client/package.json"
else
    echo "❌ src/client/package.json (missing)"
    all_files_exist=false
fi

if [[ -f "installer/client/package.json" ]]; then
    echo "✅ installer/client/package.json"
else
    echo "❌ installer/client/package.json (missing)"
    all_files_exist=false
fi

# Check yarn.lock files
echo ""
echo "🧶 Checking yarn.lock files:"

if [[ -f "src/client/yarn.lock" ]]; then
    echo "✅ src/client/yarn.lock"
else
    echo "❌ src/client/yarn.lock (missing)"
    all_files_exist=false
fi

if [[ -f "installer/client/yarn.lock" ]]; then
    echo "✅ installer/client/yarn.lock"
else
    echo "❌ installer/client/yarn.lock (missing)"
    all_files_exist=false
fi

# Check Dockerfile content
echo ""
echo "🐳 Checking Dockerfile content:"

if grep -q "yarn install --frozen-lockfile" Dockerfile; then
    echo "✅ Dockerfile uses yarn (not npm)"
else
    echo "❌ Dockerfile still uses npm instead of yarn"
    all_files_exist=false
fi

if grep -q "corepack enable" Dockerfile; then
    echo "✅ Dockerfile enables corepack for yarn"
else
    echo "❌ Dockerfile missing corepack enable"
    all_files_exist=false
fi

# Check railway configuration
echo ""
echo "🚂 Checking Railway configuration:"

if grep -q 'dockerfilePath = "Dockerfile.railway"' railway.toml; then
    echo "✅ railway.toml points to correct Dockerfile"
else
    echo "❌ railway.toml has incorrect dockerfilePath"
    all_files_exist=false
fi

if grep -q '"dockerfilePath": "Dockerfile.railway"' railway.json; then
    echo "✅ railway.json points to correct Dockerfile"
else
    echo "❌ railway.json has incorrect dockerfilePath"
    all_files_exist=false
fi

# Final result
echo ""
echo "=================================="
if $all_files_exist; then
    echo "🎉 All checks passed! Ready for Railway deployment."
    echo ""
    echo "Next steps:"
    echo "1. Commit and push all changes to GitHub"
    echo "2. Deploy to Railway using the dashboard or CLI"
    echo "3. Add MySQL database service in Railway"
    echo "4. Monitor deployment logs"
else
    echo "❌ Some issues found. Please fix them before deploying."
fi

echo ""
echo "🔗 Useful commands:"
echo "git add . && git commit -m 'Add Railway deployment configuration'"
echo "git push"
echo "./railway-deploy.sh"
