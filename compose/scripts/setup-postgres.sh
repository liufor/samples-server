#!/bin/sh
set -eu

# Use environment variables or fallback to defaults for local PostgreSQL
POSTGRES_HOST=${POSTGRES_HOST:-postgresql}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_USER=${POSTGRES_USER:-temporal}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-temporal}

echo 'Starting PostgreSQL schema setup...'
echo "Using PostgreSQL: ${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}"
echo 'Waiting for PostgreSQL port to be available...'
nc -z -w 10 "$POSTGRES_HOST" "$POSTGRES_PORT"
echo 'PostgreSQL port is available'

# Create and setup temporal database
echo 'Setting up primary temporal database...'
temporal-sql-tool --plugin postgres12 --ep "$POSTGRES_HOST" -u "$POSTGRES_USER" -p "$POSTGRES_PORT" --db temporal create
temporal-sql-tool --plugin postgres12 --ep "$POSTGRES_HOST" -u "$POSTGRES_USER" -p "$POSTGRES_PORT" --db temporal setup-schema -v 0.0
temporal-sql-tool --plugin postgres12 --ep "$POSTGRES_HOST" -u "$POSTGRES_USER" -p "$POSTGRES_PORT" --db temporal update-schema -d /etc/temporal/schema/postgresql/v12/temporal/versioned

# Create and setup visibility database
echo 'Setting up advanced visibility database...'
temporal-sql-tool --plugin postgres12 --ep "$POSTGRES_HOST" -u "$POSTGRES_USER" -p "$POSTGRES_PORT" --db temporal_visibility create
temporal-sql-tool --plugin postgres12 --ep "$POSTGRES_HOST" -u "$POSTGRES_USER" -p "$POSTGRES_PORT" --db temporal_visibility setup-schema -v 0.0
temporal-sql-tool --plugin postgres12 --ep "$POSTGRES_HOST" -u "$POSTGRES_USER" -p "$POSTGRES_PORT" --db temporal_visibility update-schema -d /etc/temporal/schema/postgresql/v12/visibility/versioned

echo 'PostgreSQL schema setup complete'
