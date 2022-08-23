ARG PHP_VERSION=${PHP_VERSION:-8.1}

FROM php:${PHP_VERSION}

ARG PROJECT_ROOT
ARG NODE_VERSION
ARG RECORDS_DIR
ARG CHARTS_DIR
ARG DATABASE_DEFAULT_URL
ARG DATABASE_OBSERVATIONS_URL

ENV PHP_VERSION=${PHP_VERSION:-8.1} \
    NODE_VERSION=${NODE_VERSION:-16.17.0} \
    PROJECT_ROOT=${PROJECT_ROOT:-/opt/birdnet} \
    RECORDS_DIR=${RECORDS_DIR:-/media/data/birdnet/records} \
    CHARTS_DIR=${CHARTS_DIR:-/media/data/birdnet/charts} \
    DATABASE_DEFAULT_URL=${DATABASE_DEFAULT_URL:-mysql://birdnet:secret@birdnet_database/birdnet} \
    DATABASE_OBSERVATIONS_URL=${DATABASE_OBSERVATIONS_URL:-mysql://birdnet:secret@birdnet_database/birdnet_observations} 

ENV APP_ENV=${APP_ENV:-prod}
ENV APP_DEBUG=${APP_DEBUG:-0}

# RUN apt-get update && apt-get upgrade -y \
#     && apt-get install -y \
#     curl \
#     zip \
#     unzip \
#     zlib1g-dev \
#     libzip-dev \
#     git \
#     vim \
#     && apt-get clean 

# RUN docker-php-ext-install zip pdo_mysql

# # Install composer
# RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
#     && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# # Install nodejs and npm
# ENV NVM_DIR="/usr/local/nvm"
# RUN mkdir ${NVM_DIR}
# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# RUN . "$NVM_DIR/nvm.sh" \
#     && nvm install ${NODE_VERSION} \
#     && nvm use ${NODE_VERSION} \
#     && nvm alias default ${NODE_VERSION} \
#     && npm install -g yarn
# ENV PATH="$PATH:/usr/local/nvm/versions/node/v${NODE_VERSION}/bin"

# Change permissions for the home folder of www-data (used for composer cache)
RUN chown -R www-data:www-data /var/www
COPY . ${PROJECT_ROOT}
WORKDIR ${PROJECT_ROOT}/www
RUN rm -rf {vendor,node_modules}
RUN chown -R www-data:www-data .

USER www-data
# Setup .env
RUN cp .env.local.example .env.local
RUN sed -i "s/^APP_ENV=.*/APP_ENV=prod/g" .env.local \
&& sed -i "s/^APP_DEBUG=.*/APP_DEBUG=0/g" .env.local \
&& sed -i "s/^APP_SECRET=.*/APP_SECRET=${APP_SECRET}/g" .env.local \
&& sed -i "s|^DATABASE_DEFAULT_URL=.*|DATABASE_DEFAULT_URL=${DATABASE_DEFAULT_URL}|g" .env.local \
&& sed -i "s|^DATABASE_OBSERVATIONS_URL=.*|DATABASE_OBSERVATIONS_URL=${DATABASE_OBSERVATIONS_URL}|g" .env.local \
&& sed -i "s|^RECORDS_DIR=.*|RECORDS_DIR=${RECORDS_DIR}|g" .env.local \
&& sed -i "s|^CHARTS_DIR=.*|CHARTS_DIR=${CHARTS_DIR}|g" .env.local

# # # Install yarn dependencies
# RUN . "$NVM_DIR/nvm.sh" && yarn install && yarn build

# # Install composer dependencies
# RUN composer install --no-interaction --prefer-dist --optimize-autoloader
# RUN composer dump-env prod
# RUN composer dump-autoload