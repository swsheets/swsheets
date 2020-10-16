#!/bin/bash
until PGPASSWORD=password1 psql -h db -U "postgres" -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable: sleeping..."
  sleep 1
done

if [ "${1}" = "setup" ]; then
  echo "Creating database user..."
  PGPASSWORD=password1 psql -h db -U postgres -c "CREATE USER pair with PASSWORD 'password1' CREATEDB;"
  # createuser -h db -U postgres pair -d
  
  echo "Creating and migrating development database..."
  mix do ecto.drop, ecto.create
  PGPASSWORD=password1 psql -h db -U postgres edgebuilder_development -c "CREATE EXTENSION pgcrypto"
  mix do ecto.migrate, seed
elif [ "${1}" = "test" ]; then
  echo "Running tests..."
  MIX_ENV=test mix do ecto.drop, ecto.create
  PGPASSWORD=password1 psql -h db -U postgres edgebuilder_test -c "CREATE EXTENSION pgcrypto"
  MIX_ENV=test mix do ecto.migrate, seed
  mix test "${@:2}"
elif [ ! -z ${1} ]; then
  mix "$@"
else
  echo "Starting Phoenix server..."
  mix phx.server
fi
