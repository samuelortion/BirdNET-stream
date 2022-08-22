ARG PHP_VERSION=${PHP_VERSION:-8.1}

FROM php:${PHP_VERSION}

ARG PROJECT_ROOT=${PROJECT_ROOT:-/opt/birdnet}
ARG NODE_VERSION=${NODE_VERSION:-16.17.0}

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    curl \
    gzip \
    git \
    vim \
    && apt-get clean 

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install nodejs and npm
ENV NVM_DIR="/usr/local/nvm"
RUN mkdir ${NVM_DIR}
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" \
    && nvm install ${NODE_VERSION} \
    && nvm use ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && npm install -g yarn
ENV PATH="$PATH:/usr/local/nvm/versions/node/v${NODE_VERSION}/bin"

COPY . ${PROJECT_ROOT}
RUN chown -R www-data:www-data "${PROJECT_ROOT}"
WORKDIR ${PROJECT_ROOT}/www
USER www-data
# Install composer packages
RUN composer install
# Install yarn dependencies
RUN . "$NVM_DIR/nvm.sh" && yarn install && yarn build

CMD ["bash"]