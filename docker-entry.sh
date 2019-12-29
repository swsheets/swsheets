#!/bin/sh
echo "Installing dependencies..."
mix deps.get

until psql -h db -U "postgres" -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable: sleeping..."
  sleep 1
done

if [ "${1}" = "setup" ]; then
  echo "Creating database user..."
  createuser -h db -U postgres pair -d
  
  echo "Creating and migrating development database..."
  mix do ecto.drop, ecto.create
  psql -h db -U postgres edgebuilder_development -c "CREATE EXTENSION pgcrypto"
  mix do ecto.migrate, seed
else
  echo "Starting Phoenix server..."
  mix phx.server
fi
