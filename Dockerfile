FROM python:3.7-slim-buster
WORKDIR /app
RUN set -x \
  && buildDeps=" \
  git \
  build-essential \
  inotify-tools \
  libffi-dev \
  libfreetype6-dev \
  liblcms2-dev \
  default-libmysqlclient-dev \
  libpq-dev \
  libtiff5-dev \
  libwebp-dev \
  libxml2-dev \
  libxml++2.6-dev \
  libxslt1-dev \
  libyaml-dev \
  libzbar-dev \
  libssl-dev \
  zlib1g-dev \
  gnupg \
  " \
  && runDeps=" \
  libjpeg-dev \
  default-mysql-client \
  pkg-config \
  swig \
  unzip \
  " \
  && apt-get update \
  && apt-get install -y --no-install-recommends $buildDeps \
  && apt-get install -y --no-install-recommends $runDeps \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
