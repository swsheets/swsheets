#!/bin/bash
MIX_ENV=test mix do ecto.drop, ecto.create
psql -h localhost -p 5432 -U pair edgebuilder_test -c "CREATE EXTENSION pgcrypto"
MIX_ENV=test mix do ecto.migrate, seed
MIX_ENV=test mix do compile --warnings-as-errors, coveralls.json
