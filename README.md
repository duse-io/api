[![Build Status](https://travis-ci.org/duse-io/api.svg)](https://travis-ci.org/duse-io/api)
[![Coverage Status](https://img.shields.io/coveralls/duse-io/api.svg)](https://coveralls.io/r/duse-io/api?branch=master)
[![Code Climate](https://codeclimate.com/github/duse-io/api/badges/gpa.svg)](https://codeclimate.com/github/duse-io/api)

> This project is still under heavy development, it is not suited for
> production use!

duse api
========

The RESTful api for duse.

Requirements
------------

- Ubuntu 14.04
- Ruby 2.1.5
- Postgres

Ruby

	\curl -sSL https://get.rvm.io | bash -s stable --ruby

PostgreSQL

	sudo apt-get install postgresql libpq-dev postgresql-server-dev-all

Clone and install dependencies

	git clone
	bundle install

Start
-----

In development you can simply start the server with

	foreman start

In production it can be started with the rackup command

	rackup

Docker Setup
------------

	sudo docker run --name duse-postgres -d postgres
	sudo docker run -p 5000:5000 --name duse-api --link duse-postgres:postgres -d duseio/api sh -c 'sudo DATABASE_URL=postgres://postgres@$POSTGRES_PORT_5432_TCP_ADDR/postgres foreman start'

API Documentation
-----------------

Check out the interactive [api documentation](http://docs.duseapi.apiary.io/).
