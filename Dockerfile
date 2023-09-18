# Dockerfile
FROM ruby:2.3.1

# The ruby:2.3.1 image is ancient, based of debian jessie which no longer
# receives active security updates. Therefore we must declare the debian
# archive as a source instead.
RUN rm /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list.d/jessie.list
RUN echo "deb http://archive.debian.org/debian jessie main" >> /etc/apt/sources.list.d/jessie.list

# Rails and SAPI has some additional dependencies, e.g. rake requires a JS
# runtime, so attempt to get these from apt, where possible
RUN apt-get update
RUN apt-get install -y --force-yes libsodium-dev libgmp3-dev libssl-dev
RUN apt-get install -y --force-yes libpq-dev
RUN apt-get install -y --force-yes nodejs
# rake requires a JS runtime, such as nodejs, so install it.
# postgresql-9.5 postgresql-contrib-9.5
# cannot find postgresql-contrib-9.5 - maybe postgres archive? Do we need it?

ADD . /usr/src/app
WORKDIR /usr/src/app

RUN gem install bundler -v 1.17.3
RUN bundle config without test production
RUN bundle install
