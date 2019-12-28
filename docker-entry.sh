#!/bin/sh
until psql -h db -U "postgres" -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable: sleeping..."
  sleep 1
done

if [ "${1}" = "setup" ]; then
  echo "Creating database user and extensions..."
  createuser -h db -U postgres pair -d
  psql -h db -U postgres edgebuilder_development -c "CREATE EXTENSION pgcrypto"

  echo "Creating and migrating development database..."
  mix do ecto.drop, ecto.create
  mix do ecto.migrate, seed
else
  echo "Installing dependencies..."
  mix deps.get

  echo "Launching Phoenix web server..."
  mix phx.server
fi
