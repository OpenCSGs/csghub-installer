# CSGHub Docker Deployment Guide

> **Tips:**
>
> - This method is currently in the testing phase and is not suitable for production deployment.
> - Now supports AMD64/ARM64 architecture.
> - [中文文档](../docs/zh/README_docker_cn.md)

## Overview

Omnibus CSGHub is a way for OpenCSG to quickly deploy CSGHub using Docker, mainly for rapid functional experience and testing. The Docker deployment method allows users to deploy CSGHub on local computers at a lower cost. This deployment method is very suitable for proof of concept and testing, allowing users to immediately access the core functions of CSGHub (including models, dataset management, space application creation, and model inference and fine-tuning (GPU required)).

## Advantages

- **Quick configuration:** Supports one-click deployment and quick start.
- **Unified management:** Supports integrated model, dataset, space application management, and built-in multi-source synchronization function.
- **Simple operation:** Supports model inference, fine-tune instance quick start.

## Deployment

### Prerequisites

- The host used for deployment has [Docker Desktop](https://docs.docker.com/desktop/) or [Docker Engine](https://docs.docker.com/engine/) installed.
- The operating system is Linux, macOS, Windows, and the configuration is not less than 4c8g.
- Fine-tune instances requires GPU (currently only supports NVIDIA)

### Installation Steps

> **Tips:**
>
> - HTTPS access configuration is not supported yet, you can adjust the Nginx configuration in the container yourself.
> - If`SERVER_DOMAIN`and`SERVER_PORT`are modified, it is recommended to delete the persistent data directory and recreate it.
> - Cloud server`SERVER_DOMAIN = <external public ip>`
>
> **Note:**
>
> - Please make sure that your local IP address segment and the docker default address segment (172.17.0.0) do not overlap. If they overlap, please try changing the local network connection (for example, changing the Ethernet network).

#### Pre-installation instructions

- If you need to adjust the port number exposed to the outside, you also need to modify the relevant variables. All adjusted port numbers must be re-entered into the container in the form of variables.

    For example: adjust `SERVER_PORT` to `8080`.

    ```shell
    export SERVER_PORT=8080
    docker run -it -d \
    ...
    -p ${SERVER_PORT}:80 \
    ...
    -e SERVER_PORT=${SERVER_PORT} \
    opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
    ```


| Port number | Function                                           | Adjustment method                          |
| :---------: | :------------------------------------------------- | :----------------------------------------- |
|     80      | Nginx service port, providing csghub access        | SERVER_PORT=`[port]`                       |
|    2222     | Git SSH service port, providing git clone over SSH | GITLAB_SHELL_SSH_PORT=`[port]`             |
|    5000     | Registry service port, container image repository  | REGISTRY_ADDRESS=`${SERVER_DOMAIN}:[port]` |
|    8000     | Casdoor service port, user authentication service  | CASDOOR_PORT=`[port]`                      |
|    9000     | Minio service port, object storage service         | S3_ENDPOINT=`${SERVER_DOMAIN}:[port]`      |

#### Quick Installation (Space and model inference & fine-tuning functions cannot be used)

- **Linux**

    > **Tips:**
    >
    > - Please replace `<your ip address>` with your host IPv4 address.
    >
    > - To view the IPv4 address, enter the following command in the terminal command line:
    >
    >     `ip -4 -o addr show $(ip route show default | awk '/default/ {print $5}')`

    - Quick start without data persistence volumes

        ```shell
        export SERVER_DOMAIN=$(ip addr show $(ip route show default | awk '/default/ {print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
        export SERVER_PORT=80
        docker run -it -d \
            --name omnibus-csghub \
            --hostname omnibus-csghub \
            -p ${SERVER_PORT}:80 \
            -p 2222:2222 \
            -p 8000:8000 \
            -p 9000:9000 \
            -e SERVER_DOMAIN=${SERVER_DOMAIN} \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        ```

    - Normal startup with persistent data volumes

        ```shell
        export SERVER_DOMAIN=$(ip addr show $(ip route show default | awk '/default/ {print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
        export SERVER_PORT=80
        docker run -it -d \
            --name omnibus-csghub \
            --hostname omnibus-csghub \
            -p ${SERVER_PORT}:80 \
            -p 2222:2222 \
            -p 8000:8000 \
            -p 9000:9000 \
            -v /srv/csghub/data:/var/opt \
            -v /srv/csghub/log:/var/log \
            -e SERVER_DOMAIN=${SERVER_DOMAIN} \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        ```

- **macOS**

    > **Tips:**
    >
    > - To deploy with Docker Desktop, please enable Rosetta. The method to enable it is as follows:
    >
    >     `Settings` > `General` > `Use Rosetta for x86_64/amd64 emulation on Apple Silicon`
    >
    > - Please replace `<your ip address>` with your host IPv4 address.
    >
    > - To view the IPv4 address, enter the following command in the terminal command line:
    >
    >     `ipconfig getifaddr $(route get default | grep interface | awk '{print $2}')`
    >
    > ***Note:** Rosetta runs Slightly slower. Before version v1.2.0, container running in Rosetta mode will prompt `WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested`. Just ignore it.*

    - Manually pull the image

        ```shell
        docker pull opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        ```

    - Quick start without data persistence volumes

        ```shell
        export SERVER_DOMAIN=$(ipconfig getifaddr $(route get default | grep interface | awk '{print $2}'))
        export SERVER_PORT=80
        docker run -it -d \
            --name omnibus-csghub \
            --hostname omnibus-csghub \
            -p ${SERVER_PORT}:80 \
            -p 2222:2222 \
            -p 8000:8000 \
            -p 9000:9000 \
            -e SERVER_DOMAIN=${SERVER_DOMAIN} \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        ```

    - Normal startup with persistent data volumes

        ```shell
        export SERVER_DOMAIN=$(ipconfig getifaddr $(route get default | grep interface | awk '{print $2}'))
        export SERVER_PORT=80
        docker run -it -d \
            --name omnibus-csghub \
            --hostname omnibus-csghub \
            -p ${SERVER_PORT}:80 \
            -p 2222:2222 \
            -p 8000:8000 \
            -p 9000:9000 \
            -v ~/Documents/csghub/data:/var/opt \
            -v ~/Documents/csghub/log:/var/log \
            -e SERVER_DOMAIN=${SERVER_DOMAIN} \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        ```

- **Windows**

    >**Tips:**
    >
    >- Please replace `<your ip address>` with your host IPv4 address.
    >
    >- To view the IPv4 address:
    >
    >   Use the key combination `Win + R`, enter `cmd`, and after the window opens, enter `ipconfig` to obtain the IPv4 address.
    >   
    
    - **Powershell**
    
        ```shell
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
        ```
    
    - **CMD**
    
        ```shell
        for /F "tokens=2 delims=:" %i in ('ipconfig ^| findstr /C:"以太网适配器" /C:"IPv4 地址"') do (
            set "tempIpv4=%i"
            set SERVER_DOMAIN=%tempIpv4:~1%
        )
        set SERVER_PORT=80
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
        ```
    
    - **WSL**
    
        Please refer to the **Linux deployment method**.

#### General installation (Space, model inference & fine-tuning features can be used (requires NVIDIA GPU))

- **Linux**

    >**Prerequisites:**
    >
    >- A Kubernetes cluster with Knative Serving deployed is required.
    >- For other precautions, see the Quick Installation section.

    - Quickly configure the k8s cluster

        ```shell
        curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/scripts/k3s-install.sh | bash -s
        
        # If enable NVIDIA GPU
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

    - Install CSGHub

        ```shell
        export SERVER_DOMAIN=$(ip addr show $(ip route show default | awk '/default/ {print $5}') | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
        export SERVER_PORT=80
        docker run -it -d \
            --name omnibus-csghub \
            --hostname omnibus-csghub \
            -p ${SERVER_PORT}:80 \
            -p 2222:2222 \
            -p 5000:5000 \
            -p 8000:8000 \
            -p 9000:9000 \
            -v /srv/csghub/data:/var/opt \
            -v /srv/csghub/log:/var/log \
            -v ~/.kube:/etc/.kube \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -e SERVER_DOMAIN=${SERVER_DOMAIN} \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        ```

- **macOS**

    Please configure Kubernetes cluster yourself and make sure the file `~/.kube/config` exists. Then use a command similar to the following to install it:

    ```shell
    export SERVER_DOMAIN=$(ipconfig getifaddr $(route get default | grep interface | awk '{print $2}'))
    export SERVER_PORT=80
    docker run -it -d \
        --name omnibus-csghub \
        --hostname omnibus-csghub \
        -p ${SERVER_PORT}:80 \
        -p 2222:2222 \
        -p 5000:5000 \
        -p 8000:8000 \
        -p 9000:9000 \
        -v ~/Documents/csghub/data:/var/opt \
        -v ~/Documents/csghub/log:/var/log \
        -v ~/.kube:/etc/.kube \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e SERVER_DOMAIN=${SERVER_DOMAIN} \
        -e SERVER_PORT=${SERVER_PORT} \
        opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
    ```

- **Windows**

    The following commands are for reference only. Please configure according to your actual situation.

    - **PowerShell**

        ```shell
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

        Please refer to Linux deployment method.

### Visit CSGHub

After the above deployment is successful, use the following method to access:

Access address: `http://<SERVER_DOMAIN>:<SERVER_PORT>`, for example http://192.168.1.12

Default administrator: `root`

Default password: `Root@1234`

### Command Line Tools

Currently, a simple command line tool is provided for restarting services and viewing logs separately.

- Service Managemnet

    ```shell
    # View all services status
    csghub-ctl status 
    
    # View all jobs status 
    # EXITED is expected status
    csghub-ctl jobs
    
    # Restart a service
    csghub-ctl restart nginx
    ```

- Log

    ```shell
    # View all service logs in real time
    csghub-ctl tail 
    
    # View a service log in real time
    csghub-ctl tail nginx
    ```

- Others

    All other command options are inherited from supervisorctl.

### Variable Description

***Tips:** Only configurable parameters are listed. 127.0.0.1 is a local service. By specifying the following variables, third-party services are used, but this does not disable internal services.* 

### Server

| Variable Name | Default Value      | Description                                     |
| :------------ | :----------------- | :---------------------------------------------- |
| SERVER_DOMAIN | csghub.example.com | Specifies the access IP address or domain name. |
| SERVER_PORT   | 80                 | Specifies the access port.                      |

#### PostgreSQL

| Variable Name                                   | Default Value   | Description                                                  |
| :---------------------------------------------- | :-------------- | :----------------------------------------------------------- |
| POSTGRES_HOST                                   | 127.0.0.1       | Specifies the database access address.                       |
| POSTGRES_PORT                                   | 5432            | Execution database port.                                     |
| POSTGRES_SERVER_USER / POSTGRES_SERVER_PASS     | csghub_server   | Specify the csghub_server service database user and password. |
| POSTGRES_PORTAL_USER / POSTGRES_PORTAL_PASS     | csghub_portal   | Specify the csghub_portal service database user and password. |
| POSTGRES_CASDOOR_USER / POSTGRES_CASDOOR_PASS   | csghub_casdoor  | Specify the csghub_casdoor service database user and password. |
| POSTGRES_TEMPORAL_USER / POSTGRES_TEMPORAL_PASS | csghub_temporal | Specify the csghub_temporal service database user and password. |

#### Redis

| Variable Name  | Default Value  | Description                          |
| :------------- | :------------- | :----------------------------------- |
| REDIS_ENDPOINT | 127.0.0.1:6379 | Specifies the Redis service address. |

#### ObjectStorage

| Variable Name      | Default Value   | Description                                                  |
| :----------------- | :-------------- | :----------------------------------------------------------- |
| S3_ENDPOINT        | 127.0.0.1:9000  | Specifies the object storage.                                |
| S3_ACCESS_KEY      | minio           | Specifies the object storage access credentials.             |
| S3_ACCESS_SECRET   | Minio@2025!     | Specifies the object storage access credentials.             |
| S3_REGION          | cn-north-1      | Specifies the object storage region.                         |
| S3_ENABLE_SSL      | false           | Specifies whether SSL encryption is enabled for the object store. |
| S3_REGISTRY_BUCKET | csghub-registry | Specifies the bucket assigned to the registry.               |
| S3_PORTAL_BUCKET   | csghub-portal   | Specifies the bucket assigned to csghub-portal.              |
| S3_SERVER_BUCKET   | csghub-server   | Specifies the bucket assigned to csghub-server.              |

#### Gitlab-Shell

| Variable Name         | Default Value | Description                        |
| :-------------------- | :------------ | :--------------------------------- |
| GITLAB_SHELL_SSH_PORT | 2222          | Specifies the Git SSH port number. |

#### Registry

| Variable Name      | Default Value       | Description                                                 |
| :----------------- | :------------------ | :---------------------------------------------------------- |
| REGISTRY_ADDRESS   | $SERVER_DOMAIN:5000 | Specifies the address of the Registry service.              |
| REGISTRY_NAMESPACE | csghub              | Specifies the namespace used by the Registry.               |
| REGISTRY_USERNAME  | registry            | Specifies the username for the Registry service connection. |
| REGISTRY_PASSWORD  | Registry@2025!      | Specifies the password for the Registry service connection. |

#### Space

***Tips:** The following configuration will be automatically obtained if `KNATIVE_SERVING_ENABLE = true` is configured.* 

| Variable name    | Default value           | Description                                                  |
| :--------------- | :---------------------- | :----------------------------------------------------------- |
| SPACE_APP_NS     | spaces                  | Specifies the default Kubernetes namespace used by Space.    |
| SPACE_APP_DOMAIN | app.internal            | Specifies the internal domain name used by Knative Serving.  |
| SPACE_APP_HOST   | 127.0.0.1               | Specifies the gateway of the Knative Serving network component. |
| SPACE_APP_PORT   | 80                      | Specifies the port of the Knative Serving network component. |
| SPACE_DATA_PATH  | /var/opt/csghub-builder | Specifies the data storage directory for Space builds.       |

#### Casdoor

| Variable Name | Default Value | Description                 |
| :------------ | :------------ | :-------------------------- |
| CASDOOR_PORT  | 8000          | Specifies the CASDOOR port. |

#### Temporal

| Variable Name | Default Value  | Description                                                  |
| :------------ | :------------- | :----------------------------------------------------------- |
| TEMPORAL_USER | temporal       | Specifies the user name for authenticating Temporal logins.  |
| TEMPORAL_PASS | Temporal@2025! | Specifies the user password for authenticating Temporal logins. |

#### Kubernetes

| Variable name          | Default value | Description                                                  |
| :--------------------- | :------------ | :----------------------------------------------------------- |
| KNATIVE_SERVING_ENABLE | false         | Specifies whether to automatically install Knative Serving.  |
| KNATIVE_KOURIER_TYPE   | NodePort      | Specifies the service exposure method of the knative Serving Kourier network component. |
| NVIDIA_DEVICE_PLUGIN   | false         | Specifies whether to automatically install the nvidia device plugin (the default runtime of the GPU node containerd needs to be configured by yourself). |
| CSGHUB_WITH_K8S        | 1             | Whether to connect to the Kubernetes cluster.                |

### Function Exploration

CSGHub provides several key functions:

- **Model hosting:**

    - Currently supports model hosting, easy upload and management of models.

    - Supports creating inference and fine-tuning instances (NVIDIA GPU required).

    - Multi-source synchronization is enabled by default, and multi-source synchronization will automatically start after startup (synchronization takes a while to complete).


- **Dataset hosting:**

    - Simplified tools for processing datasets, ideal for rapid testing and verification.

- **Application hosting:**

    - Quickly create large model applications through custom programs and model combinations.

### Destroy the container

If you are not using or need to rebuild the container, you can do the following:

```shell
docker rm -f omnibus-csghub
```

If you also need to uninstall the k3s environment, you can do the following:

```shell
/usr/local/bin/k3s-uninstall.sh
```
