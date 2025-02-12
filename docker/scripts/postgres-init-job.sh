#!/bin/bash

set -e

check_postgresql() {
  echo "Waiting PostgreSQL ready..."
  until pg_isready; do
    sleep 2
  done
  echo "PostgreSQL is ready."
}

create_user() {
  local USER=$1
  local PASS=$USER
  local DB=$USER

  if [ -z "$USER" ]; then
    echo "Error: No username provided."
    return 1
  fi

  echo "Checking if user $USER exists..."
  IF_USER_EXISTS=$(/usr/bin/psql -A -t -c "SELECT count(1) FROM pg_roles WHERE rolname = '$USER'")
  if [ "$IF_USER_EXISTS" -eq 0 ]; then
    echo "Creating user $USER..."
    /usr/bin/psql -c "CREATE USER \"${USER}\" WITH ENCRYPTED PASSWORD '${PASS}';"
  else
    echo "User $USER already exists."
  fi

  echo "Checking if database $DB exists..."
  IF_DB_EXISTS=$(/usr/bin/psql -A -t -c "SELECT count(1) FROM pg_database WHERE datname = '$DB'")
  if [ "$IF_DB_EXISTS" -eq 0 ]; then
    echo "Creating database $DB..."
    /usr/bin/psql -c "CREATE DATABASE \"${DB}\" ENCODING 'UTF-8' OWNER \"${USER}\";"
  else
    echo "Database $DB already exists."
  fi

  echo "Granting privileges on database $DB to user $USER..."
  /usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE \"${DB}\" TO \"${USER}\";"
}

promote_user() {
  local USER=$1
  if [ -z "$USER" ]; then
    echo "Error: No username provided for promotion."
    return 1
  fi

  echo "Promoting user $USER to SUPERUSER..."
  /usr/bin/psql -c "ALTER USER \"${USER}\" SUPERUSER;"
}

check_postgresql

echo "Initializing PostgreSQL databases..."
for USER in "$POSTGRES_SERVER_USER" "$POSTGRES_PORTAL_USER" "$POSTGRES_CASDOOR_USER" "$POSTGRES_TEMPORAL_USER"; do
  create_user "$USER"
done

echo "Promote users with SUPERUSER..."
for USER in "$POSTGRES_SERVER_USER" "$POSTGRES_TEMPORAL_USER"; do
  promote_user "$USER"
done
