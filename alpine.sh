#!/bin/bash

set -eux
apk add --no-cache --virtual .ruby-builddeps \
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
		zlib-dev \

mkdir -p /usr/local/etc
{
  echo 'install: --no-document';
  echo 'update: --no-document';
} >> /usr/local/etc/gemrc

wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.xz"
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

export ac_cv_func_isnan=yes ac_cv_func_isinf=yes
./configure --build="$gnuArch" --disable-install-doc --enable-shared 
	
make -j "$(nproc)"
make install
runDeps="$( \
  scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
)"
apk add --no-network --virtual .ruby-rundeps $runDeps	
apk del --no-network .ruby-builddeps
cd /
rm -r /usr/src/ruby
	! apk --no-network list --installed \
		| grep -v '^[.]ruby-rundeps' \
		| grep -i ruby \
	
[ "$(command -v ruby)" = '/usr/local/bin/ruby' ]
# rough smoke test
ruby --version
gem --version