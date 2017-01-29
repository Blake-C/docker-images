#!/bin/bash

set -e # terminate on errors

function test_mysql {
  mysqladmin -h "mysql" ping
}

function test_redis {
  redis-cli -h "redis" PING
}

until (test_mysql && test_redis); do
  >&2 echo "Dependencies unavailable - sleeping."
  sleep 3
done

>&2 echo "Dependencies are up - executing command."

exec "$@"