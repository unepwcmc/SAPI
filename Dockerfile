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
  postgresql-common \
  nodejs \
  socat \
  texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra \
;

# pg_dump requires that the client library >= the server (major) version
RUN yes | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
RUN apt-get install -y --force-yes libpq-dev postgresql-client-17

RUN mkdir /SAPI
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
