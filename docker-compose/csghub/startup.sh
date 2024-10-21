#!/bin/bash

log() {
  # Define log levels as constants
  local log_level="$1"
  local message="$2"
  # Define colors
  local green="\033[0;32m"
  local yellow="\033[0;33m"
  local red="\033[0;31m"
  local blue="\033[0;34m"
  local reset="\033[0m"  # Reset to default color
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

  # Print logs with timestamp, log level, and color
  if [ "$log_level" = "ERRO" ]; then
    echo -e "${color}[${timestamp}] [${log_level}] ${color}${message}${reset}"
    return 1
  else
    echo -e "${color}[${timestamp}] [${log_level}] ${message}${reset}"
  fi
}

CURRENT_DIR=$(
  cd "$(dirname "$0")"
  pwd
)

function initialCheck() {
  if [[ "$EUID" -ne 0 && $(uname) != 'Darwin' ]]; then
    log "ERRO" "You need to run this script as root user!"
    exit 1
  fi

  if [ -z "$SERVER_DOMAIN" ]; then
    log "ERRO" "SERVER_DOMAIN environment from .env file is required!"
    exit 1
  fi

  if [ "$KNATIVE_GATEWAY_HOST" != "" ]; then
    log "TIPS" "Tip 1: Please make sure namespace space was created in k8s cluster."
    log "TIPS" "Tip 2: Please make sure the gateway can be accessed in csghub server: telnet ${KNATIVE_GATEWAY_HOST} ${KNATIVE_GATEWAY_PORT}."
  fi

  checkOS
}

function checkOS() {
  arch_info=$(arch)
  if [[ $arch_info != "x86_64" && $arch_info != "amd64" && $arch_info != "aarch64" && $arch_info != "arm64" ]]; then
    log "ERRO" "Current OS architecture is $arch_info, Only x86_64/amd64 or aarch64/arm64 is supported!"
    exit 1
  fi
  if [ $(uname) == 'Darwin' ]; then
    sed() {
      gsed "$@"
    }
  fi
}

nginx_conf=${CURRENT_DIR}/nginx/nginx.conf
casdoor_init_data_conf=${CURRENT_DIR}/casdoor/conf/init_data.json
gitaly_keys_folder=${CURRENT_DIR}/data/gitlab-shell/keys

source ${CURRENT_DIR}/.env

## check for root, OS etc..
initialCheck

set | grep -E "SERVER_DOMAIN=[0-9a-z.]*" >>/dev/null
if [[ $? -ne 0 ]]; then
  log "ERRO" "SERVER_DOMAIN is not set, you should set a valid domain name, such as 121.11.40.42 or demo.opencsg.com etc.."
  exit 1
fi

log "NORM" "The configured domain name is ${SERVER_DOMAIN}."
log "INFO" "1. Rendering nginx and casdoor configuration files."
log "NORM" "1.1 Replace server domain and port in nginx.conf for nginx."
sed -i "s/_CSGHUB_DOMAINNAME/${SERVER_DOMAIN}/g" ${nginx_conf}
sed -i "s/_CSGHUB_DOMAINPORT/${SERVER_PORT}/g" ${nginx_conf}

log "NORM" "1.2 Replace server domain and port in init_data.json for casdoor."
sed -i "s/_CSGHUB_DOMAINNAME/${SERVER_DOMAIN}/g" ${casdoor_init_data_conf}
sed -i "s/_CSGHUB_DOMAINPORT/${SERVER_PORT}/g" ${casdoor_init_data_conf}

if [ "$KNATIVE_GATEWAY_HOST" != "" ]; then
  log "NORM" "1.3 Replace knative gateway host and port in nginx.conf for proxy nginx."
  rproxy_nginx_conf=${CURRENT_DIR}/rproxy_nginx/nginx.conf
  sed -i "s/_CSGHUB_KNATIVE_GATEWAY_HOST/${KNATIVE_GATEWAY_HOST}/g" ${rproxy_nginx_conf}
  sed -i "s/_CSGHUB_KNATIVE_GATEWAY_PORT/${KNATIVE_GATEWAY_PORT}/g" ${rproxy_nginx_conf}
fi

log "INFO" "2. Prepare host key pairs for gitaly and gitlab-shell."
if [[ ! -d "$gitaly_keys_folder" ]]; then
  mkdir -p $gitaly_keys_folder 2>/dev/null
fi

if [[ ! -e "$gitaly_keys_folder/ssh_host_rsa_key" ]]; then
  log "INFO" "2.1 generate RSA host key pair."
  ssh-keygen -t rsa -N "" -f $gitaly_keys_folder/ssh_host_rsa_key
else
  log "WARN" "2.1 ssh_host_rsa_key pair already exists."
fi

if [[ ! -e "$gitaly_keys_folder/ssh_host_ecdsa_key" ]]; then
  log "INFO" "2.2 generate ECDSA host key pair."
  ssh-keygen -t ecdsa -N "" -f $gitaly_keys_folder/ssh_host_ecdsa_key
else
  log "WARN" "2.2 ssh_host_ecdsa_key pair already exists."
fi

if [[ ! -e "$gitaly_keys_folder/ssh_host_ed25519_key" ]]; then
  log "INFO" "2.3 generate ED25519 host key pair."
  ssh-keygen -t ed25519 -N "" -f $gitaly_keys_folder/ssh_host_ed25519_key
else
  log "WARN" "2.3 ssh_host_ed25519_key pair already exists."
fi

log "INFO" "3. Start the service by docker compose."
docker compose -f docker-compose.yml up -d

log "INFO" "Service status:"
docker compose -f docker-compose.yml ps --format "table {{.ID}}\t{{.Name}}\t{{.Status}}\t{{.Ports}}"

log "INFO" "Installation Completed."
log "INFO" "CSGHub service can be visited by URL:"
if [ "${SERVER_PORT}" -eq 80 ]; then
  log "NORM" "\thttp://${SERVER_DOMAIN}"
else
  log "NORM" "\thttp://${SERVER_DOMAIN}:${SERVER_PORT}"
fi
