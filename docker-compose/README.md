# CSGHub Docker Compose Deployment Guide

> **Tips:**
>
> - v0.4.0 supports the Space function.
> - v0.7.0 supports model fine-tuning and inference, as well as the Space function.
> - [中文文档](../docs/zh/README_cn_docker_compose.md)

## Overview

This script enables the one-click deployment of an all-in-one CSGHub instance, including all related components:

- **csghub_server:** Provides the main service logic and API interface to handle client requests and service interactions.

- **csghub_portal:** Responsible for the management and display of the user interface, allowing users to interact directly with the system.

- **user_server:** Manage user identity, authentication, and related operations to ensure user security and data privacy.

- **natsmaster:** Implement messaging and event-driven architecture between microservices, and provide efficient asynchronous communication capabilities.

- **csghub_server_proxy:** Used for request forwarding and load balancing to ensure smooth communication between different services in the system.

- **account_server:** Responsible for financial and accounting processing, monitoring transactions and generating relevant reports.

- **mirror-repo-sync/mirror-lfs-sync:** Provide warehouse synchronization services to ensure efficient synchronization of warehouse data.

- **csghub_server_runner:** Responsible for deploying application instances to the Kubernetes cluster.

- **space_builder:** Mainly responsible for building application images and uploading them to the container image repository.

- **gitaly:** CSGHub's Git storage backend, providing efficient implementation of Git operations.

- **gitlab-shell:** Provides Git over SSH interaction between CSGHub and Gitaly repositories for SSH access for Git operations.

- **ingress-nginx:** As an ingress controller in a Kubernetes cluster, it manages traffic from external access to internal services.

- **minio:** Provides object storage services for csghub_server, csghub_portal, and gitaly to support file storage and access.

- **postgresq:** A relational database management system responsible for storing and managing (csghub_server/csghub_portal/casdoor) structured data.

- **registry:** Provides a container image repository to facilitate the storage and distribution of container images.

- **redis:** Provides high-performance cache and data storage services for csghub_builder and csghub_mirror, supporting fast data reading and writing.

- **casdoor:** Responsible for user authentication and authorization, providing single sign-on (SSO) and multiple authentication methods.

- **coredns:** Used to handle and resolve internal DNS resolution.

- **fluentd:** A log collection and processing framework that aggregates and forwards application logs for easy analysis and monitoring.

- **temporal:** Asynchronous task management service.

- **temporal-ui:** Provide asynchronous task viewing dashboard. 

- **nginx:** Provide routing forwarding.

## Prerequisites

* **Hardware**
    * Minimum: 4 CPU/8GB RAM/50GB Hard Disk
    * Recommended: 8 CPU/16GB RAM/500GB Hard Disk


* **Software**
    - Linux/AMD64, Linux/ARM64
    - Docker Engine (>=5:20.10.24)

## Usage

1. Navigate to the `docker-compose` directory.
2. Edit the `.env` file and set `SERVER_DOMAIN` to the current host's IP address or domain name. DO NOT use `127.0.0.1` or `localhost`.
3. The space and registry related configurations in .env can be ignored without Kubernetes cluster. The configuration for integration with the existing Kubernetes cluster can be found in following [section](#Configure-kubernetes).
4. Run the `startup.sh` script. Once all services are started, you can visit the self-deployed CSGHub service at `http://[SERVER_DOMAIN]`. If SERVER_PORT not 80 default, please visit by adding `:[SERVER_PORT]`.
5. Once CSGHub instance startup, you can login with default admin account with `root/Root@1234`.
6. You can access backend async task panel with `/temporal-ui` and default admin account is `admin/Admin@1234` 

### Notes

1. Self-deployed CSGHub uses local-type Docker volumes for persistence, such as for PostgreSQL and Minio. Ensure that Docker local volumes have sufficient disk space.
2. Ensure that the external port `2222` of the host is accessible, as Git operations via the SSH protocol depend on it.
3. Make sure the host's external port `31001` is accessible, which is used by the casdoor service for user registration and login.
4. The Minio console can be visited through the port `9001`. If Minio console is not required, this port can be closed.
5. By default, only HTTP protocol is supported for CSGHub services. If HTTPS is required, configure it accordingly.
6. Completely remove CSGHub instance with below command:
```
docker compose -f docker-compose.yml down -v
```

## Configure Kubernetes

### Prerequisites

- Kubernetes version > 1.20+.
- Minimum server configuration 8c16g, X86_64 architecture (non-X86_64 system architecture is not supported yet).
- Kubernetes can be deployed in a variety of ways, such as Docker Desktop, [K3s](https://docs.k3s.io/quick-start), [Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
- CSGHub instance running with Docker Compose installation scripts.

### Knative Configuration

Please refer to [Knative installation](https://opencsg.com/docs/csghub/101/helm/installation) for knative configuration.

### Argo Workflow Configuration

Please refer to [Argo installation](https://opencsg.com/docs/csghub/101/helm/installation) for argo configuration.

### CSGHub Configuration

Reconfigure CSGHub instance to connect to the specified Kubernetes cluster. Assume the following information:
- CSGHub IP：`110.95.70.140`
- Kubernetes Master node: `101.201.52.76`
- Kubernetes Worker node: `59.10.62.160`
- Using service type`NodePort` to expose Knative service，its value is`30541`.

Refer to [Knative config](https://opencsg.com/docs/csghub/101/helm/installation#%E5%AE%89%E8%A3%85%E7%BD%91%E7%BB%9C%E7%BB%84%E4%BB%B6) for more details. 

### Reconfigure CSGHub instance

Based on the above information, first change the `.env` file content as follows:
```
# Common Configuration
## CSGHub service's domain name, can be ip or domain name
SERVER_DOMAIN=110.95.70.140
SERVER_PORT=80


## Casdoor Configuration
SERVER_CASDOOR_PORT=31001

## Default CSGHub server token. A 128-bit string consisting of numbers and lowercase letters.
HUB_SERVER_API_TOKEN=c7ab4948c36d6ecdf35fd4582def759ddd820f8899f5ff365ce16d7185cb2f609f3052e15681e931897259872391cbf46d78f4e75763a0a0633ef52abcdc840c

## Space Configuration
### The namespace that user's space app will use
SPACE_APP_NS=space

### User space app's internal domain name. It is knative network layer endpoint, it can be an internal lb or ip which will not be exposed to external
SPACE_APP_INTERNAL_DOMAIN=app.internal
### if internal domain uses lb service, it should be 80 or 443
SPACE_APP_INTERNAL_DOMAIN_PORT=30541
## User space app's external domain name (it should be a wildcard domain, CAN NOT BE ip address!!)
SPACE_APP_EXTERNAL_DOMAIN=

### space builder sever. the docker daemon that used to build space image, such as "59.110.62.16:31375"
SPACE_BUILDER_SERVER=110.95.70.140:31375


## Registry configuration
DOCKER_REGISTRY_SECRET=space-registry-credential
DOCKER_REGISTRY_SERVER=110.95.70.140:5000
DOCKER_REGISTRY_USERNAME=csghub
DOCKER_REGISTRY_PASSWD=csghub@2024!
DOCKER_REGISTRY_NS=opencsg_space

## Knative gateway Configuration
### The namespace that user's  app will use
#KNATIVE_APP_NS=space
### It is knative network layer endpoint, it can be an internal lb or ip which will not be exposed to external
#KNATIVE_DOMAIN=app.internal
#### the expose ip or host that can visit knative service, it can be lb or k8s worker ip (using nodeport)
KNATIVE_GATEWAY_HOST=59.10.62.160
### if knative domain uses lb service, it should be 80 or 443
KNATIVE_GATEWAY_PORT=30541
```

Move kube config file of the Kubernetes cluster to the `.kube` folder of the CSGHub installation directory and restart CSGHub instance:

```
docker compose -f docker-compose.yml down
docker compose -f docker-compose.yml up -d
```

#### Reconfigure Kubernetes


- Create new namespace and secret
```
kubectl create ns space

kubectl create secret docker-registry space-registry-credential --docker-server=110.95.70.140:5000 --docker-username=csghub --docker-password=csghub@2024! -n space
```

- Enable CSGHub's insecure docker registry for Kubernetes

    The default installation of CSGHub uses an insecure registry (that is, the one mentioned above: 110.95.70.140:5000). You need to ensure that Kubernetes can pull images from this registry. Perform the following operations on each worker node of Kubernetes:

    Before configuration, please confirm whether the configuration file `/etc/containerd/config.toml` exists or not. If not, you can create it with the following command.

    ```shell
    mkdir -p /etc/containerd/ && containerd config default >/etc/containerd/config.toml
    ```

1. config_path settings 

   - Containerd 2.x

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

2. restart `containerd` service

    ```shell
    systemctl restart containerd
    ```

3. hosts.toml settings

    ```shell
    mkdir /etc/containerd/certs.d/110.95.70.140:5000
    
    cat <<EOF > /etc/containerd/certs.d/110.95.70.140:5000/hosts.toml
    server = "http://110.95.70.140:5000"
    
    [host."http://110.95.70.140:5000"]
            capabilities = ["pull", "resolve", "push"]
            skip_verify = true
    EOF
    ```

​	*Note: This configuration takes effect directly.*
