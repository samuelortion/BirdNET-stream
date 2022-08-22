FROM nginx

ARG SERVER_NAME
ARG PROJECT_ROOT
ARG SYMFONY_PUBLIC
ARG CHARTS_FOLDER
ARG RECORDS_FOLDER
ARG PHP_FPM_HOST
ARG PHP_FPM_PORT

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y nginx-full

USER root
COPY "docker/nginx/nginx.conf.template" "/etc/nginx/sites-available/birdnet.conf" 
RUN ln -s /etc/nginx/sites-available/birdnet.conf /etc/nginx/sites-enabled/birdnet.conf
RUN sed -i "s|<SERVER_NAME>|${SERVER_NAME}|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<PHP_FPM_HOST>|${PHP_FPM_HOST}|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<PHP_FPM_PORT>|${PHP_FPM_PORT}|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<SYMFONY_PUBLIC>|${SYMFONY_PUBLIC}|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<RECORDS_FOLDER>|${RECORDS_FOLDER}|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<CHARTS_FOLDER>|${CHARTS_FOLDER}|g" /etc/nginx/sites-available/birdnet.conf
RUN mkdir -p /etc/nginx/certs/birdnet 
WORKDIR /etc/nginx/certs/birdnet
RUN openssl req -x509 -newkey rsa:4096 -keyout privkey.pem -out fullchain.pem -sha256 -days 365 -nodes --subj "/CN=${SERVER_NAME}"
RUN sed -i "s|<CERTIFICATE>|/etc/nginx/certs/birdnet/fullchain.pem|g" /etc/nginx/sites-available/birdnet.conf \
    && sed -i "s|<PRIVATE_KEY>|/etc/nginx/certs/birdnet/privkey.pem|g" /etc/nginx/sites-available/birdnet.conf

EXPOSE 443
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]