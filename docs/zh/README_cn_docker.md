# CSGHub Omnibus 快速部署文档

> 提示：
>
> - 此种方式目前处于测试阶段，暂不适用于生产环境部署。
> - 目前仅支持 AMD64 架构（支持 Docker Desktop Rosetta）。

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

> 提示：
>
> - HTTPS 访问配置暂时不支持，可自行调整容器内 Nginx 配置。
> - 如果`SERVER_DOMAIN`和`SERVER_PORT`进行了修改，建议删除持久化数据目录后重新创建。
> - 云服务器 `SERVER_DOMAIN = <external public ip>`

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
        export SERVER_PORT=80
        docker run -it -d \
            --name omnibus-csghub \
            --hostname omnibus-csghub \
            -p ${SERVER_PORT}:80 \
            -p 2222:2222 \
            -p 8000:8000 \
            -p 9000:9000 \
            -e SERVER_DOMAIN=<your ip address> \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
        ```

    - 正常启动（持久化数据）

        ```shell
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
            -e SERVER_DOMAIN=<your ip address> \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
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
    > ***注意：**Rosetta运行速度较慢。以 Rosetta 方式运行的容器会提示 `WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested `忽略即可。*

    - 手动拉取镜像

        ```shell
        docker pull --platform=linux/amd64 opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
        ```

    - 快速启动（不做数据持久化）

        ```shell
        export SERVER_PORT=80
        docker run -it -d \
            --name omnibus-csghub \
            --hostname omnibus-csghub \
            -p ${SERVER_PORT}:80 \
            -p 2222:2222 \
            -p 8000:8000 \
            -p 9000:9000 \
            -e SERVER_DOMAIN=<your ip address> \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
        ```

    - 正常启动（持久化数据）

        ```shell
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
            -e SERVER_DOMAIN=<your ip address> \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
        ```

- **Windows**

    >***提示：***
    >
    >- 请自行替换`<your ip address>`为主机 IPv4 地址。
    >
    >- IPv4 地址查看方式：
    >
    >    组合键 `Win + R`, 输出 `cmd`, 待窗口打开后输入 `ipconfig`获取 IPv4 地址。

    - **Powershell**

        ```shell
        $env:SERVER_PORT = "80"
        docker run -it -d `
            --name omnibus-csghub `
            --hostname omnibus-csghub `
            -p ${env:SERVER_PORT}:80 `
            -p 2222:2222 `
            -p 8000:8000 `
            -p 9000:9000 `
            -e SERVER_DOMAIN="<your ip address>" `
            -e SERVER_PORT=$env:SERVER_PORT `
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
        ```

    - **CMD**

        ```shell
        set SERVER_PORT=80
        docker run -it -d ^
            --name omnibus-csghub ^
            --hostname omnibus-csghub ^
            -p %SERVER_PORT%:80 ^
            -p 2222:2222 ^
            -p 8000:8000 ^
            -p 9000:9000 ^
            -e SERVER_DOMAIN=<your ip address> ^
            -e SERVER_PORT=%SERVER_PORT% ^
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
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
            -e SERVER_DOMAIN=<your ip address> \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
        ```

- **macOS/Windows**

    请自行配置 Kubernetes 集群，且保证 `~/.kube/config` 文件存在。然后使用类似如下命令进行安装：

    - **macOS**

        ```shell
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
            -e SERVER_DOMAIN=<your ip address> \
            -e SERVER_PORT=${SERVER_PORT} \
            opencsg-registry.cn-beijing.cr.aliyuncs.com/opencsg_public/omnibus-csghub:v1.0.0
        ```

    - **Windows**

        暂未支持。

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

如果还需要卸载 k8s 环境，可以执行如下操作：

```shell
/usr/local/bin/k3s-uninstall.sh
```



