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
echo "Create buckets..."
for BUCKET in "$STARHUB_SERVER_S3_BUCKET" "$CSGHUB_PORTAL_S3_BUCKET" "$REGISTRY_S3_BUCKET"; do
  if ! mc ls myMinio/"$BUCKET"; then
    mc mb myMinio/"$BUCKET"
    echo "Bucket $BUCKET created."
  else
    echo "Bucket $BUCKET already exits."
  fi
done