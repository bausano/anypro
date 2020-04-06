# Basis for this Dockerfile has been taken from a guide by Cody Boggs.
# Source: https://semaphoreci.com/community/tutorials/dockerizing-elixir-and-phoenix-applications

FROM ubuntu

# postgresql-client package provides the psql command used by Ecto’s adapter.
RUN apt-get update && \
    apt-get install -y libssl1.0.0 postgresql-client && \
    apt-get autoclean

# A base where we copy the source files.
RUN mkdir -p /app

# The name of the app as stated in mix.exs file.
ENV APP_NAME anypro

# exrm bundles releases up into a ready-to-ship tar/gzip archive, which we copy
# into our container.
ARG SOURCE_TAR_GZ
COPY ${SOURCE_TAR_GZ} "/app/${APP_NAME}.tar.gz"
COPY scripts/wait-for-postgres.sh /app/wait-for-postgres.sh
WORKDIR /app
RUN tar xvzf "${APP_NAME}.tar.gz"

# Get a secrete key. This will be consumed by the phoenix fw.
ARG SECRET_KEY_BASE

# Configure database connection.
ARG DATABASE_USER
ARG DATABASE_PWD
ARG DATABASE_HOST
ARG DATABASE_NAME
ENV DATABASE_URL "ecto://${DATABASE_USER}:${DATABASE_PWD}@${DATABASE_HOST}/${DATABASE_NAME}"

# Make Elixir stop throwing warnings about the container’s locale at runtime.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Our project’s prod config (config/prod.exs) relies on an environment variable,
# $PORT, to know what port Phoenix should bind.
ENV PORT 8888

CMD ["/app/bin/${APP_NAME}", "start"]
