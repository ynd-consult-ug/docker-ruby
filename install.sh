#!/bin/bash

set -eux

export RUBY_VERSION=$1
RUBY_DOWNLOAD_SHA256=$2

RUBY_MAJOR=$(echo ${RUBY_VERSION} | cut -d'.' -f -2 -)


apk add --virtual .ruby-builddeps \
		autoconf \
		bison \
		bzip2 \
		bzip2-dev \
		ca-certificates \
		coreutils \
		dpkg-dev dpkg \
		gcc \
		gdbm-dev \
		glib-dev \
		libc-dev \
		libffi-dev \
		libxml2-dev \
		libxslt-dev \
		linux-headers \
		make \
		ncurses-dev \
		openssl \
		openssl-dev \
		patch \
		procps \
		readline-dev \
		ruby \
		tar \
		xz \
		yaml-dev \
		zlib-dev


wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz"
echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum --check --strict

mkdir -p /usr/src/ruby
tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1
rm ruby.tar.xz

cd /usr/src/ruby

wget -O 'thread-stack-fix.patch' 'https://bugs.ruby-lang.org/attachments/download/7081/0001-thread_pthread.c-make-get_main_stack-portable-on-lin.patch'
echo '3ab628a51d92fdf0d2b5835e93564857aea73e0c1de00313864a94a6255cb645 *thread-stack-fix.patch' | sha256sum --check --strict
patch -p1 -i thread-stack-fix.patch
rm thread-stack-fix.patch

{
  echo '#define ENABLE_PATH_CHECK 0'
  echo
  cat file.c
} > file.c.new
mv file.c.new file.c

autoconf
gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
# the configure script does not detect isnan/isinf as macros
export ac_cv_func_isnan=yes ac_cv_func_isinf=yes
./configure \
  --build="$gnuArch" \
  --disable-install-doc \
  --enable-shared \

make -j "$(nproc)"
make install
runDeps="$(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')"

apk add --virtual .ruby-rundeps \
  $runDeps \
  bzip2 \
  ca-certificates \
  libffi-dev \
  procps \
  yaml-dev \
  zlib-dev \
  gmp-dev \
  bash \
  bc \
  build-base \
  busybox \
  ca-certificates \
  curl \
  curl-dev \
  gdbm-dev \
  git \
  glib \
  graphviz \
  jq \
  less \
  libgcc \
  libintl \
  libssl1.1 \
  libstdc++ \
  libx11 \
  libxext \
  libxml2 \
  libxml2-dev \
  libxrender \
  libxslt \
  libxslt-dev \
  linux-headers \
  musl-dev \
  netcat-openbsd \
  nodejs \
  nodejs-npm \
  openssh \
  postgresql-client \
  postgresql-dev \
  readline-dev \
  ttf-dejavu \
  ttf-droid \
  ttf-freefont \
  ttf-liberation \
  ttf-ubuntu-font-family \
  vim \
  yaml-dev \
  yarn \

apk del --no-network .ruby-builddeps

cd /
rm -rf /usr/src/ruby

! apk --no-network list --installed | grep -v '^[.]ruby-rundeps' | grep -i ruby

[ "$(command -v ruby)" = '/usr/local/bin/ruby' ]

gem install bundler

ruby --version
gem --version
bundle --version

