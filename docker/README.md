# CSGHub Docker Quick Deployment

> **Tips:**
>
> - This method is suitable for quick testing, Not suitable for production use.
> - Supports AMD64/ARM64.
> - [Chinese Docs](../docs/zh/README_docker_cn.md)

## Overview

Omnibus CSGHub is a method launched by OpenCSG to quickly deploy CSGHub using Docker, mainly for quick function experience and testing. The Docker deployment method allows users to deploy CSGHub on local computers at a low cost. This deployment method is very suitable for proof of concept and testing, allowing users to immediately access the core functions of CSGHub (including models, dataset management, Space application creation, and model reasoning and fine-tuning).

## Advantages

- **Quick configuration:** Supports one-click deployment and quick start.

- **Unified management:** Supports integrated model, dataset, Space application management, multi-source synchronization and other functions.

- **Simple operation:** Supports model reasoning and quick start of fine-tuning instances.

## Quick deployment

### Prerequisites

- The host used for deployment has [Docker Desktop](https://docs.docker.com/desktop/) or [Docker Engine](https://docs.docker.com/engine/) installed

- Operating system Linux, macOS, Windows, configuration not less than 4c8g
- Inference, fine-tuning, and model evaluation functions require GPU resources

### Quick installation

Currently, this deployment method only supports `macOS` and `Linux`.

```shell
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/quick_install.sh | bash -s -- -h csghub.example.com -p 80
```

If you need to connect to [K8S cluster](#Quickly configure K3S test environment) (support model inference, fine-tuning, evaluation and Space functions):

```shell
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/quick_install.sh | bash -s -- -h csghub.example.com -p 80 -k -c ~/.kube
```

**Note:**

- The above method only supports `macOS, Linux, Windows (WSL)` For other configurations, please check the command help `-H, --help`. 

    For other methods, please refer to [Other Windows deployment methods](#Other Windows deployment methods).

- HTTPS access configuration is not currently supported. If necessary, please adjust the port mapping and nginx configuration file template yourself.

- `-h host` or `SERVER_DOMAIN` can use `domain name` or `IPv4 address`.

    - **Domain name:** Please configure domain name resolution by yourself when using a domain name

    - **IPv4:** Do not use `172.17.0.0/16` (this address segment is the default address segment of Docker, which will cause access exceptions)

- The above method is not applicable to using external database services. If necessary, please refer to [Variable Description](#Variable Description) to configure it yourself.

### Visit CSGHub

After the above deployment is successful, use the following method to access:

Access address: `http://<host>:<port>`, for example, http://192.168.1.12

Access credentials: `root/Root@1234`

## More instructions

### Quickly configure the K3S test environment

- Quickly configure the k3s environment

```shell
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/scripts/k3s-install.sh | bash -s

# If NVIDIA GPU configuration is enabled
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/scripts/k3s-install.sh | ENABLE_NVIDIA_GPU=true bash -s
```

- Configure Docker

```shell
# Add insecure registry
cat <<EOF > /etc/docker/daemon.json
{
"insecure-registries": ["<your ip address>:5000"]
}
EOF

# Restart docker
systemctl restart docker
```

- `<your ip address>` defaults to `csghub.example.com`, which can be specified with the `-h` option.

- `5000` is the default registry access port, which can be specified with the `-r` option.

### Windows other deployment methods

- **PowerShell**

    ```shell
    # Without K8S
    $env:SERVER_DOMAIN = ((Get-NetAdapter -Physical | Get-NetIPAddress -AddressFamily IPv4)[0].IPAddress) 
    $env:SERVER_PORT = "80"
    docker run -it -d `
        --name omnibus-csghub `
        --hostname omnibus-csghub `
        -p ${env:SERVER_PORT}:80 `
        -p 2222:2222 `
        -p 8000:8000 `
        -p 9000:9000 `
        -e SERVER_DOMAIN=$env:SERVER_DOMAIN `
        -e SERVER_PORT=$env:SERVER_PORT `
        opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        
    # With K8S
    $env:SERVER_DOMAIN = ((Get-NetAdapter -Physical | Get-NetIPAddress -AddressFamily IPv4)[0].IPAddress) 
    $env:SERVER_PORT = "80"
    docker run -it -d `
        --name omnibus-csghub `
        --hostname omnibus-csghub `
        -p ${env:SERVER_PORT}:80 `
        -p 2222:2222 `
        -p 5000:5000 `
        -p 8000:8000 `
        -p 9000:9000 `
        -v $env:USERPROFILE\Documents\csghub\data:/var/opt `
        -v $env:USERPROFILE\Documents\csghub\log:/var/log `
        -v $env:USERPROFILE\.kube:/etc/.kube `
        -v DOCKER_HOST=<YOUR DOCKER SERVER> `
        -e SERVER_DOMAIN=$env:SERVER_DOMAIN `
        -e SERVER_PORT=$env:SERVER_PORT `
        opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
    ```

- **CMD**

    ```shell
    for /F "tokens=2 delims=:" %i in ('ipconfig ^| findstr /C:"以太网适配器" /C:"IPv4 地址"') do (
        set "tempIpv4=%i"
        set SERVER_DOMAIN=%tempIpv4:~1%
    )
    
    set SERVER_PORT=80
    
    # Without K8S
    docker run -it -d ^
        --name omnibus-csghub ^
        --hostname omnibus-csghub ^
        -p %SERVER_PORT%:80 ^
        -p 2222:2222 ^
        -p 8000:8000 ^
        -p 9000:9000 ^
        -e SERVER_DOMAIN=%SERVER_DOMAIN% ^
        -e SERVER_PORT=%SERVER_PORT% ^
        opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        
    # With K8S
    docker run -it -d ^
        --name omnibus-csghub ^
        --hostname omnibus-csghub ^
        -p %SERVER_PORT%:80 ^
        -p 2222:2222 ^
        -p 5000:5000 ^
        -p 8000:8000 ^
        -p 9000:9000 ^
        -v %USERPROFILE%\Documents\csghub\data:/var/opt ^
        -v %USERPROFILE%\Documents\csghub\log:/var/log ^
        -v %USERPROFILE%\.kube:/etc/.kube ^
        -e DOCKER_HOST=<YOUR DOCKER SERVER> ^
        -e SERVER_DOMAIN=%SERVER_DOMAIN% ^
        -e SERVER_PORT=%SERVER_PORT% ^
        opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
    ```

- **WSL**

    Please refer to [Quick Deployment](#Quick Deployment).

### Command Line Tools

omnibus-csghub provides a simple command line tool for managing services and viewing service logs.

- Service Management

```shell
# View all service status
csghub-ctl status

# View all job status
# EXITED is the normal status
csghub-ctl jobs

# Restart a service
csghub-ctl restart nginx
```

- Log Management

```shell
# View all service logs in real time
csghub-ctl tail

# View a service log in real time
csghub-ctl tail nginx
```

- Other parameters

All other command options are inherited from `supervisorctl`.

### Remove service

If you no longer use or need to rebuild the container, perform the following operations:

```shell
docker rm -f omnibus-csghub
```

If you need to uninstall the K3S environment, perform the following operations:

```shell
/usr/local/bin/k3s-uninstall.sh
```

### Variable description

_**Tips: **Only configurable parameters are listed. `127.0.0.1` is a local service. Third-party services are used by specifying the following variables, but this does not disable internal services._

#### Server

| Variable Name | Default Value      | Description                                     |
| :------------ | :----------------- | :---------------------------------------------- |
| SERVER_DOMAIN | csghub.example.com | Specifies the access IP address or domain name. |
| SERVER_PORT   | 80                 | Specifies the access port.                      |

#### PostgreSQL

| Variable Name                                   | Default Value   | Description                                                  |
| :---------------------------------------------- | :-------------- | :----------------------------------------------------------- |
| POSTGRES_HOST                                   | 127.0.0.1       | Specifies the database access address.                       |
| POSTGRES_PORT                                   | 5432            | Execution database port.                                     |
| POSTGRES_SERVER_USER / POSTGRES_SERVER_PASS     | csghub_server   | Specifies the csghub_server service database user and password. |
| POSTGRES_PORTAL_USER / POSTGRES_PORTAL_PASS     | csghub_portal   | Specify the csghub_portal service database user and password. |
| POSTGRES_CASDOOR_USER / POSTGRES_CASDOOR_PASS   | csghub_casdoor  | Specify the csghub_casdoor service database user and password. |
| POSTGRES_TEMPORAL_USER / POSTGRES_TEMPORAL_PASS | csghub_temporal | Specify the csghub_temporal service database user and password. |

#### Redis

| Variable Name  | Default Value  | Description                        |
| :------------- | :------------- | :--------------------------------- |
| REDIS_ENDPOINT | 127.0.0.1:6379 | Specify the Redis service address. |

#### ObjectStorage

| Variable Name      | Default Value   | Description                                                  |
| :----------------- | :-------------- | :----------------------------------------------------------- |
| S3_ENDPOINT        | 127.0.0.1:9000  | Specifies the object storage.                                |
| S3_ACCESS_KEY      | minio           | Specifies the object storage access credentials.             |
| S3_ACCESS_SECRET   | Minio@2025!     | Specifies the object storage access credentials.             |
| S3_REGION          | cn-north-1      | Specifies the object storage region.                         |
| S3_ENABLE_SSL      | false           | Specifies whether SSL encryption is enabled for the object storage. |
| S3_REGISTRY_BUCKET | csghub-registry | Specifies the bucket allocated for the registry.             |
| S3_PORTAL_BUCKET   | csghub-portal   | Specifies the bucket assigned to csghub-portal.              |
| S3_SERVER_BUCKET   | csghub-server   | Specifies the bucket assigned to csghub-server.              |

#### Gitlab-Shell

| Variable Name         | Default Value | Description                        |
| :-------------------- | :------------ | :--------------------------------- |
| GITLAB_SHELL_SSH_PORT | 2222          | Specifies the Git SSH port number. |

#### Registry

| Variable Name      | Default Value       | Description                                                  |
| :----------------- | :------------------ | :----------------------------------------------------------- |
| REGISTRY_ADDRESS   | $SERVER_DOMAIN:5000 | Specifies the Registry service address.                      |
| REGISTRY_NAMESPACE | csghub              | Specify the namespace used by the Registry.                  |
| REGISTRY_USERNAME  | registry            | Specify the username for connecting to the Registry service. |
| REGISTRY_PASSWORD  | Registry@2025!      | Specify the password for connecting to the Registry service. |

#### Space

***Tip:** The following configurations will be automatically obtained if `KNATIVE_SERVING_ENABLE = true` is configured. *

| Variable Name    | Default Value           | Description                                                  |
| :--------------- | :---------------------- | :----------------------------------------------------------- |
| SPACE_APP_NS     | spaces                  | Specify the default Kubernetes namespace used by Space.      |
| SPACE_APP_DOMAIN | app.internal            | Specify the internal domain name used by Knative Serving.    |
| SPACE_APP_HOST   | 127.0.0.1               | Specifies the gateway of the Knative Serving network component. |
| SPACE_APP_PORT   | 80                      | Specifies the port of the Knative Serving network component. |
| SPACE_DATA_PATH  | /var/opt/csghub-builder | Specifies the data storage directory for Space construction. |

#### Casdoor

| Variable Name | Default Value | Description                 |
| :------------ | :------------ | :-------------------------- |
| CASDOOR_PORT  | 8000          | Specifies the CASDOOR port. |

#### Temporal

| Variable Name | Default Value  | Description                                               |
| :------------ | :------------- | :-------------------------------------------------------- |
| TEMPORAL_USER | temporal       | Specifies the user name for verifying Temporal login.     |
| TEMPORAL_PASS | Temporal@2025! | Specifies the user password for verifying Temporal login. |

#### Kubernetes

| Variable Name          | Default Value | Description                                                  |
| :--------------------- | :------------ | :----------------------------------------------------------- |
| KNATIVE_SERVING_ENABLE | false         | Specifies whether to automatically install Knative Serving.  |
| KNATIVE_KOURIER_TYPE   | NodePort      | Specifies the service exposure method of the knative Serving Kourier network component. |
| NVIDIA_DEVICE_PLUGIN   | false         | Specifies whether to automatically install the nvidia device plugin (the default runtime of the GPU node containerd needs to be configured by yourself). |
| CSGHUB_WITH_K8S        | 0             | Whether to connect to the Kubernetes cluster.                |

For more variables, please refer to [csghub_config_load.sh](https://github.com/OpenCSGs/csghub-installer/blob/main/docker/etc/profile.d/csghub_config_load.sh).
