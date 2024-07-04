FROM php:8.3-cli

RUN apt-get update && \
    apt-get install -y git zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /var && \
    mkdir -p /var/www && \
    chown www-data:www-data /var/www

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html/

USER root

RUN composer self-update

USER www-data:www-data

RUN touch /var/www/.gitconfig && \
    git config --global --add safe.directory /var/www

COPY --chown=www-data:www-data ./composer.json ./composer.lock /var/www/html/
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-scripts

COPY --chown=www-data:www-data ./bin /var/www/html/bin
COPY --chown=www-data:www-data ./src /var/www/html/src

RUN composer dump-autoload --no-dev

EXPOSE 8000
CMD ["sleep", "infinity"]
