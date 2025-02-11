# CSGHub Docker 快速部署文档

> 提示：
>
> - 此种方式目前处于测试阶段，暂不适用于生产环境部署。
> - 目前支持 AMD64/ARM64 架构。

## 概述

Omnibus CSGHub 是 OpenCSG 推出的使用 Docker 快速部署 CSGHub 的一种方式，主要用于快速功能体验和测试。Docker 部署方式允许用户以较低成本在本地计算机部署 CSGHub。此种部署方法非常适合概念验证和测试，使用户能够立即访问 CSGHub 的核心功能（包括模型，数据集管理、Space 应用创建以及模型的推理和微调（需要 GPU））。

## 优势

- **快速配置：** 支持一键部署，快速启动。
- **统一管理：** 支持集成模型、数据集、Space 应用管理，并内置多源同步功能。
- **操作简单：** 支持模型推理、微调实例快速启动。

## 部署方式

### 先决条件

- 用于部署的主机已安装 [Docker Desktop](https://docs.docker.com/desktop/) 或 [Docker Engine](https://docs.docker.com/engine/)。
- 操作系统 Linux、macOS、Windows，配置不低于 4c8g。
- 微调实例需要 GPU（目前仅支持 NVIDIA）

### 安装步骤

> **提示：**
>
> - HTTPS 访问配置暂时不支持，可自行调整容器内 Nginx 配置。
> - 如果`SERVER_DOMAIN`和`SERVER_PORT`进行了修改，建议删除持久化数据目录后重新创建。
> - 云服务器 `SERVER_DOMAIN = <external public ip>`
>
> **注意：**
>
> - 请确保你本地的IP地址段和docker默认的地址段（172.17.0.0）不重叠，如果重叠，请尝试更换本地网络连接（例如更换以太网网络）。

#### 安装前说明

- 如果有需要调整对外暴露的端口号，还需要修改相关变量。所有调整的端口号都要以变量的形式重新传入到容器中。

    例如：调整 `SERVER_PORT`为`8080`。

    ```shell
    export SERVER_PORT=8080
    docker run -it -d \
    		...
        -p ${SERVER_PORT}:80 \
    		...
        -e SERVER_PORT=${SERVER_PORT} \
        opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
    ```

| 端口号 | 作用                                      | 调整方式                                   |
| :----: | :---------------------------------------- | :----------------------------------------- |
|   80   | Nginx 服务端口，提供 csghub 访问          | SERVER_PORT=`[port]`                       |
|  2222  | Git SSH 服务端口，提供 git clone over SSH | GITLAB_SHELL_SSH_PORT=`[port]`             |
|  5000  | Registry 服务端口，容器镜像仓库           | REGISTRY_ADDRESS=`${SERVER_DOMAIN}:[port]` |
|  8000  | Casdoor 服务端口，用户鉴权服务            | CASDOOR_PORT=`[port]`                      |
|  9000  | Minio 服务端口，对象存储服务              | S3_ENDPOINT=`${SERVER_DOMAIN}:[port]`      |

#### 快速安装（无法使用 Space、模型推理微调功能）

- **Linux**

    > ***提示：***
    >
    > - 请自行替换`<your ip address>`为主机 IPv4 地址。
    >
    > - IPv4 地址查看方式，终端命令行输入:
    >
    >     `ip -4 -o addr show $(ip route show default | awk '/default/ {print $5}')`

    - 快速启动（不做数据持久化）

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

    - 正常启动（持久化数据）

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

    > **提示：**
    >
    > - Docker Desktop 部署请开启 Rosetta，方式如下：
    >
    >     `Settings` > `General` > `Use Rosetta for x86_64/amd64 emulation on Apple Silicon`
    >
    > - 请自行替换`<your ip address>`为主机 IPv4 地址。
    >
    > - IPv4 地址查看方式，终端命令行输入:
    >
    >     `ipconfig getifaddr $(route get default | grep interface | awk '{print $2}')`
    >
    > ***注意：**Rosetta运行速度稍慢。v1.2.0 以前版本以 Rosetta 方式运行的容器会提示 `WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested `忽略即可。*

    - 手动拉取镜像

        ```shell
        docker pull opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:latest
        ```

    - 快速启动（不做数据持久化）

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

    - 正常启动（持久化数据）

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

    >***提示：***
    >
    >- 请自行替换`<your ip address>`为主机 IPv4 地址。
    >
    >- IPv4 地址查看方式：
    >
    >    组合键 `Win + R`, 输出 `cmd`, 待窗口打开后输入 `ipconfig`获取 IPv4 地址。

    - **PowerShell**

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
    
        请参考 Linux 部署方式。

#### 通用安装（可以使用 Space、模型推理微调功能（需要 NVIDIA GPU））

- **Linux**

    >**前置条件：**
    >
    >- 需要一个部署好 Knative Serving 的 Kubernetes 集群。
    >- 其他注意事项见快捷安装部分。

    - 快速配置 k8s 环境

        ```shell
        curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/scripts/k3s-install.sh | bash -s
        
        # 如果启用 NVIDIA GPU 配置
        curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/scripts/k3s-install.sh | ENABLE_NVIDIA_GPU=true bash -s
        ```

    - 配置 Docker

        ```shell
        # 添加 insecure registry
        cat <<EOF > /etc/docker/daemon.json
        {
          "insecure-registries": ["<your ip address>:5000"]
        }
        EOF
        
        # 重启 docker
        systemctl restart docker
        ```

    - 安装 CSGHub

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

    请自行配置 Kubernetes 集群，且保证 `~/.kube/config` 文件存在。然后使用类似如下命令进行安装：

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

    以下命令仅供参考，请根据实际进行配置。
    
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
    
        请参考 Linux 部署方式。

### 访问 CSGHub

当以上部署成功后使用如下方式进行访问：

访问地址：`http://<SERVER_DOMAIN>:<SERVER_PORT>`，例如 http://192.168.1.12

默认管理员：`root`

默认密码：`Root@1234`

### 命令行工具

Omnibus-csghub 提供了简易的命令行工具用来管理服务和查看服务日志。

- 服务管理

    ```shell
    # 查看所有服务状态
    csghub-ctl status 
    
    # 查看所有作业状态
    # EXITED 是正常状态
    csghub-ctl jobs
    
    # 重启某个服务
    csghub-ctl restart nginx
    ```

- 日志管理

    ```shell
    # 实时查看所有服务日志
    csghub-ctl tail 
    
    # 实时查看某个服务日志
    csghub-ctl tail nginx
    ```

- 其他参数

    所有其他命令选项继承自`supervisorctl`。

### 变量说明

***提示：**仅列举可配置参数。127.0.0.1 为本地服务，通过指定如下变量使用第三方服务，但这并不会禁用内部服务。*

### Server

| 变量名        | 默认值             | 说明                       |
| :------------ | :----------------- | :------------------------- |
| SERVER_DOMAIN | csghub.example.com | 指定是访问 IP 地址或域名。 |
| SERVER_PORT   | 80                 | 指定访问的端口。           |

#### PostgreSQL

| 变量名                                          | 默认值          | 说明                                        |
| :---------------------------------------------- | :-------------- | :------------------------------------------ |
| POSTGRES_HOST                                   | 127.0.0.1       | 指定数据库访问地址。                        |
| POSTGRES_PORT                                   | 5432            | 执行数据库端口。                            |
| POSTGRES_SERVER_USER / POSTGRES_SERVER_PASS     | csghub_server   | 指定 csghub_server 服务数据库用户、密码。   |
| POSTGRES_PORTAL_USER / POSTGRES_PORTAL_PASS     | csghub_portal   | 指定 csghub_portal 服务数据库用户、密码。   |
| POSTGRES_CASDOOR_USER / POSTGRES_CASDOOR_PASS   | csghub_casdoor  | 指定 csghub_casdoor 服务数据库用户、密码。  |
| POSTGRES_TEMPORAL_USER / POSTGRES_TEMPORAL_PASS | csghub_temporal | 指定 csghub_temporal 服务数据库用户、密码。 |

#### Redis 

| 变量名         | 默认值         | 说明                  |
| :------------- | :------------- | :-------------------- |
| REDIS_ENDPOINT | 127.0.0.1:6379 | 指定 Redis 服务地址。 |

#### ObjectStorage

| 变量名             | 默认值          | 说明                                    |
| :----------------- | :-------------- | :-------------------------------------- |
| S3_ENDPOINT        | 127.0.0.1:9000  | 指定对象存储。                          |
| S3_ACCESS_KEY      | minio           | 指定对象存储访问凭据。                  |
| S3_ACCESS_SECRET   | Minio@2025!     | 指定对象存储访问凭据。                  |
| S3_REGION          | cn-north-1      | 指定对象存储地域。                      |
| S3_ENABLE_SSL      | false           | 指定对象存储是否启用 SSL 加密。         |
| S3_REGISTRY_BUCKET | csghub-registry | 指定分配给 Registry 使用的存储桶。      |
| S3_PORTAL_BUCKET   | csghub-portal   | 指定分配给 csghub-portal 使用的存储桶。 |
| S3_SERVER_BUCKET   | csghub-server   | 指定分配给 csghub-server 使用的存储桶。 |

#### Gitlab-Shell

| 变量名                | 默认值 | 说明                  |
| :-------------------- | :----- | :-------------------- |
| GITLAB_SHELL_SSH_PORT | 2222   | 指定 Git SSH 端口号。 |

#### Registry

| 变量名             | 默认值              | 说明                             |
| :----------------- | :------------------ | :------------------------------- |
| REGISTRY_ADDRESS   | $SERVER_DOMAIN:5000 | 指定 Registry 服务地址。         |
| REGISTRY_NAMESPACE | csghub              | 指定 Registry 使用的命名空间。   |
| REGISTRY_USERNAME  | registry            | 指定 Registry 服务连接用户名。   |
| REGISTRY_PASSWORD  | Registry@2025!      | 指定 Registry 服务连接用户密码。 |

#### Space

***提示：**以下配置如果配置 `KNATIVE_SERVING_ENABLE = true` 会自动获取。*

| 变量名           | 默认值                  | 说明                                        |
| :--------------- | :---------------------- | :------------------------------------------ |
| SPACE_APP_NS     | spaces                  | 指定 Space 默认使用的 Kubernetes 命名空间。 |
| SPACE_APP_DOMAIN | app.internal            | 指定 Knative Serving 使用的内部域名。       |
| SPACE_APP_HOST   | 127.0.0.1               | 指定 Knative Serving 网络组件网关。         |
| SPACE_APP_PORT   | 80                      | 指定 Knative Serving 网络组件端口。         |
| SPACE_DATA_PATH  | /var/opt/csghub-builder | 指定 Space 构建数据存储目录。               |

#### Casdoor

| 变量名       | 默认值 | 说明                |
| :----------- | :----- | :------------------ |
| CASDOOR_PORT | 8000   | 指定 CASDOOR 端口。 |

#### Temporal

| 变量名        | 默认值         | 说明                                |
| :------------ | :------------- | :---------------------------------- |
| TEMPORAL_USER | temporal       | 指定验证 Temporal  登录的用户名。   |
| TEMPORAL_PASS | Temporal@2025! | 指定验证 Temporal  登录的用户密码。 |

#### Kubernetes

| 变量名                 | 默认值   | 说明                                                         |
| :--------------------- | :------- | :----------------------------------------------------------- |
| KNATIVE_SERVING_ENABLE | false    | 指定是否自动安装 Knative Serving。                           |
| KNATIVE_KOURIER_TYPE   | NodePort | 指定 knative Serving Kourier 网络组件服务暴露方式。          |
| NVIDIA_DEVICE_PLUGIN   | false    | 指定是否自动安装 nvidia device plugin（GPU 节点 containerd 默认 runtime 需要自行配置）。 |
| CSGHUB_WITH_K8S        | 1        | 是否对接 Kubernetes 集群。                                   |

### 功能探索

CSGHub 提供了几个关键功能：

**模型托管：**

- 目前支持模型的托管，轻松上传和管理模型。
- 支持创建推理和微调实例（需要 NVIDIA GPU）。
- 默认以启用多源同步，启动后多源同步会自动开始同步（同步需要一段时间完成）。

**数据集托管：**

- 用于处理数据集的简化工具 ，非常适合快速测试和验证。

**应用托管：**

- 通过自定义程序和模型组合，快速创建大模型应用。

### 销毁容器

如果您不再使用或者需要重建容器，可以执行如下操作：

```shell
docker rm -f omnibus-csghub
```

如果还需要卸载 k3s 环境，可以执行如下操作：

```shell
/usr/local/bin/k3s-uninstall.sh
```



