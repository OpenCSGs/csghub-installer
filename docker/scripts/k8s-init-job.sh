#!/bin/bash

# export KNATIVE_SERVING_ENABLE=true
# export NVIDIA_DEVICE_PLUGIN=true

# Function to retry a command up to a specified number of times if it fails
retry() {
  local n=1
  local max=5
  local delay=10
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        echo "The command has failed after $n attempts."
        return 1
      fi
    }
  done
}

verify_pods_running() {
  local max_attempts=10
  local attempt=1
  local delay=10

  echo "Verify that the pods in the namespace $1 are running..."
  while [ $attempt -le $max_attempts ]; do
      local NOT_RUNNING=$(kubectl get pods --namespace "$1" | egrep -v "Running|Completed|STATUS" | wc -l)
      if [ $NOT_RUNNING -eq 0 ]; then
        echo "Pods in namespace $1 are running."
        return 0
      else
        echo "Pods in namespace $1 are not running yet. Attempt ${attempt}/${max_attempts}."
        sleep $delay
      fi
      ((attempt++))
    done

    echo "Pods in namespace $1 are not running after ${max_attempts} attempts."
    return 1
  }

create_namespace() {
  IF_EXISTS=$(kubectl get ns | grep "$SPACE_APP_NS")
  if [ -z "$IF_EXISTS" ]; then
    kubectl create ns $SPACE_APP_NS
  fi
}

install_argo_workflow() {
  # Install argo workflow
  log "INFO" "Install the ARGO Workflow component."
  retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/argo/argo.yaml
  retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/argo/rbac.yaml
}

install_knative_serving() {
  echo "Install the Knative Serving component"
  retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-crds.yaml
  retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-core.yaml
  retry kubectl patch cm config-autoscaler -n knative-serving -p='{"data":{"enable-scale-to-zero":"false"}}'
  retry kubectl patch cm config-features -n knative-serving -p='{"data":{"kubernetes.podspec-nodeselector":"enabled"}}'

  echo "Install a networking layer"
  retry kubectl apply -f https://ghp.ci/https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/kourier.yaml

  echo "Configure Knative Serving to use Kourier"
  retry kubectl patch configmap/config-network \
    --namespace knative-serving \
    --type merge \
    --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

  if [ "$KNATIVE_KOURIER_TYPE" != "LoadBalancer" ]; then
      echo "Configure Kourier to use service with NodePort"
      retry kubectl -n kourier-system patch service kourier -p '{"spec": {"type": "NodePort"}}'
  fi

  echo "Patching the domain mapping configuration to use the internal cluster IP"
  local domain="$1"
  retry eval kubectl patch configmap/config-domain \
    --namespace knative-serving \
    --type merge \
    --patch '{\"data\":{\"$domain\":\"\"}}'
}

install_nvidia_device_plugin() {
  echo "Add NVIDIA helm repository"
  retry helm repo add nvdp https://nvidia.github.io/k8s-device-plugin --force-update
  retry helm repo update

  echo "Installing NVIDIA helm chart"
  retry helm upgrade -i nvdp nvdp/nvidia-device-plugin \
          --namespace nvdp \
          --create-namespace \
          --set runtimeClassName=nvidia \
          --set image.repository=opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nvidia/k8s-device-plugin:v0.16.2 \
          --set gfd.enabled=true

  echo "Replace all nvidia-device-plugin images to local"
  retry kubectl -n nvdp patch deployment nvdp-node-feature-discovery-master -p='{"spec":{"template":{"spec":{"containers":[{"name":"master","image":"opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nfd/node-feature-discovery:v0.15.3"}]}}}}'
  retry kubectl -n nvdp patch daemonset nvdp-node-feature-discovery-worker -p='{"spec":{"template":{"spec":{"containers":[{"name":"worker","image":"opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/nfd/node-feature-discovery:v0.15.3"}]}}}}'
  retry kubectl delete pods --all -n nvdp
  retry kubectl -n nvdp patch ds nvdp-nvidia-device-plugin \
          --type='json' \
          -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args", "value": ["--device-discovery-strategy=nvml"]}]'
}

get_knative_kourier_network() {
  CONFIG="$1"
  BASE=$(basename $CONFIG)
  SERVER_URL=$(yq .clusters[0].cluster.server $CONFIG)
  BASE_KOURIER_HOST=$(echo $SERVER_URL | cut -d '/' -f 3 | cut -d ':' -f 1)
  BASE_KOURIER_PORT=80
  if [ "$KNATIVE_KOURIER_TYPE" != "LoadBalancer" ]; then
      BASE_KOURIER_PORT=$(kubectl -n kourier-system get svc kourier -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  fi
  BASE_KNATIVE_DOMAIN=$(kubectl -n knative-serving get cm/config-domain -o yaml | grep '^  [^ ]' | awk -F':' '{print $1}' | grep 'internal' | sed 's/ //g')

  jo -d . cluster="$BASE" space="$SPACE_APP_NS" knative.domain="$BASE_KNATIVE_DOMAIN" knative.host="$BASE_KOURIER_HOST" knative.port="$BASE_KOURIER_PORT"

  if [ ! -d "/etc/dnsmasq.d" ]; then
      mkdir -p /etc/dnsmasq.d
  fi
  echo "address=/${SPACE_APP_NS}.${BASE_KNATIVE_DOMAIN}/127.0.0.1" > /etc/dnsmasq.d/app-internal.conf
}

create_docker_config() {
  kubectl -n "$SPACE_APP_NS" delete secret csghub-docker-config 2>/dev/null

  retry kubectl create secret docker-registry csghub-docker-config \
    --namespace="$SPACE_APP_NS" \
    --docker-server="$REGISTRY_ADDRESS" \
    --docker-username="$REGISTRY_USERNAME" \
    --docker-password="$REGISTRY_PASSWORD"
}

if [[ ! -n $(ls -A /etc/.kube/config* 2>dev/null) ]]; then
  echo 0
fi

counter=1
cluster_infos=()
for CONFIG in $(ls -A /etc/.kube/config*); do
  export KUBECONFIG=$CONFIG

  create_namespace

  if [ "$STARHUB_SERVER_DOCKER_IMAGE_PULL_SECRET" == "csghub-docker-config" ]; then
    create_docker_config
  fi

  if [ "$ENABLE_ARGO_WORKFLOW" == "true" ]; then
    install_argo_workflow
  fi

  if [ "$KNATIVE_SERVING_ENABLE" == "true" ]; then
    DOMAIN="app${counter}.internal"
    install_knative_serving "$DOMAIN"
    verify_pods_running "knative-serving"
  fi

  if [ "$NVIDIA_DEVICE_PLUGIN" == "true" ]; then
    install_nvidia_device_plugin
    verify_pods_running "nvdp"
  fi

  CLUSTER=$(get_knative_kourier_network $CONFIG)
  cluster_infos+=("$CLUSTER")

  counter=$((counter+1))
done

if [ "${#cluster_infos[@]}" -eq 0 ]; then
  echo "Non clusters detected."
  exit 0
else
  echo "${cluster_infos[@]}" | jq -s . | jq -r '.[] | "
server {
    listen 80;
    server_name \("*." + .space + "." + .knative.domain);

    location / {
        proxy_pass http://\(.knative.host):\(.knative.port);
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        root  /usr/share/nginx/html;
    }
}
  "' > /etc/nginx/conf.d/app.internal.conf

  /usr/sbin/nginx -s reload
fi

supervisorctl restart dnsmasq