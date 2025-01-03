# CSGHub Docker Compose Deployment Guide

> **Tips:**
>
> - v0.4.0 supports Space Application.
> - v0.7.0 supports Model Finetune and Inference.
> - v1.2.0 supports Model Evaluation.
> - [中文文档](../docs/zh/README_cn_docker_compose.md)

## Overview

This script enables the one-click deployment of an all-in-one CSGHub instance, including all related components:

- **csghub-server:** Provides the main service logic and API interface to handle client requests and service interactions.

- **csghub-portal:** Responsible for the management and display of the user interface, allowing users to interact directly with the system.

- **csghub-user:** Manage user identity, authentication, and related operations to ensure user security and data privacy.

- **nats:** Implement messaging and event-driven architecture between microservices, and provide efficient asynchronous communication capabilities.

- **csghub-proxy:** Used for request forwarding and load balancing to ensure smooth communication between different services in the system.

- **csghub-accounting:** Responsible for financial and accounting processing, monitoring transactions and generating relevant reports.

- **csghub-mirror-repo/csghub-mirror-lfs:** Provide warehouse synchronization services to ensure efficient synchronization of warehouse data.

- **csghub-runner:** Responsible for deploying application instances to the Kubernetes cluster.

- **csghub-space-builder:** Mainly responsible for building application images and uploading them to the container image repository.

- **gitaly:** CSGHub's Git storage backend, providing efficient implementation of Git operations.

- **gitlab-shell:** Provides Git over SSH interaction between CSGHub and Gitaly repositories for SSH access for Git operations.

- **minio:** Provides object storage services for csghub_server, csghub_portal, and gitaly to support file storage and access.

- **postgresql:** A relational database management system responsible for storing and managing (csghub_server/csghub_portal/casdoor) structured data.

- **registry:** Provides a container image repository to facilitate the storage and distribution of container images.

- **redis:** Provides high-performance cache and data storage services for csghub_builder and csghub_mirror, supporting fast data reading and writing.

- **casdoor:** Responsible for user authentication and authorization, providing single sign-on (SSO) and multiple authentication methods.

- **coredns:** Used to handle and resolve internal DNS resolution.

- **temporal:** Asynchronous task management service.

- **temporal-ui:** Provide asynchronous task viewing dashboard. 

- **nginx:** Provide routing forwarding.

## Prerequisites

* **Hardware**
    * Minimum: 4 CPU/8GB RAM/50GB Hard Disk
    * Recommended: 8 CPU/16GB RAM/500GB Hard Disk


* **Software**
    - Linux/AMD64, Linux/ARM64(Continuing to adapt)
    - Docker Engine (>=5:20.10.24)

## Usage

1. Navigate to the `docker-compose` directory.
2. Edit the `.env` file and set `SERVER_DOMAIN` to the current host's IP address or domain name. (DO NOT use `127.0.0.1` or `localhost`!!!).
3. The Space and Registry related configurations in .env can be ignored without Kubernetes cluster. The configuration for integration with the existing Kubernetes cluster can be found in following [section](#Configure-kubernetes).
4. Run the `startup.sh` script. Once all services are started, you can visit the self-deployed CSGHub service at `http://[SERVER_DOMAIN]`. If SERVER_PORT not 80 default, please visit by adding `:[SERVER_PORT]`.
5. Once CSGHub instance startup, you can login with default admin account with `root/Root@1234`.
6. All other user/password can be found in `.env`.

*NOTES: Please use `startup.sh` to apply the modified configuration (at any time).*

### Notes

1. Self-deployed CSGHub uses local-type Docker volumes for persistence, such as for PostgreSQL and Minio. Ensure that Docker local volumes have sufficient disk space.
2. Ensure following node ports exposed (default):
    - 2222: Git Over SSH
    - 5000: Registry
    - 8000: Casdoor
    - 9000: Minio API
    - 9001: Minio Console
3. By default, only HTTP protocol is supported for CSGHub services. If HTTPS is required, configure it accordingly.
4. Completely remove CSGHub instance with below command:
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
- Using service type `NodePort` to expose Knative service，its value is`30541`.

Refer to [Knative config](https://opencsg.com/docs/csghub/101/helm/installation#%E5%AE%89%E8%A3%85%E7%BD%91%E7%BB%9C%E7%BB%84%E4%BB%B6) for more details. 

### Reconfigure CSGHub instance

Based on the above information, first change the `.env` file content as follows:
```
## External URL
## Default it should be your server ipv4 address or domain.
SERVER_DOMAIN="110.95.70.140"
SERVER_PORT=80

SPACE_APP_NAMESPACE="space"
## Define knative serving internal domain.
## It is knative network layer endpoint.
## it can be an internal lb or ip which will not be exposed to external
SPACE_APP_INTERNAL_DOMAIN="app.internal"
## Define kourier network plugin service ip and port.
SPACE_APP_INTERNAL_HOST="59.10.62.160"
## If ServiceType is LoadBalancer SPACE_APP_INTERNAL_PORT should be 80 or 443
SPACE_APP_INTERNAL_PORT="30541"

## If using Space/Finetune/Inference/Model Evaluation/Dataflow functions and so on.
KUBE_CONFIG_DIR="/root/.kube"
```
You can then run the following command to reconfigure CSGHub instance:
```
./startup.sh
```

#### Reconfigure Kubernetes

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
