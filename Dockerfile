# Runtime: ===========================================
FROM php:7.3-fpm-alpine AS runtime

WORKDIR /usr/src

ENV HOME=/usr/src \
    COMPOSER_HOME=/usr/local/composer \
    PATH=/usr/src/bin:/usr/src/vendor/bin:/usr/local/composer/vendor/bin:$PATH

RUN apk add --no-cache \
  ca-certificates \
  less \
  libzip \
  mariadb-client \
  nginx \
  openssl \
  supervisor \
  su-exec \
  tzdata \
  zlib

#  Development: ===========================================
FROM runtime AS development

RUN apk add --no-cache \
  build-base \
  chromium \
  chromium-chromedriver \
  git \
  libzip-dev \
  mariadb-dev \
  nodejs \
  npm \
  yarn \
  zlib-dev

RUN npm config set unsafe-perm true

RUN npm install -g check-dependencies

# Install PHP Packages required by Laravel:
RUN docker-php-ext-install \
  bcmath \
  pdo_mysql \
  zip

# Step 10: Install composer:
RUN set -ex \
 && export COMPOSER_VERSION=1.8.4 \
 && export COMPOSER_SHA256=1722826c8fbeaf2d6cdd31c9c9af38694d6383a0f2bf476fe6bbd30939de058a \
 && curl -o /usr/local/bin/composer "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" \
 && echo "${COMPOSER_SHA256}  /usr/local/bin/composer" | sha256sum -c - \
 && chmod a+x /usr/local/bin/composer

# Step 11 & 12: Define the arguments (with defaults) used to replicate the
# developer's user on the Docker Host, to enable generating files from inside
# the container (i.e. running php artisan make:model) with the host's user as
# their owner:
ARG DEVELOPER_USER="you"
ARG DEVELOPER_UID="1000"

# Step 13: Add the host user as a user inside the image:
RUN adduser -D -u $DEVELOPER_UID $DEVELOPER_USER \
 && addgroup $DEVELOPER_USER wheel

# Step 14: Make the developer username as an environment variable:
ENV DEVELOPER_USER=$DEVELOPER_USER

# Step 15: Create the COMPOSER_HOME directory (where the global packages will be
# in):
RUN mkdir -p $COMPOSER_HOME \
 && chgrp wheel $COMPOSER_HOME \
 && chmod g+rws $COMPOSER_HOME
