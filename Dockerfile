ARG PHP_VERSION

FROM php:$PHP_VERSION-cli

ARG PROTO_VERSION
ARG XDEBUG_VERSION

RUN apt-get update && apt-get -y install gdb

RUN pecl install protobuf-$PROTO_VERSION \
    && pecl install xdebug-$XDEBUG_VERSION \
    && docker-php-ext-enable protobuf xdebug

