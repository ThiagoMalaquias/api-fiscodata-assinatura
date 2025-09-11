#!/bin/bash
set -e

rm -f tmp/pids/server.pid

if [ -z "$SKIP_DB_PREPARE" ]; then
  echo "==> Running db:prepare"
  bundle exec rails db:prepare
else
  echo "==> Skipping db:prepare"
fi

exec "$@"
