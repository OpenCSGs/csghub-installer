#!/usr/bin/env bash

# Usage
if [ $# -ne 1 ]; then
    echo "$0 <domain>"
    echo "  eg: $0 example.com"
    exit 1
fi

DOMAIN="$1"
# Get local ip address
default_interface=$(ip route show default | awk '/default/ {print $5}')
IP_ADDRESS=$(ip addr show $default_interface | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

# Only root privileges accepted
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with root privileges"
  exit 1
fi

# Format log output
log() {
  # Define log levels as constants
  local log_level=$1
  local message=$2
  # Define colors
  local green="\033[0;32m"
  local yellow="\033[0;33m"
  local red="\033[0;31m"
  local reset="\033[0m"  # Reset to default color
  # Get the current timestamp
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

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

# Function to retry a command up to a specified number of times if it fails
retry() {
  local n=1
  local max=5
  local delay=5
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

# Detect operating system and architecture
OS=""
ARCH=$(uname -m)

if [ "${ARCH}" = "x86_64" ]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case $ID in
      ubuntu)
        OS="ubuntu"
        log "INFO" "Installing dependencies for Ubuntu..."
        apt update &>/dev/null && apt install -y curl wget unzip jq &>/dev/null
        ;;
      centos)
        OS="centos"
        log "INFO" "Installing dependencies for Centos..."
        yum install -y curl wget unzip jq &>/dev/null
        ;;
      *)
        log "ERROR" "Unsupported Linux distribution."
        exit 1
        ;;
    esac
  else
    log "ERROR" "Cannot determine the operating system."
    exit 1
  fi
else
  log "ERROR" "Unsupported architecture. This script supports only x86_64."
  exit 1
fi
log "INFO" "Detected OS: ${OS} on ${ARCH} architecture."

# For demonstration, let's retry the K3S installation with the retry function
log "INFO" "Create mirror registry files."
mkdir -p /etc/rancher/k3s &>/dev/null && chmod -R 0755 /etc/rancher/k3s
cat <<EOF > /etc/rancher/k3s/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://opencsg-registry.cn-beijing.cr.aliyuncs.com"
    rewrite:
      "^rancher/(.*)": "opencsg_public/rancher/\$1"
EOF

log  "INFO"  "Installing K3S..."
retry curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.30.4+k3s1 sh -

# Check if the K3S installation was successful
if [ $? -ne 0 ]; then
  log "ERRO" "K3S installation failed."
  exit 1
else
  log "INFO" "K3S installed successfully."
fi

# Function to check if K3S cluster is up and running
check_k3s_cluster() {
  local max_attempts=10
  local attempt=1
  local delay=10

  log "INFO" "Checking if K3S cluster is up and running..."

  while [ $attempt -le $max_attempts ]; do
    local READY=$(kubectl get nodes | grep -E 'Ready' | wc -l)
    local NOT_RUNNING=$(kubectl get pods -n kube-system | grep -v -E 'Running|Completed|STATUS' | wc -l)
    if [ $READY -eq 1 ] && [ $NOT_RUNNING -eq 0 ]; then
      log "INFO" "K3S cluster is up and running."
      return 0
    else
      log "WARN" "K3S cluster is not ready yet. Attempt ${attempt}/${max_attempts}."
      sleep $delay
    fi
    ((attempt++))
  done

  log "ERRO" "K3S cluster is not up after ${max_attempts} attempts."
  return 1
}

# Invoke the check_k3s_cluster function to verify the cluster status
check_k3s_cluster
if [ $? -ne 0 ]; then
  log "ERRO" "Failed to verify K3S cluster status."
  exit 1
fi

# Copy the kube config file to the user's home directory
log  "INFO" "Copying kube config file to the user's home directory."
mkdir ~/.kube &>/dev/null
cp -f /etc/rancher/k3s/k3s.yaml ~/.kube/config && chmod 0400 ~/.kube/config
sed -i "s/127.0.0.1/${IP_ADDRESS}/g" ~/.kube/config

# Install Helm3
log  "INFO"  "Installing Helm3..."
if helm version &> /dev/null; then
  log "INFO" "Helm installation verified successfully."
else
  retry curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod +x get_helm.sh && ./get_helm.sh
  log "ERRO" "Helm installation verification failed."
  exit 1
fi

## Install sig-storage-local-static-provisioner
#set -euo pipefail
#log "INFO" "Installing sig-storage-local-static-provisioner..."
#cat <<EOF | kubectl apply -f -
#apiVersion: storage.k8s.io/v1
#kind: StorageClass
#metadata:
#  name: fast-disks
#  annotations:
#    storageclass.kubernetes.io/is-default-class: "true"
#provisioner: kubernetes.io/no-provisioner
#volumeBindingMode: WaitForFirstConsumer
#reclaimPolicy: Delete
#allowVolumeExpansion: true
#EOF
#
#if [ $? -ne 0 ]; then
#    log "ERRO" "Failed to create storageClass."
#fi
#
#if ! kubectl get ns local-path-storage &>/dev/null; then
#  retry kubectl create namespace local-path-storage 2>/dev/null
#fi
#retry helm repo add sig-storage-local-static-provisioner https://kubernetes-sigs.github.io/sig-storage-local-static-provisioner --force-update
#retry helm repo update
#retry helm template --debug sig-storage-local-static-provisioner/local-static-provisioner --namespace local-path-storage | sed 's/registry.k8s.io/opencsg-registry.cn-beijing.cr.aliyuncs.com\/opencsg_public/g'> local-volume-provisioner.generated.yaml
#retry kubectl apply -f local-volume-provisioner.generated.yaml
#set +euo pipefail
#
## Verify that the local-path-storage pod is running
#verify_local_path_storage_pod() {
#  local max_attempts=10
#  local attempt=1
#  local delay=10
#
#  log "INFO" "Verifying that the local-path-storage pod is running..."
#
#  while [ $attempt -le $max_attempts ]; do
#    local NOT_RUNNING=$(kubectl get pods --namespace local-path-storage | grep -v -E 'Running|Completed|STATUS' | wc -l)
#    if [ $NOT_RUNNING -eq 0 ]; then
#      log "INFO" "local-path-storage pod is running."
#      return 0
#    else
#      log "WARN" "local-path-storage pod is not running yet. Attempt ${attempt}/${max_attempts}."
#      sleep $delay
#    fi
#    ((attempt++))
#  done
#
#  log "ERRO" "local-path-storage pod is not running after ${max_attempts} attempts."
#  return 1
#}
#
## Invoke the verify_local_path_storage_pod function to check the pod status
#verify_local_path_storage_pod
#if [ $? -ne 0 ]; then
#  log "ERRO" "Failed to verify local-path-storage pod status."
#  exit 1
#fi
#
## Additional script content can go here
#log "INFO" "Binding local disks to fast disks..."
#for flag in {a..z}; do
#	mkdir -p /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} 2>/dev/null
#	mount --bind /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag}
#	echo "/mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} none bind 0 0" >> /etc/fstab
#done
#
## Verify PersistentVolumes (PVs) have been created
#verify_pvs_created() {
#  local max_attempts=10
#  local attempt=1
#  local delay=10
#
#  log "INFO" "Verifying that PersistentVolumes have been created..."
#
#  while [ $attempt -le $max_attempts ]; do
#    local not_available=$(kubectl get pv | grep -v -E 'Available|Released' | wc -l)
#    if [ $not_available -eq 0 ]; then
#      log "INFO" "PersistentVolumes are available."
#      return 0
#    else
#      log "WARN" "PersistentVolumes are not available yet. Attempt ${attempt}/${max_attempts}."
#      sleep $delay
#    fi
#    ((attempt++))
#  done
#
#  log "ERRO" "PersistentVolumes are not available after ${max_attempts} attempts."
#  return 1
#}
#
## Invoke the verify_pvs_created function to check the PV status
#verify_pvs_created
#if [ $? -ne 0 ]; then
#  log "ERRO" "Failed to verify PersistentVolumes status."
#  exit 1
#fi
#
## Additional operations or script content can go here
#log "INFO" "Binding local disks to fast disks completed."

# Install Knative Serving
log "INFO" "Install the Knative Serving component."
retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/CSGHub-Installer/refs/heads/main/helm-chart/knative/serving-crds.yaml
retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/CSGHub-Installer/refs/heads/main/helm-chart/knative/serving-core.yaml
retry kubectl patch cm config-autoscaler -n knative-serving -p='{"data":{"enable-scale-to-zero":"false"}}'

# Verify if KNative serving resources created successful
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to install Knative Serving crds and core components."
    exit 1
else
    log "INFO" "Knative Serving crds and core components installed."
fi

log "INFO" "Install a networking layer."
retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/CSGHub-Installer/refs/heads/main/helm-chart/knative/kourier.yaml
# Verify if networking layer installed
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to install kourier networking layer."
    exit 1
fi

log "INFO" "Configure Knative Serving to use Kourier."
retry kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
# Verify kourier patched successful
if [ $? -ne 0 ]; then
  log "ERRO" "Failed to configure Knative Serving to use Kourier."
  exit 1
fi

log "INFO" "Configure Kourier to use service with NodePort."
retry kubectl -n kourier-system patch service kourier -p '{"spec": {"type": "NodePort"}}'

# Verify if Kourier patched with service type NodePort
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to patch Kourier to NodePort."
    exit 1
fi

# Verify that the Knative Serving pod is running
verify_knative_serving_pod() {
  local max_attempts=10
  local attempt=1
  local delay=10

  log "INFO" "Verifying that the Knative Serving pod is running..."

  while [ $attempt -le $max_attempts ]; do
    local NOT_RUNNING=$(kubectl get pods --namespace knative-serving | grep -v -E 'Running|Completed|STATUS' | wc -l)
    if [ $NOT_RUNNING -eq 0 ]; then
      log "INFO" "knative-serving pod is running."
      return 0
    else
      log "WARN" "knative-serving pod is not running yet. Attempt ${attempt}/${max_attempts}."
      sleep $delay
    fi
    ((attempt++))
  done

  log "ERRO" "knative-serving pod is not running after ${max_attempts} attempts."
  return 1
}
# Verify Knative Serving pod is running
verify_knative_serving_pod
if [ $? -ne 0 ]; then
  log "ERRO" "Failed to verify Knative Serving pod status."
  exit 1
fi

log "INFO" "Patching the domain mapping configuration to use the internal cluster IP"
retry kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"app.internal":""}}'
# Verify if Kourier patched with service type NodePort
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to patch Knative Serving configure to use self internal domain."
    exit 1
fi

log "INFO" "Creating kube-configs secrets."
if ! kubectl get ns csghub &>/dev/null; then
  retry kubectl create ns csghub
fi
kubectl -n csghub delete secret kube-configs &>/dev/null
retry kubectl -n csghub create secret generic kube-configs --from-file=/root/.kube/

if [ $? -ne 0 ]; then
    log "ERRO" "Failed to create kube configs secrets."
    exit 1
fi

log "INFO" "Add CSGHUB helm repository."
retry helm repo add csghub https://opencsgs.github.io/CSGHub-Installer --force-update && helm repo update
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to add csghub helm repository."
    exit 1
fi

log "INFO" "Installing CSGHub helm chart..."
NODE_PORT=$(kubectl get svc/kourier -n kourier-system -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
CHART_VERSION=$(helm search repo csghub -l | sort --version-sort -r | awk 'NR==1{print $2}')
rm -rf csghub-${CHART_VERSION}.tgz &>/dev/null
retry wget "https://ghp.ci/https://github.com/OpenCSGs/CSGHub-Installer/releases/download/csghub-${CHART_VERSION}/csghub-${CHART_VERSION}.tgz"
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to download csghub helm chart latest version."
    exit 1
fi

# Install helm chart
retry helm upgrade --install csghub ./csghub-${CHART_VERSION}.tgz \
	--namespace csghub \
	--create-namespace \
	--set global.domain=${DOMAIN} \
	--set global.runner.internalDomain[0].domain=app.internal \
	--set global.runner.internalDomain[0].host=${IP_ADDRESS} \
	--set global.runner.internalDomain[0].port=${NODE_PORT} | tee ./login.txt

# Verify if csghub helm chart installed
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to install csghub helm chart."
    exit 1
fi

log "INFO" "Patching ingress service to NodePort."
retry kubectl -n csghub patch service csghub-ingress-nginx-controller -p '{"spec": {"type": "NodePort"}}'

log "INFO" "Get the registry self-signed ca certificate."
retry kubectl -n csghub get secret csghub-certs -ojsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
# Verify if registry tls secret fetched
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to get registry ca certificate."
    exit 1
fi

log "INFO" "Patching Knative Serving controller."
kubectl -n knative-serving delete secret csghub-registry-certs-ca &>/dev/null
retry kubectl -n knative-serving create secret generic csghub-registry-certs-ca --from-file=ca.crt=./ca.crt
retry kubectl -n knative-serving patch deployment.apps/controller --type=json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/env/-",
    "value": {
      "name": "SSL_CERT_DIR",
      "value": "/opt/certs/x509"
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/volumes",
    "value": [
      {
        "name": "custom-certs",
        "secret": {
          "secretName": "csghub-registry-certs-ca"
        }
      }
    ]
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts",
    "value": [
      {
        "name": "custom-certs",
        "mountPath": "/opt/certs/x509"
      }
    ]
  }
]' &>/dev/null

# Verify if Knative Serving controller patched
if [ $? -ne 0 ]; then
    log "ERRO" "Failed to patch Knative Serving controller."
    exit 1
fi

log "INFO" "Adding insecure registry to k3s."
SECRET_JSON=$(kubectl -n csghub get secret csghub-registry-docker-config -ojsonpath='{.data.\.dockerconfigjson}' | base64 -d)
REGISTRY=$(echo "$SECRET_JSON" | jq -r '.auths | keys[]')
RUSERNAME=$(echo "$SECRET_JSON" | jq -r '.auths | to_entries[] | .value | .username')
RPASSWORD=$(echo  "$SECRET_JSON" | jq -r '.auths | to_entries[] | .value | .password')

cat <<EOF > /etc/rancher/k3s/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://opencsg-registry.cn-beijing.cr.aliyuncs.com"
    rewrite:
      "^rancher/(.*)": "opencsg_public/rancher/\$1"
  ${REGISTRY}:
    endpoint:
      - "https://${REGISTRY}"
configs:
  "${REGISTRY}":
    auth:
      username: ${RUSERNAME}
      password: ${RPASSWORD}
    tls:
      insecure_skip_verify: true
EOF

log "INFO" "Restarting k3s..."
systemctl restart k3s
# Verify if k3s running
if [[ $(systemctl is-active k3s) != "active" ]]; then
    log "ERRO" "Failed to install csghub helm chart."
    exit 1
else
  log "INFO" "k3s restarted successfully."
fi

log "INFO" "Environment is ready, login info at login.txt."
log "INFO" "Next you need to configure DNS domain name resolution yourself."
