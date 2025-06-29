#!/bin/bash

# Railway deployment script for OrangeHRM
set -e

echo "Starting OrangeHRM deployment on Railway..."

# Function to substitute environment variables in config file
substitute_env_vars() {
    local file="$1"
    echo "Substituting environment variables in $file..."
    
    # Replace environment variable placeholders
    sed -i "s/\${DB_HOST}/$DB_HOST/g" "$file"
    sed -i "s/\${DB_PORT}/$DB_PORT/g" "$file"
    sed -i "s/\${DB_NAME}/$DB_NAME/g" "$file"
    sed -i "s/\${DB_USER}/$DB_USER/g" "$file"
    sed -i "s/\${DB_PASSWORD}/$DB_PASSWORD/g" "$file"
    sed -i "s/\${OHRM_ADMIN_USERNAME}/$OHRM_ADMIN_USERNAME/g" "$file"
    sed -i "s/\${OHRM_ADMIN_PASSWORD}/$OHRM_ADMIN_PASSWORD/g" "$file"
    sed -i "s/\${OHRM_ADMIN_EMAIL}/$OHRM_ADMIN_EMAIL/g" "$file"
    sed -i "s/\${OHRM_ORGANIZATION_NAME}/$OHRM_ORGANIZATION_NAME/g" "$file"
    sed -i "s/\${OHRM_COUNTRY}/$OHRM_COUNTRY/g" "$file"
}

# Wait for database to be ready
echo "Waiting for database connection..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if php -r "
        try {
            \$pdo = new PDO('mysql:host=$DB_HOST;port=$DB_PORT', '$DB_USER', '$DB_PASSWORD');
            echo 'Database connection successful';
            exit(0);
        } catch (Exception \$e) {
            echo 'Database connection failed: ' . \$e->getMessage();
            exit(1);
        }
    "; then
        echo "Database is ready!"
        break
    else
        echo "Database not ready, attempt $attempt/$max_attempts"
        sleep 5
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "Failed to connect to database after $max_attempts attempts"
    exit 1
fi

# Check if OrangeHRM is already installed
if [ ! -f "src/lib/confs/Conf.php" ]; then
    echo "OrangeHRM not installed, running installation..."
    
    # Substitute environment variables in installer config
    substitute_env_vars "installer/cli_install_config.yaml"
    
    # Run the CLI installer
    cd /var/www/html
    php installer/cli_install.php
    
    echo "OrangeHRM installation completed!"
else
    echo "OrangeHRM already installed, skipping installation..."
fi

# Set proper permissions
echo "Setting file permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 src/cache src/log src/config

# Clear cache if it exists
if [ -d "src/cache" ]; then
    echo "Clearing cache..."
    rm -rf src/cache/*
fi

# Generate Doctrine proxies and clear cache
echo "Generating Doctrine proxies and clearing cache..."
cd src
php ../bin/console orm:generate-proxies
php ../bin/console cache:clear

echo "Deployment completed successfully!"

# Start Apache
echo "Starting Apache web server..."
exec apache2-foreground
