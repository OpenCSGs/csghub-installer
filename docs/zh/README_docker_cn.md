# CSGHub Docker 快速部署文档

> **提示：**
>
> - 此种方式适用于快速测试，不适用于生产环境。
> - 支持 AMD64/ARM64 。

## 概述

Omnibus CSGHub 是 OpenCSG 推出的使用 Docker 快速部署 CSGHub 的一种方式，主要用于快速功能体验和测试。Docker 部署方式允许用户以较低成本在本地计算机部署 CSGHub。此种部署方法非常适合概念验证和测试，使用户能够立即访问 CSGHub 的核心功能（包括模型，数据集管理、Space 应用创建以及模型的推理和微调）。

## 优势

- **快速配置：** 支持一键部署，快速启动。
- **统一管理：** 支持集成模型、数据集、Space 应用管理、多源同步等功能。
- **操作简单：** 支持模型推理、微调实例快速启动。

## 快速部署

### 先决条件

- 用于部署的主机已安装 [Docker Desktop](https://docs.docker.com/desktop/) 或 [Docker Engine](https://docs.docker.com/engine/)
- 操作系统 Linux、macOS、Windows，配置不低于 4c8g
- 推理、微调以及模型评测等功能需要 GPU 资源

### 快速安装

目前此种部署方式仅支持`macOS`及`Linux`。

```shell
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/quick_install.sh | bash -s -- -h csghub.example.com -p 80
```

如果需要对接 [K8S 集群](#快速配置 K3S 测试环境)（支持模型推理、微调、评测以及 Space 等功能）：

```shell
curl -sfL https://raw.githubusercontent.com/OpenCSGs/csghub-installer/refs/heads/main/docker/quick_install.sh | bash -s -- -h csghub.example.com -p 80 -k -c ~/.kube
```

**注意：**

- 以上方式仅支持`macOS、Linux、Windows(WSL)`其他配置请自行查看命令帮助`-H, --help`。

    其他方式请参考[Windows 其他部署方式](#Windows 其他部署方式)。

- 暂不支持 HTTPS 访问配置，如有需求请自行调整端口映射以及 nginx 配置文件模板。

- `-h host`或`SERVER_DOMAIN` 可使用`域名`或 `IPv4 地址`。
    - **域名：**使用域名请自行配置域名解析
    - **IPv4：**请勿使用`172.17.0.0/16`（此地址段为 Docker 默认地址段，会导致访问异常）

- 以上方式不适用于使用外部数据库服务，如有需要请参考[变量说明](#变量说明)自行配置。

### 访问 CSGHub

当以上部署成功后使用如下方式进行访问：

访问地址：`http://<host>:<port>`，例如 http://192.168.1.12

访问凭据：`root/Root@1234`

## 更多说明

### 快速配置 K3S 测试环境

- 快速配置 k3s 环境

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

    - `<your ip address>` 默认为`csghub.example.com`，可通过`-h`选项进行指定。
    - `5000` 为默认 Registry 访问端口，可通过`-r`选项进行指定。

### Windows 其他部署方式

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

    请参考[快速部署](#快速部署)。

### 命令行工具

omnibus-csghub 提供了简易的命令行工具用来管理服务和查看服务日志。

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

    所有其他命令选项均继承自`supervisorctl`。

### 删除服务

如果您不再使用或者需要重建容器，执行如下操作：

```shell
docker rm -f omnibus-csghub
```

如果需要卸载 K3S 环境，执行如下操作：

```shell
/usr/local/bin/k3s-uninstall.sh
```

### 变量说明

***提示：**仅列举可配置参数。`127.0.0.1` 为本地服务，通过指定如下变量使用第三方服务，但这并不会禁用内部服务。*

#### Server

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
| CSGHUB_WITH_K8S        | 0        | 是否对接 Kubernetes 集群。                                   |

更多变量请参考[csghub_config_load.sh](https://github.com/OpenCSGs/csghub-installer/blob/main/docker/etc/profile.d/csghub_config_load.sh)。
