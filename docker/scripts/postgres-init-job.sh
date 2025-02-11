#!/bin/bash

check_postgresql() {
  echo "Waiting PostgreSQL ready..."
  until pg_isready; do
    sleep 2
  done
  echo "PostgreSQL is ready."
}

create_user() {
  if [ -z "$1" ]; then
    return 1
  fi

  USER=$1
  PASS=$1
  DB=$1
  /usr/bin/psql -c "CREATE USER ${USER} WITH ENCRYPTED PASSWORD '${PASS}';"
  /usr/bin/psql -c "CREATE DATABASE ${DB} OWNER ${USER};"
  /usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE ${DB} TO ${USER};"
}

promote_user() {
  if [ -z "$1" ]; then
    return 1
  fi

  USER=$1
  /usr/bin/psql -c "ALTER USER ${USER} SUPERUSER;"
}

check_postgresql

echo "Initialize postgres databases"
create_user "csghub_server"
create_user "csghub_portal"
create_user "csghub_casdoor"
create_user "csghub_temporal"
promote_user "csghub_server"
promote_user "csghub_temporal"

IF_EXISTS=$(/usr/bin/psql -t -A -l | egrep 'csghub|casdoor' | wc -l)
if [ "$IF_EXISTS" -eq 6 ]; then
    exit 0
else
    exit 1
fi
