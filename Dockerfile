ARG RUBY_VERSION=3.4.9

FROM ruby:$RUBY_VERSION-slim AS base
  ARG NODE_VERSION=18.20.8
  ARG POSTGRES_CLIENT_MAJOR=17
  ARG TARGETARCH=amd64
  ARG DEBIAN_FRONTEND=noninteractive

  WORKDIR /rails

  ##
  # Rails and SAPI has some additional dependencies, e.g. rake requires a JS
  # runtime, so attempt to get these from apt, where possible
  RUN --mount=type=bind,source=docker_config/,target=docker_config/ \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -qq \
    && bash docker_config/system_packages.sh common base | \
      xargs -r apt-get install --no-install-recommends -y \
    \
    ##
    # Keep PostgreSQL client major version aligned with DB server major version
    # to avoid the generation of SQL which is inconsistent with the DB server, e.g.
    # unpinned `postgresql-client` can upgrade to 17 and generate `structure.sql`
    # that includes `transaction_timeout`, which fails to load on PostgreSQL 15.
    # pg_dump requires that the client library >= the server (major) version
    # `postgresql-client-${POSTGRES_CLIENT_MAJOR}` requires PostgreSQL `apt`
    # repository.
    && \
    bash docker_config/install_pg.sh $POSTGRES_CLIENT_MAJOR \
    && \
    bash docker_config/install_node.sh $NODE_VERSION $TARGETARCH \
  ;


  # Debian installs jemalloc in an architecture-specific library directory. Resolve the actual path at build time and
  # expose one stable preload path so both the Rails web process and Sidekiq use the same allocator automatically.
  RUN jemalloc_path="$(find /usr/lib -name 'libjemalloc.so.2' | head -n 1)" \
    && test -n "${jemalloc_path}" \
    && ln -sf "${jemalloc_path}" /usr/local/lib/libjemalloc.so.2 \
  ;

  ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

FROM base AS runtime
  ARG DEBIAN_FRONTEND=noninteractive
  RUN --mount=type=bind,source=docker_config/,target=docker_config/ \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -qq \
    && bash docker_config/system_packages.sh common base | \
      xargs -r apt-get install --no-install-recommends -y \
    ;

FROM base AS build
  ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=bind,source=docker_config/,target=docker_config/ \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -qq \
    && bash docker_config/system_packages.sh common build | \
      xargs -r apt-get install --no-install-recommends -y \
  ;

##
# For local development, we run `bundler` during the entrypoint
FROM build AS build-develop
  ##
  # BUNDLE_DEPLOYMENT prevents changes to Gemfile.lock
  ARG RAILS_ENV="development"
  ARG NODE_ENV="production"
  ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle"

  ARG DEBIAN_FRONTEND=noninteractive

  ARG DEBIAN_FRONTEND=noninteractive
  RUN --mount=type=bind,source=docker_config/,target=docker_config/ \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -qq \
    && bash docker_config/system_packages.sh development build | \
      xargs -r apt-get install --no-install-recommends -y \
  ;

  ##
  # Install the same version of bundler as the one used to create the lockfile
  RUN --mount=type=bind,source=Gemfile.lock,target=Gemfile.lock \
    grep -A1 '^BUNDLED WITH$' Gemfile.lock | tail -n1 | tr -d ' ' \
    | xargs -I _BUNDLER_VERSION_ gem install bundler -v _BUNDLER_VERSION_ \
  ;

FROM build-develop AS runtime-develop
  ##
  # You may wish to do the following:
  #
  #   export LOCAL_UID=$(id -u)
  #   export LOCAL_GID=$(id -g)
  ARG LOCAL_UID=1000
  ARG LOCAL_GID=1000

  RUN --mount=type=bind,source=docker_config/,target=docker_config/ \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -qq \
    && bash docker_config/system_packages.sh development runtime | \
      xargs -r apt-get install --no-install-recommends -y \
  ;

  ##
  # Docker UID/GID Mapping to Host: reuse or create group, then reuse or create
  # user, and give them passwordless sudo.
  RUN --mount=type=bind,source=docker_config/,target=docker_config/ \
    bash docker_config/create_docker_user.sh \
  ;

  ##
  # Ensure writable dirs for the non-root user
  RUN mkdir -p /usr/local/bundle \
      ./ ./db ./log ./storage ./tmp \
    && chown -R $LOCAL_UID:$LOCAL_GID \
      /usr/local/bundle \
      ./ ./db ./log ./storage ./tmp \
  ;

  ##
  # Run as the numeric UID:GID so it works regardless of whether we created
  # a user
  USER ${LOCAL_UID}:${LOCAL_GID}

##
# The build step for staging
FROM build AS build-staging
  ENV NODE_ENV="production" \
    RAILS_ENV="staging" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

  RUN --mount=type=bind,source=docker_config/,target=docker_config/ \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -qq \
    && bash docker_config/system_packages.sh staging build | \
      xargs -r apt-get install --no-install-recommends -y \
  ;

  COPY Gemfile Gemfile.lock ./

  RUN grep -A1 '^BUNDLED WITH$' Gemfile.lock | tail -n1 | tr -d ' ' \
    | xargs -I _BUNDLER_VERSION_ \
      gem install bundler -v _BUNDLER_VERSION_ \
  ;

  RUN bundle install \
    && rm -rf \
      ~/.bundle/ \
      "${BUNDLE_PATH}"/ruby/*/cache \
      "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git \
    && bundle exec bootsnap precompile --gemfile \
  ;

  COPY . .

  RUN bundle exec bootsnap precompile app/ lib/

  RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

FROM runtime AS runtime-staging
  ARG DEFAULT_GROUPNAME=railsgroup
  ARG DEFAULT_USERNAME=railsuser
  ENV BUNDLE_PATH="/usr/local/bundle"

  RUN --mount=type=bind,source=docker_config/,target=docker_config/ \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -qq \
    && bash docker_config/system_packages.sh staging runtime | \
      xargs -r apt-get install --no-install-recommends -y \
  ;

  # Run and own only the runtime files as a non-root user for security
  RUN groupadd $DEFAULT_GROUPNAME \
      --gid 1000 --system \
    && useradd $DEFAULT_USERNAME \
      --uid 1000 --gid 1000 --create-home --shell /bin/bash \
  ;

  USER 1000:1000

  COPY --from="build-staging" --chown=1000:1000 $BUNDLE_PATH $BUNDLE_PATH
  COPY --from="build-staging" --chown=1000:1000 /rails/ /rails/

FROM runtime-staging AS deploy-staging
  ENV RAILS_ENV="staging" \
    BUNDLE_WITHOUT="development"

  CMD ["tail", "-f", "/dev/null"]

FROM runtime-staging AS exec-staging
  ENV RAILS_ENV="staging" \
    BUNDLE_WITHOUT="development"

  ENTRYPOINT ["/rails/bin/docker-entrypoint"]

  EXPOSE 80

  CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

FROM runtime-develop AS deploy-develop
  CMD ["tail", "-f", "/dev/null"]

FROM runtime-develop AS exec-develop
  ENTRYPOINT ["/rails/bin/docker-entrypoint-develop"]

  EXPOSE 80

  CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
