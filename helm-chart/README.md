# CSGHub Helm Chart Deployment Guide

## Overview

CSGHub is an open source, trusted large model asset management platform that helps users manage assets (datasets, model files, codes, etc.) involved in the life cycle of LLM and LLM applications. Based on CSGHub, users can operate assets such as model files, data sets, codes, etc. through the Web interface, Git command line, or natural language Chatbot, including uploading, downloading, storage, verification, and distribution; at the same time, the platform provides microservice submodules and standardized APIs to facilitate users to integrate with their own systems.

CSGHub is committed to bringing users an asset management platform that is natively designed for large models and can be privately deployed and run offline. CSGHub provides a similar private HuggingFace function to manage LLM assets in a similar way to OpenStack Glance managing virtual machine images, Harbor managing container images, and Sonatype Nexus managing artifacts.

## Instructions

### Deployments

This Helm Chart currently only contains the creation of necessary resources for necessary components. If you encounter any problems during use, you can submit feedback to the project [csghub-installer](https://github.com/OpenCSGs/csghub-installer/issues) .

### Versions

Currently, the version of CSGHub Helm Chart is consistent with the CSGHub version.

| Chart version | CSGHub version | Remark |
| :-----------: | :------------: | ------ |
|     1.0.x     |     v1.0.x     |        |
|     0.9.x     |     v0.9.x     |        |
|     0.8.x     |     v0.8.x     |        |

### Components

The following will introduce the necessary components created when deploying the CSGHub Helm Chart.

- **csghub_server**: Provides the main service logic and API interface to handle client requests and service interactions.

- **csghub_portal**: Responsible for the management and display of the user interface for users to interact directly with the system.

- **csghub_user**: Manages user identity, authentication and related operations to ensure user security and data privacy.

- **csghub_nats**: Implements message passing and event-driven architecture between microservices, and provides efficient asynchronous communication capabilities.

- **csghub_proxy**: Used for request forwarding and load balancing to ensure smooth communication between different services in the system.

- **csghub_accounting**: Responsible for financial and accounting processing, monitoring transactions and generating related reports.

- **csghub_mirror**: Provides warehouse synchronization services to ensure efficient synchronization of warehouse data.

- **csghub_runner**: Responsible for deploying application instances to Kubernetes clusters.

- **csghub_builder**: Mainly responsible for building application images and uploading them to the container image repository.

- **csghub_watcher**: Monitors all secret and configmap changes and manages pod dependencies.

- **gitaly**: CSGHub's Git storage backend, providing efficient implementation of Git operations.

- **gitlab-shell**: Provides Git over SSH interaction between CSGHub and Gitaly repositories for SSH access to Git operations.

- **ingress-nginx**: As an ingress controller in the Kubernetes cluster, it manages traffic from external access to internal services.

- **minio**: Provides object storage services for csghub_server, csghub_portal and gitaly to support file storage and access.

- **postgresql**: A relational database management system responsible for storing and managing (csghub_server / csghub_portal / casdoor) structured data.

- **registry**: Provides a container image repository to facilitate the storage and distribution of container images.

- **redis**: Provides high-performance cache and data storage services for csghub_builder and csghub_mirror, supporting fast data reading and writing.

- **casdoor**: Responsible for user authentication and authorization, providing single sign-on (SSO) and multiple authentication methods.

- **coredns**: Used to process and resolve internal DNS resolution.

- **fluentd**: Log collection and processing framework, aggregating and forwarding application logs for easy analysis and monitoring.

### Data persistence

CSGHub Helm Chart has multiple components that need to persist data, including the following components:

- PostgreSQL ( Default 50Gi )
- Redis ( Default 10Gi )
- Minio ( Default 200Gi )
- Registry ( Default 200Gi )
- Gitaly ( Default 200Gi )
- Builder ( Default 50Gi )
- Nats ( Default 10Gi )
- GitLab-Shell ( Default 1Gi )

In the actual deployment process, you need to customize the size of PVC according to usage, or directly use the scalable StorageClass.

The above persistent storage automatically applies for the creation of PV through PVC, so your Kubernetes cluster needs to support dynamic PV management.

### Domain

CSGHub Helm Chart only supports domain name deployment (Ingress does not support IP addresses).

For example:

if the domain name is specified as **example.com**, the following domain name will be generated after deployment:

- **csghub.example.com**: Access entry for CSGHub services.
- **casdoor.example.com**: Access to casdoor unified login system.
- **minio.example.com**: Access to object storage.
- **registry.example.com**: Access to container image repositories.

If the domain you are using is a public domain name, please configure DNS yourself to ensure that domain names can be correctly resolved. If it is a temporary domain name, please ensure that /etc/hosts and Kubernetes coredns can resolve these domain names.

### KubeConfig

CSGHub deployment depends on the `.kube/config` file of the target cluster. However, as a private configuration file for accessing the Kubernetes cluster, the `.kube/config` file should not be directly placed in `values.yaml`. In addition, because CSGHub supports multi-cluster deployment, the service account (serviceAccount) cannot meet the operation requirements of CSGHub. Therefore, `.kube/config` is essential and must at least include full read and write permissions to the namespace where the target cluster will create the deployment instance.

## Prerequisites

Hardware requirements:

- x86_64/aarch64  8c16g

Software requirements:

- Kubernetes 1.20+
- Helm 3.8.0+
- PV Dynamic Provisioning

## Basic environment preparation

### Deployment Kubernetes

> **Only for users who do not have a k8s basic environment. If you already have a K8S shipping environment, please continue configuration from the next chapter. ** 

> **Tips:**
>
> - The services deployed in this chapter are for testing only and have not been verified in the production environment.
>
> - If you already have a K8S cluster, you can skip the first 3 chapters and directly configure Knative Serving.

For users who do not have a basic environment, you can quickly prepare the deployment environment through this chapter. The deployment content is as follows:

- Kubernetes cluster deployment
- Helm installation
- PV dynamic provisioning

#### Deployment Kubernetes Cluster

Currently, there are many ways to quickly pull up a Kubernetes environment, such as K3S, MiniKube, Kubeadm, MicroK8s, etc. Here we mainly introduce the following two ways to quickly pull up a basic environment:

- **[Docker Desktop](https://docs.docker.com/desktop/kubernetes/)**

    If you are using macOS, using Docker Desktop may be a more convenient way. To enable it, go to:

     `Dashboards` >  `Settings` > `Kubernets` > `Enable Kubernetes` > `Apply`

    Wait for the Kubernetes cluster to start. The Kubernetes cluster integrated with Docker Desktop can support PV dynamic management and ServiceLB. These two features can simplify deployment operations and provide friendly access to CSGHub services during deployment.

- **[K3S](https://docs.k3s.io/zh/quick-start)**

    K3S also has built-in PV Dynamic Provisioning and ServiceLB, and the deployment is simple and practical. The deployment method is as follows:

    ```shell
    # Installing the cluster
    curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.30.4+k3s1 sh -s - --disable=traefik --bind-address=<IPv4>
    
    # The following operations deploy the user CSGHub Helm Chart. The following configuration is not required for normal use of the k3s cluster
    mkdir ~/.kube && cp /etc/rancher/k3s/k3s.yaml .kube/config && chmod 0400 .kube/config
    
    # Before proceeding, please make sure that the Kubernetes cluster is running properly:
    # Confirm node health
    kubectl get nodes 
    # Confirm that all Pods are running normally
    kubectl get pods -A 
    ```

#### Install Helm

There are two installation methods:

- [Official](https://helm.sh/docs/intro/install/)

    ```shell
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh && ./get_helm.sh && helm version
    ```

- Other

    ```shell
    snap install helm --classic && helm version
    ```

#### Configuring PV Dynamic Management

If your cluster already supports this feature, or if it is a Kubernetes cluster enabled by the above method, you can skip this section. The method described in this section is **only for testing**, **only for testing**, **only for testing**, and **only for testing**. Do not use it in a production environment.

The solution here comes from [kubernetes-sigs/sig-storage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner), please refer to [Install local-volume-provisioner with helm](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner) for details.

The detailed configuration operations are as follows:

1. Create StorageClass

    ```shell
    # Create namespace
    kubectl create ns kube-storage
    
    # Create storage class
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
    ```

2. Deployment local-volume-provisoner

    ```shell
    # Add helm repository
    helm repo add sig-storage-local-static-provisioner https://kubernetes-sigs.github.io/sig-storage-local-static-provisioner
    
    # Update the repository
    helm repo update
    
    # Creating resource files
    helm template --debug sig-storage-local-static-provisioner/local-static-provisioner --namespace kube-storage | sed 's/registry.k8s.io/opencsg-registry.cn-beijing.cr.aliyuncs.com\/opencsg_public/g'> local-volume-provisioner.generated.yaml
    
    # Application resource files
    kubectl apply -f local-volume-provisioner.generated.yaml
    ```

3. Creating a Virtual Disk

    ```shell
    for flag in {a..z}; do
    	mkdir -p /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} 2>/dev/null
    	mount --bind /mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag}
    	echo "/mnt/fake-disks/sd${flag} /mnt/fast-disks/sd${flag} none bind 0 0" >> /etc/fstab
    done
    ```

   *Note: This mounting method cannot strictly control the PV size, but it does not affect the test use.* 

4. Functional Verification

    ```shell
    cat <<EOF | kubectl apply -f -
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: local-volume-example
      namespace: default
    spec:
      serviceName: "local-volume-example-service"
      replicas: 1  # 实例数量
      selector:
        matchLabels:
          app: local-volume-example
      template:
        metadata:
          labels:
            app: local-volume-example
        spec:
          containers:
          - name: local-volume-example
            image: busybox:latest
            ports:
            - containerPort: 80
            volumeMounts:
            - name: example-storage
              mountPath: /data
      volumeClaimTemplates:
      - metadata:
          name: example-storage
        spec:
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 1Gi
    EOF
    
    # Verify pvc/pv
    kubectl get pvc
    ```

### Configuration Existing Kubernetes

> **If you already have a Kubernetes basic environment, please continue configuration from this section. **

> **Tip:**
>
> - This section does not apply to K8S clusters created using the above method.

Although this helm chart has a simple Container Registry built in for testing, it does not provide reliable encrypted access. You still need to go through [more configuration](https://github.com/containerd/containerd/blob/main/docs/hosts.md) to pull images from the Registry normally. Please prepare the Registry for the production environment yourself.

- Configure containerd to allow access to the Registry using insecure encryption

    Before configuration, please confirm whether the configuration file `/etc/containerd/config.toml` exists. If it does not exist, you can use the following command to create it.

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

         This configuration requires restarting the containerd service.

      2. Restart Containerd

         ```shell
         systemctl restart containerd
         ```
    
      3. Configure hosts.toml
    
         ```shell
         # This port is the built-in NodePort port of this helm, which can be modified through .Values.global.registry.service.nodePort
         mkdir /etc/containerd/certs.d/registry.example.com:32500
           
         cat <<EOF > /etc/containerd/certs.d/registry.example.com:32500/hosts.toml
         server = "https://registry.example.com:5000"
           
         [host."http://192.168.170.22:5000"]
           capabilities = ["pull", "resolve", "push"]
           skip_verify = true
         EOF
         ```
    
         *Note: This configuration takes effect immediately without restarting.*
    
      4. Verify the configuration
    
         ```shell
         ctr images pull --hosts-dir "/etc/containerd/certs.d" registry.example.com:5000/image_name:tag
         ```

## Deployment Knative Serving

Knative Serving is a necessary component for CSGHub to create application instances.

- [Install Knative Serving using YAML files](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#install-a-networking-layer)

The steps are as follows

1. Installing core components

    ```shell
    # Installing Custom Resources
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-crds.yaml
        
    # Installing core resources
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-core.yaml
    ```

2. Installing Network Components

    ```shell
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/kourier.yaml
    ```

3. Configuring default network components

    ```shell
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
    ```

4. Configuring service access methods

    ```shell
    kubectl patch service/kourier \
        --namespace kourier-system \
        --type merge \
        --patch '{"spec": {"type": "NodePort"}}'
    ```

5. <a id="configure-dns">Configure DNS</a>

    Configure Knative Serving to use RealDNS with the following configuration.

    ```shell
    kubectl patch configmap/config-domain \
      --namespace knative-servings \
      --type merge \
      --patch '{"data":{"app.internal":""}}' 
    ```

    `app.internal` is a secondary domain name used to expose the ksvc service. This domain name does not need to be exposed to the Internet, so you can define it as any domain name. This domain name resolution will be completed through the coredns component of the CSGHub Helm Chart.

6. Disable ksvc pod scaling to 0

    ```shell
    kubectl patch configmap/config-autoscaler \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"enable-scale-to-zero":"false"}}'
    ```

7. <a id="kourier-svc">Verify all services</a>

    ```shell
    $ kubectl -n kourier-system get service kourier
    NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
    kourier   NodePort   10.43.190.125   <none>        80:32497/TCP,443:30876/TCP   42m
        
    $ kubectl -n knative-serving get pods
    NAME                                     READY   STATUS    RESTARTS   AGE
    activator-665d7d76b7-fc2x5               1/1     Running   0          42m
    autoscaler-779b955d67-zpcqr              1/1     Running   0          42m
    controller-69b7d4cd45-r2cnl              1/1     Running   0          18m
    net-kourier-controller-cf85dbc87-rbfpw   1/1     Running   0          42m
    webhook-6c655cb488-2mm26                 1/1     Running   0          42m
    ```

​	Confirm that all services are running normally.

## Install CSGHub Helm Chart

### Manual deployment

#### Create KubeConfig Secret

We need to create the Secret for saving `.kube/config` by ourselves. Since the configuration file is relatively private, it is not integrated into the helm chart.

If you have multiple config files, you can store them in the target directory in the form of `.kube/config*`. After the Secret is created, it will be stored uniformly.

```shell
# This namespace will be used later
kubectl create ns csghub 
# Create Secret
kubectl -n csghub create secret generic kube-configs --from-file=/root/.kube/
```

#### Deployment CSGHub

1. Add helm repository

    ```shell
    helm repo add csghub https://opencsgs.github.io/csghub-installer
    helm repo update
    ```

2. Deployment CSGHub

    - `global`

        - `domain`：The [Second-level domain name](#Domain) required in the previous section.
        - `runner.internalDomain[i]`
            - `domain`：The internal domain name configured when installing Knative Serving (#configure-dns).
            - `host`：The `EXTERNAL-IP` address exposed by the [Kourier component service](#kourier-svc). In the example, `172.25.11.130` is the local IP address.
            - `port`：The NodePort port corresponding to port 80 exposed by the Kourier component service is 32497 in this example.

    - **LoadBalancer**

        >**Tips：**If you are using an automatic installation script or the cluster you are using does not have the LoadBalancer provisioning capability, please use the NodePort method to install it. Otherwise, after installation, CSGHub will occupy port 22 on the local machine, causing SSH to fail to log in normally. If you insist on using the LoadBalancer service type for installation, please change the server SSHD service port to a non-port 22 in advance.

        ```shell
        helm install csghub csghub/csghub \
        	--namespace csghub \
        	--create-namespace \
        	--set global.domain=example.com \
        	--set global.runner.internalDomain[0].domain=app.internal \
        	--set global.runner.internalDomain[0].host=172.25.11.130 \
        	--set global.runner.internalDomain[0].port=32497
        ```

    - **NodePort**

        If the Kubernetes environment you are using does not have the LoadBalancer load balancing function, you can deploy it in the following way.

        ```shell
        helm install csghub csghub/csghub \
        	--namespace csghub \
        	--create-namespace \
        	--set global.domain=example.com \
        	--set global.ingress.service.type=NodePort \
        	--set global.runner.internalDomain[0].domain=app.internal \
        	--set global.runner.internalDomain[0].host=172.25.11.130 \
        	--set global.runner.internalDomain[0].port=32497
        ```

        Due to configuration dependency issues, the NodePort port is defined as the following mappings: 80/30080, 443/30443, 22/30022.

3. Configure Knative Serving

    When deploying CSGHub Helm Chart, a self-signed certificate is used by default to reduce unnecessary problems. Therefore, Knative Serving needs to be configured to pull the image normally.

    ```shell
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

4. DNS Resolution

    If you are using a cloud server and have a domain name that has been registered and can be used normally, please configure DNS to resolve the domain names `csghub.example.com`, `casdoor.example.com`, `minio.example.com`, and `registry.example.com` to the cloud server.

    If you are using a local test server, please configure the host and client's /etc/hosts domain name resolution, and configure Kubernetes CoreDNS as follows:

    ```shell
    # Add custom domain name resolution
    $ kubectl apply -f - <<EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: coredns-custom
      namespace: kube-system
    data:
      example.server: |
        example.com {
          hosts {
            172.25.11.131 csghub.example.com csghub
            172.25.11.131 casdoor.example.com casdoor
            172.25.11.131 registry.example.com registry
            172.25.11.131 minio.example.com minio
          }
        }
    EOF
    
    # Update coredns pods
    $ kubectl -n kube-system rollout restart deploy coredns
    ```

5. Configure Registry

    If your basic K8S environment uses K3S, you can configure it in the following ways:

    ```shell 
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
    ```

    Restart K3s.

    ```shell
    systemctl restart k3s
    ```

6. Visit CSGHub

    Login URL: 

    - LoadBalancer: http://csghub.example.com 
    - NodePort: http://csghub.example.com:30080

    Username：`root`

    Password：`Um9vdEAxMjM0NTY=`

    *For more information, see the helm install output, which is roughly as follows:*

    ```shell
    ......
    To access the CSGHub Portal®, please navigate to the following URL:
    
        http://csghub.example.com
    
    You can use the following admin credentials to log in:
         Username: root
         Password: xxxxxxxx
    ......
    ```

### Quick deployment

Use the try method to quickly start the CSGHub Helm Chart test environment.

```shell
# <domain>: like example.com
## default ingress service type: NodePort
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | bash -s -- <domain>

## Tip: When using the LoadBalancer service type for installation, please change the server sshd service port to a non-port 22 in advance. This type will automatically occupy port 22 as the git ssh service port.
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | INGRESS_SERVICE_TYPE=LoadBalancer bash -s -- <domain>

## Enable NVIDIA GPU support
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | ENABLE_NVIDIA_GPU=true bash -s -- <domain>
```

If it is a custom domain name, please configure local hosts resolution before accessing.

## Troubleshooting

### dial tcp: lookup casdoor.example.com on 10.43.0.10:53: no such host

This problem occurs because the cluster cannot resolve the custom domain name. You need to add the domain name resolution to the coredns configuration inside Kubernetes.

### ssh: connect to host csghub.example.com port 22: Connection refused

This problem is caused by a bug in helm adaptation. The temporary solution is as follows:

```shell
$ kubectl -n csghub edit configmap/csghub-ingress-nginx-tcp
....
data:
  "22": csghub/csghub-gitlab-shell:22
....

$ kubectl rollout restart deploy csghub-ingress-nginx-controller -n csghub
```

### Clicking on the avatar does not allow you to create a new warehouse

This issue has been fixed in v0.9.3 and later versions. The temporary solution is as follows:

Click on the avatar > Account settings > Fill in **Email** > Save

### Space Application instance not building

This issue has been fixed in v0.9.3 and later versions. The temporary solution is as follows:

Click your profile picture > Account Settings > Access Token
