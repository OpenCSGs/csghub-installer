## CSGHub All-in-One Deployment Guide

This script enables the one-click deployment of an all-in-one CSGHub instance, including all related components:

* csghub-portal
* csghub-server
* nginx
* postgresql
* git-server
* minio
* casdoor
* account server
* user server
* space builder
* registry
* mirror-repo-sync
* mirror-lfs-sync
* natsmaster


**Notice:**
CSGHhub v0.4.0 supports the space function, and v0.7.0 supports model fine-tuning, inference. Space, model fine-tuning and inference all require Kubernetes and other related environments and configurations, since Kubernetes is not included here,  the All-in-one deployment here `does not include space, model fine-tuning and inference functions`.

### Prerequisites
* Hardware

Minimum Configuration: 4c CPU / 8GB RAM / 50GB Hard Disk

Recommended Configuration: 8c CPU / 16GB RAM / 500GB Hard Disk

* Software

Any Linux OS with x86_64 architecture

Docker Engine (>=5:20.10.24)

### Usage
1. Navigate to the `csghub` directory.
2. Edit the `.env` file and set `SERVER_DOMAIN` to the current host's IP address or domain name. DO NOT use `127.0.0.1` or `localhost`.
3. the space and registry related configurations in .env can be ignored without Kubernetes cluster. The configuration for integration with the existing Kubernetes cluster can be found [on below section](#Configure-kubernetes).
3. Run the `startup.sh` script. Once all services are started, you can visit the self-deployed CSGHub service at `http://[SERVER_DOMAIN]`.

### Notes
1. Self-deployed CSGHub uses local-type Docker volumes for persistence, such as for PostgreSQL and Minio. Ensure that Docker local volumes have sufficient disk space.
1. Ensure that the external port `2222` of the host is accessible, as Git operations via the SSH protocol depend on it.
1. Make sure the host's external port 31001 is accessible, which is used by the casdoor service for user registration and login.
1. The Minio console can be visited through the port `9001`. If Minio console is not required, this port can be closed.
1. By default, only HTTP protocol is supported for CSGHub services. If HTTPS is required, configure it accordingly.
1. Completely remove CSGHub instance with below command:
```
docker compose -f docker-compose.yml down -v
```

## Configure kubernetes
### Prerequisites

* Kubernetes version > 1.20+
* Minimum server configuration 8c16g, X86_64 architecture (non-X86_64 system architecture is not supported yet)
* Kubernetes can be deployed in a variety of ways, such as Docker Desktop，[K3s](https://docs.k3s.io/quick-start), [Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
* CSGhub instance running with docker compose installation script

### Knative Configuration

Please refer to [Knative installation](https://opencsg.com/docs/csghub/101/helm/installation) for knative configration

### CSGHub Configration

Re-config CSGHub instance to connect to the specified Kubernetes cluster. Assume the following information:
* CSGHub ip：110.95.70.140
* Kubernetes master node: 101.201.52.76;  worker node: 59.10.62.160 
* `NodePort` mode is used to expose Knative service，its value is`30541`。Refer to [knative config](https://opencsg.com/docs/csghub/101/helm/installation#%E5%AE%89%E8%A3%85%E7%BD%91%E7%BB%9C%E7%BB%84%E4%BB%B6) for more details. 


#### Re-config CSGHub instance
Based on the above information, first change the .env file content as follows:
```
# Common Configuration
## csghub service's domain name, can be ip or domain name
SERVER_DOMAIN=110.95.70.140
SERVER_PORT=80


## Casdoor Configuration
SERVER_CASDOOR_PORT=31001

## Default csghub server token. A 128-bit string consisting of numbers and lowercase letters.
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

move kube config file of the Kubernetes cluster to the `.kube` folder of the CSGHub installation directory 

restart CSGHub instance:
```
docker compose -f docker-compose.yml down
docker compose -f docker-compose.yml up -d
```

####  Re-config Kubernetes


* Create new namespace and secret
```
kubectl create ns space

kubectl create secret docker-registry space-registry-credential --docker-server=110.95.70.140:5000 --docker-username=csghub --docker-password=csghub@2024!  -n space
```

* enable CSGHub's insecure docker registry for Kubernetes

The default installation of CSGHub uses an insecure registry (that is, the one mentioned above: 110.95.70.140:5000). You need to ensure that Kubernetes can pull images from this registry. Perform the following operations on each worker node of Kubernetes:

Before configuration, please confirm whether the configuration file `/etc/containerd/config.toml` exists or not. If not , you can create it with the following command.
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

restart `containerd` service

2.  hosts.toml settings

   ```shell
   mkdir /etc/containerd/certs.d/110.95.70.140:5000

   cat <<EOF > /etc/containerd/certs.d/110.95.70.140:5000/hosts.toml
   server = "http://110.95.70.140:5000"

   [host."http://110.95.70.140:5000"]
           capabilities = ["pull", "resolve", "push"]
           skip_verify = true
   EOF
   ```

Note: This configuration takes effect directly without restarting
