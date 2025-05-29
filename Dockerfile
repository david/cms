# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?name=ubuntu
# https://hub.docker.com/_/ubuntu/tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian/tags?name=bookworm-20250428-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: docker.io/hexpm/elixir:1.18.3-erlang-27.3.3-debian-bookworm-20250428-slim
#
ARG ELIXIR_VERSION="1.18"
ARG OTP_VERSION="27"
ARG DEBIAN_VERSION=bookworm-20250428-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

### Dev

FROM elixir:${ELIXIR_VERSION} AS dev

WORKDIR /tmp

RUN apt-get update && \
    apt-get install --no-install-recommends -y lsb-release && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > \
      /etc/apt/sources.list.d/pgdg.list && \
    curl -so - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install --no-install-recommends -y inotify-tools postgresql-client-17 && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sLo /tmp/elixir-ls.zip \
      https://github.com/elixir-lsp/elixir-ls/releases/download/v0.27.2/elixir-ls-v0.27.2.zip && \
    mkdir -p /usr/local/lsp/elixir-ls && \
    unzip /tmp/elixir-ls.zip -d /usr/local/lsp/elixir-ls && \
    rm -f /tmp/elixir-ls.zip && \
    useradd -mu 1000 -s /bin/bash dev && \
    mkdir -p /app && \
    chown -R dev:dev /app

USER dev

WORKDIR /app

RUN mkdir -p /home/dev/.mix

### Builder

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force \
  && mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

RUN mix assets.setup

COPY priv priv

COPY lib lib

COPY assets assets

RUN mix assets.deploy

RUN mix compile

COPY config/runtime.exs config/

COPY rel rel
RUN mix release

### Prod

FROM ${RUNNER_IMAGE} AS final

RUN apt-get update \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses5 locales ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

ENV MIX_ENV="prod"

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/cms ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
