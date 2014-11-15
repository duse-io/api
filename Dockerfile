FROM ubuntu:14.04

RUN sudo apt-get update
RUN sudo apt-get install -y curl autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libpq-dev postgresql-server-dev-all
RUN cd /tmp && curl ftp://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz | tar xz
RUN cd /tmp/ruby-2.1.5 && ./configure --disable-install-rdoc && make && sudo make install
RUN rm -rf /tmp/ruby-2.1.5
RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc
RUN sudo gem install bundler --no-ri --no-rdoc
ADD . /app
RUN cd /app && bundle install

WORKDIR /app

ENV DATABASE_URL postgres://duse_api:password1@localhost/duse_api_test
EXPOSE 5000
CMD ["sudo foreman start"]
