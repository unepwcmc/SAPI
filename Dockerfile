ARG RUBY_VERSION=3.4.9

FROM ruby:$RUBY_VERSION-slim AS base
  ARG NODE_VERSION=18.20.8
  ARG POSTGRES_CLIENT_MAJOR=17
  ARG DEBIAN_FRONTEND=noninteractive

  WORKDIR /rails

  ##
  # Rails and SAPI has some additional dependencies, e.g. rake requires a JS
  # runtime, so attempt to get these from apt, where possible
  RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
      # Needed to install Node.js from official distribution archives.
      curl ca-certificates xz-utils gnupg \
      \
      # Needed by psych native extension (`yaml.h`) when bundling on slim images.
      libyaml-dev \
      \
      # Use jemalloc for long-running Rails/Sidekiq processes to reduce allocator fragmentation and lower RSS during
      # memory-heavy jobs such as questionnaire publish loop expansion.
      libjemalloc2 \
      \
      # Needed for various library building activities
      build-essential pkg-config \
      \
      # Do not install Postgres libraries from Debian; needs a specific version:
      #   postgresql-client libpq
      # Do not install Node.js from Debian; needs a specific version:
      #   nodejs
    \
    ##
    # Keep PostgreSQL client major version aligned with DB server major version
    # to avoid the generation of SQL which is inconsistent with the DB server, e.g.
    # unpinned `postgresql-client` can upgrade to 17 and generate `structure.sql`
    # that includes `transaction_timeout`, which fails to load on PostgreSQL 15.
    # pg_dump requires that the client library >= the server (major) version
    # `postgresql-client-${POSTGRES_CLIENT_MAJOR}` requires PostgreSQL `apt`
    # repository.
    && install -d /usr/share/postgresql-common/pgdg \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      | gpg --dearmor -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.gpg \
    && . /etc/os-release \
    && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.gpg] http://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list \
    \
    && apt-get install --no-install-recommends -y --force-yes \
      # Install the correct version of the postgres client
      "postgresql-client-${POSTGRES_CLIENT_MAJOR}" libpq-dev \
      \
      # Install libvips for Active Storage preview support
      libvips \
      \
      # Zip for exports
      zip \
      #
      libsodium-dev libgmp3-dev libssl-dev \
      \
      # socat is just for binding ports within docker, not needed for the application
      socat \
      \
      # TeX is used for the generation of CITES Checklist PDFs.
      texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives \
  ;

  # Detect the runtime architecture from the image itself instead of trusting a
  # caller-provided build arg. Local Docker Compose builds do not reliably set
  # TARGETARCH, and falling back to amd64 installs an x64 Node binary into an
  # arm64 image. ExecJS then tries to launch that binary during template asset
  # compilation and fails with the Rosetta loader error seen in development.
  RUN image_arch="$(dpkg --print-architecture)" \
    && case "$image_arch" \
      in \
        amd64) NODE_ARCH=x64 ;; \
        arm64) NODE_ARCH=arm64 ;; \
        *) echo "Unsupported architecture: '$image_arch'"; exit 1 ;; \
      esac \
    && echo https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz \
    && curl -fsSL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz \
      | tar -xJ -C /usr/local --strip-components=1 \
  ;

  # Debian installs jemalloc in an architecture-specific library directory. Resolve the actual path at build time and
  # expose one stable preload path so both the Rails web process and Sidekiq use the same allocator automatically.
  RUN jemalloc_path="$(find /usr/lib -name 'libjemalloc.so.2' | head -n 1)" \
    && test -n "${jemalloc_path}" \
    && ln -sf "${jemalloc_path}" /usr/local/lib/libjemalloc.so.2 \
  ;

  ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

FROM base AS build
  ARG DEBIAN_FRONTEND=noninteractive
  RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
      build-essential git libyaml-dev pkg-config \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives \
  ;

##
# For local development, we run `bundler` during the entrypoint
FROM build AS build-develop
  ##
  # BUNDLE_DEPLOYMENT prevents changes to Gemfile.lock
  ENV RAILS_ENV="development" \
    NODE_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle"

  ##
  # Install the same version of bundler as the one used to create the lockfile
  RUN --mount=type=bind,source=Gemfile.lock,target=Gemfile.lock \
    grep -A1 '^BUNDLED WITH$' Gemfile.lock | tail -n1 | tr -d ' ' \
    | xargs -I _BUNDLER_VERSION_ gem install bundler -v _BUNDLER_VERSION_ \
  ;

FROM build-develop AS built-develop
  ##
  # You may wish to do the following:
  #
  #   export LOCAL_UID=$(id -u)
  #   export LOCAL_GID=$(id -g)
  ARG LOCAL_UID=1000
  ARG LOCAL_GID=1000
  ARG DEFAULT_GROUPNAME=railsgroup
  ARG DEFAULT_USERNAME=railsuser

  ##
  # Docker UID/GID Mapping to Host: reuse or create group, then reuse or create
  # user, and give them passwordless sudo.
  RUN if getent group $LOCAL_GID > /dev/null; then \
        grp=$(getent group $LOCAL_GID | cut -d: -f1); \
      else \
        groupadd -g $LOCAL_GID $DEFAULT_GROUPNAME; \
        grp=$DEFAULT_GROUPNAME; \
      fi \
    && if getent passwd $LOCAL_UID > /dev/null; then \
        user=$(getent passwd $LOCAL_UID | cut -d: -f1); \
      else \
        useradd -m -u $LOCAL_UID -g "$grp" $DEFAULT_USERNAME; \
        user=$DEFAULT_USERNAME; \
      fi \
    && mkdir -p /etc/sudoers.d/ \
    && echo "${user} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${user}"\
    && chmod 0440 "/etc/sudoers.d/${user}" \
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

FROM base AS built-staging
  ARG DEFAULT_GROUPNAME=railsgroup
  ARG DEFAULT_USERNAME=railsuser
  ENV BUNDLE_PATH="/usr/local/bundle"

  # Run and own only the runtime files as a non-root user for security
  RUN groupadd $DEFAULT_GROUPNAME \
      --gid 1000 --system \
    && useradd $DEFAULT_USERNAME \
      --uid 1000 --gid 1000 --create-home --shell /bin/bash \
  ;

  USER 1000:1000

  COPY --from="build-staging" --chown=1000:1000 $BUNDLE_PATH $BUNDLE_PATH
  COPY --from="build-staging" --chown=1000:1000 /rails/ /rails/

FROM built-staging AS deploy-staging
  ENV RAILS_ENV="staging" \
    BUNDLE_WITHOUT="development"

  CMD ["tail", "-f", "/dev/null"]

FROM built-staging AS exec-staging
  ENV RAILS_ENV="staging" \
    BUNDLE_WITHOUT="development"

  ENTRYPOINT ["/rails/bin/docker-entrypoint"]

  EXPOSE 80

  CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

##
# The build step for production
FROM build AS build-production
  ENV NODE_ENV="production" \
    RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

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

FROM base AS built-production
  ARG DEFAULT_GROUPNAME=railsgroup
  ARG DEFAULT_USERNAME=railsuser
  ENV BUNDLE_PATH="/usr/local/bundle"

  # Run and own only the runtime files as a non-root user for security
  RUN groupadd $DEFAULT_GROUPNAME \
      --gid 1000 --system \
    && useradd $DEFAULT_USERNAME \
      --uid 1000 --gid 1000 --create-home --shell /bin/bash \
  ;

  USER 1000:1000

  COPY --from="build-production" --chown=1000:1000 $BUNDLE_PATH $BUNDLE_PATH
  COPY --from="build-production" --chown=1000:1000 /rails/ /rails/

FROM built-production AS deploy-production
  ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development"

  CMD ["tail", "-f", "/dev/null"]

FROM built-production AS exec-production
  ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development"

  ENTRYPOINT ["/rails/bin/docker-entrypoint"]

  EXPOSE 80

  CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

FROM built-develop AS deploy-develop
  CMD ["tail", "-f", "/dev/null"]

FROM built-develop AS exec-develop
  ENTRYPOINT ["/rails/bin/docker-entrypoint-develop"]

  EXPOSE 80

  CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
