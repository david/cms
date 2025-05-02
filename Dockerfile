FROM elixir:1.18

WORKDIR /tmp

RUN apt-get update && \
    apt-get install --no-install-recommends -y lsb-release && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > \
      /etc/apt/sources.list.d/pgdg.list && \
    curl -so - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install --no-install-recommends -y inotify-tools postgresql-client-17 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -mu 1000 -s /bin/bash dev && \
    mkdir -p /app && \
    chown -R dev:dev /app

USER dev

WORKDIR /app

RUN mkdir -p /home/dev/.mix
