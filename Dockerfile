# WARNING:
# This file is for development, not for production.
# For production, please refer to https://railsdiff.org/7.0.8.4/7.1.3.4#diff-466a28a0e93935ce250159682062e5a94698a3d8
# or SUS-ORS project.

# Dockerfile
FROM ruby:3.2.5

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

# COPY Gemfile /SAPI/Gemfile
# COPY Gemfile.lock /SAPI/Gemfile.lock
RUN gem install bundler -v 2.5.17
# RUN bundle install

# COPY . /SAPI

EXPOSE 3000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
