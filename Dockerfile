# Debian GNU/Linux 11 
FROM php:8.1-apache

ENV ACCEPT_EULA=Y

# instalacion de dependencias
RUN apt-get update && apt-get install -y \ 
    libzip-dev \
    git \
    curl \
    libpq-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    lsb-release 

RUN echo "file_uploads = On\n" \
        "memory_limit = 512M\n" \
        "upload_max_filesize = 2G\n" \
        "post_max_size = 2G\n" \
        "max_execution_time = 36000\n" \
        > /usr/local/etc/php/conf.d/uploads.ini

# Actualiza los repositorios e instala las dependencias necesarias
RUN apt-get update \
    && apt-get install -y libcurl4-openssl-dev

RUN apt-get install ca-certificates

RUN apt-get update && apt-get install -y gnupg2

# Instalar extensiones PHP 
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mysqli mbstring exif pcntl bcmath gd zip soap

# limpiar cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers
RUN chmod -R 777 /var/www/html

# 4. start with base php config, then add extensions
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY docker/php/php.ini /usr/local/etc/php/
COPY docker/apache/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY docker/apache/apache2.conf /etc/apache2/apache2.conf

# Actualizar composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# cambiar directorio de trabajo
COPY --chown=www-data:www-data . /var/www/html
WORKDIR /var/www/html