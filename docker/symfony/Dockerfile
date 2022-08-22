ARG PHP_VERSION=${PHP_VERSION:-8.1}
FROM php:${PHP_VERSION}
ENV PROJECT_ROOT=${PROJECT_ROOT:-/opt/birdnet}
ENV SYMFONY_PUBLIC=${SYMFONY_PUBLIC:-${PROJECT_ROOT}/www/public}

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    nginx \
    curl \
    gzip \
    git \
    vim \
    && apt-get clean 

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer


ENV NODE_VERSION="16.17.0"
ENV NVM_DIR="/usr/local/nvm"
RUN mkdir ${NVM_DIR}
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" \
    && nvm install ${NODE_VERSION} \
    && nvm use ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && npm install -g yarn
ENV PATH="$PATH:/usr/local/nvm/versions/node/v${NODE_VERSION}/bin"

WORKDIR ${PROJECT_ROOT}
RUN chown -R www-data:www-data "${PROJECT_ROOT}"
# Install composer dependencies
USER www-data
WORKDIR ${PROJECT_ROOT}/www
RUN composer install
# Install yarn dependencies
RUN . "$NVM_DIR/nvm.sh" && yarn install && yarn build
USER root
COPY docker/www/nginx.conf.template /etc/nginx/sites-available/birdnet.conf
RUN ln -s /etc/nginx/sites-available/birdnet.conf /etc/nginx/sites-enabled/birdnet.conf \
    && sed -i "s|<SERVER_NAME>|${SERVER_NAME}|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<SYMFONY_PUBLIC>|${SYMFONY_PUBLIC}|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<RECORDS_DIR>|${RECORDS_DIR}|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<CHARTS_DIR>|${CHARTS_DIR}|g" /etc/nginx/sites-available/birdnet.conf
RUN mkdir -p /etc/nginx/certs/birdnet 
WORKDIR /etc/nginx/certs/birdnet
RUN openssl req -x509 -newkey rsa:4096 -keyout privkey.pem -out fullchain.pem -sha256 -days 365 -nodes --subj "/CN=${SERVER_NAME}"
RUN sed -i "s|<CERTIFICATE>|/etc/nginx/certs/birdnet/fullchain.pem|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<PRIVATE_KEY>|/etc/nginx/certs/birdnet/privkey.pem|g" /etc/nginx/sites-available/birdnet.conf
RUN nginx -t

EXPOSE 443
EXPOSE 80
CMD [""]
CMD ["nginx", "-g", "daemon off;"]