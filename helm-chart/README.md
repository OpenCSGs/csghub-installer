## CSGHUB Helm Chart

CSGHub is an open source, trustworthy large model asset management platform that can assist users in governing the assets involved in the lifecycle of LLM and LLM applications (datasets, model files, codes, etc).

### Helm Usage Instructions

Due to the version problem, the configuration is relatively complicated, which will be optimized in later versions. To simplify the configuration, only global parameters are defined in values.yaml. The mapping method of sub-charts in global in this helm chart is consistent with directly modifying the sub-chart configuration in the parent chart. Therefore, when modifying a subchart, you only need to add or modify the parameters of the corresponding subchart in global.

## Quick deployment

You can use quick deployment to pull up a usable csghub environment in minutes.
g
Recommended operating system:
- Ubuntu >= 20.04 / Debian >=10 / CentOS 7  
- Hardware >= 4c8g

```shell
# <domain>: like example.com
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | bash -s -- <domain>

# If enable Nvidia GPU
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | ENABLE_NVIDIA_GPU=true bash -s -- <domain>
```

## Manual deployment

### Prerequisites
- Kubernetes 1.20+
- Helm 3.8+
- PV Dynamic Provisioning 

### Install KNative Serving

> - Reference：[Install Knative Serving using YAML files](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#install-a-networking-layer)
>
> *Note: If the cluster where the instance is finally deployed is not this Kubernetes cluster, please install KNative Serving to the target cluster.*

KNative Serving is a necessary component for CSGHub to create Space and other applications. If you are in a cloud environment, you can consider using similar components provided by the cloud.

#### Install the Knative Serving component

1. Install the required custom resources

    ```shell
    kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.15.2/serving-crds.yaml
    
    # If you have trouble pulling the gcr.io image, use the following command
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-crds.yaml
    ```

2. Install the core components of Knative Serving

    ```shell
    kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.15.2/serving-core.yaml
    
    # If you have trouble pulling the gcr.io image, use the following command
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-core.yaml
    ```

#### Install a networking layer

Here choosing `Kourier` as default. If you want to use other network components, please refer to the [Knative documentation](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#install-a-networking-layer) for details

1. Install the Knative Kourier controller

    ```shell
    kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.15.1/kourier.yaml
    
    # If you have trouble pulling the gcr.io image, use the following command
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/kourier.yaml
    ```

2. Configure Knative Serving to use Kourier by default

    ```shell
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
    ```

3. Fetch the External IP address

    ```shell
    kubectl --namespace kourier-system get service kourier
    ```

4. Verify Installation

    ```shell
    kubectl get pods -n knative-serving
    ```

### Configure DNS

Normally, Knative Serving services can use Magic DNS or Real DNS to resolve internal addresses. However, due to the characteristics of multi-cluster management integration, it can only be configured through Real DNS.

```shell
# Replace knative.example.com with your domain suffix
kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"app.internal":""}}' 
```

#### Install optional Serving extensions

```shell
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.15.2/serving-hpa.yaml

# If you have trouble pulling the gcr.io image, use the following command
kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-hpa.yaml
```

## Create KubeConfig Secret

Also, because CSGHub needs to be able to connect to multiple Kubernetes clusters, it can only connect to multiple clusters through the .kube/config file, and cannot use serviceAccount. To ensure the security of .kube/config, you need to create secrets yourself and provide them to helm.

Before creating, please place the config files of all your connected Kubernetes clusters under the target file, such as the .kube directory. You can use different config file names, such as numbering the file names.

```shell
kubectl create namespace csghub
kubectl create secret generic kube-configs --from-file=/root/.kube --namespace=csghub
```

The above command will create all config files in the .kube directory into the `kube-configs` Secret resource. You can use .Values.global.runner.kubeConfig.secretName to execute non-default secret files.

### Install CSGHub Helm Chart

Before performing the following operations, you must be ready for the above operations.

- Add helm repository

    ```shell
    helm repo add csghub https://opencsgs.github.io/csghub-installer
    helm repo update
    ```

- Install Chart

  > The default service exposure uses NodePort because most local test environments do not have LoadBalancer capabilities.

    ```shell
    # global.ingress.hosts: Replace with your own second-level domain name
    # global.builder.internal[0].domain: The internal domain name configured above
    # global.builder.internal[0].service.host: The external address of the kourier service
    # global.builder.internal[0].service.port: Kourier service external port
    helm install csghub csghub/csghub \
        --namespace csghub \
        --create-namespace \
        --set global.domain=example.com \
        --set global.ingress.service.type=NodePort \
        --set global.runner.internalDomain[0].domain=app.internal \
        --set global.runner.internalDomain[0].host=xxx.xxx.xx.xx \
        --set global.runner.internalDomain[0].port=30463  
  
    # Patch ingress svc type to NodePort
    kubectl -n csghub patch service csghub-ingress-nginx-controller -p '{"spec": {"type": "NodePort"}}'
  
    # Patch knative serving
    kubectl -n csghub get secret csghub-certs -ojsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
    kubectl -n knative-serving create secret generic csghub-registry-certs-ca --from-file=ca.crt=./ca.crt
    kubectl -n knative-serving patch deployment.apps/controller --type=json -p='[
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
    ]'
    ```
  
  After the resources are ready, you can **log in to csghub according to the helm output prompt**. It should be further explained that some functions are not ready in the current helm chart due to the complexity of enabling them. For example, model inference and model fine-tuning have been enabled, but some configuration may still be required to run the instance normally. 

  *Hint: You need to configure the corresponding third-level domain name to DNS according to the prompts after installation.*

### Post-installation configuration

  Although this helm chart has a simple Container Registry program built in for testing, it does not provide reliable encrypted access. You still need to go through [more configuration](https://github.com/containerd/containerd/blob/main/docs/hosts.md) to pull images from the Registry normally. Please prepare the Registry yourself for the production environment.

- Configure containerd to allow access to the registry using non-secure encryption

  Before configuration, please confirm whether the configuration file `/etc/containerd/config.toml` exists. If it does not exist, you can create it with the following command.

   ```shell
   mkdir -p /etc/containerd/ && containerd config default >/etc/containerd/config.toml
   ```

    1. Configure config_path

       - containerd 2.x

        ```toml
        version = 3
          
        [plugins."io.containerd.cri.v1.images".registry]
           config_path = "/etc/containerd/certs.d"
        ```

       - Containerd 1.x

        ```toml
        version = 2
          
        [plugins."io.containerd.grpc.v1.cri".registry]
           config_path = "/etc/containerd/certs.d"
        ```

       This configuration requires restarting the `containerd` service.

    2. Configure hosts.toml

        ```shell
        mkdir /etc/containerd/certs.d/registry.example.com:32500 # This port is the built-in NodePort port of this helm, which can be modified by .Values.global.registry.service.nodePort
          
        cat <<EOF > /etc/containerd/certs.d/registry.example.com:32500/hosts.toml
        server = "https://registry.example.com:5000"
          
        [host."http://192.168.170.22:5000"]
          capabilities = ["pull", "resolve", "push"]
          skip_verify = true
        EOF
        ```

       *Note: This configuration takes effect directly without restarting*

    3. Verify the configuration

        ```shell
        ctr images pull --hosts-dir "/etc/containerd/certs.d" registry.example.com:5000/image_name:tag
        ```