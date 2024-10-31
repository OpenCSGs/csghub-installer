# CSGHub Helm Chart Deployment Document（Detailed）

## CSGHub Summary

CSGHub is an open source, trusted large model asset management platform that helps users manage assets (datasets, model files, codes, etc.) involved in the life cycle of LLM and LLM applications. Based on CSGHub, users can operate assets such as model files, data sets, codes, etc. through the Web interface, Git command line, or natural language Chatbot, including uploading, downloading, storage, verification, and distribution; at the same time, the platform provides microservice submodules and standardized APIs to facilitate users to integrate with their own systems.

CSGHub is committed to bringing users an asset management platform that is natively designed for large models and can be privately deployed and run offline. CSGHub provides a similar private Huggingface function to manage LLM assets in a similar way to OpenStack Glance managing virtual machine images, Harbor managing container images, and Sonatype Nexus managing artifacts.

## Deployment

Currently, there are three official deployment methods:

- [Docker](../../docker/README.md)

- [Docker Compose](../../docker-compose/README.md)

- [Helm Chart](../../helm-chart/README.md)

This document describes how to deploy Helm Chart. Helm Chart currently only contains the creation of necessary resources for necessary components. If you encounter any problems during use, you can submit feedback through:

-  [csghub-installer](https://github.com/OpenCSGs/csghub-installer/issues)

Contributions to this deployment project are also welcome.

## Version Notes

Currently, the version of csghub helm chart is basically consistent with the csghub version.

| Chart version | Csghub version | Remark |
| :-----------: | :------------: | ------ |
|     0.9.x     |     0.9.x      |        |
|     0.8.x     |     0.8.x      |        |

## Component Introduction

The following describes the necessary components created when the csghub helm chart is deployed.

1. **csghub_server**: Provides the main service logic and API interface to handle client requests and service interactions.
2. **csghub_portal**: Responsible for the management and display of the user interface, allowing users to interact directly with the system.
3. **csghub_user**: Manage user identity, authentication, and related operations to ensure user security and data privacy.
4. **csghub_nats**: Implement messaging and event-driven architecture between microservices, and provide efficient asynchronous communication capabilities.
5. **csghub_proxy**: Used for request forwarding and load balancing to ensure smooth communication between different services in the system.
6. **csghub_accounting**: Responsible for financial and accounting processing, monitoring transactions and generating relevant reports.
7. **csghub_mirror**: Provide warehouse synchronization services to ensure efficient synchronization of warehouse data.
8. **csghub_runner**: Responsible for deploying application instances to the Kuberenetes cluster.
9. **csghub_builder**: Mainly responsible for building application images and uploading them to the container image repository.
10. **csghub_watcher**: Monitor all secret and configmap changes and manage pod dependencies.
11. **gitaly**: CSGHub's Git storage backend, providing efficient implementation of Git operations.
12. **gitlab-shell**: Provides Git over SSH interaction between CSGHub and Gitaly repositories for SSH access for Git operations.
13. **ingress-nginx**: As an ingress controller in a Kubernetes cluster, it manages traffic from external access to internal services.
14. **minio**: Provides object storage services for csghub_server, csghub_portal, and gitaly to support file storage and access.
15. **postgresql**: A relational database management system responsible for storing and managing (csghub_server / csghub_portal / casdoor) structured data.
16. **registry**: Provides a container image repository to facilitate the storage and distribution of container images.
17. **redis**: Provides high-performance cache and data storage services for csghub_builder and csghub_mirror, supporting fast data reading and writing.
18. **casdoor**: Responsible for user authentication and authorization, providing single sign-on (SSO) and multiple authentication methods.
19. **coredns**: Used to handle and resolve internal DNS resolution.
20. **fluentd**: A log collection and processing framework that aggregates and forwards application logs for easy analysis and monitoring.

## Persistent Data

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

## Domain

CSGHub Helm Chart deployment requires a domain name, and Ingress does not currently support the use of IP addresses. In actual deployment, you need to specify a domain name similar to `example.com`. After deployment, the following domain name will be automatically used:

- **csghub.example.com**: Access entry for the csghub main service.
- **casdoor.example.com**: Used to access the casdoor unified login system.
- **minio.example.com**: Used to access object storage.
- **registry.example.com**: Used to access the container image repository.

If the domain name you are using is a public domain name, please configure DNS yourself to ensure that the above domain names can be correctly resolved to the Kubernetes cluster. If it is a temporary domain name, please ensure that the host's /etc/hosts and Kubernetes coredns can resolve these domain names.

## Kube Config 

The `.kube/config` file is an important private configuration file for accessing the Kubernetes cluster. It is required during the deployment of the csghub helm chart. Because csghub supports cross-cluster features, the service account (serviceAccount) cannot meet the operation requirements of csghub. This `.kube/config` must at least contain full read and write permissions to the namespace where the target cluster deployment instance is located.

## Prerequisites

Hardware requirements for the deployment environment:

- X86_64 8c16g
- Arm64 ( Then came )

Software requirements for the deployment environment:

- Kubernetes 1.20+
- Helm 3.8.0+
- PV Dynamic Provisioning
- Knative Serving

## Basic environment preparation

For users of the basic environment, you can quickly prepare the prerequisites through this chapter. It mainly involves the following:

- Kubernetes cluster deployment
- Helm installation
- PV dynamic management simulation
- Knative Serving deployment

### Kubernetes

There are many ways to quickly pull up the Kubernetes environment, such as K3S, MiniKube, Kubeadm, MicroK8s, etc. Here we mainly introduce the following two ways to quickly pull up the basic environment:

- [Docker Desktop](https://docs.docker.com/desktop/kubernetes/)

If you are using macOS environment, using Docker Desktop may be a more convenient way. The activation method is as follows:

`Dashboards` > `Settings` > `Kubernets` > `Enable Kubernetes` > `Apply`

Wait for the Kubernetes cluster to start. The Kubernetes cluster integrated with Docker Desktop can support PV dynamic management and ServiceLB. These two features can simplify deployment operations and provide friendly access to csghub services during deployment.

- [K3S](https://docs.k3s.io/zh/quick-start)

K3S also has built-in PV Dynamic Provisioning and ServiceLB, and the deployment is simple and practical. The deployment method is as follows:

```shell
# Install kubernetes cluster
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_VERSION=v1.30.4+k3s1 sh -s - --disable=traefik

# The following operations deploy the user csghub helm chart. The following configuration is not required for normal use of the k3s cluster
mkdir ~/.kube && cp /etc/rancher/k3s/k3s.yaml .kube/config && chmod 0400 .kube/config
```

Before proceeding, please confirm that the Kubernetes cluster is running properly:

```shell
# Confirm that the nodes are healthy
kubectl get nodes
# Confirm that all Pods are running properly
kubectl get pods -A
```

### Helm

There are two installation methods:

- [Offical](https://helm.sh/docs/intro/install/)

    ```shell
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh && ./get_helm.sh && helm version
    ```

- Other

    ```shell
    snap install helm --classic && helm version
    ```

### PV Dynamic Provisioning

If your cluster already supports this feature, or if it is a Kubernetes cluster enabled by the above method, you can skip this section. The method described in this section is **only for testing**, **only for testing**, **only for testing**, and should not be used in production environments.

The solution here comes from [kubernetes-sigs/sig-storage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner)

For details, please refer to [Install local-volume-provisioner with helm](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/helm/README.md)

The deployment method is as follows:

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
    
    # Update helm repository
    helm repo update
    
    # Rendering resource files
    helm template --debug sig-storage-local-static-provisioner/local-static-provisioner --namespace kube-storage | sed 's/registry.k8s.io/opencsg-registry.cn-beijing.cr.aliyuncs.com\/opencsg_public/g'> local-volume-provisioner.generated.yaml
    
    # Apply resource files
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

4. Functional testing

    ```shell
    cat <<EOF | kubectl apply -f -
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: local-volume-example
      namespace: default
    spec:
      serviceName: "local-volume-example-service"
      replicas: 1 
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
    
    # Review pvc/pv resources created
    kubectl get pvc
    ```

### Knative Serving

Knative Serving is a necessary component for csghub to create application instances. Because this component is not necessarily installed in the cluster where csghub is located, it is not integrated into the csghub helm chart. However, although the installation of this service requires more resources, it is usually smoother. For details, please refer to the following:
    
- [Install Knative Serving using YAML files](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#install-a-networking-layer)
    
Deployment is as follows:

1. Installing core components

    ```shell
    # Installing Custom Resources
    kubectl apply -f https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/knative/serving-crds.yaml
            
    # Installing Core Components
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

   Knative Serving provides multiple DNS methods, but currently only supports RealDNS. The configuration is as follows.

    ```shell
    kubectl patch configmap/config-domain \
      --namespace knative-servings \
      --type merge \
      --patch '{"data":{"app.internal":""}}' 
    ```

    `app.internal` is a secondary domain name used to expose the ksvc service. This domain name does not need to be exposed to the Internet, so you can define it as any domain name. This domain name resolution will be completed through the coredns component of the csghub helm chart.

6. Turn off enable-scale-to-zero

    ```shell
    kubectl patch configmap/config-autoscaler \
        --namespace knative-serving \
        --type merge \
        --patch '{"data":{"enable-scale-to-zero":"false"}}'
    ```

7. <a id="kourier-svc">Service Verification</a>

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

Confirm that all services are running normally.

## Install CSGHub Helm Chart

### Manual deployment

#### Create KubeConfig Secret

We need to create the Secret for saving `.kube/config` ourselves. Since the configuration file is relatively private, it is not integrated into the helm chart.

If you have multiple config files, you can store them in the target directory using `.kube/config*`. After the Secret is created, they will be stored uniformly.

```shell
# This namespace will be used later.
kubectl create ns csghub 
# Create Secret
kubectl -n csghub create secret generic kube-configs --from-file=/root/.kube/
```

#### Deployment csghub

1. Add helm repo

    ```shell
    helm repo add csghub https://opencsgs.github.io/csghub-installer
    helm repo update
    ```

2. Deploymnet csghub

    - `global`

        - `domain`: The [secondary domain name](#Domain) required in the previous section.
        - `runner.internalDomain[i]`
            - `domain`: The [internal domain name](#configure-dns) configured when installing Knative Serving.
            - `host`: The `EXTERNAL-IP` address exposed by the [Kourier component service](#kourier-svc). In the example, `172.25.11.130` is the local IP address.
            - `port`: The `NodePort` port corresponding to 80 exposed by the [Kourier component service](#kourier-svc). In this example, it is `32497`.

    - LoadBalancer

      <font color='red'>*Hint: If you are using the [automatic installation script](https://github.com/OpenCSGs/csghub-installer/blob/main/helm-chart/README.md#quick-deployment) or do not have the LoadBalancer supply capability, please use the NodePort method to install it. Otherwise, csghub will occupy port 22 of the local machine after installation. If you insist on using the LoadBalancer service type for installation, please modify the server sshd service port to a non-port 22 in advance.*</font>

        ```shell
        helm install csghub csghub/csghub \
        	--namespace csghub \
        	--create-namespace \
        	--set global.domain=example.com \
        	--set global.runner.internalDomain[0].domain=app.internal \
        	--set global.runner.internalDomain[0].host=172.25.11.130 \
        	--set global.runner.internalDomain[0].port=32497
        ```

    - NodePort

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

        Due to configuration complexity, NodePort ports are defined as the following mappings: 80/30080, 443/30443, 22/30022.
   
3. Configure DNS

    If you are using a cloud server and have a domain name that has been registered and can be used normally, please configure DNS to resolve the csghub.example.com, casdoor.example.com, minio.example, and registry.example.com domain names to the cloud server.

    If you are using a local test server, please configure the host and client's `/etc/hosts` domain name resolution, and configure Kubernetes coredns. The configuration method is as follows:

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

4. Access csghub

    Login URL: http://csghub.example.com 或 http://csghub.example.com:30080

    Username：root

    Password：
    
    *See the helm install output, the output is as follows:*

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

Use the try method to quickly start the csghub helm chart test environment.

```shell
# <domain>: like example.com
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/helm-chart/install.sh | bash -s -- example.com
```

After the script is executed, you still need to configure DNS resolution yourself.

## Troubleshooting

### dial tcp: lookup casdoor.example.com on 10.43.0.10:53: no such host

This problem is caused by the cluster being unable to resolve the custom domain name. Domain name resolution needs to be added to the coredns configuration inside Kubernetes.

### ssh: connect to host csghub.example.com port 22: Connection refused

This problem is caused by a bug in helm adaptation. The temporary solution is as follows:

```shell
# Modify configuration
$ kubectl -n csghub edit configmap/csghub-ingress-nginx-tcp
....
data:
  "22": csghub/csghub-gitlab-shell:22
....
# Apply configuration
$ kubectl rollout restart deploy csghub-ingress-nginx-controller -n csghub
```

### Clicking on the avatar fails to create a new warehouse

This issue has been fixed in later versions, the temporary solution is as follows:

`Click on the avatar` > `Account Settings` > `Fill in Email` > `Save`

### The application space instance is not built

This issue has been fixed in later versions, the temporary solution is as follows:

`Click on the avatar` > `Account Settings` > `Access Token`




