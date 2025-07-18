ARG ELIXIR_VERSION="1.18"
ARG OTP_VERSION="27"
ARG DEBIAN_VERSION="bookworm-20250630-slim"

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE}

RUN useradd -m -u 1000 -s /bin/bash dev
RUN mkdir -p /usr/local/keyrings /usr/local/lsp

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      gnupg \
      inotify-tools \
      lsb-release \
      unzip && \
    rm -rf /var/lib/apt/lists/*

# elixir-ls
RUN curl -sLo /tmp/elixir-ls.zip \
      https://github.com/elixir-lsp/elixir-ls/releases/download/v0.28.0/elixir-ls-v0.28.0.zip && \
    mkdir -p /usr/local/lsp/elixir-ls && \
    unzip /tmp/elixir-ls.zip -d /usr/local/lsp/elixir-ls && \
    ln -s /usr/local/lsp/elixir-ls/language_server.sh /usr/local/bin/elixir-ls && \
    rm -f /tmp/elixir-ls.zip

# postgresql client
RUN echo -n "deb [signed-by=/usr/local/keyrings/pgdg.gpg]" \
      "http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list && \
    curl -so - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      | gpg --dearmor \
      > /usr/local/keyrings/pgdg.gpg

# node
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      nodejs \
      postgresql-client-17 && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g @tailwindcss/language-server

USER dev

RUN mkdir -p /home/dev/.mix

VOLUME /home/dev/.mix
