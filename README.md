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
- Ruby 2.1.3
- Postgres

Ruby

	\curl -sSL https://get.rvm.io | bash -s stable --ruby

PostgreSQL

	sudo apt-get install libpq-dev

Clone and install dependencies

	git clone
	bundle install

API Documentation
-----------------

The api is self documenting and generates browsable [swagger
documentation](http://swagger.io/).

To check out the api documentation clone the repository and start the
application with

	foreman start

Then the generated (json) documentation can be found under

	http://localhost:5000/v1/swagger_doc.json

Use that link to display it in the
[swagger-ui](https://github.com/swagger-api/swagger-ui) or use the [swagger-ui
demo](http://petstore.swagger.wordnik.com/).
