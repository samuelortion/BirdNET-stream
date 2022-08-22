ARG PHP_VERSION=${PHP_VERSION:-8.1}

FROM php:${PHP_VERSION}-fpm

RUN apt-get update && apt-get upgrade -y 
RUN docker-php-ext-install pdo_mysql

EXPOSE 9000