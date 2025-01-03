FROM trafex/php-nginx:latest

USER root

WORKDIR /app

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apk add --update --no-cache php83-pdo_pgsql php83-pdo_mysql php83-pdo_sqlite php83-simplexml bash nodejs npm php83-pecl-xdebug git
RUN apk add --update --no-cache php83-sodium php83-iconv php83-zip php83-openssl

USER nobody
