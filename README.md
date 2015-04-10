[![Build Status](https://travis-ci.org/duse-io/api.svg)](https://travis-ci.org/duse-io/api)
[![Coverage Status](https://coveralls.io/repos/duse-io/api/badge.svg?branch=master)](https://coveralls.io/r/duse-io/api?branch=master)
[![Code Climate](https://codeclimate.com/github/duse-io/api/badges/gpa.svg)](https://codeclimate.com/github/duse-io/api)
[![Dependency Status](https://gemnasium.com/duse-io/api.svg)](https://gemnasium.com/duse-io/api)
[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

> This project is still under heavy development, it is not suited for
> production use!

duse api
========

Duse is a cryptographic server client application created to securely share
secrets among signed up users. It is meant to be used for secrets such as
passwords and ssh-keys, but it can very well be used to encrypt and share
anything.

How It Works
------------

Duse uses a combination of algorithms to build its cryptographic protocol.

The following are the high level steps a client has to do to share a secret
with this api.

  * Decide on what to share (password, ssh-key, etc.)
  * Decide who to share with
  * Apply Shamir's Secret Sharing to the secret
  * Encrypt each share with corresponding users public key
  * Sign each of the encrypted shares with the creating users private key
  * post all generated data to the api

However, there are several difficulties that have to be dealt with

  * allowing arbitrary length of secrets
  * allow any utf-8 character
  * maintaining security
  * validation

A supported client implementation is
[duse.rb](https://github.com/duse-io/duse.rb). It is a ruby library which
consumes the duse api and provides a CLI.

API Documentation
-----------------

Check out the interactive [api documentation](http://docs.duseapi.apiary.io/).

Requirements
------------

You will need docker and docker-compose to start the application. On Ubuntu
14.04 you can easily install them with the following commands (run as root)

	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
	sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
	apt-get update
	apt-get install lxc-docker
	curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

Setup
-----

Once you have cloned the repository you can download the dependencies and build
the docker image with

	sudo docker-compose build

Then start the database container

	sudo docker-compose up -d db

Now you can setup the database

	sudo docker-compose run web rake db:create
	sudo docker-compose run web rake db:migrate

And initialize the environment

	sudo docker-compose run web rake env

Done! Start the api with the `sudo docker-compose up` command.

