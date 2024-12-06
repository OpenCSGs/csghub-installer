#!/bin/bash

check_minio() {
  echo "Waiting MinIO ready..."
  until /usr/bin/curl -s http://127.0.0.1:9000/minio/health/live; do
    sleep 2
  done
  echo "MinIO is ready."
}

check_minio

echo "Initialize minio buckets"
export MC_CONFIG_DIR=/tmp
mc alias set myMinio "http://127.0.0.1:9000" "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"
mc mb myMinio/csghub-server
mc mb myMinio/csghub-portal
mc mb myMinio/csghub-registry

IF_EXISTS=$(mc ls myMinio | wc -l)
if [ "$IF_EXISTS" -eq 3 ]; then
    exit 0
else
    exit 1
fi