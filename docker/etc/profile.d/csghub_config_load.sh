# This is a configuration file used to define various environment variables for the postgresql database.

# Global Server Environments
# export SERVER_DOMAIN=${SERVER_DOMAIN?"error: Environment SERVER_DOMAIN is not set"}
export SERVER_DOMAIN=${SERVER_DOMAIN:-"csghub.example.com"}
export SERVER_PORT=${SERVER_PORT:-"80"}
if [ "$SERVER_PORT" == "80" ] || [ "$SERVER_PORT" == "443" ] ; then
  export SERVER_ENDPOINT=${SERVER_ENDPOINT:-"http://$SERVER_DOMAIN"}
else
  export SERVER_ENDPOINT=${SERVER_ENDPOINT:-"http://$SERVER_DOMAIN:$SERVER_PORT"}
fi
export SERVER_API_TOKEN=${SERVER_API_TOKEN:-37a8eec1ce19687d132fe29051dca629d164e2c4958ba141d5f4133a33f0688f4f71deadef7db1880384df3edbfa7c54bc6bee0d9e91bcf4ecf5e894a3734591}
export SERVER_JWT_SIGNING_KEY=${SERVER_JWT_SIGNING_KEY:-e2kk6awudc3620ed9a}

# PostgreSQL Environments
export POSTGRES_HOST=${POSTGRES_HOST:-127.0.0.1}
export POSTGRES_PORT=${POSTGRES_PORT:-5432}
export POSTGRES_SERVER_USER=${POSTGRES_SERVER_USER:-csghub_server}
export POSTGRES_PORTAL_USER=${POSTGRES_PORTAL_USER:-csghub_portal}
export POSTGRES_CASDOOR_USER=${POSTGRES_CASDOOR_USER:-casdoor}
export POSTGRES_TEMPORAL_USER=${POSTGRES_TEMPORAL_USER:-temporal}

# Redis Environments
export REDIS_ENDPOINT=${REDIS_ENDPOINT:-"127.0.0.1:6379"}

# Minio Environments
export MINIO_ROOT_USER="minio"
export MINIO_ROOT_PASSWORD="Minio@2024"
export MINIO_REGION_NAME="cn-north-1"

# Registry Environments
export REGISTRY_ADDRESS=${REGISTRY_ADDRESS:-"$SERVER_DOMAIN:5000"}
export REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE:-csghub}
export REGISTRY_USERNAME=${REGISTRY_USERNAME:-registry}
export REGISTRY_PASSWORD=${REGISTRY_PASSWORD:-registry}
export REGISTRY_S3_ENDPOINT=${S3_ENDPOINT:-"http://127.0.0.1:9000"}
export REGISTRY_S3_ACCESS_KEY=${S3_ACCESS_KEY:-"$MINIO_ROOT_USER"}
export REGISTRY_S3_ACCESS_SECRET=${S3_ACCESS_SECRET:-"$MINIO_ROOT_PASSWORD"}
export REGISTRY_S3_REGION=${S3_REGION:-"$MINIO_REGION_NAME"}
export REGISTRY_S3_BUCKET=${S3_REGISTRY_BUCKET:-csghub-registry}

# Gitaly Environments
export GITALY_TOKEN="YWJjMTIzc2VjcmV0"

# GitLab-Shell Environments
export GITLAB_SHELL_SSH_PORT=${GITLAB_SHELL_SSH_PORT:-2222}

# Space Builder Environments

# Knative Serving and Space Application
export SPACE_APP_NS=${SPACE_APP_NS:-space}
export SPACE_APP_DOMAIN=${SPACE_APP_DOMAIN:-app.internal}
export SPACE_APP_HOST=${SPACE_APP_HOST:-127.0.0.1}
export SPACE_APP_PORT=${SPACE_APP_PORT:-80}
export SPACE_DATA_PATH=${SPACE_DATA_PATH:-/var/opt/space-builder}
export SPACE_SESSION_SECRET_KEY=${SPACE_SESSION_SECRET_KEY:-c8f771f2a178089b99172cbbd7e3b01d}

# Runner Environments
export STARHUB_SERVER_DOCKER_REG_BASE="${REGISTRY_ADDRESS}/${REGISTRY_NAMESPACE}/"
export STARHUB_SERVER_DOCKER_IMAGE_PULL_SECRET="${REGISTRY_SECRET:-csghub-docker-config}"
export STARHUB_SERVER_ARGO_S3_PUBLIC_BUCKET=${S3_PORTAL_BUCKET:-csghub-portal}

# Casdoor Environments
export CASDOOR_PORT=${CASDOOR_PORT:-"8000"}
export CASDOOR_CLIENT_ID=${CASDOOR_CLIENT_ID:-"7a97bc5168cb75ffc514"}
export CASDOOR_CLIENT_SECRET=${CASDOOR_CLIENT_SECRET:-"33bd85106818efd90c57fb35ffc787aabbff6f7a"}
export CASDOOR_ENDPOINT=${CASDOOR_ENDPOINT:-"http://$SERVER_DOMAIN:$CASDOOR_PORT"}
export CASDOOR_CERTIFICATE="/etc/casdoor/token_jwt_key.pem"

# Accounting Configuration
export OPENCSG_ACCOUNTING_FEE_EVENT_SUBJECT="accounting.fee.>"
export OPENCSG_ACCOUNTING_NOTIFY_NOBALANCE_SUBJECT="accounting.notify.nobalance"
export OPENCSG_ACCOUNTING_MSG_FETCH_TIMEOUTINSEC=5
export OPENCSG_ACCOUNTING_CHARGING_ENABLE=true

# Nats Configuration
export NATS_USERNAME="natsadmin"
export NATS_PASSWORD="gALqqbP6SpftVdFzrU2URJ8k1Gn"

# Server Environments
## PostgreSQL Configuration
export STARHUB_DATABASE_DSN="postgresql://${POSTGRES_SERVER_USER}:${POSTGRES_SERVER_PASS:-"$POSTGRES_SERVER_USER"}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_SERVER_DB:-"$POSTGRES_SERVER_USER"}?sslmode=disable"
export STARHUB_DATABASE_TIMEZONE=${POSTGRES_DATABASE_TIMEZONE:-"UTC"}
## Redis Configuration
export STARHUB_SERVER_REDIS_ENDPOINT=${REDIS_ENDPOINT:-"127.0.0.1:6379"}
## Gitaly Configuration
export STARHUB_SERVER_GITSERVER_TYPE=gitaly
export STARHUB_SERVER_GITALY_SERVER_SOCKET=${GITALY_SERVER_SOCKET:-"tcp://127.0.0.1:8075"}
export STARHUB_SERVER_GITALY_STORAGE="default"
export STARHUB_SERVER_GITALY_TOKEN=${GITALY_TOKEN}
## Gitlab Shell Configuration
export STARHUB_SERVER_SSH_DOMAIN="ssh://git@${SERVER_DOMAIN}:${GITLAB_SHELL_SSH_PORT}"
## Objects Storage Configuration
export STARHUB_SERVER_S3_ACCESS_KEY_ID=${S3_ACCESS_KEY:-"$MINIO_ROOT_USER"}
export STARHUB_SERVER_S3_ACCESS_KEY_SECRET=${S3_ACCESS_SECRET:-"$MINIO_ROOT_PASSWORD"}
export STARHUB_SERVER_S3_ENDPOINT=${S3_ENDPOINT:-"127.0.0.1:9000"}
export STARHUB_SERVER_S3_INTERNAL_ENDPOINT=${S3_ENDPOINT}
export STARHUB_SERVER_S3_BUCKET=${S3_SERVER_BUCKET:-csghub-server}
export STARHUB_SERVER_S3_REGION=${S3_REGION:-"$MINIO_REGION_NAME"}
export STARHUB_SERVER_S3_ENABLE_SSL=${S3_ENABLE_SSL:-false}
## Space Builder Configuration
export SPACE_BUILDER_PORT=${SPACE_BUILDER_PORT:-"8089"}
export STARHUB_SERVER_SPACE_BUILDER_ENDPOINT=${SPACE_BUILDER_ENDPOINT:-"http://127.0.0.1:$SPACE_BUILDER_PORT"}
export STARHUB_SERVER_SPACE_RUNNER_ENDPOINT=${RUNNER_ENDPOINT:-"http://127.0.0.1:8082"}
export STARHUB_SERVER_PUBLIC_ROOT_DOMAIN=""
export STARHUB_SERVER_INTERNAL_ROOT_DOMAIN=${SPACE_APP_NS}.${SPACE_APP_DOMAIN}:${SPACE_APP_PORT}
export STARHUB_SERVER_MODEL_DOWNLOAD_ENDPOINT=${SERVER_ENDPOINT}
export STARHUB_SERVER_PUBLIC_DOMAIN=${SERVER_ENDPOINT}
## Casdoor Configuration
export STARHUB_SERVER_CASDOOR_CLIENT_ID=${CASDOOR_CLIENT_ID}
export STARHUB_SERVER_CASDOOR_CLIENT_SECRET=${CASDOOR_CLIENT_SECRET}
export STARHUB_SERVER_CASDOOR_ENDPOINT=${CASDOOR_ENDPOINT}
export STARHUB_SERVER_CASDOOR_CERTIFICATE=${CASDOOR_CERTIFICATE}
export STARHUB_SERVER_CASDOOR_ORGANIZATION_NAME=${CASDOOR_ORGANIZATION_NAME:-OpenCSG}
export STARHUB_SERVER_CASDOOR_APPLICATION_NAME=${CASDOOR_APPLICATION_NAME:-CSGHub}
## Accounting Configuration
export OPENCSG_ACCOUNTING_NATS_URL="nats://$NATS_USERNAME:$NATS_PASSWORD@127.0.0.1:4222"
export OPENCSG_ACCOUNTING_SERVER_HOST="http://127.0.0.1"
export OPENCSG_ACCOUNTING_SERVER_PORT=8086
## User Configuration
export OPENCSG_USER_SERVER_HOST="http://127.0.0.1"
export OPENCSG_USER_SERVER_PORT=8088
export OPENCSG_USER_SERVER_SIGNIN_SUCCESS_REDIRECT_URL="${SERVER_ENDPOINT}/server/callback"
## Temporal Configuration
export OPENCSG_WORKFLOW_SERVER_ENDPOINT=${TEMPORAL_ADDRESS}
## Other Configuration
export STARHUB_SERVER_API_TOKEN=${SERVER_API_TOKEN}
export STARHUB_JWT_SIGNING_KEY=${SERVER_JWT_SIGNING_KEY}
export STARHUB_SERVER_MIRRORSERVER_ENABLE=${STARHUB_SERVER_MIRRORSERVER_ENABLE:-false}
export STARHUB_SERVER_MULTI_SYNC_ENABLED=${STARHUB_SERVER_MULTI_SYNC_ENABLED:-true}
export STARHUB_SERVER_SAAS=false
export CSGHUB_MIRROR_FIRST_START=${CSGHUB_MIRROR_FIRST_START:-true}

# Proxy Environments
export STARHUB_SERVER_SPACE_SESSION_SECRET_KEY=$SPACE_SESSION_SECRET_KEY

# Portal Environments
export CSGHUB_PORTAL_ON_PREMISE=${CSGHUB_PORTAL_ON_PREMISE:-true}
export CSGHUB_PORTAL_SENSITIVE_CHECK=${CSGHUB_PORTAL_SENSITIVE_CHECK:-false}
export CSGHUB_PORTAL_ENABLE_HTTPS=${CSGHUB_PORTAL_ENABLE_HTTPS:-false}
export CSGHUB_PORTAL_STARHUB_BASE_URL=${SERVER_ENDPOINT}
export CSGHUB_PORTAL_STARHUB_API_KEY=${SERVER_API_TOKEN}
export CSGHUB_PORTAL_DATABASE_DSN="postgresql://${POSTGRES_PORTAL_USER}:${POSTGRES_PORTAL_PASS:-"$POSTGRES_PORTAL_USER"}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_PORTAL_DB:-"$POSTGRES_PORTAL_USER"}?sslmode=disable"
export CSGHUB_PORTAL_LOGIN_URL="${CASDOOR_ENDPOINT}/login/oauth/authorize?client_id=${CASDOOR_CLIENT_ID}&response_type=code&redirect_uri=${SERVER_ENDPOINT}/api/v1/callback/casdoor&scope=read&state=casdoor"
export CSGHUB_PORTAL_S3_ENABLE_SSL=${S3_ENABLE_SSL:-false}
export CSGHUB_PORTAL_S3_REGION=${S3_REGION:-"$MINIO_REGION_NAME"}
export CSGHUB_PORTAL_S3_ACCESS_KEY_ID=${S3_ACCESS_KEY:-"$MINIO_ROOT_USER"}
export CSGHUB_PORTAL_S3_ACCESS_KEY_SECRET=${S3_ACCESS_SECRET:-"$MINIO_ROOT_PASSWORD"}
export CSGHUB_PORTAL_S3_BUCKET=${S3_PORTAL_BUCKET:-csghub-portal}
export CSGHUB_PORTAL_S3_ENDPOINT=${S3_ENDPOINT:-"$SERVER_DOMAIN:9000"}

# Knative Serving Environments
export KNATIVE_SERVING_ENABLE=${KNATIVE_SERVING_ENABLE:-false}
export KNATIVE_KOURIER_TYPE=${KNATIVE_KOURIER_TYPE:-NodePort}

# NVIDIA device plugin Environments
export NVIDIA_DEVICE_PLUGIN=${NVIDIA_DEVICE_PLUGIN:-false}

# Docker Environments
export DOCKER_HOST=unix:///var/run/docker.sock

# Temporal Environments
export TEMPORAL_ADDRESS=${TEMPORAL_ADDRESS:-"127.0.0.1:7233"}
export TEMPORAL_UI=${TEMPORAL_UI:-true}
export TEMPORAL_UI_PUBLIC_PATH="/temporal-ui"
export TEMPORAL_UI_PORT=8180
export TEMPORAL_CORS_ORIGINS="http://localhost:3000"
export TEMPORAL_HOME="/etc/temporal"
export TEMPORAL_USER=${TEMPORAL_USER:-admin}
export TEMPORAL_PASS=${TEMPORAL_PASS:-"Admin@1234"}
export DB=${DB:-postgres12}
export POSTGRES_SEEDS=${POSTGRES_HOST}
export DB_PORT=${POSTGRES_PORT}
export POSTGRES_USER=${POSTGRES_USER:-temporal}
export POSTGRES_PWD=${POSTGRES_PWD:-temporal}
export DEFAULT_NAMESPACE_RETENTION=${DEFAULT_NAMESPACE_RETENTION:-"7d"}

# Kubernetes
CSGHUB_WITH_K8S=${CSGHUB_WITH_K8S:-1}