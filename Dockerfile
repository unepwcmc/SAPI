# Dockerfile
FROM ruby:2.3.1

# The ruby:2.3.1 image is ancient, based of debian jessie which no longer
# receives active security updates. Therefore we must declare the debian
# archive as a source instead.
RUN rm /etc/apt/sources.list && \
  echo "deb http://archive.debian.org/debian-security jessie/updates main" \
    >> /etc/apt/sources.list.d/jessie.list && \
  echo "deb http://archive.debian.org/debian jessie main" \
    >> /etc/apt/sources.list.d/jessie.list \
;

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

COPY Gemfile /SAPI/Gemfile
COPY Gemfile.lock /SAPI/Gemfile.lock
RUN gem install bundler -v 1.17.3
RUN bundle install

COPY . /SAPI

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
