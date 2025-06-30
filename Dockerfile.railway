# Multi-stage build for OrangeHRM on Railway
# Stage 1: Build frontend assets
FROM node:18-alpine AS frontend-builder

WORKDIR /app
COPY src/client/package*.json ./
RUN npm ci

COPY src/client/ ./
RUN npm run build

# Stage 2: Build installer frontend
FROM node:18-alpine AS installer-frontend-builder

WORKDIR /app
COPY installer/client/package*.json ./
RUN npm ci

COPY installer/client/ ./
RUN npm run build

# Stage 3: Main PHP application
FROM php:8.3-apache-bookworm

# Set environment variables
ENV APACHE_DOCUMENT_ROOT=/var/www/html
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    libldap2-dev \
    libicu-dev \
    unzip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-libdir=lib/$(uname -m)-linux-gnu/ \
    && docker-php-ext-install -j "$(nproc)" \
        gd \
        opcache \
        intl \
        pdo_mysql \
        zip \
        ldap

# Configure OPcache
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Configure PHP for production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set working directory
WORKDIR /var/www/html

# Copy application source
COPY . .

# Copy built frontend assets
COPY --from=frontend-builder /app/dist ./web/dist
COPY --from=installer-frontend-builder /app/dist ./installer/client/dist

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP dependencies
RUN cd src && composer install --no-dev --optimize-autoloader --no-interaction

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 src/cache src/log src/config \
    && chmod -R 775 installer/client/dist web/dist

# Copy Railway-specific configuration
COPY railway-install-config.yaml installer/cli_install_config.yaml

# Copy deployment script
COPY deploy.sh /usr/local/bin/deploy.sh
RUN chmod +x /usr/local/bin/deploy.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start script
CMD ["/usr/local/bin/deploy.sh"]
