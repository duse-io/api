#!/bin/bash
set -e

HOST_PORT=`echo $DATABASE_URL | awk -F/ '{print $3}' | awk -F@ '{print $2}'`
HOST=`echo $HOST_PORT | awk -F: '{print $1}'`
PORT=`echo $HOST_PORT | awk -F: '{print $2}'`

if [ -z "${PORT}" ]; then
  PORT='5432'
fi

ping_postgres_successful()
{
  pg_isready --host=$HOST > /dev/null 2>&1
  return $?
}

until ( ping_postgres_successful ); do
  sleep 1s
  echo 'Waiting for postgres to start ...'
done

bundle exec rake db:migrate
bundle exec bundle exec rackup -p 5000 --host 0.0.0.0
