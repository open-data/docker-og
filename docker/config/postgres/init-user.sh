#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER IF NOT EXISTS homestead;
    ALTER USER homestead PASSWORD 'secret';
    CREATE DATABASE IF NOT EXISTS og_d8_local;
    GRANT ALL PRIVILEGES ON DATABASE og_d8_local TO homestead;
EOSQL