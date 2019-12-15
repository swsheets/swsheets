#!/bin/bash
MIX_ENV=test mix do ecto.drop, ecto.create
psql edgebuilder_test -c "CREATE EXTENSION pgcrypto"
MIX_ENV=test mix do ecto.migrate, seed
mix test
