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
  echo "Please run this script with root privileges."
  exit 1
fi

ENABLE_K3S=${ENABLE_K3S:-"true"}
ENABLE_DYNAMIC_PV=${ENABLE_DYNAMIC_PV:-"false"}
ENABLE_KNATIVE_SERVING=${ENABLE_KNATIVE_SERVING:-$ENABLE_K3S}
ENABLE_NVIDIA_GPU=${ENABLE_NVIDIA_GPU:-"false"}
ENABLE_HTTPS=${ENABLE_HTTPS:-"false"}
ENABLE_HOSTS=${ENABLE_HOSTS:-"true"}
KNATIVE_INTERNAL_DOMAIN=${KNATIVE_INTERNAL_DOMAIN:-"app.internal"}
KNATIVE_INTERNAL_HOST=${KNATIVE_INTERNAL_HOST:-"127.0.0.1"}
KNATIVE_INTERNAL_PORT=${KNATIVE_INTERNAL_PORT:-80}
INGRESS_SERVICE_TYPE=${INGRESS_SERVICE_TYPE:-"LoadBalancer"}

# Format log output
log() {
  # Define log levels as constants
  local log_level="$1"
  local message="$2"
  # Define colors
  local green="\033[0;32m"
  local yellow="\033[0;33m"
  local red="\033[0;31m"
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

# 封装确认函数
confirm_action() {
  while true; do
    read -p "Do you want to continue? (yes/no): " confirm
      case "$confirm" in
        [Yy][Ee][Ss])
          log "INFO" "Continuing with the process..."
          return 0  # 返回成功
          ;;
        [Nn][Oo])
          log "INFO" "Exiting the process..."
          exit 1  # 返回失败并退出
          ;;
        *)
          log "ERROR" "Invalid input. Please enter 'yes' or 'no'."
          ;;
      esac
  done
}

# Detect operating system and architecture
OS=""
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
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

# https://docs.k3s.io/advanced?_highlight=nvidia#nvidia-container-runtime-support
if [ "$ENABLE_K3S" == "true" ]; then
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

  log "INFO" "Installing K3S..."
  if [ "$ENABLE_NVIDIA_GPU" == "true" ]; then
    retry curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.30.4+k3s1 sh -s - --disable=traefik --default-runtime=nvidia
  else
    retry curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.30.4+k3s1 sh -s - --disable=traefik
  fi
  chmod 0400 /etc/rancher/k3s/k3s.yaml
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

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
      local READY=$(kubectl get nodes | grep -E -c 'Ready')
      local NOT_RUNNING=$(kubectl get pods -n kube-system | grep -v -E -c 'Running|Completed|STATUS')
      if [ "$READY" -eq 1 ] && [ "$NOT_RUNNING" -eq 0 ]; then
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
  log "INFO" "Copying kube config file to the user's home directory."
  mkdir ~/.kube &>/dev/null
  cp -f /etc/rancher/k3s/k3s.yaml ~/.kube/config && chmod 0400 ~/.kube/config
  sed -i "s/127.0.0.1/${IP_ADDRESS}/g" ~/.kube/config
fi

if [ "$ENABLE_K3S" == "true" ]; then
  # Install Helm3
  log "INFO" "Installing Helm3..."
  retry curl -fsSL -o get_helm.sh https://ghp.ci/https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod +x get_helm.sh && ./get_helm.sh
  if helm version &> /dev/null; then
    log "INFO" "Helm installation verified successfully."
  else
    log "ERRO" "Helm installation verification failed."
    exit 1
  fi
fi

if [ "$ENABLE_DYNAMIC_PV" == "true" ] && [ "$ENABLE_K3S" == "false" ]; then
  # Install sig-storage-local-static-provisioner
  set -euo pipefail
  log "INFO" "Installing sig-storage-local-static-provisioner..."
  cat <<EOF | kubectl apply -f -
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: fast-disks
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
  provisioner: kubernetes.io/no-provisioner
  volumeBindingMode: WaitForFirstConsumer
  reclaimPolicy: Delete
  allowVolumeExpansion: true
EOF

  if [ $? -ne 0 ]; then
      log "ERRO" "Failed to create storageClass."
  fi

  if ! kubectl get ns local-path-storage &>/dev/null; then
    retry kubectl create namespace local-path-storage 2>/dev/null
  fi

  retry helm repo add sig-storage-local-static-provisioner https://kubernetes-sigs.github.io/sig-storage-local-static-provisioner --force-update
  retry helm repo update
  retry helm template --debug sig-storage-local-static-provisioner/local-static-provisioner --namespace local-path-storage | sed 's/registry.k8s.io/opencsg-registry.cn-beijing.cr.aliyuncs.com\/opencsg_public/g'> local-volume-provisioner.generated.yaml
  retry kubectl apply -f local-volume-provisioner.generated.yaml
  set +euo pipefail

  # Verify that the local-path-storage pod is running
  verify_local_path_storage_pod() {
    local max_attempts=10
    local attempt=1
    local delay=10

    log "INFO" "Verifying that the local-path-storage pod is running..."

    while [ $attempt -le $max_attempts ]; do
      local NOT_RUNNING=$(kubectl get pods --namespace local-path-storage | grep -v -c -E 'Running|Completed|STATUS')
      if [ "$NOT_RUNNING" -eq 0 ]; then
        log "INFO" "local-path-storage pod is running."
        return 0
      else
        log "WARN" "local-path-storage pod is not running yet. Attempt ${attempt}/${max_attempts}."
        sleep $delay
      fi
      ((attempt++))
    done

    log "ERRO" "local-path-storage pod is not running after ${max_attempts} attempts."
    return 1
  }

  # Invoke the verify_local_path_storage_pod function to check the pod status
  verify_local_path_storage_pod
  if [ $? -ne 0 ]; then
    log "ERRO" "Failed to verify local-path-storage pod status."
    exit 1
  fi

  # Additional script content can go here
  log "INFO" "Binding local disks to fast disks..."
  for FLAG in {a..z}; do
    mkdir -p /mnt/fake-disks/sd"$FLAG" /mnt/fast-disks/sd"$FLAG" 2>/dev/null
    mount --bind /mnt/fake-disks/sd"$FLAG" /mnt/fast-disks/sd"$FLAG"
    echo "/mnt/fake-disks/sd"$FLAG" /mnt/fast-disks/sd"$FLAG" none bind 0 0" >> /etc/fstab
  done

  # Verify PersistentVolumes (PVs) have been created
  verify_pvs_created() {
    local max_attempts=10
    local attempt=1
    local delay=10

    log "INFO" "Verifying that PersistentVolumes have been created..."

    while [ $attempt -le $max_attempts ]; do
      local NOT_AVAILABLE=$(kubectl get pv | grep -v -c -E 'Available|Released')
      if [ "$NOT_AVAILABLE" -eq 0 ]; then
        log "INFO" "PersistentVolumes are available."
        return 0
      else
        log "WARN" "PersistentVolumes are not available yet. Attempt ${attempt}/${max_attempts}."
        sleep $delay
      fi
      ((attempt++))
    done

    log "ERRO" "PersistentVolumes are not available after ${max_attempts} attempts."
    return 1
  }

  # Invoke the verify_pvs_created function to check the PV status
  verify_pvs_created
  if [ $? -ne 0 ]; then
    log "ERRO" "Failed to verify PersistentVolumes status."
    exit 1
  fi

  # Additional operations or script content can go here
  log "INFO" "Binding local disks to fast disks completed."
fi

if [ "$ENABLE_KNATIVE_SERVING" == "true" ]; then
  # Install Knative Serving
  log "INFO" "Install the Knative Serving component."
  retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-crds.yaml
  retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-core.yaml
  retry kubectl patch cm config-autoscaler -n knative-serving -p='{"data":{"enable-scale-to-zero":"false"}}'
  retry kubectl patch cm config-features -n knative-serving -p='{"data":{"kubernetes.podspec-nodeselector":"enabled"}}'
  # Verify if KNative serving resources created successful
  if [ $? -ne 0 ]; then
    log "ERRO" "Failed to install Knative Serving crds and core components."
    exit 1
  else
    log "INFO" "Knative Serving crds and core components installed."
  fi

  log "INFO" "Install a networking layer."
  retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/kourier.yaml
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
fi

if [ "$ENABLE_HTTPS" == "true" ]; then
  log "INFO" "Before enabling HTTPS, please confirm that the following domain names can access this host using public DNS."
  log "WARN" "subdomains: csghub.${DOMAIN} minio.${DOMAIN} casdoor.${DOMAIN} registry.${DOMAIN}"
  confirm_action
  log "INFO" "Install cert-manager"
  retry kubectl apply -f https://ghp.ci/https://github.com/cert-manager/cert-manager/releases/download/v1.16.0/cert-manager.yaml
  retry kubectl apply -f https://ghp.ci/https://github.com/cert-manager/cert-manager/releases/download/v1.16.0/cert-manager.crds.yaml
  # Verify that the Cert Manager pod is running
  verify_cert_manager_pod() {
    local max_attempts=10
    local attempt=1
    local delay=10

    log "INFO" "Verifying that the Cert-Manager pod is running..."

    while [ $attempt -le $max_attempts ]; do
      local NOT_RUNNING=$(kubectl get pods --namespace cert-manager | grep -v -E 'Running|Completed|STATUS' | wc -l)
      if [ $NOT_RUNNING -eq 0 ]; then
        log "INFO" "cert-manager pod is running."
        return 0
      else
        log "WARN" "cert-manager pod is not running yet. Attempt ${attempt}/${max_attempts}."
        sleep $delay
      fi
      ((attempt++))
    done

    log "ERRO" "cert-manager pod is not running after ${max_attempts} attempts."
    return 1
  }
  # Verify Cert Manager pod is running
  verify_cert_manager_pod
  if [ $? -ne 0 ]; then
    log "ERRO" "Failed to verify Cert Manager pod status."
    exit 1
  fi
fi

if [ "$ENABLE_K3S" == "false" ]; then
  log "INFO" "Please place the .kube/config file in /root and make sure that the config uses a non-127.0.0.1 or localhost address."
  confirm_action
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
retry helm repo add csghub https://opencsgs.github.io/csghub-installer --force-update && helm repo update
if [ $? -ne 0 ]; then
  log "ERRO" "Failed to add csghub helm repository."
  exit 1
fi

if [ "$ENABLE_KNATIVE_SERVING" == "true" ]; then
  KNATIVE_INTERNAL_HOST="$IP_ADDRESS"
  KNATIVE_INTERNAL_PORT=$(kubectl get svc/kourier -n kourier-system -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
fi

log "INFO" "Installing CSGHub helm chart..."
CHART_VERSION=$(helm search repo csghub -l | sort --version-sort -r | awk 'NR==1{print $2}')
rm -rf csghub-"$CHART_VERSION".tgz &>/dev/null
retry wget "https://ghp.ci/https://github.com/OpenCSGs/csghub-installer/releases/download/csghub-"$CHART_VERSION"/csghub-"$CHART_VERSION".tgz" >/dev/null
if [ $? -ne 0 ]; then
  log "ERRO" "Failed to download csghub helm chart latest version."
  exit 1
fi

# Install helm chart
if [ "$ENABLE_HTTPS" == "true" ]; then
retry helm upgrade --install csghub ./csghub-"$CHART_VERSION".tgz \
    --namespace csghub \
    --create-namespace \
    --set global.domain="$DOMAIN" \
    --set global.ingress.service.type="$INGRESS_SERVICE_TYPE" \
    --set global.ingress.tls.enabled=true \
    --set global.ingress.tls.autoGenerated=true \
    --set global.postgresql.parameters.timezone=UTC \
    --set global.runner.internalDomain[0].domain="$KNATIVE_INTERNAL_DOMAIN" \
    --set global.runner.internalDomain[0].host="$KNATIVE_INTERNAL_HOST" \
    --set global.runner.internalDomain[0].port="$KNATIVE_INTERNAL_PORT" | tee ./login.txt
else
retry helm upgrade --install csghub ./csghub-"$CHART_VERSION".tgz \
    --namespace csghub \
    --create-namespace \
    --set global.postgresql.parameters.timezone=UTC \
    --set global.domain="$DOMAIN" \
    --set global.ingress.service.type="$INGRESS_SERVICE_TYPE" \
    --set global.runner.internalDomain[0].domain="$KNATIVE_INTERNAL_DOMAIN" \
    --set global.runner.internalDomain[0].host="$KNATIVE_INTERNAL_HOST" \
    --set global.runner.internalDomain[0].port="$KNATIVE_INTERNAL_PORT" | tee ./login.txt
fi

# Verify if csghub helm chart installed
if [ $? -ne 0 ]; then
  log "ERRO" "Failed to install csghub helm chart."
  exit 1
fi

#if [ "$INGRESS_SERVICE_TYPE" == "NodePort" ]; then
#  log "INFO" "Patching ingress service to NodePort."
#  retry kubectl -n csghub patch service csghub-ingress-nginx-controller -p '{"spec": {"type": "NodePort"}}'
#fi

if [ "$ENABLE_KNATIVE_SERVING" == "true" ]; then
   log "INFO" "Get the registry self-signed ca certificate."
   retry kubectl -n csghub get secret csghub-certs -ojsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
   # Verify if registry tls secret fetched
   if [ $? -ne 0 ]; then
     log "ERRO" "Failed to get registry ca certificate."
     exit 1
   fi

   if [ -s ca.crt ]; then
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
   fi
   retry kubectl -n knative-serving rollout restart deployment.apps/controller
fi

if [ "$ENABLE_NVIDIA_GPU" == "true" ]; then
  log "INFO" "Installing NVIDIA Container Toolkit and patch Containerd."
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  apt update && apt-get install -y alsa-utils nvidia-container-toolkit
  nvidia-ctk runtime configure --runtime=containerd --config=/var/lib/rancher/k3s/agent/etc/containerd/config.toml

   # Verify if Containerd patched
   if [ $? -ne 0 ]; then
     log "ERRO" "Failed to patch Containerd."
     exit 1
   fi

  log "INFO" "Restarting k3s..."
    systemctl restart k3s
    # Verify if k3s running
    if [[ $(systemctl is-active k3s) != "active" ]]; then
      log "ERRO" "Failed to install csghub helm chart."
      exit 1
    else
      log "INFO" "k3s restarted successfully."
    fi

  log "INFO" "Add NVIDIA helm repository."
  retry helm repo add nvdp https://nvidia.github.io/k8s-device-plugin --force-update && helm repo update

  log "INFO" "Installing NVIDIA helm chart..."
  retry helm upgrade -i nvdp nvdp/nvidia-device-plugin \
          --namespace nvdp \
          --create-namespace \
          --set runtimeClassName=nvidia \
          --set image.repository=opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nvidia/k8s-device-plugin:v0.16.2 \
          --set gfd.enabled=true

  log "INFO" "Replace all nvidia-device-plugin images to local."
  retry kubectl -n nvdp patch deployment nvdp-node-feature-discovery-master -p='{"spec":{"template":{"spec":{"containers":[{"name":"master","image":"opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nfd/node-feature-discovery:v0.15.3"}]}}}}'
  retry kubectl -n nvdp patch daemonset nvdp-node-feature-discovery-worker -p='{"spec":{"template":{"spec":{"containers":[{"name":"worker","image":"opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nfd/node-feature-discovery:v0.15.3"}]}}}}'
  retry kubectl delete pods --all -n nvdp
  #  kubectl -n nvdp patch daemonset nvdp-nvidia-device-plugin -p='{"spec":{"template":{"spec":{"containers":[{"name":"nvidia-device-plugin","image":"opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nvidia/k8s-device-plugin:v0.16.2"}]}}}}'
  retry kubectl -n nvidia-device-plugin patch ds nvdp-nvidia-device-plugin \
          --type='json' \
          -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--device-discovery-strategy=nvml"]}]'
  #        -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--device-discovery-strategy=tegra"]}]'

  log "INFO" "Add labels for all nodes to enable Multi-Process Service."
  NODES=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable}{"\n"}{end}' | awk '{print $1}')
  for NODE in $NODES; do
    # kubectl label node "$NODE" nvidia.com/mps.capable=true nvidia.com/gpu=true
    kubectl label node "$NODE" nvidia.com/mps.capable=true

    GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)
    GPU_MODEL=$(echo "$GPU_INFO" | sed 's/ /-/g')
    kubectl label node "$NODE" nvidia.com/nvidia_name=${GPU_MODEL}
  done
fi

if [ "$ENABLE_HOSTS" == true ]; then
  log "INFO" "Configure local custom domain name resolution."
  retry kubectl apply -f - <<EOF
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: coredns-custom
    namespace: kube-system
  data:
    ${DOMAIN}.server: |
      ${DOMAIN} {
        hosts {
          ${IP_ADDRESS} csghub.${DOMAIN} csghub
          ${IP_ADDRESS} casdoor.${DOMAIN} casdoor
          ${IP_ADDRESS} registry.${DOMAIN} registry
          ${IP_ADDRESS} minio.${DOMAIN} minio
        }
      }
EOF

  log "INFO" "Rollout restart deployment coredns."
  retry kubectl -n kube-system rollout restart deploy coredns
fi


if [ "$ENABLE_K3S" == "true" ]; then
  log "INFO" "Adding insecure registry to k3s."
  SECRET_JSON=$(kubectl -n csghub get secret csghub-registry-docker-config -ojsonpath='{.data.\.dockerconfigjson}' | base64 -d)
  REGISTRY=$(echo "$SECRET_JSON" | jq -r '.auths | keys[]')
  REGISTRY_USERNAME=$(echo "$SECRET_JSON" | jq -r '.auths | to_entries[] | .value | .username')
  REGISTRY_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.auths | to_entries[] | .value | .password')

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
      username: ${REGISTRY_USERNAME}
      password: ${REGISTRY_PASSWORD}
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
else
  log "INFO" "Please config insecure registries by follow https://github.com/OpenCSGs/csghub-installer?tab=readme-ov-file#post-installation-configuration."
fi

log "INFO" "Environment is ready, login info at login.txt."
if [ "$ENABLE_HTTPS" == "false" ] && [ "$ENABLE_HOSTS" == "true" ]; then
  log "INFO" "Add domain resolution to /etc/hosts."
  HOST_ENTRIES=(
      "${IP_ADDRESS} csghub.${DOMAIN} csghub"
      "${IP_ADDRESS} casdoor.${DOMAIN} casdoor"
      "${IP_ADDRESS} registry.${DOMAIN} registry"
      "${IP_ADDRESS} minio.${DOMAIN} minio"
  )

  for ENTRY in "${HOST_ENTRIES[@]}"; do
      if ! grep -qF "$ENTRY" /etc/hosts; then
          echo "$ENTRY" >> /etc/hosts
      fi
  done
fi
