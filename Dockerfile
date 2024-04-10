# Dockerfile
FROM ruby:3.0.6

# Rails and SAPI has some additional dependencies, e.g. rake requires a JS
# runtime, so attempt to get these from apt, where possible
RUN apt-get update && apt-get install -y --force-yes \
  libsodium-dev libgmp3-dev libssl-dev \
  libpq-dev postgresql-client \
  nodejs \
  texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra \
;
# NB: Postgres client from Debian is 9.4 - not sure if this is acceptable

RUN mkdir /SAPI
WORKDIR /SAPI

# COPY Gemfile /SAPI/Gemfile
# COPY Gemfile.lock /SAPI/Gemfile.lock
RUN gem install bundler -v 2.2.33
# RUN bundle install

# COPY . /SAPI

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
