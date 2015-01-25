FROM ruby:2.2.0

RUN apt-get update
RUN apt-get install -y libpq-dev postgresql-server-dev-all

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

EXPOSE 5000
CMD ["sudo rackup -p 5000"]
