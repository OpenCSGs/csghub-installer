# CSGHub Docker Compose deployment document

## Introduction

Docker Compose is one of the common installation methods of CSGHub, which has many advantages. For example, simple service management, flexible and easy deployment, fast configuration and startup, etc. If it is deployed in a production environment, this method will be one of the optional methods.

## Software/Hardware Support

Hardware environment requirements:

- \>= 4c 8g 100gb

- amd64/arm64

Software environment requirements:

- Docker Engine (>=5:20.10.24)

- Docker Compose (>=2.20.0)

## Version Description

CSGHub `major.minor` version is consistent with CSGHub Server, and `Patch` version is updated as needed.

| Chart version | Csghub version | Description |
| :--------: | :---------: | ----------------------------- |
| 0.8.x | 0.8.x | |
| 0.9.x | 0.9.x | Added components Gitaly, Gitlab-Shell |
| 1.0.x | 1.0.x | |
| 1.1.x | 1.1.x | Added component Temporal |
| 1.2.x | 1.2.x | |
| 1.3.x | 1.3.x | Removed component Gitea |

## Domain name and IP

CSGHub Docker Compose deployment method is more flexible in the use of domain name and IP, which can use either `domain name` or `IPv4`.

- **Domain name**

Domain name can use public domain name or custom domain name. CSGHub Docker Compose uses a single domain name for deployment and access. Compared with the CSGHub Helm Chart method, the domain name usage is much simpler.

***Note:** If it is a custom domain name, please configure Hosts resolution yourself. For public domain names, please configure DNS cloud resolution.* 

- **IPv4**

IP address selection needs to use addresses other than `127.0.0.1` and `localhost`.

## .kube/config

The `.kube/config` file is an important configuration file for accessing the Kubernetes cluster. It is directly provided to the installer as a file path during the CSGHub Docker Compose deployment process. This `.kube/config` must at least contain full read and write permissions for the namespace where the target cluster deployment instance is located.

***Note:** If the automatic configuration of argo and KnativeServing is enabled in subsequent versions, more permissions such as creating namespaces are required.* 

## Data persistence

For ease of use and management, this deployment method directly uses `Volume Mount/Directory Mapping` to store persistent data. By default, it is stored in the `data` directory under the installation directory and is stored separately in the `./data/<component>` format.

In addition, all configuration files are stored in the `./configs` directory.

## Deployment example

### Installation package download

Please download from the [Release](https://github.com/OpenCSGs/csghub-installer/releases) page.

```shell
wget https://github.com/OpenCSGs/csghub-installer/releases/download/v1.3.0/csghub-docker-compose-v1.3.0.tgz
```

### Installation Configuration

- Unzip Program

```shell
tar -zxf csghub-docker-compose-v1.3.0.tgz && cd ./csghub
```

- Configuration Update

Currently, this deployment method recommends that all configurations be configured in the `.env` file. The minimum configuration only requires the following parameters.

```shell
SERVER_DOMAIN="<domain or ipv4>"
SERVER_PORT="80"
SERVER_PROTOCOL="http"

# Specify whether to connect to K8S. 0 for access, 1 for non-access
CSGHUB_WITH_K8S=1
KUBE_CONFIG_DIR=".kube/config"

# SPACE_APP Some configurations need to be configured in advance
SPACE_APP_NAMESPACE="spaces"
SPACE_APP_INTERNAL_DOMAIN="app.internal" # Default is
SPACE_APP_INTERNAL_HOST="<Kourier Service IP>"
SPACE_APP_INTERNAL_PORT="<Kourier Service Port>"
```

- Start configuration

This command can be used for the first deployment and can also be used to start CSGHub, replacing `docker compose up -d`. Because this script will render the configuration file each time it is executed, the configuration consistency is maintained.

```shell
./configure
```

Wait for the program to automatically configure and start.

- Access address

| Service | Address | Admin | Notes |
| :------: | :-------------------------------: | :----------------------------: | :------------------------------------------------: |
| CSGhub | http://\<ip address> | root/Root@1234 | Can be modified in Casdoor |
| Minio | http://\<ip address>:9001 | *Please check the default account defined in .env* | MINIO_ROOT_USER<br>MINIO_ROOT_PASSWORD |
| Temporal | http://\<ip address>/temporal-ui/ | *Please check the default account defined in .env* | TEMPORAL_CONSOLE_USER<br>TEMPORAL_CONSOLE_PASSWORD |
| Casdoor | http://\<ip address>:8000 | admin/123 | Can be modified in Casdoor |
| Registry | \<ip address>:5000 | *Please check the default account defined in .env* | REGISTRY_USERNAME<br/>REGISTRY_PASSWORD |

## External resources

> **Tip:** If the built-in service is not disabled while using an external service, the service will still start normally.

***Note:** Because the service startup control in docker compose is not very flexible, if the following variables are directly configured as external services, you can also switch to using external services. At the same time, the following configuration can also modify the internal service configuration.* 

### Registry

| Variable | Type | Default value | Description |
| :----------------- | :----- | :-------------------------------- | :------------------------------------------- |
| REGISTRY_ENABLED | number | 1 | 1: Use built-in Registry<br>0: Disable built-in Registry |
| REGISTRY_PORT | number | 5000 | Registry service port number, 80, please leave it blank. |
| REGISTRY_ADDRESS | string | ${SERVER_DOMAIN}:${REGISTRY_PORT} | Specify the registry endpoint. |
| REGISTRY_NAMESPACE | string | csghub | Specify the namespace used by the registry. |
| REGISTRY_USERNAME | string | registry | Specify the username for accessing the registry |
| REGISTRY_PASSWORD | string | registry@2025! | Specify the password for accessing the registry |

### PostgreSQL

***Note:** Please create the databases csghub_server, csghub_portal, casdoor, temporal, dataflow by yourself.* 

| Variable | Type | Default | Description |
| :---------------- | :----- | :------------ | :----------------------------------------------- |
| POSTGRES_ENABLED | number | 1 | 1: Use built-in PostgreSQL<br>0: Disable built-in PostgreSQL |
| POSTGRES_HOST | string | postgres | PostgreSQL service address. |
| POSTGRES_PORT | number | 5432 | Specify the PostgreSQL service port number. |
| POSTGRES_TIMEZONE | string | Asia/Shanghai | Default. No actual meaning, no configuration required. |
| POSTGRES_USER| string | csghub | Specifies the username for connecting to PostgreSQL |
| POSTGRES_PASSWORD | string | Csghub@2025! | Specifies the password for connecting to PostgreSQL |

### ObjectStore

| Variable | Type | Default | Description |
| :---------------------- | :----- | :--------------------------------- | :--------------------------------------------- |
| MINIO_ENABLED | number | 1 | 1: Use built-in object storage<br>0: Disable built-in object storage |
| MINIO_API_PORT | number | 9000 | Minio API service port number. |
| MINIO_CONSOLE_PORT | number | 9001 | Minio Console service port number. |
| MINIO_ENDPOINT | string | ${SERVER_DOMAIN}:${MINIO_API_PORT} | Specifies the namespace used by the object store. |
| MINIO_EXTERNAL_ENDPOINT | string | / | The external object storage is consistent with MINIO_ENDPOINT, otherwise it is left blank. |
| MINIO_ROOT_USER | string | minio | Specifies the username for accessing the object storage. |
| MINIO_ROOT_PASSWORD | string | Minio@2025! | Specifies the password for accessing the object storage. |
| MINIO_REGION | string | cn-north-1 | Specifies the object storage region. |
| MINIO_ENABLE_SSL | bool | false | Specifies whether to enable encrypted access to the object storage. |
| USING_PATH_STYLE | bool | true | Whether to use the path method for accessing the object storage bucket. |

## Other variables

### Image configuration

| Variable | Type | Default | Description |
| :------------------ | :----- | :----------------------------------------- | :--------------------------------------------------- |
| CSGHUB_IMAGE_PREFIX | string | opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public | Only public image repositories are supported here. |
| CSGHUB_VERSION | string | latest | Specifies the image version of csghub_portal and csghub_server services. |

### Nginx configuration

| Variable | Type | Default | Description |
| :---------- | :----- | :---------------- | :------------------------------------------ |
| SERVER_DOMAIN | string | csghub.example.com | Specifies the domain name or IPv4 used to configure CSGHub. |
| SERVER_PORT | number | 80 | Specifies the NGINX listening port. For encrypted access, please configure it to 443. |
| SERVER_PROTOCOL | string | http | Specifies the URL protocol. For encrypted access, please configure it to https. |
| SERVER_SSL_CERT | string | / | Refers to the certificate for enabling encrypted access. |
| SERVER_SSL_KEY | string | / | Refers to the private key for enabling encrypted access. |

### CSGHub Portal Configuration

| Variable | Type | Default Value | Description |
| :------------------------- | :--- | :----- | :--------------------------------------------- |
| CSGHUB_PORTAL_ENABLE_HTTPS | bool | false | If NGINX is configured for encrypted access, this needs to be configured to true. |

### Git Configuration

| Variable         | Type   | Default | Description                                                       |
| :----------- | :----- | :----- | :--------------------------------------------------------- |
| GIT_SSH_PORT | number | 2222   | Configure the port number used by Git Over SSH. It cannot conflict with the local SSHD service. |

### Kubernetes Configuration

| Variable | Type | Default | Description |
| :---------- | :----- | :---------- | :---------------------------------------------------------- |
| CSGHUB_WITH_K8S | number | 0 | 1: Connect to K8S<br/>0: Do not connect to K8S. |
| KUBE_CONFIG_DIR | string | /root/.kube | The path to store config files. Multiple config files need to be renamed to files starting with config. |

### Space Application Configuration

| Variable | Type | Default Value | Description |
| :------------------------ | :----- | :----------- | :----------------------------------------------------------- |
| SPACE_APP_NAMESPACE | string | spaces | Create the K8S namespace where various deployment instances are located (will be created automatically). |
| SPACE_APP_INTERNAL_DOMAIN | string | app.internal | The domain name used by KnativeServing configuration. |
| SPACE_APP_INTERNAL_HOST | string | 127.0.0.1 | The access address of Kourier used by KnativeServing configuration. Fill in according to the actual situation. It cannot be set to 127.0.0.1 or localhost. |
| SPACE_APP_INTERNAL_PORT | number | 30541 | The access port of Kourier used by KnativeServing configuration. Fill in according to the actual situation. |

### Gitaly Configuration

| Variable | Type | Default | Description |
| :------------------- | :----- | :---------------- | :------------------------- |
| GITALY_ENABLED | number | 1 | 1: Use built-in Gitaly<br>0: Disable built-in Gitaly. |
| GITALY_SERVER_SOCKET | string | tcp://gitaly:8075 | Gitaly service address. |
| GITALY_STORAGE | string | default | Keep the default. |
| GITALY_AUTH_TOKEN | string | Gitaly@2025! | Specify the authentication token for connecting to the Gitaly service. |

### Temporal Configuration

| Variable | Type| Default value | Description |
| :------------------------ | :----- | :------------- | :------------------------------- |
| TEMPORAL_UI_ENABLED | number | 1 | Enable UI access service. |
| TEMPORAL_CONSOLE_USER | string | temporal | Specify the username for accessing Temporal service. |
| TEMPORAL_CONSOLE_PASSWORD | string | Temporal@2025! | Specify the password for accessing Temporal service. |

### Casdoor Configuration

Please keep the default.

### Nats Configuration

Please keep the default.

### Fixed Configuration

Please keep the default.

## Troubleshooting

### http: server gave HTTP response to HTTPS client

CSGHub is installed by default using an insecure registry (i.e., `<domain or IPv4>:5000` as mentioned above). You need to ensure that Kubernetes can pull images from this registry. Therefore, the following configuration needs to be done on each Kubernetes node:

1. Before configuration, please confirm whether the configuration file `/etc/containerd/config.toml` exists. If it does not exist, you can use the following command to create it.

```shell
mkdir -p /etc/containerd/ && containerd config default >/etc/containerd/config.toml
```

 2. Configure `config_path` 

     - Containerd 1.x

        ```toml
        version = 2
        
        [plugins."io.containerd.grpc.v1.cri".registry]
             config_path = "/etc/containerd/certs.d"
        ```
       
    - Containerd 2.x
    
       ```toml
        version = 3
       
        [plugins."io.containerd.cri.v1.images".registry]
             config_path = "/etc/containerd/certs.d"
       ```
    
3. Configure `hosts.toml`

     ```shell
     # Create Registry configuration directories
     mkdir /etc/containerd/certs.d/<domain or IPv4>:5000
     
     # Add configuraion
     cat /etc/containerd/certs.d/<domain or IPv4>:5000/hosts.toml
     server = "http://<domain or IPv4>:5000"
     
     [host."http://<domain or IPv4>:5000"]
        capabilities = ["pull", "resolve", "push"]
        skip_verify = true
        plain-http = true
     EOF
     ```

4. Restart `containerd` service

     ```shell
     systemctl restart containerd
     ```

## Feedback

If you encounter any problems during use, you can submit feedback through:

- [Feedback](https://github.com/OpenCSGs/csghub-installer/issues)