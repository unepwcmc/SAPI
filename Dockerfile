# WARNING:
# This file is for development, not for production.
# For production, please refer to https://railsdiff.org/7.0.8.4/7.1.3.4#diff-466a28a0e93935ce250159682062e5a94698a3d8
# or SUS-ORS project.

# Dockerfile
FROM ruby:3.2.5-slim

# Rails and SAPI has some additional dependencies, e.g. rake requires a JS
# runtime, so attempt to get these from apt, where possible
# socat is just for binding ports within docker, not needed for the application
RUN apt-get update && apt-get install --no-install-recommends -y --force-yes \
  # ?
  libsodium-dev libgmp3-dev libssl-dev \
  # PSQL
  libpq-dev postgresql-client \
  # node js
  curl xz-utils \
  # For minio, local s3, development only.
  socat \
  # latex (huge file size)
  texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra \
  # Clean up
  && rm -rf /var/lib/apt/lists/*
# NB: Postgres client from Debian is 9.4 - not sure if this is acceptable

# Install Node.js 18.20.8 manually
ARG NODE_VERSION=18.20.8
ARG TARGETARCH
# Map Docker TARGETARCH to Node.js archive name
RUN case "$TARGETARCH" in \
  amd64) NODE_ARCH=x64 ;; \
  arm64) NODE_ARCH=arm64 ;; \
  *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;; \
  esac && \
  curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz \
  | tar -xJ -C /usr/local --strip-components=1

WORKDIR /SAPI

#
# Don't need to do these, as we have done this with Docker bindings
#   COPY Gemfile /SAPI/Gemfile
#   COPY Gemfile.lock /SAPI/Gemfile.lock
RUN gem install bundler -v 2.5.17

##
# This happens in the entrypoint
#   RUN bundle install
#
# This is done via docker bindings
#   COPY . /SAPI

ENTRYPOINT ["/SAPI/bin/docker-entrypoint-develop"]
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
