# WARNING:
# This file is for development, not for production.
# For production, please refer to https://railsdiff.org/7.0.8.4/7.1.3.4#diff-466a28a0e93935ce250159682062e5a94698a3d8
# or SUS-ORS project.

# Dockerfile
FROM ruby:3.4.9

# Rails and SAPI has some additional dependencies, e.g. rake requires a JS
# runtime, so attempt to get these from apt, where possible
# socat is just for binding ports within docker, not needed for the application
RUN apt-get update && apt-get install -y --force-yes \
  libsodium-dev libgmp3-dev libssl-dev \
  libpq-dev postgresql-client \
  nodejs \
  socat \
  texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra \
  ;
# NB: Postgres client from Debian is 9.4 - not sure if this is acceptable

RUN mkdir /SAPI
WORKDIR /SAPI

COPY Gemfile.lock /SAPI/Gemfile.lock

RUN grep -A1 '^BUNDLED WITH$' Gemfile.lock | tail -n1 | tr -d ' ' \
  | xargs -I _BUNDLER_VERSION_ gem install bundler -v _BUNDLER_VERSION_

# Don't this any more, as we get it with Docker bindings
RUN rm /SAPI/Gemfile.lock

##
# This happens in the entrypoint
#   RUN bundle install
#
# This is done via docker bindings
#   COPY . /SAPI

ENTRYPOINT ["/SAPI/bin/docker-entrypoint-develop"]
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
