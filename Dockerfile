# Set the image
FROM php:8.2-fpm-bookworm

# Install dependencies
RUN apt-get update && apt-get install -y pandoc

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo_mysql 
# copy the last composer 
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# create app directory
RUN mkdir -p /usr/src/app

# set vi mode on tinker and bash
RUN useradd -G www-data -u 1000 -d /home/app app && \
    mkdir -p /home/app/.composer && \
    chown -R app:app /home/app && \
    echo 'set -o vi' > /home/app/.bashrc && \
    echo '"\C-l":clear-screen' > /home/app/.inputrc && \
    echo 'set editing-mode vi' >> /home/app/.inputrc && \
    echo 'bind -v' > /home/app/.editrc

COPY . /usr/src/app

WORKDIR /usr/src/app

RUN chown -R app: /usr/src/app

USER app

RUN composer install

RUN php artisan cache:clear && \
    php artisan config:clear

CMD ["sh", "./docker-entrypoint.sh"]

