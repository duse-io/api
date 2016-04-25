FROM alpine:3.3

RUN apk --update add bash build-base postgresql-client postgresql-dev ruby ruby-dev ruby-json ruby-irb ruby-bundler ruby-rdoc ruby-doc ruby-bigdecimal ruby-io-console && \
    rm -rf /var/cache/apk/*

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without development test

COPY . /usr/src/app

EXPOSE 5000
ENV RACK_ENV=production
ENTRYPOINT ["/usr/src/app/docker-entrypoint.sh"]
CMD bundle exec rackup -p ${PORT:-5000} --host 0.0.0.0

