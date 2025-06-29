# OrangeHRM Deployment on Railway

This guide will help you deploy your OrangeHRM application on Railway.

## Prerequisites

1. Railway account (sign up at [railway.app](https://railway.app))
2. GitHub repository with your OrangeHRM code
3. Railway CLI (optional, for local development)

## Quick Deployment Steps

### 1. Prepare Your Repository

Ensure these files are in your repository root:
- `Dockerfile.railway` - Custom Dockerfile for Railway
- `railway.toml` - Railway configuration
- `railway-install-config.yaml` - Installation configuration
- `deploy.sh` - Deployment script

### 2. Deploy to Railway

#### Option A: Deploy via Railway Dashboard

1. Go to [railway.app](https://railway.app) and sign in
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose your OrangeHRM repository
5. Railway will automatically detect the `railway.toml` configuration

#### Option B: Deploy via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Deploy
railway up
```

### 3. Add MySQL Database

1. In your Railway project dashboard
2. Click "New Service"
3. Select "Database" → "MySQL"
4. Railway will automatically create the database and set environment variables

### 4. Configure Environment Variables

The following environment variables will be automatically set by Railway:
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` (from MySQL addon)

You can customize these in the Railway dashboard:
- `OHRM_ADMIN_USERNAME` (default: Admin)
- `OHRM_ADMIN_PASSWORD` (default: Ohrm@1423)
- `OHRM_ADMIN_EMAIL` (default: admin@example.com)
- `OHRM_ORGANIZATION_NAME` (default: OrangeHRM)
- `OHRM_COUNTRY` (default: US)

### 5. Access Your Application

1. Once deployed, Railway will provide a URL (e.g., `https://your-app.railway.app`)
2. The application will automatically install OrangeHRM on first run
3. Login with your configured admin credentials

## Configuration Details

### Dockerfile.railway

- Multi-stage build for optimal performance
- Builds Vue.js frontend assets
- Installs PHP dependencies
- Configures Apache web server
- Sets up proper file permissions

### railway.toml

- Defines build and deployment configuration
- Sets up MySQL database service
- Configures environment variables
- Sets health check endpoints

### Deployment Process

1. **Build Phase**: 
   - Builds frontend assets (Vue.js)
   - Installs PHP dependencies via Composer
   - Sets up Apache configuration

2. **Deploy Phase**:
   - Waits for database connection
   - Runs OrangeHRM CLI installer (if not already installed)
   - Sets file permissions
   - Clears cache and generates Doctrine proxies
   - Starts Apache web server

## Troubleshooting

### Build Issues

If you encounter npm/yarn build warnings or errors:

1. **npm warnings about `--only=production`**: These are harmless warnings about deprecated flags
2. **Frontend build failures**: Check that both `src/client/yarn.lock` and `installer/client/yarn.lock` exist
3. **Missing dependencies**: The build process installs all dependencies including devDependencies for building

### Database Connection Issues

If you encounter database connection problems:

1. Check that MySQL service is running in Railway dashboard
2. Verify environment variables are set correctly
3. Check deployment logs for connection errors
4. Ensure the MySQL service is linked to your web service

### Installation Issues

If installation fails:

1. Check deployment logs in Railway dashboard
2. Verify all environment variables are set correctly
3. Ensure database is accessible and empty
4. Check that the installer config file was processed correctly
5. Try redeploying the service

### File Permission Issues

If you encounter permission errors:

1. The deployment script automatically sets permissions
2. Check if the `deploy.sh` script ran successfully
3. Verify Apache is running as www-data user
4. Check that cache and log directories are writable

### Build Process Debug

To debug build issues:

1. Check Railway build logs for specific error messages
2. Verify that both frontend builds completed successfully
3. Ensure all required files are copied to the container
4. Check that PHP dependencies were installed correctly

## Customization

### Admin Credentials

Change the default admin credentials by setting these environment variables in Railway:

```
OHRM_ADMIN_USERNAME=your_username
OHRM_ADMIN_PASSWORD=your_secure_password
OHRM_ADMIN_EMAIL=your_email@domain.com
```

### Organization Settings

Customize your organization details:

```
OHRM_ORGANIZATION_NAME=Your Company Name
OHRM_COUNTRY=Your Country Code (e.g., US, UK, IN)
```

### Custom Domain

To use a custom domain:

1. Add your domain in Railway project settings
2. Configure DNS to point to Railway
3. Railway will automatically handle SSL certificates

## Support

For Railway-specific issues:
- Railway Documentation: [docs.railway.app](https://docs.railway.app)
- Railway Discord: [discord.gg/railway](https://discord.gg/railway)

For OrangeHRM issues:
- OrangeHRM Documentation: [orangehrm.com/documentation](https://orangehrm.com/documentation)
- OrangeHRM Community: [github.com/orangehrm/orangehrm](https://github.com/orangehrm/orangehrm)

## Security Notes

1. Change default admin password after first login
2. Use strong passwords for database and admin accounts
3. Regularly update OrangeHRM to latest version
4. Monitor Railway logs for security issues
5. Consider using Railway's private networking for database connections

## Cost Optimization

1. Railway offers a free tier with limitations
2. Monitor resource usage in Railway dashboard
3. Consider upgrading to paid plan for production use
4. Optimize Docker image size for faster deployments
