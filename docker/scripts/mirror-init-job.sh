#!/bin/bash

export PGHOST=${POSTGRES_HOST}
export PGPORT=${POSTGRES_PORT}
export PGUSER=${POSTGRES_SERVER_USER}
export PGPASSWORD=${POSTGRES_SERVER_PASS:-"$POSTGRES_SERVER_USER"}
export PGDATABASE=${POSTGRES_SERVER_DB:-"$POSTGRES_SERVER_USER"}

if [ "$CSGHUB_MIRROR_FIRST_START" == false ]; then
  exit 0
fi

check_postgresql_isready() {
  until pg_isready -q -d $PGDATABASE; do
    sleep 2
  done
}

check_postgresql() {
  check_postgresql_isready

  echo "Waiting PostgreSQL ready..."
  until su - postgres -lc 'psql -t -A -c \\du' | grep -q "${POSTGRES_SERVER_USER}"; do
    sleep 2
  done
  echo "PostgreSQL is ready."
}

check_minio() {
  echo "Waiting MinIO ready..."
  until /usr/bin/curl -s http://${STARHUB_SERVER_S3_ENDPOINT}/minio/health/live; do
    sleep 2
  done
  echo "MinIO is ready."
}

check_server() {
  echo "Waiting CSGHub-Server ready..."
  until /usr/bin/curl -s -o /dev/null http://127.0.0.1:8080/api/v1/tags; do
    sleep 2
  done
  echo "CSGHub-Server is ready."
}

check_postgresql

if [ "$MINIO_ROOT_USER" == "minio" ]; then
  check_minio
fi

check_server

echo "Start multi-source synchronization background and Initialize the sample repository"
exec /usr/bin/csghub-server sync sync-as-client