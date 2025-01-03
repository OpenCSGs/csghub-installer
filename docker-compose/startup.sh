#!/bin/bash

set -eu

log() {
  # Define log levels as constants
  local log_level="$1"
  local message="$2"
  # Define colors
  local green="\033[0;32m"
  local yellow="\033[0;33m"
  local red="\033[0;31m"
  local blue="\033[0;34m"
  local reset="\033[0m"
  # Get the current timestamp
  local timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

  # Set color based on log level
  case "$log_level" in
    INFO)
      local color=$green
      ;;
    WARN)
      local color=$yellow
      ;;
    ERRO)
      local color=$red
      ;;
    TIPS)
      local color=$blue
       ;;
    *)
      local color=$reset  # Default color if log level is unknown
      ;;
  esac

retry() {
  local n=1
  local max=5
  local delay=10
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        log "WARN" "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        log "ERRO" "The command has failed after $n attempts."
        return 1
      fi
    }
  done
}

  # Print logs with timestamp, log level, and color
  if [ "$log_level" = "ERRO" ]; then
    echo -e "${color}[${timestamp}] [${log_level}] ${color}${message}${reset}"
    return 1
  else
    echo -e "${color}[${timestamp}] [${log_level}] ${message}${reset}"
  fi
}

CURRENT_DIR=$(
  cd "$(dirname "$0")" && pwd
)
source ${CURRENT_DIR}/.env

function initial_check() {
  if [[ "$EUID" -ne 0 && $(uname) != 'Darwin' ]]; then
    log "ERRO" "You need to run this script as root user!"
    exit 1
  fi

  if [ -z "$SERVER_DOMAIN" ]; then
    log "ERRO" "SERVER_DOMAIN environment from .env file is required!"
    exit 1
  fi

  if [ "$SPACE_APP_INTERNAL_HOST" != "" ]; then
    log "WARN" "Tip 1: Please make sure namespace space was created in k8s cluster."
    log "WARN" "Tip 2: Please make sure the gateway can be accessed in csghub server: telnet ${SPACE_APP_INTERNAL_HOST} ${SPACE_APP_INTERNAL_PORT}."
  fi

  check_arch
}

function check_arch() {
  arch_info=$(arch)
  if [[ $arch_info != "x86_64" && $arch_info != "amd64" && $arch_info != "aarch64" && $arch_info != "arm64" ]]; then
    log "ERRO" "Current OS architecture is $arch_info, Only x86_64/amd64 or aarch64/arm64 is supported!"
    exit 1
  fi
  if [ $(uname) == 'Darwin' ]; then
    if which gsed >/dev/null 2>&1; then
      sed() {
        gsed "$@"
      }
    else
      echo "Command gsed not found"
      exit 1
    fi
  fi
}

function mkdirs() {
  DIR="$1"
  if [[ ! -d "$DIR" ]]; then
    mkdir -p "$DIR" 2>/dev/null || true
  fi
}

## check for root, OS etc..
initial_check

set | grep -E "SERVER_DOMAIN=[0-9a-z.]*" >>/dev/null
if [[ "$?" -ne 0 ]]; then
  log "ERRO" "SERVER_DOMAIN is not set, you should set a valid domain name, such as 121.11.40.42 or demo.opencsg.com etc.."
  exit 1
fi

log "NORM" "Current configured domain name is ${SERVER_DOMAIN}."
####################################################################################
# Configure Nginx Main
####################################################################################
log "NORM" "Nginx Main:"
NGINX_CONF_DIR="${CURRENT_DIR}/configs/nginx"

log "INFO" "- render nginx configuration file."
sed "s/_SERVER_DOMAIN/${SERVER_DOMAIN}/g;s/_SERVER_PORT/${SERVER_PORT}/g" "$NGINX_CONF_DIR"/nginx.conf.sample > "$NGINX_CONF_DIR"/nginx.conf

log "INFO" "- generate temporal auth file."
docker run --rm --entrypoint htpasswd httpd -Bbn "$TEMPORAL_CONSOLE_USER" "$TEMPORAL_CONSOLE_PASSWORD" > "$NGINX_CONF_DIR"/.htpasswd

####################################################################################
# Configure CoreDNS
####################################################################################
log "NORM" "CoreDNS:"
COREDNS_CONF_DIR="${CURRENT_DIR}/configs/coredns"

log "INFO" "- render coredns Corefile."
sed -e "s/_SPACE_APP_NAMESPACE/${SPACE_APP_NAMESPACE}/g" \
    -e "s/_SPACE_APP_INTERNAL_DOMAIN/${SPACE_APP_INTERNAL_DOMAIN}/g" \
    -e "s/_SPACE_APP_NAMESPACE/${SPACE_APP_NAMESPACE}/g" \
    -e "s/_SPACE_APP_INTERNAL_DOMAIN/${SPACE_APP_INTERNAL_DOMAIN}/g" \
    "$COREDNS_CONF_DIR"/Corefile.sample > "$COREDNS_CONF_DIR"/Corefile

log "INFO" "- generate CoreDNS reverse parsing files."
cat <<EOF > "${COREDNS_CONF_DIR}/${SPACE_APP_NAMESPACE}.${SPACE_APP_INTERNAL_DOMAIN}"
\$ORIGIN ${SPACE_APP_NAMESPACE}.${SPACE_APP_INTERNAL_DOMAIN}.
@ 3600 IN SOA ns1.${SPACE_APP_NAMESPACE}.${SPACE_APP_INTERNAL_DOMAIN}. admin.${SPACE_APP_NAMESPACE}.${SPACE_APP_INTERNAL_DOMAIN}. (
        2022042401 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400      ; Minimum TTL
)

*   3600 IN A  192.171.100.112
EOF

####################################################################################
# Configure Registry
####################################################################################
log "NORM" "Registry:"
REGISTRY_CONF_DIR="${CURRENT_DIR}/configs/registry"

log "INFO" "- create config directories."
mkdirs "$REGISTRY_CONF_DIR"/auth

log "INFO" "- generate registry auth file."
docker run --rm --entrypoint htpasswd httpd -Bbn "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD" > "$REGISTRY_CONF_DIR"/auth/.htpasswd

####################################################################################
# Configure Gitaly
####################################################################################
log "NORM" "Gitaly:"
GITALY_CONF_DIR="${CURRENT_DIR}/configs/gitaly"

log "INFO" "- render configuration file."
sed "s/_GITALY_AUTH_TOKEN/${GITALY_AUTH_TOKEN}/g" "$GITALY_CONF_DIR"/config.toml.sample > "$GITALY_CONF_DIR"/config.toml

####################################################################################
# Configure Gitlab-Shell
####################################################################################
log "NORM" "Gitlab-Shell:"
GITLAB_SHELL_CONF_DIR="${CURRENT_DIR}/configs/gitlab-shell"

log "INFO" "- generate gitaly auth file."
echo "$GITALY_AUTH_TOKEN" > "$GITLAB_SHELL_CONF_DIR"/.gitlab_shell_secret

log "INFO" "- generate host key pairs for gitlab-shell."
GITLAB_SHELL_DATA_DIR="${CURRENT_DIR}/data/gitlab-shell/keys"
mkdirs "$GITLAB_SHELL_DATA_DIR"

generate_ssh_key() {
    local key_type=$1
    local key_file="$GITLAB_SHELL_DATA_DIR/ssh_host_${key_type}_key"

    if [[ ! -d "$GITLAB_SHELL_DATA_DIR" ]]; then
        mkdir -p "$GITLAB_SHELL_DATA_DIR" 2>/dev/null
    fi

    if [[ ! -e "$key_file" ]]; then
        log "INFO" "- generating ${key_type} host key pair."
        ssh-keygen -t "$key_type" -N "" -f "$key_file"
    else
        log "WARN" "- ssh_host_${key_type}_key pair already exists."
    fi
}

generate_ssh_key "rsa"
generate_ssh_key "ecdsa"
generate_ssh_key "ed25519"
####################################################################################
# Configure Csghub_Space_Builder
####################################################################################
log "NORM" "Csghub_Space_Builder:"
CSGHUB_SPACE_BUILDER_CONF_DIR="${CURRENT_DIR}/configs/docker"

log "INFO" "- render docker daemon file."
sed -e "s/_SERVER_DOMAIN/${SERVER_DOMAIN}/g" \
    -e "s/_REGISTRY_PORT/${REGISTRY_PORT}/g" \
    "$CSGHUB_SPACE_BUILDER_CONF_DIR"/daemon.json.sample > "$CSGHUB_SPACE_BUILDER_CONF_DIR"/daemon.json

log "INFO" "- render docker config file."
REGISTRY_USER_PASSWORD_BASE64=$(echo -n "${REGISTRY_USERNAME}:${REGISTRY_PASSWORD}" | base64)
sed -e "s/_REGISTRY_USERNAME/${REGISTRY_USERNAME}/g" \
    -e "s/_REGISTRY_PASSWORD/${REGISTRY_PASSWORD}/g" \
    -e "s/_REGISTRY_ADDRESS/${REGISTRY_ADDRESS}/g" \
    -e "s/_REGISTRY_USER_PASSWORD_BASE64/${REGISTRY_USER_PASSWORD_BASE64}/g" \
    "$CSGHUB_SPACE_BUILDER_CONF_DIR"/config.json.sample > "$CSGHUB_SPACE_BUILDER_CONF_DIR"/config.json

####################################################################################
# Configure Nats
####################################################################################
log "NORM" "Nats:"
NATS_CONF_DIR="${CURRENT_DIR}/configs/nats"

log "INFO" "- render nats config file."
NATS_ROOT_PASSWORD_HTPASSWD=$(docker run --rm --entrypoint htpasswd httpd -Bbn "$NATS_ROOT_USER" "$NATS_ROOT_PASSWORD" | cut -d ':' -f 2)
sed -e "s/_NATS_ROOT_USER/${NATS_ROOT_USER}/g" \
    -e "s|_NATS_ROOT_PASSWORD_HTPASSWD|${NATS_ROOT_PASSWORD_HTPASSWD}|g" \
    "$NATS_CONF_DIR"/nats-server.conf.sample > "$NATS_CONF_DIR"/nats-server.conf

####################################################################################
# Configure Casdoor
####################################################################################
log "NORM" "Casdoor:"
CASDOOR_CONF_DIR="${CURRENT_DIR}/configs/casdoor/conf"

log "INFO" "- render casdoor init_data file."
sed -e "s/_SERVER_DOMAIN/${SERVER_DOMAIN}/g" \
    -e "s/_SERVER_PORT/${SERVER_PORT}/g" \
   "$CASDOOR_CONF_DIR"/init_data.json.sample > "$CASDOOR_CONF_DIR"/init_data.json

log "INFO" "- render casdoor config file."
sed -e "s/_POSTGRES_USER/${POSTGRES_USER}/g" \
    -e "s/_POSTGRES_PASSWORD/${POSTGRES_PASSWORD}/g" \
    -e "s/_POSTGRES_HOST/${POSTGRES_HOST}/g" \
    -e "s/_POSTGRES_PORT/${POSTGRES_PORT}/g" \
    "$CASDOOR_CONF_DIR"/app.conf.sample > "$CASDOOR_CONF_DIR"/app.conf

####################################################################################
# Configure Csghub Proxy Nginx
####################################################################################
log "NORM" "Csghub_Proxy_Nginx:"
PROXY_NGINX_CONF_DIR="${CURRENT_DIR}/configs/proxy_nginx"

log "INFO" "- render proxy nginx config file."
sed -e "s/_SPACE_APP_INTERNAL_HOST/${SPACE_APP_INTERNAL_HOST}/g" \
    -e "s/_SPACE_APP_INTERNAL_PORT/${SPACE_APP_INTERNAL_PORT}/g" \
    -e "s/_SPACE_APP_NAMESPACE/${SPACE_APP_NAMESPACE}/g" \
    -e "s/_SPACE_APP_INTERNAL_DOMAIN/${SPACE_APP_INTERNAL_DOMAIN}/g" \
    "$PROXY_NGINX_CONF_DIR"/nginx.conf.sample > "$PROXY_NGINX_CONF_DIR"/nginx.conf

####################################################################################
# Configure Csghub Runner Docker Config
####################################################################################
if [ -f "$KUBE_CONFIG_DIR/config" ]; then
  EXISTS=$(docker run --rm -v "$KUBE_CONFIG_DIR"/config:/.kube/config bitnami/kubectl:latest get secret -n "$SPACE_APP_NAMESPACE" | grep -c csghub-docker-config)
  if [ "$EXISTS" -eq 1 ]; then
    docker run --rm -v "$KUBE_CONFIG_DIR"/config:/.kube/config bitnami/kubectl:latest \
        delete secret csghub-docker-config \
        --namespace="$SPACE_APP_NAMESPACE"
  fi

  docker run --rm -v "$KUBE_CONFIG_DIR"/config:/.kube/config bitnami/kubectl:latest \
      create secret docker-registry csghub-docker-config \
      --docker-server="$REGISTRY_ADDRESS" \
      --docker-username="$REGISTRY_USERNAME" \
      --docker-password="$REGISTRY_PASSWORD" \
      --namespace="$SPACE_APP_NAMESPACE"
fi

set +e
log "NORM" "Starting services..."
retry docker compose -f docker-compose.yml up -d

log "NORM" "Installation Completed."
log "INFO" "CSGHub service can be visited by URL:"
if [ "${SERVER_PORT}" -eq 80 ]; then
  log "INFO" "\thttp://${SERVER_DOMAIN}"
else
  log "INFO" "\thttp://${SERVER_DOMAIN}:${SERVER_PORT}"
fi

docker compose -f docker-compose.yml ps --format "table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.Ports}}"
