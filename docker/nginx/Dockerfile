FROM nginx:latest

ENV PHP_FPM_PORT=${PHP_FPM_PORT:-9000}

ENV SERVER_NAME=${SERVER_NAME:-birdnet.lan} 
ENV PROJECT_ROOT=${PROJECT_ROOT:-/opt/birdnet}
ENV SYMFONY_PUBLIC=${SYMFONY_PUBLIC:-${PROJECT_ROOT}/www/public}

USER root
COPY docker/nginx/nginx.conf.template /etc/nginx/sites-available/birdnet.conf
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
CMD ["nginx", "-g", "daemon off;"]