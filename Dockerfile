# Runtime: ===========================================
FROM php:7.3-fpm-alpine

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
