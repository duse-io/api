[![Build Status](https://travis-ci.org/duse-io/api.svg)](https://travis-ci.org/duse-io/api)
[![Coverage Status](https://coveralls.io/repos/duse-io/api/badge.svg?branch=master)](https://coveralls.io/r/duse-io/api?branch=master)
[![Code Climate](https://codeclimate.com/github/duse-io/api/badges/gpa.svg)](https://codeclimate.com/github/duse-io/api)

> This project is still under heavy development, it is not suited for
> production use!

duse api
========

The RESTful api for duse.

Requirements
------------

You will need docker and fig to start the application. On Ubuntu 14.04 you can
easily install docker with:

	sudo apt-get install docker.io

And fig with

	curl -L https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m` > /usr/local/bin/fig; chmod +x /usr/local/bin/fig

Setup
-----

Once you have cloned the repository you can download the dependencies and build
the docker image with

	sudo fig build

Then start the database container

	sudo fig up -d db

Now you can setup the database

	sudo fig run web rake create
	sudo fig run web rake migrate

And initialize the environment

	sudo fig run web rake env

Done! Start the api with the `sudo fig up` command.

API Documentation
-----------------

Check out the interactive [api documentation](http://docs.duseapi.apiary.io/).

