#!/bin/bash

sudo apt-get update -q -y

su -l vagrant -c "wget -qO- https://raw.githubusercontent.com/flower-pot/desktop-install/master/install.sh | sudo bash -s -- --silent --dotfiles"

sudo apt-get -y --quiet install postgresql libpq-dev postgresql-server-dev-all

su -l vagrant -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
su -l vagrant -c "curl -L https://get.rvm.io | bash -s stable"
su -l vagrant -c "source \"/home/vagrant/.rvm/scripts/rvm\""
su -l vagrant -c "rvm install ruby-2.1.4"
su -l vagrant -c "gem install bundler"

sudo -u postgres psql -U postgres -d postgres -c "CREATE USER duse_api WITH PASSWORD 'password1' CREATEDB;"
sudo -u postgres psql -U postgres -d postgres -c "CREATE DATABASE duse_api_test WITH OWNER duse_api;"
