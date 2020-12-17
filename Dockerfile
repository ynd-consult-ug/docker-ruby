ARG DISTRO_VERSION=3.12
FROM alpine:${DISTRO_VERSION}


RUN apk add --no-cache \
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
  yarn

ARG UID=1000

RUN adduser -h /ruby -D -u $UID ruby

USER ${UID}

SHELL [ "/bin/bash", "-lc" ]

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0

ENV LANG C.UTF-8

RUN echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc

ARG RUBY_VERSION
RUN ~/.asdf/bin/asdf plugin add ruby && \
  RUBY_EXTRA_CONFIGURE_OPTIONS="--enable-shared --disable-install-doc" ~/.asdf/bin/asdf install ruby ${RUBY_VERSION} && \
  ~/.asdf/bin/asdf global ruby ${RUBY_VERSION}

CMD ["/bin/bash"]